-- Habilitar extensión PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Crear tabla Usuarios (base común)
CREATE TABLE Usuarios (
    ID SERIAL PRIMARY KEY,
    RUT VARCHAR(20) UNIQUE,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    Tipo VARCHAR(20) NOT NULL CHECK (Tipo IN ('CLIENTE', 'REPARTIDOR', 'ADMIN')),
    geom geometry(Point, 4326) -- NUEVO: ubicación geoespacial del repartidor
);

-- Crear tabla Clientes (hereda de Usuarios)
CREATE TABLE Clientes (
    Usuario_ID INT PRIMARY KEY REFERENCES Usuarios(ID) ON DELETE CASCADE,
    Direccion VARCHAR(100) NOT NULL
);

-- Crear tabla Repartidores (hereda de Usuarios con nuevos atributos)
CREATE TABLE Repartidores (
    Usuario_ID INT PRIMARY KEY REFERENCES Usuarios(ID) ON DELETE CASCADE,
    Tipo_vehiculo VARCHAR(20) NOT NULL CHECK (Tipo_vehiculo IN ('AUTO', 'MOTO', 'BICICLETA', 'CAMIONETA'))
);

-- Crear tabla Administradores
CREATE TABLE Administradores (
    Usuario_ID INT PRIMARY KEY REFERENCES Usuarios(ID) ON DELETE CASCADE,
    Nivel_acceso INT DEFAULT 1,
    Departamento VARCHAR(50)
);

-- Crear tabla Medios_de_pago
CREATE TABLE Medios_de_pago (
    ID SERIAL PRIMARY KEY,
    Tipo VARCHAR(50)
);

-- Crear tabla Farmacias
CREATE TABLE Farmacias (
    ID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100),
    Lugar VARCHAR(100),
    geom geometry(Point, 4326) -- NUEVO: ubicación geoespacial de la farmacia
);

-- Crear tabla De puntos de entrega de farmacias
CREATE TABLE Punto_de_entrega (
    ID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100),
    Farmacia_ID INT REFERENCES Farmacias(ID),
    geom geometry(Point, 4326) -- NUEVO: ubicación geoespacial del punto de entrega
);

-- Crear tabla Pedidos
CREATE TABLE Pedidos (
    ID SERIAL PRIMARY KEY,
    Fecha DATE,
    Urgencia BOOLEAN,
    Total_pagado INT,
    Estado_entrega VARCHAR(50),
    Fecha_entrega DATE,
    Cliente_ID INT REFERENCES Usuarios(ID),
    Medio_pago_ID INT REFERENCES Medios_de_pago(ID),
    Farmacia_ID INT REFERENCES Farmacias(ID),
    Repartidor_ID INT REFERENCES Usuarios(ID),
    ruta_estimada geometry(LineString, 4326) -- NUEVO: ruta estimada del pedido
);

-- Crear tabla Productos
CREATE TABLE Productos (
    ID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100),
    Precio INT,
    Stock INT,
    Requiere_receta BOOLEAN
);

-- Crear tabla Detalle_de_pedidos
CREATE TABLE Detalle_de_pedidos (
    ID SERIAL PRIMARY KEY,
    Pedido_ID INT REFERENCES Pedidos(ID),
    Producto_ID INT REFERENCES Productos(ID),
    Cantidad INT
);

-- Crear tabla Calificaciones
CREATE TABLE Calificaciones (
    ID SERIAL PRIMARY KEY,
    Puntuacion VARCHAR(50),
    Estrellas INT,
    Cliente_ID INT REFERENCES Usuarios(ID),
    Repartidor_ID INT REFERENCES Usuarios(ID)
);

-- Crear tabla Pedidos_Repartidores
CREATE TABLE Pedidos_Repartidores (
    Pedido_ID INT REFERENCES Pedidos(ID),
    Repartidor_ID INT REFERENCES Usuarios(ID),
    PRIMARY KEY (Pedido_ID, Repartidor_ID)
);

-- Crear tabla Farmacias_Productos
CREATE TABLE Farmacias_Productos (
    Farmacia_ID INT REFERENCES Farmacias(ID),
    Producto_ID INT REFERENCES Productos(ID),
    PRIMARY KEY (Farmacia_ID, Producto_ID)
);

-- Crear tabla Notificaciones
CREATE TABLE Notificaciones (
    id SERIAL PRIMARY KEY,
    mensaje TEXT,
    pedido_id INT,
    fecha DATE
);

-- NUEVO: Tabla Zonas de Cobertura
CREATE TABLE Zonas_cobertura (
    ID SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    geom geometry(Polygon, 4326) -- Polígono que representa la zona de cobertura
);


-- PROCEDIMIENTOS ALMACENADOS
-- 7. Registrar un pedido completo. [Omar]
CREATE OR REPLACE PROCEDURE registrar_pedido(
  p_fecha DATE,
  p_urgencia BOOLEAN,
  p_total INT,
  p_estado TEXT,
  p_fecha_entrega DATE,
  p_medio_pago_id INT,
  p_farmacia_id INT,
  p_repartidor_id INT,
  p_cliente_id INT,
  p_detalles JSON
)
LANGUAGE plpgsql
AS $$
DECLARE
  item JSON;
  pedido_id INT;
BEGIN
  INSERT INTO "pedidos" (
    "fecha", "urgencia", "total_pagado", "estado_entrega", "fecha_entrega", "cliente_id",
    "medio_pago_id", "farmacia_id", "repartidor_id"
  )
  VALUES (
    p_fecha, p_urgencia, p_total, p_estado, p_fecha_entrega,
    p_medio_pago_id, p_farmacia_id, p_repartidor_id, p_cliente_id
  )
  RETURNING "id" INTO pedido_id;

  FOR item IN SELECT * FROM json_array_elements(p_detalles)
  LOOP
    INSERT INTO "detalle_de_pedidos" ("id", "pedido_id", "producto_id", "cantidad")
    VALUES (
      (SELECT COALESCE(MAX("id"), 0) + 1 FROM "detalle_de_pedidos"),
      pedido_id,
      (item->>'producto_id')::INT,
      (item->>'cantidad')::INT
    );
  END LOOP;
END;
$$;


-- 8. Cambiar el estado de un pedido con validación. [Isaac]
CREATE OR REPLACE PROCEDURE cambiar_estado_pedido(
    id_pedido INT,
    nuevo_estado VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si pedido existe
    IF NOT EXISTS (SELECT 1 FROM pedidos WHERE id = id_pedido) THEN
        RAISE EXCEPTION 'Error: Pedido no existe';
    END IF;
    
    -- Validar el nuevo estado
    IF nuevo_estado NOT IN ('Entregado', 'Fallido', 'Pendiente') THEN
        RAISE EXCEPTION 'Error: Estado invalido';
    END IF;
    
    -- Actualizar el estado del pedido
    UPDATE pedidos 
    SET estado_entrega = nuevo_estado
    WHERE id = id_pedido;
END;
$$;
-- Ejemplo llamada, muestra tabla con resultadod de ejecuion
-- CALL cambiar_estado_pedido(2,'Fallido');


-- 9. Descontar stock al confirmar pedido. [Williams]
CREATE OR REPLACE PROCEDURE public.descontar_stock_confirmado(IN p_pedido_id integer)
    LANGUAGE 'plpgsql'
    
AS $BODY$
DECLARE
  v_producto_id INT;
  v_cantidad INT;
  v_stock_actual INT;
BEGIN
  -- Actualizamos el estado del pedido a 'Entregado'
  UPDATE pedidos
  SET estado_entrega = 'Entregado'
  WHERE id = p_pedido_id;

  -- Recorremos cada producto en el detalle del pedido
  FOR v_producto_id, v_cantidad IN
    SELECT producto_id, cantidad
    FROM detalle_de_pedidos
    WHERE pedido_id = p_pedido_id
  LOOP
    -- Obtener el stock actual del producto
    SELECT stock INTO v_stock_actual
    FROM productos
    WHERE id = v_producto_id;

    -- Verificar si el stock es suficiente
    IF v_stock_actual < v_cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente para el producto %', v_producto_id;
    END IF;

    -- Descontar el stock
    UPDATE productos
    SET stock = stock - v_cantidad
    WHERE id = v_producto_id;
  END LOOP;
  
END;
$BODY$;

-- TRIGGERS
-- 10. Insertar automáticamente la fecha de entrega al marcar como entregado.

-- Función que utiliza el trigger
CREATE OR REPLACE FUNCTION actualizar_fecha_entrega()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica si el estado cambia a 'entregado'
    IF NEW.estado_entrega = 'entregado' THEN
        NEW.fecha_entrega := NOW();  -- Asigna la fecha actual
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trigger_actualizar_fecha_entrega
BEFORE UPDATE ON pedidos
FOR EACH ROW
WHEN (OLD.estado_entrega IS DISTINCT FROM NEW.estado_entrega)
EXECUTE FUNCTION actualizar_fecha_entrega();


-- 11. Registrar una notificación si un medicamento con receta es pedido sin validación. [Emir]
CREATE OR REPLACE FUNCTION registrar_notificacion_medicamento_sin_validacion()
RETURNS trigger AS
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Productos p
        JOIN Pedidos pe ON pe.id = NEW.pedido_id
        WHERE p.id = NEW.producto_id
        AND p.requiere_receta = TRUE
        AND pe.estado_entrega != 'Entregado'
    ) THEN
        INSERT INTO Notificaciones (mensaje, pedido_id, fecha)
        VALUES ('El medicamento con receta fue pedido sin validación.', NEW.pedido_id, CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_registrar_notificacion_medicamento_sin_validacion
AFTER INSERT ON Detalle_de_pedidos
FOR EACH ROW
EXECUTE FUNCTION registrar_notificacion_medicamento_sin_validacion();


-- 12. Insertar una calificación automática si no se recibe en 48 horas. [Williams]

-- Función para que el trigger utilice

CREATE OR REPLACE FUNCTION revisar_pedidos_tardados()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si el pedido está pendiente y lleva más de 48 horas
    IF NEW.estado_entrega = 'Pendiente' AND NEW.fecha_entrega < NOW() - INTERVAL '48 hours' THEN
        -- Marcar como 'Tardado'
        UPDATE pedidos
        SET estado_entrega = 'Tardado'
        WHERE id = NEW.id;

        -- Insertar calificación automática
        INSERT INTO calificaciones (puntuacion, estrellas, cliente_id, repartidor_id)
        VALUES ('Fallo por demora en evaluación', 1, NEW.cliente_id, NEW.repartidor_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger

CREATE TRIGGER trigger_revisar_pedidos_tardados
AFTER INSERT OR UPDATE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION revisar_pedidos_tardados();

-- VISTAS
-- 13. Resumen de pedidos por cliente (monto total, número de pedidos).
CREATE OR REPLACE VIEW resumen_pedidos_por_cliente AS
SELECT
    u.id AS cliente_id,
    u.nombre,
    u.apellido,
    u.email,
    COUNT(p.id) AS cantidad_pedidos,
    COALESCE(SUM(p.total_pagado), 0) AS monto_total
FROM
    usuarios u
LEFT JOIN pedidos p ON u.id = p.cliente_id
WHERE
    u.tipo = 'CLIENTE'
GROUP BY
    u.id, u.nombre, u.apellido, u.email;

-- 15. Vista de farmacias con mayor volumen de productos entregados.[Isaac]
CREATE OR REPLACE VIEW farmacias_volumen_entregas_exitosas AS
SELECT 
    f.id, 
	f.Nombre AS farmacia, 
	f.Lugar,
    COALESCE(SUM(dp.cantidad), 0) AS total_productos_pedidos, -- pedidos de todos los estados
    COALESCE(SUM(dp.cantidad) FILTER (WHERE p.estado_entrega = 'Entregado'), 0) AS total_productos_entregados
FROM farmacias AS f LEFT JOIN pedidos AS p
	ON f.id = p.farmacia_id
	LEFT JOIN detalle_de_pedidos AS dp
	ON p.id = dp.pedido_id
GROUP BY f.id, f.nombre, f.lugar
ORDER BY total_productos_entregados DESC;

-- 14. Vista de desempeño por repartidor.

CREATE VIEW vista_desempeno_repartidor AS
SELECT 
    u.nombre AS nombre,
    u.apellido AS apellido,
    r.tipo_vehiculo AS vehiculo,
    COUNT(p.id) AS total_pedidos,
    AVG(c.estrellas) AS promedio_estrellas,
    COALESCE(fve.total_productos_entregados, 0) AS total_productos_entregados,
    COALESCE(fve.total_productos_pedidos, 0) AS total_productos_pedidos,
    CASE 
        WHEN fve.total_productos_pedidos > 0 
        THEN ROUND((fve.total_productos_entregados::decimal / fve.total_productos_pedidos) * 100, 2)
        ELSE 0 
    END AS porcentaje_entregas_exitosas
FROM repartidores r
JOIN usuarios u ON r.usuario_id = u.id
LEFT JOIN pedidos p ON p.repartidor_id = r.usuario_id
LEFT JOIN calificaciones c ON c.repartidor_id = r.usuario_id
LEFT JOIN farmacias_volumen_entregas_exitosas fve ON fve.farmacia = (
    SELECT f.nombre 
    FROM farmacias f 
    JOIN pedidos p2 ON p2.farmacia_id = f.id 
    WHERE p2.repartidor_id = r.usuario_id 
    LIMIT 1
)
GROUP BY u.nombre, u.apellido, r.tipo_vehiculo, fve.total_productos_entregados, fve.total_productos_pedidos;