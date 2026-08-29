# 📖 GUÍA DE PRUEBAS Y USO DE LA API
## «El Camino del Guardabarranco»

Esta guía contiene todos los pasos, cuentas de prueba, flujos pedagógicos y cuerpos JSON listos para **copiar y pegar** para probar el 100% de los endpoints de la API en **Swagger UI** o **Postman**.

---

## 📑 ÍNDICE
1. [Cómo Iniciar la API en Visual Studio 2022](#1-cómo-iniciar-la-api-en-visual-studio-2022)
2. [Cuentas de Prueba Pre-cargadas](#2-cuentas-de-prueba-pre-cargadas)
3. [Paso a Paso: Autenticación y Token JWT](#3-paso-a-paso-autenticación-y-token-jwt)
4. [Flujo Pedagógico y Gamificación (Estudiante)](#4-flujo-pedagógico-y-gamificación-estudiante)
5. [Flujo de Gestión Escolar (Docente)](#5-flujo-de-gestión-escolar-docente)
6. [Flujo de Monitoreo Familiar (Padre / Tutor)](#6-flujo-de-monitoreo-familiar-padre--tutor)
7. [Flujo de Tienda, Avatares y Personalización](#7-flujo-de-tienda-avatares-y-personalización)
8. [Flujo de Sincronización Offline (SQLite <-> SQL Server)](#8-flujo-de-sincronización-offline-sqlite---sql-server)
9. [Catálogos del Sistema](#9-catálogos-del-sistema)

---

## 1. Cómo Iniciar la API en Visual Studio 2022

1. Abre la solución `ElCaminoGuardabarranco.sln` ubicada en `C:\Users\Navi\APP MOVIL CONCURSO\ElCaminoGuardabarranco`.
2. Asegúrate de que el proyecto de inicio sea **`ElCaminoGuardabarranco.API`**.
3. Presiona el botón verde de **Iniciar** (o la tecla `F5` / `Ctrl + F5`).
4. Tu navegador abrirá automáticamente la dirección:
   - **HTTPS:** `https://localhost:7059/swagger`
   - *(O en HTTP alternativo: `http://localhost:5128/swagger`)*

---

## 2. Cuentas de Prueba Pre-cargadas

Todas las cuentas de prueba comparten la misma contraseña: **`Seguridad123!`**

| Rol | Alias (Usuario) | Contraseña | IdUsuario | Descripción |
| :--- | :--- | :--- | :---: | :--- |
| **Estudiante** | `josue_guardabarranco` | `Seguridad123!` | **5** | Alumno de 4to Grado con nivel 3, 480 puntos, 95 monedas y racha de 5 días. |
| **Estudiante** | `maria_masaya` | `Seguridad123!` | **6** | Alumna de 4to Grado con 320 puntos y 60 monedas. |
| **Estudiante** | `pedro_granada` | `Seguridad123!` | **7** | Alumno de 5to Grado con 510 puntos y 110 monedas. |
| **Estudiante** | `ana_leon` | `Seguridad123!` | **8** | Alumna de 6to Grado con 150 puntos y 25 monedas. |
| **Docente** | `profesor_carlos` | `Seguridad123!` | **2** | Docente del Colegio Público República de Cuba, administra 2 aulas. |
| **Padre/Tutor** | `padre_roberto` | `Seguridad123!` | **3** | Tutor de los estudiantes Josué y María. |
| **Padre/Tutor** | `madre_elena` | `Seguridad123!` | **4** | Tutora del estudiante Pedro. |

---

## 3. Paso a Paso: Autenticación y Token JWT

La mayoría de los endpoints del sistema requieren autorización mediante **JWT**.

### Paso 3.1: Iniciar Sesión (`POST /api/Auth/login`)
1. En Swagger, expande la sección **Auth** y haz clic en **`POST /api/Auth/login`**.
2. Presiona **Try it out**.
3. Pega el siguiente JSON en el cuadro de texto:
```json
{
  "alias": "josue_guardabarranco",
  "contrasena": "Seguridad123!"
}
```
4. Presiona **Execute**.
5. Recibirás una respuesta exitosa (`200 OK`) con el siguiente formato:
```json
{
  "success": true,
  "message": "Inicio de sesión exitoso.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "idUsuario": 5,
    "alias": "josue_guardabarranco",
    "rol": "Estudiante",
    "fechaExpiracion": "2026-09-05T..."
  }
}
```

### Paso 3.2: Activar la Autorización en Swagger
1. Copia el valor de `"token"` recibido (sin comillas).
2. Ve a la parte superior derecha de la página de Swagger y haz clic en el botón verde **`Authorize 🔓`**.
3. En el campo **Value**, escribe la palabra `Bearer` seguida de un espacio y tu token:
   ```text
   Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
4. Haz clic en **Authorize** y luego en **Close**.
5. ¡Listo! El candado ahora aparecerá cerrado 🔒 y podrás ejecutar todos los endpoints protegidos.

---

### Paso 3.3: Registrar Nuevos Usuarios (`POST /api/Auth/register`)

Si deseas crear nuevos usuarios desde cero:

#### A) Registrar un nuevo Estudiante (4to a 6to Grado):
```json
{
  "alias": "sofia_esteli",
  "contrasena": "Seguridad123!",
  "nombreRol": "Estudiante",
  "idGradoEscolar": 1,
  "fechaNacimiento": "2016-04-10T00:00:00.000Z",
  "institucion": null,
  "telefono": null
}
```
*(Valores para `idGradoEscolar`: `1` = 4to Grado, `2` = 5to Grado, `3` = 6to Grado)*.

#### B) Registrar un nuevo Docente:
```json
{
  "alias": "profesora_martha",
  "contrasena": "Seguridad123!",
  "nombreRol": "Docente",
  "idGradoEscolar": null,
  "fechaNacimiento": null,
  "institucion": "Escuela Enmanuel Mongalo, Rivas",
  "telefono": "+505 8999-1122"
}
```

#### C) Registrar un nuevo Padre / Tutor:
```json
{
  "alias": "padre_carlos_padilla",
  "contrasena": "Seguridad123!",
  "nombreRol": "PadreTutor",
  "idGradoEscolar": null,
  "fechaNacimiento": null,
  "institucion": null,
  "telefono": "+505 8444-5566"
}
```

---

## 4. Flujo Pedagógico y Gamificación (Estudiante)

Prueba el recorrido completo de un estudiante a través del mapa de Nicaragua y los retos escolares:

### 1. Consultar el Perfil Integral (`GET /api/Perfil/{idUsuario}`)
- **Endpoint:** `GET /api/Perfil/5`
- **Qué devuelve:** Datos del estudiante, avatar equipado, nivel alcanzado, puntos, monedas, racha de días, e insignias ganadas.

### 2. Explorar el Mapa de Nicaragua (`GET /api/Mapa/departamentos/{idEstudiante}`)
- **Endpoint:** `GET /api/Mapa/departamentos/5`
- **Qué devuelve:** Los 17 departamentos de Nicaragua con sus coordenadas GPS, indicando si están `Desbloqueado`, `Bloqueado` o `Completado`.

### 3. Ver Municipios de un Departamento (`GET /api/Mapa/municipios/{idDepartamento}/estudiante/{idEstudiante}`)
- **Endpoint:** `GET /api/Mapa/municipios/1/estudiante/5` *(1 = Managua)*
- **Qué devuelve:** Municipios de Managua (Managua Capital, Tipitapa, Ciudad Sandino, Mateare) con el total de retos disponibles y superados.

### 4. Consultar Contenido Cultural del Municipio (`GET /api/Cultura/municipio/{idMunicipio}`)
- **Endpoint:** `GET /api/Cultura/municipio/1`
- **Qué devuelve:** Leyendas (La Mocuana), sitios históricos (Plaza de la Revolución) y tradiciones con su multimedia asociada.

### 5. Ver Retos Pedagógicos de un Municipio (`GET /api/Retos/municipio/{idMunicipio}/estudiante/{idEstudiante}`)
- **Endpoint:** `GET /api/Retos/municipio/1/estudiante/5`
- **Qué devuelve:** Lista de retos disponibles en Managua (Matemática con Frutas Nicas, Poemas de Rubén Darío, etc.) y si el alumno ya los completó.

### 6. Obtener Preguntas y Opciones de un Reto (`GET /api/Retos/{idReto}/preguntas`)
- **Endpoint:** `GET /api/Retos/1/preguntas` *(Reto 1: Fracciones en el Mercado Oriental)*
- **Qué devuelve:** Enunciados de las preguntas con sus 4 opciones de respuesta (sin revelar la respuesta correcta para evitar trampas).

### 7. Responder una Pregunta y Registrar Intento (`POST /api/Progreso/intento`)
- **Endpoint:** `POST /api/Progreso/intento`
- **JSON para responder correctamente (Opción 33 = 5 pitahayas):**
```json
{
  "idUsuario": 5,
  "idReto": 1,
  "idPregunta": 1,
  "idOpcionSeleccionada": 33,
  "tiempoRespuestaSegundos": 5,
  "idDispositivoOrigen": "Android-Tablet-Escuela"
}
```
- **Qué devuelve:** `esCorrecta: true`, la retroalimentación explicativa y los puntos/monedas acreditados.

### 8. Evaluar Insignias Automáticas (`POST /api/Gamificacion/insignias/evaluar/{idEstudiante}`)
- **Endpoint:** `POST /api/Gamificacion/insignias/evaluar/5`
- **Qué hace:** Analiza si el estudiante cumplió criterios para desbloquear nuevas insignias (primer reto, racha de días, guardián departamental).

### 9. Tabla de Clasificación / Leaderboard (`GET /api/Gamificacion/ranking/{idEstudiante}`)
- **Endpoint:** `GET /api/Gamificacion/ranking/5?top=10`
- **Qué devuelve:** Ranking nacional con las posiciones, avatares, niveles y puntos de los estudiantes más destacados.

---

## 5. Flujo de Gestión Escolar (Docente)

Con la cuenta del Profesor Carlos (`IdUsuario = 2`):

### 1. Listar Grupos Escolares del Docente (`GET /api/Docente/{idDocente}/grupos`)
- **Endpoint:** `GET /api/Docente/2/grupos`
- **Qué devuelve:** Las aulas creadas por el docente (4to Grado A, 5to Grado B) y su código de acceso.

### 2. Crear un Nuevo Grupo Escolar (`POST /api/Docente/grupos`)
- **Endpoint:** `POST /api/Docente/grupos`
```json
{
  "idDocente": 2,
  "nombre": "6to Grado C - Los Sacuanjoches",
  "idGradoEscolar": 3,
  "codigoAcceso": "6TOC-SAC"
}
```

### 3. Inscribir un Alumno al Grupo (`POST /api/Docente/grupos/estudiantes`)
- **Endpoint:** `POST /api/Docente/grupos/estudiantes`
```json
{
  "idGrupo": 1,
  "aliasEstudiante": "ana_leon"
}
```

### 4. Ver Reporte Pedagógico de Alumnos (`GET /api/Docente/grupos/{idGrupo}/progreso`)
- **Endpoint:** `GET /api/Docente/grupos/1/progreso`
- **Qué devuelve:** Lista de alumnos del aula con sus puntos, nivel, retos completados y última fecha de actividad.

---

## 6. Flujo de Monitoreo Familiar (Padre / Tutor)

Con la cuenta de Don Roberto (`IdUsuario = 3`):

### 1. Consultar Progreso de los Hijos Vinculados (`GET /api/Padre/{idPadre}/hijos`)
- **Endpoint:** `GET /api/Padre/3/hijos`
- **Qué devuelve:** El resumen académico y de gamificación de sus hijos (Josué y María), sus rachas de estudio y logros alcanzados.

### 2. Vincular un Nuevo Hijo mediante su Alias (`POST /api/Padre/vincular`)
- **Endpoint:** `POST /api/Padre/vincular`
```json
{
  "idPadre": 3,
  "aliasEstudiante": "sofia_esteli"
}
```

### 3. Desvincular un Hijo (`DELETE /api/Padre/{idPadre}/hijos/{idEstudiante}`)
- **Endpoint:** `DELETE /api/Padre/3/hijos/6`

---

## 7. Flujo de Tienda, Avatares y Personalización

### 1. Ver Catálogo de Avatares (`GET /api/Avatares/{idUsuario}`)
- **Endpoint:** `GET /api/Avatares/5`
- **Qué devuelve:** Los avatares disponibles (Guardabarranco Clásico, Güegüense, Xoloitzcuintle, Princesa de Tiscapa, Cacique Diriangén), su costo y cuál tiene equipado.

### 2. Comprar un Avatar con Monedas Virtuales (`POST /api/Avatares/comprar`)
- **Endpoint:** `POST /api/Avatares/comprar`
```json
{
  "idUsuario": 5,
  "idAvatar": 2
}
```

### 3. Equipar un Avatar Adquirido (`POST /api/Avatares/equipar`)
- **Endpoint:** `POST /api/Avatares/equipar`
```json
{
  "idUsuario": 5,
  "idAvatar": 2
}
```

### 4. Ver Artículos de la Tienda (`GET /api/Tienda/{idUsuario}`)
- **Endpoint:** `GET /api/Tienda/5`
- **Qué devuelve:** Sombreros de pita, cintas patrias, fondos interactivos (Volcán Masaya) y pociones de pistas.

### 5. Comprar un Artículo de la Tienda (`POST /api/Tienda/comprar`)
- **Endpoint:** `POST /api/Tienda/comprar`
```json
{
  "idUsuario": 5,
  "idItem": 2
}
```

---

## 8. Flujo de Sincronización Offline (SQLite <-> SQL Server)

Diseñado para que la aplicación móvil en Flutter funcione en zonas rurales de Nicaragua sin internet:

### 1. Sincronización PULL (Descargar Catálogos y Contenidos a SQLite)
- **Endpoint:** `GET /api/Sync/pull` *(o con filtro de última fecha: `GET /api/Sync/pull?ultimaSincronizacion=2026-08-01T00:00:00`)*
- **Qué devuelve:** El lote completo de departamentos, municipios, contenidos culturales, retos, preguntas y opciones de respuesta actualizadas para guardarse en la base de datos local SQLite del celular/tablet.

### 2. Sincronización PUSH (Subir Intentos Registrados Offline a SQL Server)
- **Endpoint:** `POST /api/Sync/push`
- **JSON de ejemplo para subir lote de intentos resueltos sin internet:**
```json
{
  "idUsuario": 5,
  "idDispositivo": "Tablet-Escuela-Rural-01",
  "intentos": [
    {
      "idReto": 1,
      "idPregunta": 1,
      "idOpcionSeleccionada": 33,
      "esCorrecta": true,
      "tiempoRespuestaSegundos": 4,
      "fechaIntento": "2026-08-28T14:30:00Z"
    },
    {
      "idReto": 1,
      "idPregunta": 2,
      "idOpcionSeleccionada": 37,
      "esCorrecta": true,
      "tiempoRespuestaSegundos": 6,
      "fechaIntento": "2026-08-28T14:32:00Z"
    }
  ]
}
```
- **Qué hace el Backend:** Procesa en una única transacción los intentos, actualiza el progreso en SQL Server, acredita puntos/monedas y devuelve el número de registros sincronizados exitosamente.

---

## 9. Catálogos del Sistema

Endpoints de lectura pública para inicializar la aplicación:

- **Asignaturas:** `GET /api/Catalogos/asignaturas` *(Matemática, Lengua y Literatura, Inglés, Geografía e Historia)*.
- **Grados Escolares:** `GET /api/Catalogos/grados` *(4to Grado, 5to Grado, 6to Grado)*.
- **Roles:** `GET /api/Catalogos/roles` *(Estudiante, Docente, PadreTutor, Administrador)*.

---
*Documento generado para el proyecto de desarrollo Backend de «El Camino del Guardabarranco».*
