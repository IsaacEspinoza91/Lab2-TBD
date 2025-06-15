
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

2 **Cargar datos georeferenciales (Chile)**  
   Descarga el archivo desde Google Drive:  
   https://drive.google.com/file/d/1wmatr37a0w9cX5W6xFGHiVvmoNy7RLsE/view?usp=sharing
   (nombre: `Laboratorio_2_Geom_TDB_GRUPO1`)  
   
3.1 **OPCION 1 por comandos**
   Luego ejecuta:
   ```bash
   psql -U <tu_usuario> -d delivery_medicamentos -f Laboratorio_2_Geom_TDB_GRUPO1.sql
   ```

3.2 **OPCION 2 por pgAdmin4**
   Cargar dentro de la base de datos delivery_medicamentos, el archivo Laboratorio_2_Geom_TDB_GRUPO1 y ejecutarlo

   Nota: tarda al rededor 2 a 5 minutos cargar todo


## ⚙️ Requisitos de Puertos

- **8080** – Backend  
- **5173** – Frontend  

Ambos deben estar libres antes de iniciar las aplicaciones.

---
