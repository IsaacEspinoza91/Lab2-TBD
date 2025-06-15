
# Lab 2 – Taller de Base de Datos

📌 Aplicación Web diseñada para gestionar el delivery de medicamentos a domicilio. Permite administrar pedidos, clientes, farmacias, productos y repartidores, ofreciendo consultas analíticas y automatización de procesos.

---

## 👨‍💻 Integrantes – Grupo 1 (Ejecución)

- [@EmirSilva](https://github.com/EmirSilva) – Emir Silva  
- [@Bastian444](https://github.com/Bastian444) – Bastián Olea  
- [@IsaacEspinoza91](https://github.com/IsaacEspinoza91) – Isaac Espinoza  
- [@OmarSaez](https://github.com/OmarSaez) – Omar Sáez  
- [@willer0](https://github.com/willer0) – Williams Jiménez  

---

## 🛠️ Tecnologías Utilizadas

- **Backend:** Java 17 + Spring Boot 3.4.5  
- **Frontend:** Vue.js con Vite + Node.js 22.14.0  
- **Base de Datos:** PostgreSQL 17 + PostGIS  
- **ORM:** SQL2O 1.9.1  
- **Autenticación:** JSON Web Token (JWT) 0.11.5  

---

## 🚀 Cómo Ejecutar el Proyecto

1. **Clonar repositorio**  
   ```bash
   git clone https://github.com/IsaacEspinoza91/Lab2-TBD.git
   cd Lab2-TBD
   ```

2. **Configurar y ejecutar el Backend**  
   - Abrir la carpeta "Backend DeliveryMediamentos" desde un IDE y ejecutar 
   > ⚠️ El backend arranca en el puerto **8080** por defecto.

3. **Ejecutar el Frontend**  
   ```bash
   cd 'Front DeliveryMedicamentos/delivery'
   npm install
   npm run dev
   ```  
   Abre en tu navegador: [http://localhost:5173](http://localhost:5173)


## 🗄️ Configurar la Base de Datos

Antes de arrancar el backend y frontend, crea y estructura la base de datos siguiendo estos pasos:

1. **Crear la base de datos**  
   Conéctate a PostgreSQL y ejecuta:
   ```sql
   CREATE DATABASE delivery_medicamentos;
   \c delivery_medicamentos
   CREATE EXTENSION postgis;
   ```

2. **Cargar datos georeferenciales (Chile)**  
   Descarga el archivo desde Google Drive:  
   https://drive.google.com/file/d/1HiM09HpVrqF_bcZF4D3BC1_SyRPVzC9t/view?usp=sharing  
   (nombre: `osm_2po_4pgr.sql`)  
   Luego ejecuta:
   ```bash
   psql -U <tu_usuario> -d delivery_medicamentos -f osm_2po_4pgr.sql
   ```

3. **Crear la estructura de tablas**  
   Ejecuta el script de definición de tablas:
   ```bash
   psql -U <tu_usuario> -d delivery_medicamentos -f Tablas_labs2.sql
   ```

4. **Poblar datos iniciales**  
   Carga el script de datos de prueba:
   ```bash
   psql -U <tu_usuario> -d delivery_medicamentos -f Poblado.sql
   ```

---

## ⚙️ Requisitos de Puertos

- **8080** – Backend  
- **5173** – Frontend  

Ambos deben estar libres antes de iniciar las aplicaciones.

---
