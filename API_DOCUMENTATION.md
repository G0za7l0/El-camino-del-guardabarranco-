# ðŸ‡³ðŸ‡® DocumentaciÃ³n Oficial de la API: "El Camino del Guardabarranco"

Backend / API REST desarrollada en **ASP.NET Core Web API (.NET 8)** y **SQL Server**, diseÃ±ada especialmente para integrarse con la aplicaciÃ³n mÃ³vil en **Flutter / Dart** y soporte offline con **SQLite**.

---

## 1. InformaciÃ³n General y ConexiÃ³n con Flutter

- **URL Base Local (HTTP):** `http://localhost:5128`
- **URL Swagger / OpenAPI UI:** `http://localhost:5128/` (o `http://localhost:5128/swagger`)
- **EspecificaciÃ³n OpenAPI (JSON):** `http://localhost:5128/swagger/v1/swagger.json`
- **Formato de ComunicaciÃ³n:** `application/json; charset=utf-8`
- **AutenticaciÃ³n:** JSON Web Tokens (JWT) mediante cabecera `Authorization: Bearer <token>`
- **CORS:** Habilitado para desarrollo en Web y MÃ³vil (`AllowAnyOrigin`, `AllowAnyMethod`, `AllowAnyHeader`).

### Estructura EstÃ¡ndar de Respuesta (`ApiResponse<T>`)
Todas las respuestas de la API siguen una envoltura consistente y predecible:
```json
{
  "success": true,
  "message": "OperaciÃ³n realizada con Ã©xito",
  "data": { ... },
  "errors": null
}
```

En caso de error (`400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `500 Internal Server Error`):
```json
{
  "success": false,
  "message": "DescripciÃ³n clara del error",
  "data": null,
  "errors": [
    "Detalle 1 del error"
  ]
}
```

---

## 2. Mapa de Pantallas de Flutter vs Endpoints de la API

| Pantalla en Flutter | Funcionalidad en la App | Endpoint HTTP | MÃ©todo |
|---|---|---|---|
| **Splash / Inicio** | Descarga de catÃ¡logos para SQLite | `/api/sync/pull?fechaDesde={fecha}` | `GET` |
| **Login** | Iniciar sesiÃ³n del estudiante/docente/padre | `/api/auth/login` | `POST` |
| **Registro** | Crear nueva cuenta | `/api/auth/register` | `POST` |
| **Perfil del Estudiante** | Ver nivel, avatar, monedas, puntos, insignias y racha | `/api/perfil/{idUsuario}` | `GET` |
| **Ajustes de Accesibilidad** | Cambiar tamaÃ±o de letra, contraste y lector de voz | `/api/perfil/preferencias` | `PUT` |
| **Mapa de Nicaragua** | Mapa interactivo de los 17 departamentos | `/api/mapa/departamentos/{idUsuario}` | `GET` |
| **Detalle Departamento** | Lista de municipios con avance | `/api/mapa/municipios/{idDepartamento}?idUsuario={id}` | `GET` |
| **RincÃ³n Cultural** | Historias, leyendas, flora, fauna y tradiciones | `/api/cultura/municipio/{idMunicipio}` | `GET` |
| **SelecciÃ³n de Retos** | Lista de desafÃ­os por materia en el municipio | `/api/retos/municipio/{idMunicipio}?idUsuario={id}` | `GET` |
| **Juego / Pregunta** | Cargar preguntas del reto pedagÃ³gico | `/api/retos/{idReto}/preguntas` | `GET` |
| **Juego / ValidaciÃ³n** | Enviar respuesta y recibir monedas/XP | `/api/progreso/intento` | `POST` |
| **Logros / Insignias** | Evaluar y desbloquear insignias | `/api/gamificacion/evaluar-insignias/{idUsuario}` | `POST` |
| **Barra de Nivel / XP** | Consultar rango y progreso hacia el siguiente nivel | `/api/gamificacion/nivel/{idUsuario}` | `GET` |
| **Tabla de Posiciones** | Leaderboard de mejores estudiantes | `/api/gamificacion/ranking` | `GET` |
| **Tienda Virtual** | Comprar accesorios, pistas y fondos | `/api/tienda/items/{idUsuario}` | `GET` / `POST` |
| **Armario de Avatares** | Ver, comprar y equipar avatares | `/api/avatares/{idUsuario}` | `GET` / `POST` |
| **Panel Docente** | Ver aulas y avance de los alumnos | `/api/docente/grupos/{idDocente}` | `GET` / `POST` |
| **Panel Familiar** | Monitoreo del hijo por el padre/tutor | `/api/padre/hijos/{idPadre}` | `GET` / `POST` |
| **Bandeja de Alertas** | Notificaciones del estudiante o docente | `/api/notificaciones/{idUsuario}` | `GET` / `PUT` |
| **Sincronizador Offline** | Subir progreso acumulado en SQLite | `/api/sync/push` | `POST` |

---

## 3. CatÃ¡logo Detallado de Endpoints

### ðŸ” 3.1 MÃ³dulo: AutenticaciÃ³n (`/api/auth`)

#### `POST /api/auth/register`
Registra un nuevo usuario en el sistema.
- **Body JSON:**
```json
{
  "alias": "chavalito_nica",
  "contrasena": "Seguridad123!",
  "nombreRol": "Estudiante",
  "idGradoEscolar": 1,
  "fechaNacimiento": "2016-05-14",
  "institucion": null,
  "telefono": null
}
```
- **Respuesta `201 Created`:**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiration": "2026-08-29T20:00:00Z",
    "idUsuario": 9,
    "alias": "chavalito_nica",
    "idRol": 1,
    "nombreRol": "Estudiante"
  }
}
```

#### `POST /api/auth/login`
Inicia sesiÃ³n y valida las credenciales.
- **Body JSON:**
```json
{
  "alias": "josue_guardabarranco",
  "contrasena": "Seguridad123!"
}
```

---

### ðŸ‘¤ 3.2 MÃ³dulo: Perfil y Accesibilidad (`/api/perfil`)

#### `GET /api/perfil/{idUsuario}`
Devuelve el perfil completo del estudiante con insignias, avatar, nivel y racha diaria.
- **Respuesta `200 OK`:**
```json
{
  "success": true,
  "message": "OperaciÃ³n realizada con Ã©xito",
  "data": {
    "idUsuario": 5,
    "alias": "josue_guardabarranco",
    "nombreRol": "Estudiante",
    "fechaNacimiento": "2016-05-14",
    "gradoEscolar": "4to Grado",
    "puntosAcumulados": 480,
    "monedasVirtuales": 95,
    "rachaActualDias": 5,
    "mejorRachaDias": 8,
    "nivelTitulo": "GuardiÃ¡n de Lagos y Volcanes",
    "nivelNumero": 3,
    "avatarEquipado": "Guardabarranco ClÃ¡sico",
    "avatarUrl": "https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/guardabarranco_explorador.png",
    "altoContraste": false,
    "lecturaVozActiva": false,
    "tamanoFuente": 2,
    "insignias": [
      {
        "idInsignia": 1,
        "nombre": "Semilla Germinada",
        "descripcion": "Completaste tu primer reto. Â¡El camino ha comenzado!",
        "insigniaUrl": "https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/semilla_germinada.png",
        "fechaObtencion": "2026-07-15T00:00:00"
      }
    ]
  }
}
```

#### `PUT /api/perfil/preferencias`
Guarda las preferencias de accesibilidad.
- **Body JSON:**
```json
{
  "idUsuario": 5,
  "altoContraste": true,
  "lecturaVozActiva": false,
  "tamanoFuente": 3
}
```

---

### ðŸ—ºï¸ 3.3 MÃ³dulo: Mapa y Cultura (`/api/mapa` y `/api/cultura`)

#### `GET /api/mapa/departamentos/{idUsuario}`
Lista los 17 departamentos con su estado: `Bloqueado`, `Desbloqueado` o `Completado`.

#### `GET /api/mapa/municipios/{idDepartamento}?idUsuario={id}`
Lista los municipios del departamento seleccionado.

#### `GET /api/cultura/municipio/{idMunicipio}`
Historias, tradiciones, leyendas, fauna y flora nicaragÃ¼ense del municipio.

---

### ðŸŽ® 3.4 MÃ³dulo: Retos y Progreso (`/api/retos` y `/api/progreso`)

#### `GET /api/retos/municipio/{idMunicipio}?idUsuario={id}&idAsignatura={idAsig}`
Obtiene los retos disponibles (MatemÃ¡tica, Lengua, GeografÃ­a, InglÃ©s).

#### `GET /api/retos/{idReto}/preguntas`
Obtiene las preguntas y opciones para la partida (sin exponer `esCorrecta`).

#### `POST /api/progreso/intento`
Registra la respuesta seleccionada por el estudiante.
- **Body JSON:**
```json
{
  "idUsuario": 5,
  "idReto": 1,
  "idPregunta": 1,
  "idOpcionSeleccionada": 33,
  "tiempoRespuestaSegundos": 5,
  "idDispositivoOrigen": "Flutter-Android-Tablet"
}
```
- **Respuesta `200 OK`:**
```json
{
  "success": true,
  "message": "Â¡Excelente! Has completado el reto y ganado monedas/puntos.",
  "data": {
    "esCorrecta": true,
    "retroalimentacion": "Para calcular 1/4 de 20, dividimos 20 entre 4 = 5 pitahayas.",
    "retoCompletado": true,
    "puntosGanados": 50,
    "monedasGanadas": 15,
    "rachaActualDias": 5
  }
}
```

---

### ðŸ† 3.5 MÃ³dulo: GamificaciÃ³n (`/api/gamificacion`)

#### `GET /api/gamificacion/nivel/{idUsuario}`
Progreso de XP y nivel del Guardabarranco:
```json
{
  "success": true,
  "data": {
    "idNivel": 3,
    "nivelNumero": 3,
    "nivelTitulo": "GuardiÃ¡n de Lagos y Volcanes",
    "puntosActuales": 480,
    "puntosNivelBase": 350,
    "nivelSiguienteNumero": 4,
    "nivelSiguienteTitulo": "Centinela del Sacuanjoche",
    "puntosRequeridosSiguiente": 650,
    "puntosParaSubir": 170,
    "porcentajeAvance": 43.33
  }
}
```

#### `GET /api/gamificacion/ranking?top=20`
Tabla de clasificaciÃ³n con los estudiantes mÃ¡s destacados.

---

### ðŸ›ï¸ 3.6 MÃ³dulo: Tienda y Avatares (`/api/tienda` y `/api/avatares`)

- `GET /api/tienda/items/{idUsuario}`
- `POST /api/tienda/comprar` `{"idUsuario": 5, "idItem": 2}`
- `GET /api/avatares/{idUsuario}`
- `POST /api/avatares/comprar` `{"idUsuario": 5, "idAvatar": 2}`
- `POST /api/avatares/equipar` `{"idUsuario": 5, "idAvatar": 2}`

---

### ðŸ‘©â€ðŸ« 3.7 MÃ³dulo: Docentes y Padres (`/api/docente` y `/api/padre`)

- `GET /api/docente/grupos/{idDocente}`
- `POST /api/docente/grupos` `{"idDocente": 2, "nombre": "4to Grado A", "idGradoEscolar": 1, "codigoAcceso": "4TOA-2026"}`
- `POST /api/docente/grupos/estudiantes` `{"idGrupo": 1, "aliasEstudiante": "josue_guardabarranco"}`
- `GET /api/docente/grupos/{idGrupo}/progreso`
- `GET /api/padre/hijos/{idPadre}`
- `POST /api/padre/vincular` `{"idPadre": 3, "aliasEstudiante": "josue_guardabarranco"}`

---

### ðŸ”„ 3.8 MÃ³dulo: SincronizaciÃ³n Offline (`/api/sync`)

#### `GET /api/sync/pull?fechaDesde=2026-08-01T00:00:00`
Descarga todos los catÃ¡logos y contenido modificado en 10 conjuntos de datos JSON para almacenar en la base de datos local SQLite.

#### `POST /api/sync/push`
Sube en lote las respuestas y avances generados por el estudiante cuando no tenÃ­a conexiÃ³n a internet.
- **Body JSON:**
```json
{
  "idUsuario": 5,
  "idDispositivoOrigen": "Flutter-Offline-Cache",
  "intentos": [
    {
      "idReto": 2,
      "idPregunta": 3,
      "idOpcion": 39,
      "fechaIntento": "2026-08-28T14:30:00Z",
      "tiempoRespuestaSegundos": 8
    }
  ]
}
```

---

## 4. GuÃ­a de ConexiÃ³n en Flutter (Dart)

### Ejemplo de Servicio en Dart usando `http`:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GuardabarrancoApiService {
  static const String baseUrl = 'http://10.0.2.2:5128/api'; // 10.0.2.2 para emulador Android

  Future<Map<String, dynamic>> login(String alias, String contrasena) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alias': alias,
        'contrasena': contrasena,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']; // Contiene token, idUsuario, alias, rol
    } else {
      throw Exception(data['message'] ?? 'Error de autenticaciÃ³n');
    }
  }

  Future<Map<String, dynamic>> getPerfil(int idUsuario, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/perfil/$idUsuario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}
```
