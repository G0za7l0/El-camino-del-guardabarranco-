/*
================================================================================
    Base de datos  : ElCaminoDelGuardabarranco
    Versión        : 2.0 — Esquema completo
    Motor mínimo   : SQL Server 2016 SP1+ (OPENJSON, CREATE OR ALTER)
    Fecha           : 2026-08-25

    Convenciones de nomenclatura
    ────────────────────────────
      PK_  = Primary Key          FK_  = Foreign Key
      UQ_  = Unique Constraint    DF_  = Default Constraint
      CK_  = Check Constraint     IX_  = Nonclustered Index
      Todas las PKs usan IDENTITY(1,1).
      Tablas en singular.  Columnas en PascalCase.
      DATETIME2 en todas las fechas.  VARCHAR para hashes ASCII.

    Módulos (secciones del script)
    ──────────────────────────────
       0  Creación de la base de datos
       1  Catálogos base
       2  Usuarios y roles
       3  Geografía
       4  Retos y preguntas
       5  Contenido cultural
       6  Economía y personalización
       7  Progreso académico
       8  Accesibilidad
       9  Notificaciones
      10  Sincronización offline
      11  Índices no clusterizados
      12  Datos semilla
      13  Seguridad — Rol de API
      14  Procedimientos almacenados
================================================================================
*/

-- =====================================================
-- SECCIÓN 0 · Creación de la base de datos
-- =====================================================

CREATE DATABASE ElCaminoDelGuardabarranco;
GO

USE ElCaminoDelGuardabarranco;
GO

-- =====================================================
-- SECCIÓN 1 · Catálogos base
-- Tablas de referencia sin dependencias externas.
-- =====================================================

CREATE TABLE Rol (
    IdRol  INT IDENTITY(1,1) CONSTRAINT PK_Rol PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL CONSTRAINT UQ_Rol_Nombre UNIQUE
);

CREATE TABLE GradoEscolar (
    IdGradoEscolar INT IDENTITY(1,1) CONSTRAINT PK_GradoEscolar PRIMARY KEY,
    Nombre         NVARCHAR(50) NOT NULL
);

CREATE TABLE Multimedia (
    IdMultimedia     INT IDENTITY(1,1) CONSTRAINT PK_Multimedia PRIMARY KEY,
    TipoArchivo      NVARCHAR(20)  NOT NULL,   -- imagen | audio | video
    Url              NVARCHAR(500) NOT NULL,
    TextoAlternativo NVARCHAR(255) NULL
);

CREATE TABLE TipoReto (
    IdTipoReto INT IDENTITY(1,1) CONSTRAINT PK_TipoReto PRIMARY KEY,
    Nombre     NVARCHAR(100) NOT NULL CONSTRAINT UQ_TipoReto_Nombre UNIQUE
);

CREATE TABLE Dificultad (
    IdDificultad        INT IDENTITY(1,1) CONSTRAINT PK_Dificultad PRIMARY KEY,
    Nombre              NVARCHAR(50) NOT NULL CONSTRAINT UQ_Dificultad_Nombre UNIQUE,
    MultiplicadorPuntos DECIMAL(3,2) NOT NULL
        CONSTRAINT DF_Dificultad_MultiplicadorPuntos DEFAULT 1.00,
    CONSTRAINT CK_Dificultad_MultiplicadorPuntos CHECK (MultiplicadorPuntos > 0)
);

CREATE TABLE TipoContenidoCultural (
    IdTipoContenidoCultural INT IDENTITY(1,1)
        CONSTRAINT PK_TipoContenidoCultural PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
        CONSTRAINT UQ_TipoContenidoCultural_Nombre UNIQUE
);

CREATE TABLE Asignatura (
    IdAsignatura INT IDENTITY(1,1) CONSTRAINT PK_Asignatura PRIMARY KEY,
    Nombre       NVARCHAR(100) NOT NULL CONSTRAINT UQ_Asignatura_Nombre UNIQUE,
    Activo       BIT NOT NULL CONSTRAINT DF_Asignatura_Activo DEFAULT 1
);
GO

-- =====================================================
-- SECCIÓN 2 · Usuarios y roles
-- Usuario es la tabla de autenticación pura.
-- Estudiante / Docente / PadreTutor amplían 1:1.
-- =====================================================

CREATE TABLE Usuario (
    IdUsuario      INT IDENTITY(1,1) CONSTRAINT PK_Usuario PRIMARY KEY,
    Alias          NVARCHAR(50)  NOT NULL CONSTRAINT UQ_Usuario_Alias UNIQUE,
    ContrasenaHash VARCHAR(256)  NOT NULL,   -- hash ASCII, no necesita NVARCHAR
    IdRol          INT NOT NULL CONSTRAINT FK_Usuario_Rol
                   FOREIGN KEY REFERENCES Rol(IdRol),
    Activo         BIT NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT 1,
    FechaRegistro  DATETIME2 NOT NULL
        CONSTRAINT DF_Usuario_FechaRegistro DEFAULT SYSDATETIME()
);
/*  NOTA IX_Usuario_Login (esquema base v1):
    El índice original ON (Alias, ContrasenaHash) se elimina.
    UQ_Usuario_Alias ya provee un índice único sobre Alias.
    La comparación del hash se resuelve en la capa API/aplicación,
    no en el WHERE de SQL. Un key-lookup puntual es trivial.       */

CREATE TABLE Estudiante (
    IdUsuario       INT NOT NULL
        CONSTRAINT PK_Estudiante   PRIMARY KEY
        CONSTRAINT FK_Estudiante_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdGradoEscolar  INT NOT NULL
        CONSTRAINT FK_Estudiante_GradoEscolar FOREIGN KEY REFERENCES GradoEscolar(IdGradoEscolar),
    FechaNacimiento DATE NULL
);

CREATE TABLE Docente (
    IdUsuario   INT NOT NULL
        CONSTRAINT PK_Docente  PRIMARY KEY
        CONSTRAINT FK_Docente_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    Institucion NVARCHAR(200) NULL
);

CREATE TABLE PadreTutor (
    IdUsuario INT NOT NULL
        CONSTRAINT PK_PadreTutor  PRIMARY KEY
        CONSTRAINT FK_PadreTutor_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    Telefono  NVARCHAR(20) NULL
);

CREATE TABLE PadreEstudiante (
    IdPadre          INT NOT NULL
        CONSTRAINT FK_PadreEstudiante_PadreTutor FOREIGN KEY REFERENCES PadreTutor(IdUsuario),
    IdEstudiante     INT NOT NULL
        CONSTRAINT FK_PadreEstudiante_Estudiante FOREIGN KEY REFERENCES Estudiante(IdUsuario),
    FechaVinculacion DATETIME2 NOT NULL
        CONSTRAINT DF_PadreEstudiante_FechaVinculacion DEFAULT SYSDATETIME(),
    CONSTRAINT PK_PadreEstudiante PRIMARY KEY (IdPadre, IdEstudiante)
);

CREATE TABLE Grupo (
    IdGrupo        INT IDENTITY(1,1) CONSTRAINT PK_Grupo PRIMARY KEY,
    IdDocente      INT NOT NULL
        CONSTRAINT FK_Grupo_Docente FOREIGN KEY REFERENCES Docente(IdUsuario),
    Nombre         NVARCHAR(100) NOT NULL,
    IdGradoEscolar INT NOT NULL
        CONSTRAINT FK_Grupo_GradoEscolar FOREIGN KEY REFERENCES GradoEscolar(IdGradoEscolar)
);

CREATE TABLE GrupoEstudiante (
    IdGrupo            INT NOT NULL
        CONSTRAINT FK_GrupoEstudiante_Grupo FOREIGN KEY REFERENCES Grupo(IdGrupo),
    IdEstudiante       INT NOT NULL
        CONSTRAINT FK_GrupoEstudiante_Estudiante FOREIGN KEY REFERENCES Estudiante(IdUsuario),
    FechaIncorporacion DATETIME2 NOT NULL
        CONSTRAINT DF_GrupoEstudiante_FechaIncorporacion DEFAULT SYSDATETIME(),
    CONSTRAINT PK_GrupoEstudiante PRIMARY KEY (IdGrupo, IdEstudiante)
);
GO

-- =====================================================
-- SECCIÓN 3 · Geografía
-- =====================================================

CREATE TABLE Departamento (
    IdDepartamento    INT IDENTITY(1,1) CONSTRAINT PK_Departamento PRIMARY KEY,
    Nombre            NVARCHAR(100) NOT NULL,
    OrdenDesbloqueo   INT NOT NULL CONSTRAINT UQ_Departamento_OrdenDesbloqueo UNIQUE,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_Departamento_FechaModificacion DEFAULT SYSDATETIME()
);

CREATE TABLE Municipio (
    IdMunicipio       INT IDENTITY(1,1) CONSTRAINT PK_Municipio PRIMARY KEY,
    IdDepartamento    INT NOT NULL
        CONSTRAINT FK_Municipio_Departamento FOREIGN KEY REFERENCES Departamento(IdDepartamento),
    Nombre            NVARCHAR(100) NOT NULL,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_Municipio_FechaModificacion DEFAULT SYSDATETIME()
);
GO

-- =====================================================
-- SECCIÓN 4 · Retos y preguntas
-- =====================================================

CREATE TABLE Reto (
    IdReto            INT IDENTITY(1,1) CONSTRAINT PK_Reto PRIMARY KEY,
    IdAsignatura      INT NOT NULL
        CONSTRAINT FK_Reto_Asignatura FOREIGN KEY REFERENCES Asignatura(IdAsignatura),
    IdMunicipio       INT NOT NULL
        CONSTRAINT FK_Reto_Municipio  FOREIGN KEY REFERENCES Municipio(IdMunicipio),
    IdTipoReto        INT NOT NULL
        CONSTRAINT FK_Reto_TipoReto   FOREIGN KEY REFERENCES TipoReto(IdTipoReto),
    IdDificultad      INT NOT NULL
        CONSTRAINT FK_Reto_Dificultad FOREIGN KEY REFERENCES Dificultad(IdDificultad),
    Descripcion       NVARCHAR(MAX) NOT NULL,
    PuntosOtorgados   INT NOT NULL CONSTRAINT DF_Reto_PuntosOtorgados  DEFAULT 0,
    MonedasOtorgadas  INT NOT NULL CONSTRAINT DF_Reto_MonedasOtorgadas DEFAULT 0,
    Orden             INT NOT NULL CONSTRAINT DF_Reto_Orden DEFAULT 1,
    Activo            BIT NOT NULL CONSTRAINT DF_Reto_Activo DEFAULT 1,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_Reto_FechaModificacion DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Reto_PuntosOtorgados  CHECK (PuntosOtorgados  >= 0),
    CONSTRAINT CK_Reto_MonedasOtorgadas CHECK (MonedasOtorgadas >= 0),
    CONSTRAINT CK_Reto_Orden            CHECK (Orden >= 1)
);

CREATE TABLE Pregunta (
    IdPregunta        INT IDENTITY(1,1) CONSTRAINT PK_Pregunta PRIMARY KEY,
    IdReto            INT NOT NULL
        CONSTRAINT FK_Pregunta_Reto FOREIGN KEY REFERENCES Reto(IdReto),
    Enunciado         NVARCHAR(MAX) NOT NULL,
    IdMultimedia      INT NULL
        CONSTRAINT FK_Pregunta_Multimedia FOREIGN KEY REFERENCES Multimedia(IdMultimedia),
    Orden             INT NOT NULL CONSTRAINT DF_Pregunta_Orden DEFAULT 1,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_Pregunta_FechaModificacion DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Pregunta_Orden CHECK (Orden >= 1)
);

CREATE TABLE OpcionRespuesta (
    IdOpcion   INT IDENTITY(1,1) CONSTRAINT PK_OpcionRespuesta PRIMARY KEY,
    IdPregunta INT NOT NULL
        CONSTRAINT FK_OpcionRespuesta_Pregunta FOREIGN KEY REFERENCES Pregunta(IdPregunta),
    Texto      NVARCHAR(500) NOT NULL,
    EsCorrecta BIT NOT NULL CONSTRAINT DF_OpcionRespuesta_EsCorrecta DEFAULT 0
);
GO

-- =====================================================
-- SECCIÓN 5 · Contenido cultural
-- =====================================================

CREATE TABLE ContenidoCultural (
    IdContenido             INT IDENTITY(1,1) CONSTRAINT PK_ContenidoCultural PRIMARY KEY,
    IdMunicipio             INT NOT NULL
        CONSTRAINT FK_ContenidoCultural_Municipio
        FOREIGN KEY REFERENCES Municipio(IdMunicipio),
    IdTipoContenidoCultural INT NOT NULL
        CONSTRAINT FK_ContenidoCultural_TipoContenidoCultural
        FOREIGN KEY REFERENCES TipoContenidoCultural(IdTipoContenidoCultural),
    Titulo                  NVARCHAR(200) NOT NULL,
    Descripcion             NVARCHAR(MAX) NOT NULL,
    IdMultimedia            INT NULL
        CONSTRAINT FK_ContenidoCultural_Multimedia
        FOREIGN KEY REFERENCES Multimedia(IdMultimedia),
    FechaModificacion       DATETIME2 NOT NULL
        CONSTRAINT DF_ContenidoCultural_FechaModificacion DEFAULT SYSDATETIME()
);
GO

-- =====================================================
-- SECCIÓN 6 · Economía y personalización
-- =====================================================

CREATE TABLE Billetera (
    IdUsuario           INT NOT NULL
        CONSTRAINT PK_Billetera PRIMARY KEY
        CONSTRAINT FK_Billetera_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    PuntosAcumulados    INT NOT NULL CONSTRAINT DF_Billetera_PuntosAcumulados DEFAULT 0,
    MonedasVirtuales    INT NOT NULL CONSTRAINT DF_Billetera_MonedasVirtuales DEFAULT 0,
    FechaActualizacion  DATETIME2 NOT NULL
        CONSTRAINT DF_Billetera_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen NVARCHAR(100) NULL,
    CONSTRAINT CK_Billetera_PuntosAcumulados CHECK (PuntosAcumulados >= 0),
    CONSTRAINT CK_Billetera_MonedasVirtuales CHECK (MonedasVirtuales >= 0)
);

CREATE TABLE Insignia (
    IdInsignia   INT IDENTITY(1,1) CONSTRAINT PK_Insignia PRIMARY KEY,
    Nombre       NVARCHAR(100) NOT NULL CONSTRAINT UQ_Insignia_Nombre UNIQUE,
    Descripcion  NVARCHAR(255) NOT NULL,
    IdMultimedia INT NULL
        CONSTRAINT FK_Insignia_Multimedia FOREIGN KEY REFERENCES Multimedia(IdMultimedia),
    Activo       BIT NOT NULL CONSTRAINT DF_Insignia_Activo DEFAULT 1
);

CREATE TABLE UsuarioInsignia (
    IdUsuario           INT NOT NULL
        CONSTRAINT FK_UsuarioInsignia_Usuario  FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdInsignia          INT NOT NULL
        CONSTRAINT FK_UsuarioInsignia_Insignia FOREIGN KEY REFERENCES Insignia(IdInsignia),
    FechaObtencion      DATETIME2 NOT NULL
        CONSTRAINT DF_UsuarioInsignia_FechaObtencion DEFAULT SYSDATETIME(),
    FechaActualizacion  DATETIME2 NOT NULL
        CONSTRAINT DF_UsuarioInsignia_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen NVARCHAR(100) NULL,
    CONSTRAINT PK_UsuarioInsignia PRIMARY KEY (IdUsuario, IdInsignia)
);

CREATE TABLE Avatar (
    IdAvatar          INT IDENTITY(1,1) CONSTRAINT PK_Avatar PRIMARY KEY,
    Nombre            NVARCHAR(100) NOT NULL,
    IdMultimedia      INT NULL
        CONSTRAINT FK_Avatar_Multimedia FOREIGN KEY REFERENCES Multimedia(IdMultimedia),
    CostoMonedas      INT NULL,                   -- NULL = avatar gratuito inicial
    Activo            BIT NOT NULL CONSTRAINT DF_Avatar_Activo DEFAULT 1,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_Avatar_FechaModificacion DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Avatar_CostoMonedas CHECK (CostoMonedas IS NULL OR CostoMonedas >= 0)
);

CREATE TABLE UsuarioAvatar (
    IdUsuario     INT NOT NULL
        CONSTRAINT FK_UsuarioAvatar_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdAvatar      INT NOT NULL
        CONSTRAINT FK_UsuarioAvatar_Avatar  FOREIGN KEY REFERENCES Avatar(IdAvatar),
    FechaObtenido DATETIME2 NOT NULL
        CONSTRAINT DF_UsuarioAvatar_FechaObtenido DEFAULT SYSDATETIME(),
    Equipado      BIT NOT NULL CONSTRAINT DF_UsuarioAvatar_Equipado DEFAULT 0,
    CONSTRAINT PK_UsuarioAvatar PRIMARY KEY (IdUsuario, IdAvatar)
);

CREATE TABLE ItemTienda (
    IdItem            INT IDENTITY(1,1) CONSTRAINT PK_ItemTienda PRIMARY KEY,
    Nombre            NVARCHAR(100) NOT NULL,
    Descripcion       NVARCHAR(255) NOT NULL,
    CostoMonedas      INT NOT NULL,
    IdMultimedia      INT NULL
        CONSTRAINT FK_ItemTienda_Multimedia FOREIGN KEY REFERENCES Multimedia(IdMultimedia),
    Activo            BIT NOT NULL CONSTRAINT DF_ItemTienda_Activo DEFAULT 1,
    FechaModificacion DATETIME2 NOT NULL
        CONSTRAINT DF_ItemTienda_FechaModificacion DEFAULT SYSDATETIME(),
    CONSTRAINT CK_ItemTienda_CostoMonedas CHECK (CostoMonedas >= 0)
);

CREATE TABLE CompraUsuario (
    IdCompra            INT IDENTITY(1,1) CONSTRAINT PK_CompraUsuario PRIMARY KEY,
    IdUsuario           INT NOT NULL
        CONSTRAINT FK_CompraUsuario_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdItem              INT NOT NULL
        CONSTRAINT FK_CompraUsuario_ItemTienda FOREIGN KEY REFERENCES ItemTienda(IdItem),
    FechaCompra         DATETIME2 NOT NULL
        CONSTRAINT DF_CompraUsuario_FechaCompra DEFAULT SYSDATETIME(),
    FechaActualizacion  DATETIME2 NOT NULL
        CONSTRAINT DF_CompraUsuario_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen NVARCHAR(100) NULL,
    CONSTRAINT UQ_CompraUsuario_UsuarioItem UNIQUE (IdUsuario, IdItem)
);
GO

-- =====================================================
-- SECCIÓN 7 · Progreso académico
-- =====================================================

CREATE TABLE ProgresoAcademico (
    IdProgreso          INT IDENTITY(1,1) CONSTRAINT PK_ProgresoAcademico PRIMARY KEY,
    IdUsuario           INT NOT NULL
        CONSTRAINT FK_ProgresoAcademico_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdReto              INT NOT NULL
        CONSTRAINT FK_ProgresoAcademico_Reto FOREIGN KEY REFERENCES Reto(IdReto),
    Intentos            INT NOT NULL CONSTRAINT DF_ProgresoAcademico_Intentos DEFAULT 1,
    Completado          BIT NOT NULL CONSTRAINT DF_ProgresoAcademico_Completado DEFAULT 0,
    FechaSuperacion     DATETIME2 NULL,
    FechaActualizacion  DATETIME2 NOT NULL
        CONSTRAINT DF_ProgresoAcademico_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen NVARCHAR(100) NULL,
    CONSTRAINT UQ_ProgresoAcademico_UsuarioReto UNIQUE (IdUsuario, IdReto),
    CONSTRAINT CK_ProgresoAcademico_Intentos    CHECK  (Intentos >= 1)
);

CREATE TABLE HistorialIntento (
    IdIntento               INT IDENTITY(1,1) CONSTRAINT PK_HistorialIntento PRIMARY KEY,
    IdUsuario               INT NOT NULL
        CONSTRAINT FK_HistorialIntento_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    IdReto                  INT NOT NULL
        CONSTRAINT FK_HistorialIntento_Reto    FOREIGN KEY REFERENCES Reto(IdReto),
    IdPregunta              INT NULL
        CONSTRAINT FK_HistorialIntento_Pregunta FOREIGN KEY REFERENCES Pregunta(IdPregunta),
    IdOpcionSeleccionada    INT NULL
        CONSTRAINT FK_HistorialIntento_OpcionRespuesta
        FOREIGN KEY REFERENCES OpcionRespuesta(IdOpcion),
    EsCorrecta              BIT NOT NULL,
    FechaIntento            DATETIME2 NOT NULL
        CONSTRAINT DF_HistorialIntento_FechaIntento DEFAULT SYSDATETIME(),
    TiempoRespuestaSegundos INT NULL,
    FechaActualizacion      DATETIME2 NOT NULL
        CONSTRAINT DF_HistorialIntento_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen     NVARCHAR(100) NULL,
    CONSTRAINT CK_HistorialIntento_TiempoRespuesta
        CHECK (TiempoRespuestaSegundos IS NULL OR TiempoRespuestaSegundos >= 0)
);
GO

-- =====================================================
-- SECCIÓN 8 · Accesibilidad
-- =====================================================

CREATE TABLE PreferenciaUsuario (
    IdUsuario        INT NOT NULL
        CONSTRAINT PK_PreferenciaUsuario PRIMARY KEY
        CONSTRAINT FK_PreferenciaUsuario_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    AltoContraste    BIT     NOT NULL CONSTRAINT DF_PreferenciaUsuario_AltoContraste    DEFAULT 0,
    LecturaVozActiva BIT     NOT NULL CONSTRAINT DF_PreferenciaUsuario_LecturaVozActiva DEFAULT 0,
    TamanoFuente     TINYINT NOT NULL CONSTRAINT DF_PreferenciaUsuario_TamanoFuente     DEFAULT 2,
    CONSTRAINT CK_PreferenciaUsuario_TamanoFuente CHECK (TamanoFuente BETWEEN 1 AND 5)
);
GO

-- =====================================================
-- SECCIÓN 9 · Notificaciones
-- =====================================================

CREATE TABLE Notificacion (
    IdNotificacion      INT IDENTITY(1,1) CONSTRAINT PK_Notificacion PRIMARY KEY,
    IdUsuarioDestino    INT NOT NULL
        CONSTRAINT FK_Notificacion_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    Tipo                NVARCHAR(50)  NOT NULL,
    Mensaje             NVARCHAR(255) NOT NULL,
    Leida               BIT NOT NULL CONSTRAINT DF_Notificacion_Leida DEFAULT 0,
    FechaCreacion       DATETIME2 NOT NULL
        CONSTRAINT DF_Notificacion_FechaCreacion DEFAULT SYSDATETIME(),
    FechaActualizacion  DATETIME2 NOT NULL
        CONSTRAINT DF_Notificacion_FechaActualizacion DEFAULT SYSDATETIME(),
    IdDispositivoOrigen NVARCHAR(100) NULL
);
GO

-- =====================================================
-- SECCIÓN 10 · Sincronización offline
-- =====================================================

CREATE TABLE RegistroSincronizacion (
    IdSincronizacion    INT IDENTITY(1,1) CONSTRAINT PK_RegistroSincronizacion PRIMARY KEY,
    IdUsuario           INT NOT NULL
        CONSTRAINT FK_RegistroSincronizacion_Usuario FOREIGN KEY REFERENCES Usuario(IdUsuario),
    FechaSincronizacion DATETIME2 NOT NULL
        CONSTRAINT DF_RegistroSincronizacion_FechaSincronizacion DEFAULT SYSDATETIME(),
    CantidadRegistros   INT NOT NULL
        CONSTRAINT DF_RegistroSincronizacion_CantidadRegistros DEFAULT 0,
    Estado              NVARCHAR(20) NOT NULL    -- Exitoso | Fallido | Parcial
);
GO

-- =====================================================
-- SECCIÓN 11 · Índices no clusterizados
-- Cada índice documenta el SP o patrón de consulta
-- que justifica su existencia.
-- =====================================================

-- FK: Municipio → Departamento  (sp_Mapa_ObtenerMunicipios filtra por departamento)
CREATE NONCLUSTERED INDEX IX_Municipio_IdDepartamento
    ON Municipio(IdDepartamento);

-- FK: Estudiante → GradoEscolar  (filtros por grado en panel docente)
CREATE NONCLUSTERED INDEX IX_Estudiante_IdGradoEscolar
    ON Estudiante(IdGradoEscolar);

-- FK: Reto → Asignatura  (sp_Reto_ObtenerPorMunicipio filtra opcionalmente por asignatura)
CREATE NONCLUSTERED INDEX IX_Reto_IdAsignatura
    ON Reto(IdAsignatura);

-- FK: Reto → Municipio  (sp_Reto_ObtenerPorMunicipio filtra por municipio)
CREATE NONCLUSTERED INDEX IX_Reto_IdMunicipio
    ON Reto(IdMunicipio);

-- FK: Reto → Dificultad  (JOIN en sp_Progreso_RegistrarIntento para multiplicador)
CREATE NONCLUSTERED INDEX IX_Reto_IdDificultad
    ON Reto(IdDificultad);

-- FK: ProgresoAcademico → Usuario  (todas las consultas de progreso por estudiante)
CREATE NONCLUSTERED INDEX IX_ProgresoAcademico_IdUsuario
    ON ProgresoAcademico(IdUsuario);

-- FK: ProgresoAcademico → Reto  (evaluación de departamento completado)
CREATE NONCLUSTERED INDEX IX_ProgresoAcademico_IdReto
    ON ProgresoAcademico(IdReto);

-- FK: HistorialIntento → Usuario  (conteo de intentos correctos por usuario)
CREATE NONCLUSTERED INDEX IX_HistorialIntento_IdUsuario
    ON HistorialIntento(IdUsuario);

-- FK: HistorialIntento → Reto  (validación de reto completado)
CREATE NONCLUSTERED INDEX IX_HistorialIntento_IdReto
    ON HistorialIntento(IdReto);

-- FK: UsuarioInsignia → Insignia  (JOIN inverso en reportes)
CREATE NONCLUSTERED INDEX IX_UsuarioInsignia_IdInsignia
    ON UsuarioInsignia(IdInsignia);

-- FK: Pregunta → Reto  (sp_Reto_ObtenerPreguntas y validación en RegistrarIntento)
CREATE NONCLUSTERED INDEX IX_Pregunta_IdReto
    ON Pregunta(IdReto);

-- FK: OpcionRespuesta → Pregunta  (subconsulta en sp_Reto_ObtenerPreguntas)
CREATE NONCLUSTERED INDEX IX_OpcionRespuesta_IdPregunta
    ON OpcionRespuesta(IdPregunta);

-- FK: ContenidoCultural → Municipio  (sp_ContenidoCultural_ObtenerPorMunicipio)
CREATE NONCLUSTERED INDEX IX_ContenidoCultural_IdMunicipio
    ON ContenidoCultural(IdMunicipio);

-- FK: Grupo → Docente  (listar grupos del docente)
CREATE NONCLUSTERED INDEX IX_Grupo_IdDocente
    ON Grupo(IdDocente);

-- FK: Notificacion → Usuario destino  (bandeja de notificaciones)
CREATE NONCLUSTERED INDEX IX_Notificacion_IdUsuarioDestino
    ON Notificacion(IdUsuarioDestino);

-- FK: CompraUsuario → Usuario  (historial de compras)
CREATE NONCLUSTERED INDEX IX_CompraUsuario_IdUsuario
    ON CompraUsuario(IdUsuario);

-- Sync incremental: catálogos offline consultados por FechaModificacion
CREATE NONCLUSTERED INDEX IX_Reto_FechaModificacion
    ON Reto(FechaModificacion);
CREATE NONCLUSTERED INDEX IX_Pregunta_FechaModificacion
    ON Pregunta(FechaModificacion);
CREATE NONCLUSTERED INDEX IX_ContenidoCultural_FechaModificacion
    ON ContenidoCultural(FechaModificacion);
CREATE NONCLUSTERED INDEX IX_Avatar_FechaModificacion
    ON Avatar(FechaModificacion);
CREATE NONCLUSTERED INDEX IX_ItemTienda_FechaModificacion
    ON ItemTienda(FechaModificacion);
GO

-- =====================================================
-- SECCIÓN 12 · Datos semilla (catálogos iniciales)
-- =====================================================

INSERT INTO Rol (Nombre) VALUES
    (N'Estudiante'), (N'Docente'), (N'PadreTutor'), (N'Administrador');

INSERT INTO GradoEscolar (Nombre) VALUES
    (N'4to Grado'), (N'5to Grado'), (N'6to Grado');

INSERT INTO Asignatura (Nombre) VALUES
    (N'Matemática'), (N'Lengua y Literatura'), (N'Inglés'), (N'Geografía');

INSERT INTO TipoReto (Nombre) VALUES
    (N'Selección Múltiple'), (N'Verdadero/Falso'), (N'Arrastrar y Soltar'),
    (N'Completar Texto'),    (N'Minijuego');

INSERT INTO Dificultad (Nombre, MultiplicadorPuntos) VALUES
    (N'Fácil',   1.00),
    (N'Medio',   1.50),
    (N'Difícil', 2.00);

INSERT INTO TipoContenidoCultural (Nombre) VALUES
    (N'Historia'), (N'Fauna'), (N'Flora'), (N'Tradición'), (N'Geografía');

-- Ruta del juego: Managua (inicio) → RACCS / Corn Island (final)
INSERT INTO Departamento (Nombre, OrdenDesbloqueo) VALUES
    (N'Managua',         1),
    (N'Masaya',          2),
    (N'Granada',         3),
    (N'Carazo',          4),
    (N'Rivas',           5),
    (N'León',            6),
    (N'Chinandega',      7),
    (N'Estelí',          8),
    (N'Madriz',          9),
    (N'Nueva Segovia',  10),
    (N'Jinotega',       11),
    (N'Matagalpa',      12),
    (N'Boaco',          13),
    (N'Chontales',      14),
    (N'Río San Juan',   15),
    (N'RACCN',          16),
    (N'RACCS',          17);

-- Insignias: primer reto + una por departamento + juego completo
INSERT INTO Insignia (Nombre, Descripcion) VALUES
    (N'Semilla Germinada',            N'Completaste tu primer reto. ¡El camino ha comenzado!'),
    (N'Guardián de Managua',          N'Conquistaste todos los retos de Managua.'),
    (N'Guardián de Masaya',           N'Conquistaste todos los retos de Masaya.'),
    (N'Guardián de Granada',          N'Conquistaste todos los retos de Granada.'),
    (N'Guardián de Carazo',           N'Conquistaste todos los retos de Carazo.'),
    (N'Guardián de Rivas',            N'Conquistaste todos los retos de Rivas.'),
    (N'Guardián de León',             N'Conquistaste todos los retos de León.'),
    (N'Guardián de Chinandega',       N'Conquistaste todos los retos de Chinandega.'),
    (N'Guardián de Estelí',           N'Conquistaste todos los retos de Estelí.'),
    (N'Guardián de Madriz',           N'Conquistaste todos los retos de Madriz.'),
    (N'Guardián de Nueva Segovia',    N'Conquistaste todos los retos de Nueva Segovia.'),
    (N'Guardián de Jinotega',         N'Conquistaste todos los retos de Jinotega.'),
    (N'Guardián de Matagalpa',        N'Conquistaste todos los retos de Matagalpa.'),
    (N'Guardián de Boaco',            N'Conquistaste todos los retos de Boaco.'),
    (N'Guardián de Chontales',        N'Conquistaste todos los retos de Chontales.'),
    (N'Guardián de Río San Juan',     N'Conquistaste todos los retos de Río San Juan.'),
    (N'Guardián de RACCN',            N'Conquistaste todos los retos de la RACCN.'),
    (N'Guardián de RACCS',            N'Conquistaste todos los retos de la RACCS.'),
    (N'Sacuanjoche Dorado',           N'¡Completaste el camino entero del Guardabarranco! Sos leyenda.');
GO

-- =====================================================
-- SECCIÓN 13 · Seguridad — Rol de API
-- La API solo obtiene EXECUTE; nunca acceso directo
-- a tablas. Los GRANT se emiten al final del script,
-- una vez creados todos los SPs.
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_ApiAccess' AND type = 'R')
    CREATE ROLE rol_ApiAccess;
GO

-- =====================================================
-- SECCIÓN 14 · Procedimientos almacenados
-- Prefijo: sp_<Módulo>_<Acción>
-- Todos usan SET NOCOUNT ON + BEGIN TRY/CATCH.
-- Los que escriben en >1 tabla usan transacción explícita.
-- Lectura para la API: FOR JSON PATH.
-- =====================================================

-- ─────────────────────────────────────────────────────
-- 14.1  AUTENTICACIÓN Y PERFIL
-- ─────────────────────────────────────────────────────

-- ▸ sp_Usuario_Registrar
-- Crea Usuario + fila de rol + Billetera (estudiante) + PreferenciaUsuario.
CREATE OR ALTER PROCEDURE sp_Usuario_Registrar
    @Alias           NVARCHAR(50),
    @ContrasenaHash  VARCHAR(256),
    @NombreRol       NVARCHAR(50),       -- 'Estudiante' | 'Docente' | 'PadreTutor'
    @IdGradoEscolar  INT           = NULL,  -- requerido si Estudiante
    @FechaNacimiento DATE          = NULL,  -- opcional, solo Estudiante
    @Institucion     NVARCHAR(200) = NULL,  -- opcional, solo Docente
    @Telefono        NVARCHAR(20)  = NULL,  -- opcional, solo PadreTutor
    @IdUsuario       INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdRol INT;
    SELECT @IdRol = IdRol FROM Rol WHERE Nombre = @NombreRol;

    IF @IdRol IS NULL
    BEGIN
        RAISERROR(N'Rol no válido: %s', 16, 1, @NombreRol);
        RETURN;
    END

    IF @NombreRol = N'Estudiante' AND @IdGradoEscolar IS NULL
    BEGIN
        RAISERROR(N'IdGradoEscolar es requerido para estudiantes.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Usuario (Alias, ContrasenaHash, IdRol)
        VALUES (@Alias, @ContrasenaHash, @IdRol);

        SET @IdUsuario = SCOPE_IDENTITY();

        IF @NombreRol = N'Estudiante'
        BEGIN
            INSERT INTO Estudiante (IdUsuario, IdGradoEscolar, FechaNacimiento)
            VALUES (@IdUsuario, @IdGradoEscolar, @FechaNacimiento);

            INSERT INTO Billetera (IdUsuario)
            VALUES (@IdUsuario);
        END
        ELSE IF @NombreRol = N'Docente'
        BEGIN
            INSERT INTO Docente (IdUsuario, Institucion)
            VALUES (@IdUsuario, @Institucion);
        END
        ELSE IF @NombreRol = N'PadreTutor'
        BEGIN
            INSERT INTO PadreTutor (IdUsuario, Telefono)
            VALUES (@IdUsuario, @Telefono);
        END

        INSERT INTO PreferenciaUsuario (IdUsuario)
        VALUES (@IdUsuario);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ▸ sp_Usuario_Login
-- Retorna hash + datos de perfil por Alias.
-- La API COMPARA el hash; el SP NO lo hace en el WHERE.
CREATE OR ALTER PROCEDURE sp_Usuario_Login
    @Alias NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.IdUsuario,
        u.Alias,
        u.ContrasenaHash,
        u.IdRol,
        r.Nombre  AS NombreRol,
        u.Activo
    FROM Usuario u
    INNER JOIN Rol r ON u.IdRol = r.IdRol
    WHERE u.Alias  = @Alias
      AND u.Activo = 1
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ▸ sp_Estudiante_ObtenerPerfil
-- Perfil completo: estudiante + billetera + avatar equipado + preferencias + insignias.
CREATE OR ALTER PROCEDURE sp_Estudiante_ObtenerPerfil
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.IdUsuario,
        u.Alias,
        r.Nombre          AS NombreRol,
        e.FechaNacimiento,
        g.Nombre          AS GradoEscolar,
        b.PuntosAcumulados,
        b.MonedasVirtuales,
        av.Nombre         AS AvatarEquipado,
        m_av.Url          AS AvatarUrl,
        p.AltoContraste,
        p.LecturaVozActiva,
        p.TamanoFuente,
        (
            SELECT i.Nombre, i.Descripcion, ui.FechaObtencion
            FROM UsuarioInsignia ui
            INNER JOIN Insignia i ON ui.IdInsignia = i.IdInsignia
            WHERE ui.IdUsuario = u.IdUsuario
            FOR JSON PATH
        ) AS Insignias
    FROM Usuario u
    INNER JOIN Rol            r    ON u.IdUsuario  = u.IdUsuario AND u.IdRol = r.IdRol
    INNER JOIN Estudiante     e    ON u.IdUsuario  = e.IdUsuario
    INNER JOIN GradoEscolar   g    ON e.IdGradoEscolar = g.IdGradoEscolar
    LEFT  JOIN Billetera      b    ON u.IdUsuario  = b.IdUsuario
    LEFT  JOIN UsuarioAvatar  ua   ON u.IdUsuario  = ua.IdUsuario AND ua.Equipado = 1
    LEFT  JOIN Avatar         av   ON ua.IdAvatar  = av.IdAvatar
    LEFT  JOIN Multimedia     m_av ON av.IdMultimedia = m_av.IdMultimedia
    LEFT  JOIN PreferenciaUsuario p ON u.IdUsuario = p.IdUsuario
    WHERE u.IdUsuario = @IdUsuario
      AND u.Activo    = 1
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ─────────────────────────────────────────────────────
-- 14.2  MAPA Y CONTENIDO
-- ─────────────────────────────────────────────────────

-- ▸ sp_Mapa_ObtenerDepartamentos
-- Lista departamentos con estado Bloqueado / Desbloqueado / Completado.
CREATE OR ALTER PROCEDURE sp_Mapa_ObtenerDepartamentos
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH RetoPorDepto AS (
        SELECT
            d.IdDepartamento,
            COUNT(r.IdReto)        AS TotalRetos,
            COUNT(pa.IdProgreso)   AS RetosCompletados
        FROM Departamento d
        INNER JOIN Municipio mu ON d.IdDepartamento = mu.IdDepartamento
        LEFT  JOIN Reto r       ON mu.IdMunicipio   = r.IdMunicipio AND r.Activo = 1
        LEFT  JOIN ProgresoAcademico pa
              ON  r.IdReto     = pa.IdReto
              AND pa.IdUsuario = @IdUsuario
              AND pa.Completado = 1
        GROUP BY d.IdDepartamento
    ),
    Estado AS (
        SELECT
            d.IdDepartamento,
            d.Nombre,
            d.OrdenDesbloqueo,
            ISNULL(rpd.TotalRetos, 0)      AS TotalRetos,
            ISNULL(rpd.RetosCompletados, 0) AS RetosCompletados,
            CASE
                WHEN ISNULL(rpd.TotalRetos, 0) > 0
                     AND rpd.RetosCompletados = rpd.TotalRetos
                    THEN N'Completado'
                WHEN d.OrdenDesbloqueo = 1
                    THEN N'Desbloqueado'
                WHEN EXISTS (
                        SELECT 1
                        FROM Departamento d2
                        INNER JOIN RetoPorDepto rpd2 ON d2.IdDepartamento = rpd2.IdDepartamento
                        WHERE d2.OrdenDesbloqueo = d.OrdenDesbloqueo - 1
                          AND rpd2.TotalRetos > 0
                          AND rpd2.RetosCompletados = rpd2.TotalRetos
                     )
                    THEN N'Desbloqueado'
                ELSE N'Bloqueado'
            END AS Estado
        FROM Departamento d
        LEFT JOIN RetoPorDepto rpd ON d.IdDepartamento = rpd.IdDepartamento
    )
    SELECT IdDepartamento, Nombre, OrdenDesbloqueo,
           TotalRetos, RetosCompletados, Estado
    FROM Estado
    ORDER BY OrdenDesbloqueo
    FOR JSON PATH;
END
GO

-- ▸ sp_Mapa_ObtenerMunicipios
-- Municipios de un departamento con estado de progreso.
CREATE OR ALTER PROCEDURE sp_Mapa_ObtenerMunicipios
    @IdUsuario      INT,
    @IdDepartamento INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        mu.IdMunicipio,
        mu.Nombre,
        COUNT(r.IdReto)      AS TotalRetos,
        COUNT(pa.IdProgreso) AS RetosCompletados
    FROM Municipio mu
    LEFT JOIN Reto r ON mu.IdMunicipio = r.IdMunicipio AND r.Activo = 1
    LEFT JOIN ProgresoAcademico pa
          ON  r.IdReto     = pa.IdReto
          AND pa.IdUsuario = @IdUsuario
          AND pa.Completado = 1
    WHERE mu.IdDepartamento = @IdDepartamento
    GROUP BY mu.IdMunicipio, mu.Nombre
    ORDER BY mu.Nombre
    FOR JSON PATH;
END
GO

-- ▸ sp_Reto_ObtenerPorMunicipio
-- Retos disponibles, filtro opcional por asignatura.
CREATE OR ALTER PROCEDURE sp_Reto_ObtenerPorMunicipio
    @IdMunicipio  INT,
    @IdUsuario    INT,
    @IdAsignatura INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.IdReto,
        r.Descripcion,
        a.Nombre     AS Asignatura,
        tr.Nombre    AS TipoReto,
        dif.Nombre   AS Dificultad,
        r.PuntosOtorgados,
        r.MonedasOtorgadas,
        r.Orden,
        ISNULL(pa.Completado, 0) AS Completado,
        pa.Intentos
    FROM Reto r
    INNER JOIN Asignatura  a   ON r.IdAsignatura = a.IdAsignatura
    INNER JOIN TipoReto    tr  ON r.IdTipoReto   = tr.IdTipoReto
    INNER JOIN Dificultad  dif ON r.IdDificultad  = dif.IdDificultad
    LEFT  JOIN ProgresoAcademico pa
          ON  r.IdReto     = pa.IdReto
          AND pa.IdUsuario = @IdUsuario
    WHERE r.IdMunicipio = @IdMunicipio
      AND r.Activo = 1
      AND (@IdAsignatura IS NULL OR r.IdAsignatura = @IdAsignatura)
    ORDER BY r.Orden
    FOR JSON PATH;
END
GO

-- ▸ sp_Reto_ObtenerPreguntas
-- Preguntas + opciones de un reto.  EsCorrecta NO se expone al cliente.
CREATE OR ALTER PROCEDURE sp_Reto_ObtenerPreguntas
    @IdReto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdPregunta,
        p.Enunciado,
        p.Orden,
        m.Url             AS MultimediaUrl,
        m.TipoArchivo     AS MultimediaTipo,
        m.TextoAlternativo,
        (
            SELECT o.IdOpcion, o.Texto
            FROM OpcionRespuesta o
            WHERE o.IdPregunta = p.IdPregunta
            FOR JSON PATH
        ) AS Opciones
    FROM Pregunta p
    LEFT JOIN Multimedia m ON p.IdMultimedia = m.IdMultimedia
    WHERE p.IdReto = @IdReto
    ORDER BY p.Orden
    FOR JSON PATH;
END
GO

-- ▸ sp_ContenidoCultural_ObtenerPorMunicipio
CREATE OR ALTER PROCEDURE sp_ContenidoCultural_ObtenerPorMunicipio
    @IdMunicipio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        cc.IdContenido,
        cc.Titulo,
        cc.Descripcion,
        tcc.Nombre     AS TipoContenido,
        m.Url          AS MultimediaUrl,
        m.TipoArchivo  AS MultimediaTipo,
        m.TextoAlternativo
    FROM ContenidoCultural cc
    INNER JOIN TipoContenidoCultural tcc ON cc.IdTipoContenidoCultural = tcc.IdTipoContenidoCultural
    LEFT  JOIN Multimedia m              ON cc.IdMultimedia = m.IdMultimedia
    WHERE cc.IdMunicipio = @IdMunicipio
    ORDER BY tcc.Nombre, cc.Titulo
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- 14.3  JUEGO Y PROGRESO
-- ─────────────────────────────────────────────────────

-- ▸ sp_Progreso_RegistrarIntento
-- Registra respuesta, valida, actualiza ProgresoAcademico,
-- acredita Billetera al completar el reto por primera vez.
CREATE OR ALTER PROCEDURE sp_Progreso_RegistrarIntento
    @IdUsuario               INT,
    @IdReto                  INT,
    @IdPregunta              INT,
    @IdOpcionSeleccionada    INT,
    @TiempoRespuestaSegundos INT           = NULL,
    @FechaActualizacion      DATETIME2     = NULL,
    @IdDispositivoOrigen     NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EsCorrecta         BIT;
    DECLARE @YaCompletado       BIT = 0;
    DECLARE @RetoCompletadoAhora BIT = 0;
    DECLARE @PuntosGanados      INT = 0;
    DECLARE @MonedasGanadas     INT = 0;

    -- Validar que la pregunta pertenezca al reto
    IF NOT EXISTS (SELECT 1 FROM Pregunta WHERE IdPregunta = @IdPregunta AND IdReto = @IdReto)
    BEGIN
        RAISERROR(N'La pregunta no pertenece al reto especificado.', 16, 1);
        RETURN;
    END

    -- Validar opción y obtener EsCorrecta
    SELECT @EsCorrecta = EsCorrecta
    FROM OpcionRespuesta
    WHERE IdOpcion = @IdOpcionSeleccionada
      AND IdPregunta = @IdPregunta;

    IF @EsCorrecta IS NULL
    BEGIN
        RAISERROR(N'Opción no válida para la pregunta especificada.', 16, 1);
        RETURN;
    END

    SET @FechaActualizacion = ISNULL(@FechaActualizacion, SYSDATETIME());

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar detalle del intento
        INSERT INTO HistorialIntento (
            IdUsuario, IdReto, IdPregunta, IdOpcionSeleccionada,
            EsCorrecta, FechaIntento, TiempoRespuestaSegundos,
            FechaActualizacion, IdDispositivoOrigen)
        VALUES (
            @IdUsuario, @IdReto, @IdPregunta, @IdOpcionSeleccionada,
            @EsCorrecta, @FechaActualizacion, @TiempoRespuestaSegundos,
            @FechaActualizacion, @IdDispositivoOrigen);

        -- 2. Upsert ProgresoAcademico
        IF EXISTS (SELECT 1 FROM ProgresoAcademico
                   WHERE IdUsuario = @IdUsuario AND IdReto = @IdReto)
        BEGIN
            SELECT @YaCompletado = Completado
            FROM ProgresoAcademico
            WHERE IdUsuario = @IdUsuario AND IdReto = @IdReto;

            UPDATE ProgresoAcademico
            SET Intentos            = Intentos + 1,
                FechaActualizacion  = @FechaActualizacion,
                IdDispositivoOrigen = @IdDispositivoOrigen
            WHERE IdUsuario = @IdUsuario AND IdReto = @IdReto;
        END
        ELSE
        BEGIN
            INSERT INTO ProgresoAcademico (
                IdUsuario, IdReto, Intentos, Completado,
                FechaActualizacion, IdDispositivoOrigen)
            VALUES (
                @IdUsuario, @IdReto, 1, 0,
                @FechaActualizacion, @IdDispositivoOrigen);
        END

        -- 3. Verificar si el reto se completó ahora
        --    (todas las preguntas con al menos una respuesta correcta)
        IF @YaCompletado = 0
        BEGIN
            DECLARE @TotalPreguntas      INT;
            DECLARE @PreguntasCorrectas  INT;

            SELECT @TotalPreguntas = COUNT(*)
            FROM Pregunta WHERE IdReto = @IdReto;

            SELECT @PreguntasCorrectas = COUNT(DISTINCT hi.IdPregunta)
            FROM HistorialIntento hi
            WHERE hi.IdUsuario  = @IdUsuario
              AND hi.IdReto     = @IdReto
              AND hi.EsCorrecta = 1;

            IF @TotalPreguntas > 0 AND @PreguntasCorrectas >= @TotalPreguntas
            BEGIN
                SET @RetoCompletadoAhora = 1;

                UPDATE ProgresoAcademico
                SET Completado         = 1,
                    FechaSuperacion    = @FechaActualizacion,
                    FechaActualizacion = @FechaActualizacion
                WHERE IdUsuario = @IdUsuario AND IdReto = @IdReto;

                -- Acreditar puntos (con multiplicador de dificultad) y monedas
                SELECT
                    @PuntosGanados  = CAST(r.PuntosOtorgados * d.MultiplicadorPuntos AS INT),
                    @MonedasGanadas = r.MonedasOtorgadas
                FROM Reto r
                INNER JOIN Dificultad d ON r.IdDificultad = d.IdDificultad
                WHERE r.IdReto = @IdReto;

                UPDATE Billetera
                SET PuntosAcumulados    = PuntosAcumulados  + @PuntosGanados,
                    MonedasVirtuales    = MonedasVirtuales  + @MonedasGanadas,
                    FechaActualizacion  = @FechaActualizacion,
                    IdDispositivoOrigen = @IdDispositivoOrigen
                WHERE IdUsuario = @IdUsuario;
            END
        END

        COMMIT TRANSACTION;

        -- Retornar resultado
        SELECT
            @EsCorrecta           AS EsCorrecta,
            @RetoCompletadoAhora  AS RetoCompletado,
            @PuntosGanados        AS PuntosGanados,
            @MonedasGanadas       AS MonedasGanadas
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ▸ sp_Insignia_EvaluarYOtorgar
-- Evalúa reglas de negocio y otorga insignias pendientes.
-- Regla 1: primer reto completado  → "Semilla Germinada"
-- Regla 2: departamento completado → "Guardián de {Departamento}"
-- Regla 3: juego entero completado → "Sacuanjoche Dorado"
CREATE OR ALTER PROCEDURE sp_Insignia_EvaluarYOtorgar
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InsigniasOtorgadas TABLE (IdInsignia INT);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ═══ REGLA 1: Primer reto completado ═══
        INSERT INTO UsuarioInsignia (IdUsuario, IdInsignia)
        OUTPUT inserted.IdInsignia INTO @InsigniasOtorgadas
        SELECT @IdUsuario, i.IdInsignia
        FROM Insignia i
        WHERE i.Nombre = N'Semilla Germinada'
          AND i.Activo = 1
          AND NOT EXISTS (
              SELECT 1 FROM UsuarioInsignia ui
              WHERE ui.IdUsuario = @IdUsuario AND ui.IdInsignia = i.IdInsignia)
          AND EXISTS (
              SELECT 1 FROM ProgresoAcademico
              WHERE IdUsuario = @IdUsuario AND Completado = 1);

        -- ═══ REGLA 2: Departamento completado ═══
        INSERT INTO UsuarioInsignia (IdUsuario, IdInsignia)
        OUTPUT inserted.IdInsignia INTO @InsigniasOtorgadas
        SELECT @IdUsuario, i.IdInsignia
        FROM Departamento d
        INNER JOIN Insignia i
            ON i.Nombre = N'Guardián de ' + d.Nombre AND i.Activo = 1
        WHERE NOT EXISTS (
            SELECT 1 FROM UsuarioInsignia ui
            WHERE ui.IdUsuario = @IdUsuario AND ui.IdInsignia = i.IdInsignia)
          -- Todos los retos activos del departamento están completados
          AND NOT EXISTS (
              SELECT 1
              FROM Municipio mu
              INNER JOIN Reto r ON mu.IdMunicipio = r.IdMunicipio AND r.Activo = 1
              LEFT  JOIN ProgresoAcademico pa
                    ON  r.IdReto     = pa.IdReto
                    AND pa.IdUsuario = @IdUsuario
                    AND pa.Completado = 1
              WHERE mu.IdDepartamento = d.IdDepartamento
                AND pa.IdProgreso IS NULL)
          -- Al menos un reto existe en el departamento
          AND EXISTS (
              SELECT 1
              FROM Municipio mu
              INNER JOIN Reto r ON mu.IdMunicipio = r.IdMunicipio AND r.Activo = 1
              WHERE mu.IdDepartamento = d.IdDepartamento);

        -- ═══ REGLA 3: Juego completo ═══
        INSERT INTO UsuarioInsignia (IdUsuario, IdInsignia)
        OUTPUT inserted.IdInsignia INTO @InsigniasOtorgadas
        SELECT @IdUsuario, i.IdInsignia
        FROM Insignia i
        WHERE i.Nombre = N'Sacuanjoche Dorado'
          AND i.Activo = 1
          AND NOT EXISTS (
              SELECT 1 FROM UsuarioInsignia ui
              WHERE ui.IdUsuario = @IdUsuario AND ui.IdInsignia = i.IdInsignia)
          -- No hay ningún reto activo sin completar
          AND NOT EXISTS (
              SELECT 1 FROM Reto r
              WHERE r.Activo = 1
                AND NOT EXISTS (
                    SELECT 1 FROM ProgresoAcademico pa
                    WHERE pa.IdReto = r.IdReto
                      AND pa.IdUsuario = @IdUsuario
                      AND pa.Completado = 1))
          AND EXISTS (SELECT 1 FROM Reto WHERE Activo = 1);

        COMMIT TRANSACTION;

        -- Retornar insignias recién otorgadas
        SELECT io.IdInsignia, i.Nombre, i.Descripcion
        FROM @InsigniasOtorgadas io
        INNER JOIN Insignia i ON io.IdInsignia = i.IdInsignia
        FOR JSON PATH;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- 14.4  ECONOMÍA
-- ─────────────────────────────────────────────────────

-- ▸ sp_Tienda_ComprarItem
CREATE OR ALTER PROCEDURE sp_Tienda_ComprarItem
    @IdUsuario INT,
    @IdItem    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CostoMonedas INT;
    DECLARE @SaldoActual  INT;

    SELECT @CostoMonedas = CostoMonedas
    FROM ItemTienda
    WHERE IdItem = @IdItem AND Activo = 1;

    IF @CostoMonedas IS NULL
    BEGIN
        RAISERROR(N'El artículo no existe o no está disponible.', 16, 1);
        RETURN;
    END

    SELECT @SaldoActual = MonedasVirtuales
    FROM Billetera WHERE IdUsuario = @IdUsuario;

    IF @SaldoActual IS NULL OR @SaldoActual < @CostoMonedas
    BEGIN
        RAISERROR(N'Saldo insuficiente para realizar la compra.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM CompraUsuario WHERE IdUsuario = @IdUsuario AND IdItem = @IdItem)
    BEGIN
        RAISERROR(N'El artículo ya fue adquirido anteriormente.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Billetera
        SET MonedasVirtuales   = MonedasVirtuales - @CostoMonedas,
            FechaActualizacion = SYSDATETIME()
        WHERE IdUsuario = @IdUsuario;

        INSERT INTO CompraUsuario (IdUsuario, IdItem)
        VALUES (@IdUsuario, @IdItem);

        COMMIT TRANSACTION;

        SELECT N'Compra realizada exitosamente.' AS Mensaje,
               @SaldoActual - @CostoMonedas      AS NuevoSaldo
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ▸ sp_Avatar_Comprar
CREATE OR ALTER PROCEDURE sp_Avatar_Comprar
    @IdUsuario INT,
    @IdAvatar  INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CostoMonedas INT;
    DECLARE @SaldoActual  INT;

    SELECT @CostoMonedas = ISNULL(CostoMonedas, 0)
    FROM Avatar
    WHERE IdAvatar = @IdAvatar AND Activo = 1;

    IF @CostoMonedas IS NULL
    BEGIN
        RAISERROR(N'El avatar no existe o no está disponible.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM UsuarioAvatar
               WHERE IdUsuario = @IdUsuario AND IdAvatar = @IdAvatar)
    BEGIN
        RAISERROR(N'El avatar ya fue desbloqueado anteriormente.', 16, 1);
        RETURN;
    END

    SELECT @SaldoActual = MonedasVirtuales
    FROM Billetera WHERE IdUsuario = @IdUsuario;

    IF @CostoMonedas > 0 AND ((@SaldoActual IS NULL) OR @SaldoActual < @CostoMonedas)
    BEGIN
        RAISERROR(N'Saldo insuficiente para desbloquear el avatar.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @CostoMonedas > 0
        BEGIN
            UPDATE Billetera
            SET MonedasVirtuales   = MonedasVirtuales - @CostoMonedas,
                FechaActualizacion = SYSDATETIME()
            WHERE IdUsuario = @IdUsuario;
        END

        INSERT INTO UsuarioAvatar (IdUsuario, IdAvatar, Equipado)
        VALUES (@IdUsuario, @IdAvatar, 0);

        COMMIT TRANSACTION;

        SELECT N'Avatar desbloqueado exitosamente.' AS Mensaje,
               ISNULL(@SaldoActual, 0) - @CostoMonedas AS NuevoSaldo
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ▸ sp_Avatar_Equipar
CREATE OR ALTER PROCEDURE sp_Avatar_Equipar
    @IdUsuario INT,
    @IdAvatar  INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM UsuarioAvatar
                   WHERE IdUsuario = @IdUsuario AND IdAvatar = @IdAvatar)
    BEGIN
        RAISERROR(N'No poseés este avatar.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Desequipar todos
        UPDATE UsuarioAvatar
        SET Equipado = 0
        WHERE IdUsuario = @IdUsuario AND Equipado = 1;

        -- Equipar el seleccionado
        UPDATE UsuarioAvatar
        SET Equipado = 1
        WHERE IdUsuario = @IdUsuario AND IdAvatar = @IdAvatar;

        COMMIT TRANSACTION;

        SELECT N'Avatar equipado exitosamente.' AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- 14.5  SEGUIMIENTO (docentes / padres)
-- ─────────────────────────────────────────────────────

-- ▸ sp_Padre_ObtenerProgresoHijos
CREATE OR ALTER PROCEDURE sp_Padre_ObtenerProgresoHijos
    @IdUsuario INT    -- IdUsuario del padre/tutor
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IdUsuario      AS IdEstudiante,
        u.Alias,
        g.Nombre         AS GradoEscolar,
        b.PuntosAcumulados,
        b.MonedasVirtuales,
        (SELECT COUNT(*) FROM ProgresoAcademico pa
         WHERE pa.IdUsuario = e.IdUsuario AND pa.Completado = 1)  AS RetosCompletados,
        (SELECT COUNT(*) FROM UsuarioInsignia ui
         WHERE ui.IdUsuario = e.IdUsuario)                        AS InsigniasObtenidas,
        (
            SELECT TOP 1 d2.Nombre
            FROM ProgresoAcademico pa2
            INNER JOIN Reto r2       ON pa2.IdReto = r2.IdReto AND r2.Activo = 1
            INNER JOIN Municipio mu2 ON r2.IdMunicipio = mu2.IdMunicipio
            INNER JOIN Departamento d2 ON mu2.IdDepartamento = d2.IdDepartamento
            WHERE pa2.IdUsuario  = e.IdUsuario
              AND pa2.Completado = 1
            ORDER BY d2.OrdenDesbloqueo DESC
        ) AS UltimoDepartamento
    FROM PadreEstudiante pe
    INNER JOIN Estudiante   e ON pe.IdEstudiante = e.IdUsuario
    INNER JOIN Usuario      u ON e.IdUsuario     = u.IdUsuario
    INNER JOIN GradoEscolar g ON e.IdGradoEscolar = g.IdGradoEscolar
    LEFT  JOIN Billetera    b ON e.IdUsuario     = b.IdUsuario
    WHERE pe.IdPadre = @IdUsuario
      AND u.Activo   = 1
    FOR JSON PATH;
END
GO

-- ▸ sp_Docente_ObtenerProgresoGrupo
CREATE OR ALTER PROCEDURE sp_Docente_ObtenerProgresoGrupo
    @IdGrupo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.IdUsuario      AS IdEstudiante,
        u.Alias,
        b.PuntosAcumulados,
        b.MonedasVirtuales,
        (SELECT COUNT(*) FROM ProgresoAcademico pa
         WHERE pa.IdUsuario = e.IdUsuario AND pa.Completado = 1) AS RetosCompletados,
        (SELECT COUNT(*) FROM Reto r WHERE r.Activo = 1)        AS TotalRetos,
        (SELECT COUNT(*) FROM UsuarioInsignia ui
         WHERE ui.IdUsuario = e.IdUsuario)                       AS InsigniasObtenidas,
        (
            SELECT TOP 1 d2.Nombre
            FROM ProgresoAcademico pa2
            INNER JOIN Reto r2       ON pa2.IdReto = r2.IdReto AND r2.Activo = 1
            INNER JOIN Municipio mu2 ON r2.IdMunicipio = mu2.IdMunicipio
            INNER JOIN Departamento d2 ON mu2.IdDepartamento = d2.IdDepartamento
            WHERE pa2.IdUsuario  = e.IdUsuario
              AND pa2.Completado = 1
            ORDER BY d2.OrdenDesbloqueo DESC
        ) AS UltimoDepartamento
    FROM GrupoEstudiante ge
    INNER JOIN Estudiante e ON ge.IdEstudiante = e.IdUsuario
    INNER JOIN Usuario    u ON e.IdUsuario     = u.IdUsuario
    LEFT  JOIN Billetera  b ON e.IdUsuario     = b.IdUsuario
    WHERE ge.IdGrupo = @IdGrupo
      AND u.Activo   = 1
    ORDER BY u.Alias
    FOR JSON PATH;
END
GO

-- ▸ sp_Notificacion_Crear
CREATE OR ALTER PROCEDURE sp_Notificacion_Crear
    @IdUsuarioDestino INT,
    @Tipo             NVARCHAR(50),
    @Mensaje          NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO Notificacion (IdUsuarioDestino, Tipo, Mensaje)
        VALUES (@IdUsuarioDestino, @Tipo, @Mensaje);

        SELECT SCOPE_IDENTITY() AS IdNotificacion
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ▸ sp_Notificacion_MarcarLeida
CREATE OR ALTER PROCEDURE sp_Notificacion_MarcarLeida
    @IdNotificacion INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE Notificacion
        SET Leida              = 1,
            FechaActualizacion = SYSDATETIME()
        WHERE IdNotificacion = @IdNotificacion;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Notificación no encontrada.', 16, 1);
            RETURN;
        END

        SELECT N'Notificación marcada como leída.' AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- 14.6  SINCRONIZACIÓN OFFLINE
-- ─────────────────────────────────────────────────────

-- ▸ sp_Sync_SubirProgreso
-- Recibe lotes JSON de progreso, intentos y billetera generados offline.
-- Upsert idempotente con estrategia last-write-wins por FechaActualizacion.
/*
  JSON esperado:
  @ProgresoJSON = [
    {"IdReto":1,"Intentos":3,"Completado":true,"FechaSuperacion":"2026-01-15T10:30:00",
     "FechaActualizacion":"2026-01-15T10:30:00","IdDispositivoOrigen":"dev-abc123"}, ...
  ]
  @IntentosJSON = [
    {"IdReto":1,"IdPregunta":5,"IdOpcionSeleccionada":12,"EsCorrecta":true,
     "FechaIntento":"2026-01-15T10:29:50","TiempoRespuestaSegundos":8,
     "FechaActualizacion":"2026-01-15T10:29:50","IdDispositivoOrigen":"dev-abc123"}, ...
  ]
  @BilleteraJSON = {
    "PuntosAcumulados":250,"MonedasVirtuales":80,
    "FechaActualizacion":"2026-01-15T10:30:00","IdDispositivoOrigen":"dev-abc123"
  }
*/
CREATE OR ALTER PROCEDURE sp_Sync_SubirProgreso
    @IdUsuario     INT,
    @ProgresoJSON  NVARCHAR(MAX) = NULL,
    @IntentosJSON  NVARCHAR(MAX) = NULL,
    @BilleteraJSON NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RegistrosProcesados INT = 0;
    DECLARE @Estado NVARCHAR(20) = N'Exitoso';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ═══ 1. ProgresoAcademico (MERGE, last-write-wins) ═══
        IF @ProgresoJSON IS NOT NULL AND LEN(@ProgresoJSON) > 2
        BEGIN
            ;MERGE INTO ProgresoAcademico AS target
            USING (
                SELECT
                    @IdUsuario         AS IdUsuario,
                    j.IdReto,
                    j.Intentos,
                    j.Completado,
                    j.FechaSuperacion,
                    j.FechaActualizacion,
                    j.IdDispositivoOrigen
                FROM OPENJSON(@ProgresoJSON) WITH (
                    IdReto              INT,
                    Intentos            INT,
                    Completado          BIT,
                    FechaSuperacion     DATETIME2,
                    FechaActualizacion  DATETIME2,
                    IdDispositivoOrigen NVARCHAR(100)
                ) j
            ) AS source
            ON  target.IdUsuario = source.IdUsuario
            AND target.IdReto    = source.IdReto
            WHEN MATCHED AND source.FechaActualizacion > target.FechaActualizacion THEN
                UPDATE SET
                    Intentos            = source.Intentos,
                    Completado          = source.Completado,
                    FechaSuperacion     = source.FechaSuperacion,
                    FechaActualizacion  = source.FechaActualizacion,
                    IdDispositivoOrigen = source.IdDispositivoOrigen
            WHEN NOT MATCHED THEN
                INSERT (IdUsuario, IdReto, Intentos, Completado,
                        FechaSuperacion, FechaActualizacion, IdDispositivoOrigen)
                VALUES (source.IdUsuario, source.IdReto, source.Intentos,
                        source.Completado, source.FechaSuperacion,
                        source.FechaActualizacion, source.IdDispositivoOrigen);

            SET @RegistrosProcesados = @RegistrosProcesados + @@ROWCOUNT;
        END

        -- ═══ 2. HistorialIntento (INSERT, append-only, idempotente) ═══
        IF @IntentosJSON IS NOT NULL AND LEN(@IntentosJSON) > 2
        BEGIN
            INSERT INTO HistorialIntento (
                IdUsuario, IdReto, IdPregunta, IdOpcionSeleccionada,
                EsCorrecta, FechaIntento, TiempoRespuestaSegundos,
                FechaActualizacion, IdDispositivoOrigen)
            SELECT
                @IdUsuario,
                j.IdReto,
                j.IdPregunta,
                j.IdOpcionSeleccionada,
                j.EsCorrecta,
                j.FechaIntento,
                j.TiempoRespuestaSegundos,
                j.FechaActualizacion,
                j.IdDispositivoOrigen
            FROM OPENJSON(@IntentosJSON) WITH (
                IdReto                  INT,
                IdPregunta              INT,
                IdOpcionSeleccionada    INT,
                EsCorrecta              BIT,
                FechaIntento            DATETIME2,
                TiempoRespuestaSegundos INT,
                FechaActualizacion      DATETIME2,
                IdDispositivoOrigen     NVARCHAR(100)
            ) j
            WHERE NOT EXISTS (
                SELECT 1 FROM HistorialIntento hi
                WHERE hi.IdUsuario = @IdUsuario
                  AND hi.IdReto    = j.IdReto
                  AND (hi.IdPregunta = j.IdPregunta
                       OR (hi.IdPregunta IS NULL AND j.IdPregunta IS NULL))
                  AND hi.FechaIntento = j.FechaIntento
                  AND (hi.IdDispositivoOrigen = j.IdDispositivoOrigen
                       OR (hi.IdDispositivoOrigen IS NULL AND j.IdDispositivoOrigen IS NULL))
            );

            SET @RegistrosProcesados = @RegistrosProcesados + @@ROWCOUNT;
        END

        -- ═══ 3. Billetera (last-write-wins) ═══
        IF @BilleteraJSON IS NOT NULL AND LEN(@BilleteraJSON) > 2
        BEGIN
            DECLARE @BillPuntos      INT;
            DECLARE @BillMonedas     INT;
            DECLARE @BillFecha       DATETIME2;
            DECLARE @BillDispositivo NVARCHAR(100);

            SELECT
                @BillPuntos      = j.PuntosAcumulados,
                @BillMonedas     = j.MonedasVirtuales,
                @BillFecha       = j.FechaActualizacion,
                @BillDispositivo = j.IdDispositivoOrigen
            FROM OPENJSON(@BilleteraJSON) WITH (
                PuntosAcumulados    INT,
                MonedasVirtuales    INT,
                FechaActualizacion  DATETIME2,
                IdDispositivoOrigen NVARCHAR(100)
            ) j;

            UPDATE Billetera
            SET PuntosAcumulados    = @BillPuntos,
                MonedasVirtuales    = @BillMonedas,
                FechaActualizacion  = @BillFecha,
                IdDispositivoOrigen = @BillDispositivo
            WHERE IdUsuario = @IdUsuario
              AND @BillFecha > FechaActualizacion;

            SET @RegistrosProcesados = @RegistrosProcesados + @@ROWCOUNT;
        END

        -- ═══ 4. Bitácora de sincronización ═══
        INSERT INTO RegistroSincronizacion (IdUsuario, CantidadRegistros, Estado)
        VALUES (@IdUsuario, @RegistrosProcesados, @Estado);

        COMMIT TRANSACTION;

        SELECT @RegistrosProcesados AS RegistrosProcesados, @Estado AS Estado
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        -- Intentar registrar la falla fuera de la transacción
        BEGIN TRY
            INSERT INTO RegistroSincronizacion (IdUsuario, CantidadRegistros, Estado)
            VALUES (@IdUsuario, @RegistrosProcesados, N'Fallido');
        END TRY
        BEGIN CATCH
            -- Si falla el log, no enmascarar el error original
        END CATCH

        THROW;
    END CATCH
END
GO

-- ▸ sp_Sync_ObtenerContenidoActualizado
-- Devuelve catálogos modificados desde @FechaDesde (10 result-sets JSON).
-- El primer result-set incluye catálogos estáticos completos.
CREATE OR ALTER PROCEDURE sp_Sync_ObtenerContenidoActualizado
    @FechaDesde DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    -- RS 1: Catálogos estáticos (siempre completos, cambian raramente)
    SELECT
        (SELECT IdRol, Nombre FROM Rol FOR JSON PATH) AS Roles,
        (SELECT IdGradoEscolar, Nombre FROM GradoEscolar FOR JSON PATH) AS GradosEscolares,
        (SELECT IdAsignatura, Nombre, Activo FROM Asignatura FOR JSON PATH) AS Asignaturas,
        (SELECT IdTipoReto, Nombre FROM TipoReto FOR JSON PATH) AS TiposReto,
        (SELECT IdDificultad, Nombre, MultiplicadorPuntos
         FROM Dificultad FOR JSON PATH) AS Dificultades,
        (SELECT IdTipoContenidoCultural, Nombre
         FROM TipoContenidoCultural FOR JSON PATH) AS TiposContenidoCultural,
        (SELECT IdInsignia, Nombre, Descripcion, IdMultimedia, Activo
         FROM Insignia FOR JSON PATH) AS Insignias
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    -- RS 2: Departamentos modificados
    SELECT IdDepartamento, Nombre, OrdenDesbloqueo, FechaModificacion
    FROM Departamento
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 3: Municipios modificados
    SELECT IdMunicipio, IdDepartamento, Nombre, FechaModificacion
    FROM Municipio
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 4: Retos modificados
    SELECT IdReto, IdAsignatura, IdMunicipio, IdTipoReto, IdDificultad,
           Descripcion, PuntosOtorgados, MonedasOtorgadas,
           Orden, Activo, FechaModificacion
    FROM Reto
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 5: Preguntas modificadas
    SELECT IdPregunta, IdReto, Enunciado, IdMultimedia, Orden, FechaModificacion
    FROM Pregunta
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 6: Opciones de preguntas modificadas
    SELECT o.IdOpcion, o.IdPregunta, o.Texto, o.EsCorrecta
    FROM OpcionRespuesta o
    INNER JOIN Pregunta p ON o.IdPregunta = p.IdPregunta
    WHERE p.FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 7: Contenido cultural modificado
    SELECT IdContenido, IdMunicipio, IdTipoContenidoCultural,
           Titulo, Descripcion, IdMultimedia, FechaModificacion
    FROM ContenidoCultural
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 8: Avatares modificados
    SELECT IdAvatar, Nombre, IdMultimedia, CostoMonedas, Activo, FechaModificacion
    FROM Avatar
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 9: Items de tienda modificados
    SELECT IdItem, Nombre, Descripcion, CostoMonedas,
           IdMultimedia, Activo, FechaModificacion
    FROM ItemTienda
    WHERE FechaModificacion > @FechaDesde
    FOR JSON PATH;

    -- RS 10: Multimedia referenciado por contenido modificado
    SELECT m.IdMultimedia, m.TipoArchivo, m.Url, m.TextoAlternativo
    FROM Multimedia m
    WHERE m.IdMultimedia IN (
        SELECT IdMultimedia FROM Pregunta
        WHERE FechaModificacion > @FechaDesde AND IdMultimedia IS NOT NULL
        UNION
        SELECT IdMultimedia FROM ContenidoCultural
        WHERE FechaModificacion > @FechaDesde AND IdMultimedia IS NOT NULL
        UNION
        SELECT IdMultimedia FROM Avatar
        WHERE FechaModificacion > @FechaDesde AND IdMultimedia IS NOT NULL
        UNION
        SELECT IdMultimedia FROM ItemTienda
        WHERE FechaModificacion > @FechaDesde AND IdMultimedia IS NOT NULL
        UNION
        SELECT IdMultimedia FROM Insignia
        WHERE IdMultimedia IS NOT NULL
    )
    FOR JSON PATH;
END
GO

-- =====================================================
-- SECCIÓN 13 (continuación) · GRANT EXECUTE al rol API
-- =====================================================

-- Autenticación y perfil
GRANT EXECUTE ON sp_Usuario_Registrar           TO rol_ApiAccess;
GRANT EXECUTE ON sp_Usuario_Login               TO rol_ApiAccess;
GRANT EXECUTE ON sp_Estudiante_ObtenerPerfil    TO rol_ApiAccess;

-- Mapa y contenido
GRANT EXECUTE ON sp_Mapa_ObtenerDepartamentos   TO rol_ApiAccess;
GRANT EXECUTE ON sp_Mapa_ObtenerMunicipios      TO rol_ApiAccess;
GRANT EXECUTE ON sp_Reto_ObtenerPorMunicipio    TO rol_ApiAccess;
GRANT EXECUTE ON sp_Reto_ObtenerPreguntas       TO rol_ApiAccess;
GRANT EXECUTE ON sp_ContenidoCultural_ObtenerPorMunicipio TO rol_ApiAccess;

-- Juego y progreso
GRANT EXECUTE ON sp_Progreso_RegistrarIntento   TO rol_ApiAccess;
GRANT EXECUTE ON sp_Insignia_EvaluarYOtorgar    TO rol_ApiAccess;

-- Economía
GRANT EXECUTE ON sp_Tienda_ComprarItem          TO rol_ApiAccess;
GRANT EXECUTE ON sp_Avatar_Comprar              TO rol_ApiAccess;
GRANT EXECUTE ON sp_Avatar_Equipar              TO rol_ApiAccess;

-- Seguimiento
GRANT EXECUTE ON sp_Padre_ObtenerProgresoHijos  TO rol_ApiAccess;
GRANT EXECUTE ON sp_Docente_ObtenerProgresoGrupo TO rol_ApiAccess;
GRANT EXECUTE ON sp_Notificacion_Crear          TO rol_ApiAccess;
GRANT EXECUTE ON sp_Notificacion_MarcarLeida    TO rol_ApiAccess;

-- Sincronización
GRANT EXECUTE ON sp_Sync_SubirProgreso          TO rol_ApiAccess;
GRANT EXECUTE ON sp_Sync_ObtenerContenidoActualizado TO rol_ApiAccess;
GO

PRINT N'═══════════════════════════════════════════════';
PRINT N'  ElCaminoDelGuardabarranco v2.0 — Instalación completa.';
PRINT N'  32 tablas · 21 índices · 19 SPs · 1 rol de seguridad';
PRINT N'═══════════════════════════════════════════════';
GO

USE ElCaminoDelGuardabarranco
GO
SELECT * FROM Usuario