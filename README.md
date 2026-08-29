# 🇳🇮 El Camino del Guardabarranco - Backend API

> **API RESTful Educativa y Gamificada para Estudiantes de Educación Primaria de Nicaragua (4to a 6to Grado).**

---

## 🏛️ Arquitectura del Proyecto

```
SQL Server (Base de Datos Relacional)
       ↓
ASP.NET Core Web API (.NET 8 + Dapper / ADO.NET)
       ↓
Flutter / Dart (App Móvil Multiplataforma)
       ↓
SQLite (Sincronización y Funcionamiento Offline)
```

---

## 🚀 Características Principales

- **🎮 Gamificación Integral:**
  - Sistema de Niveles y Rangos del Guardabarranco.
  - Puntos de experiencia y monedas virtuales.
  - Billetera virtual y tienda de artículos/accesorios (sombrero de pita, pociones de pistas, fondos).
  - Desbloqueo y equipamiento de avatares tradicionales (Güegüense, Cacique Diriangén, Xoloitzcuintle).
  - Insignias automáticas por logros y rachas de días de estudio.
  - Tabla de posiciones / Leaderboard nacional.

- **🗺️ Geografía e Identidad Nacional de Nicaragua:**
  - Mapa interactivo de los 17 departamentos con coordenadas GPS.
  - Municipios con progreso y contenidos culturales (leyendas, flora, fauna, tradiciones).
  - Desbloqueo progresivo departamental según rendimiento pedagógico.

- **📚 Retos Pedagógicos (4to a 6to Grado):**
  - Asignaturas: *Matemática, Lengua y Literatura, Inglés, Geografía e Historia*.
  - Preguntas con selección múltiple, retroalimentación didáctica y control de intentos.

- **👨‍🏫 Gestión Docente y Familiar:**
  - Creación de aulas/grupos escolares y asignación de códigos de acceso.
  - Reportes de rendimiento por aula y estudiante.
  - Vinculación de padres/tutores para supervisión del progreso infantil.

- **🔄 Sincronización Offline (SQLite ⇄ SQL Server):**
  - **PULL:** Descarga de catálogos y contenidos modificados para almacenamiento local.
  - **PUSH:** Subida en lote de intentos resueltos sin conexión a internet.

---

## 🛠️ Tecnologías Utilizadas

- **Plataforma:** .NET 8 (C#)
- **Framework:** ASP.NET Core Web API
- **Base de Datos:** Microsoft SQL Server 2022
- **Acceso a Datos:** `Microsoft.Data.SqlClient` (Procedimientos Almacenados optimizados)
- **Seguridad:** JWT Bearer + BCrypt para hashing de contraseñas
- **Documentación de API:** Swagger / OpenAPI con soporte para comentarios XML y autenticación Bearer
- **CORS:** Habilitado para consumo desde Flutter (Web/Android/iOS)

---

## 📂 Estructura del Repositorio

```text
├── Database/
│   ├── ElCaminoDelGuardabarranco.bak       # Backup completo de la Base de Datos con datos semilla
│   ├── Refactor_Schema_SPs.sql            # Script de refactorización y Procedimientos Almacenados
│   ├── SeedData_Pruebas.sql               # Script de datos iniciales en UTF-8 puro
│   └── CreateDatabase_Schema.sql          # Script de creación de tablas
├── ElCaminoGuardabarranco.API/            # Proyecto Web API en .NET 8
│   ├── Controllers/                       # 14 Controladores RESTful documentados
│   ├── Services/                          # Lógica de negocio (Interfaces e Implementaciones)
│   ├── Repositories/                      # Acceso a SQL Server (Interfaces e Implementaciones)
│   ├── DTOs/                              # Data Transfer Objects y ApiResponse genérico
│   ├── Data/                              # Conexión a BD e IDbConnectionFactory
│   ├── Middleware/                        # GlobalExceptionHandlerMiddleware
│   ├── Configuration/                     # Extensiones de DI, JWT y Swagger
│   ├── appsettings.json                   # Cadenas de conexión y configuración JWT
│   └── Program.cs                         # Pipeline de la aplicación ASP.NET Core
├── API_DOCUMENTATION.md                   # Documentación técnica completa para el equipo de Flutter
├── GUIA_DE_PRUEBAS_API.md                 # Guía paso a paso para probar los endpoints en Swagger
└── ElCaminoGuardabarranco.sln             # Solución de Visual Studio 2022
```

---

## ⚙️ Configuración y Ejecución Local

### 1. Restaurar la Base de Datos en SQL Server
Puedes restaurar el archivo `.bak` incluido en la carpeta `Database/` o ejecutar los scripts `.sql`:
- Archivo: `Database/ElCaminoDelGuardabarranco.bak`
- O ejecutar: `Database/Refactor_Schema_SPs.sql` y luego `Database/SeedData_Pruebas.sql`.

### 2. Configurar la Cadena de Conexión
En `ElCaminoGuardabarranco.API/appsettings.json`, confirma la cadena de conexión:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=ElCaminoDelGuardabarranco;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

### 3. Ejecutar la API
Abre `ElCaminoGuardabarranco.sln` en **Visual Studio 2022** y presiona **F5**, o ejecuta por terminal:
```bash
dotnet run --project ElCaminoGuardabarranco.API
```

Swagger UI estará disponible en:
- **HTTPS:** `https://localhost:7059/swagger`
- **HTTP:** `http://localhost:5128/swagger`

---

## 🔑 Credenciales de Prueba Pre-cargadas

Todos los usuarios tienen la contraseña: **`Seguridad123!`**

- **Estudiante:** `josue_guardabarranco` (4to Grado, Nivel 3, 480 pts, 95 monedas)
- **Estudiante:** `maria_masaya` (4to Grado, 320 pts, 60 monedas)
- **Docente:** `profesor_carlos` (Colegio República de Cuba)
- **Padre/Tutor:** `padre_roberto` (Tutor de Josué y María)
