USE [ElCaminoDelGuardabarranco];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

PRINT '=====================================================';
PRINT 'INICIANDO REFACTORIZACIÓN DE BASE DE DATOS';
PRINT '=====================================================';

-- 1. CORREGIR DUPLICADOS EN GradoEscolar
IF EXISTS (SELECT 1 FROM GradoEscolar WHERE IdGradoEscolar > 3)
BEGIN
    PRINT 'Limpiando duplicados en GradoEscolar...';
    -- Actualizar referencias si existen
    UPDATE Estudiante SET IdGradoEscolar = 1 WHERE IdGradoEscolar = 4;
    UPDATE Estudiante SET IdGradoEscolar = 2 WHERE IdGradoEscolar = 5;
    UPDATE Estudiante SET IdGradoEscolar = 3 WHERE IdGradoEscolar = 6;
    
    UPDATE Grupo SET IdGradoEscolar = 1 WHERE IdGradoEscolar = 4;
    UPDATE Grupo SET IdGradoEscolar = 2 WHERE IdGradoEscolar = 5;
    UPDATE Grupo SET IdGradoEscolar = 3 WHERE IdGradoEscolar = 6;

    DELETE FROM GradoEscolar WHERE IdGradoEscolar > 3;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_GradoEscolar_Nombre' AND object_id = OBJECT_ID('GradoEscolar'))
BEGIN
    PRINT 'Agregando restricción UQ_GradoEscolar_Nombre...';
    ALTER TABLE GradoEscolar ADD CONSTRAINT UQ_GradoEscolar_Nombre UNIQUE (Nombre);
END
GO

-- 2. CREAR TABLA Nivel SI NO EXISTE
IF OBJECT_ID('dbo.Nivel', 'U') IS NULL
BEGIN
    PRINT 'Creando tabla Nivel...';
    CREATE TABLE dbo.Nivel (
        IdNivel INT IDENTITY(1,1) NOT NULL,
        Numero INT NOT NULL,
        Titulo NVARCHAR(100) NOT NULL,
        PuntosRequeridos INT NOT NULL,
        MonedasRecompensa INT NOT NULL CONSTRAINT DF_Nivel_MonedasRecompensa DEFAULT 0,
        IdMultimedia INT NULL,
        CONSTRAINT PK_Nivel PRIMARY KEY CLUSTERED (IdNivel ASC),
        CONSTRAINT UQ_Nivel_Numero UNIQUE (Numero),
        CONSTRAINT FK_Nivel_Multimedia FOREIGN KEY (IdMultimedia) REFERENCES dbo.Multimedia(IdMultimedia)
    );
END
GO

-- 3. AGREGAR COLUMNAS DE ALTO VALOR A TABLAS EXISTENTES

-- Pregunta.Retroalimentacion
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Pregunta') AND name = 'Retroalimentacion')
BEGIN
    PRINT 'Agregando columna Retroalimentacion a Pregunta...';
    ALTER TABLE Pregunta ADD Retroalimentacion NVARCHAR(500) NULL;
END
GO

-- OpcionRespuesta.IdMultimedia
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('OpcionRespuesta') AND name = 'IdMultimedia')
BEGIN
    PRINT 'Agregando columna IdMultimedia a OpcionRespuesta...';
    ALTER TABLE OpcionRespuesta ADD IdMultimedia INT NULL CONSTRAINT FK_OpcionRespuesta_Multimedia FOREIGN KEY REFERENCES dbo.Multimedia(IdMultimedia);
END
GO

-- Grupo.CodigoAcceso
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Grupo') AND name = 'CodigoAcceso')
BEGIN
    PRINT 'Agregando columna CodigoAcceso a Grupo...';
    ALTER TABLE Grupo ADD CodigoAcceso NVARCHAR(20) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Grupo_CodigoAcceso' AND object_id = OBJECT_ID('Grupo'))
BEGIN
    PRINT 'Creando índice único para CodigoAcceso en Grupo...';
    CREATE UNIQUE NONCLUSTERED INDEX UQ_Grupo_CodigoAcceso ON Grupo(CodigoAcceso) WHERE CodigoAcceso IS NOT NULL;
END
GO

-- Departamento.Latitud y Longitud
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Departamento') AND name = 'Latitud')
BEGIN
    PRINT 'Agregando coordenadas Latitud y Longitud a Departamento...';
    ALTER TABLE Departamento ADD Latitud DECIMAL(9,6) NULL, Longitud DECIMAL(9,6) NULL;
END
GO

-- Municipio.Latitud y Longitud
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Municipio') AND name = 'Latitud')
BEGIN
    PRINT 'Agregando coordenadas Latitud y Longitud a Municipio...';
    ALTER TABLE Municipio ADD Latitud DECIMAL(9,6) NULL, Longitud DECIMAL(9,6) NULL;
END
GO

-- ItemTienda.Categoria
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ItemTienda') AND name = 'Categoria')
BEGIN
    PRINT 'Agregando columna Categoria a ItemTienda...';
    ALTER TABLE ItemTienda ADD Categoria NVARCHAR(50) NOT NULL CONSTRAINT DF_ItemTienda_Categoria DEFAULT N'Accesorio';
END
GO

-- Billetera.RachaActualDias, MejorRachaDias, UltimaFechaActividad
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Billetera') AND name = 'RachaActualDias')
BEGIN
    PRINT 'Agregando columnas de racha a Billetera...';
    ALTER TABLE Billetera ADD 
        RachaActualDias INT NOT NULL CONSTRAINT DF_Billetera_RachaActual DEFAULT 0,
        MejorRachaDias INT NOT NULL CONSTRAINT DF_Billetera_MejorRacha DEFAULT 0,
        UltimaFechaActividad DATE NULL;
END
GO

-- Default para UsuarioAvatar.FechaObtenido si falta
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('UsuarioAvatar') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('UsuarioAvatar'), 'FechaObtenido', 'ColumnId'))
BEGIN
    ALTER TABLE UsuarioAvatar ADD CONSTRAINT DF_UsuarioAvatar_FechaObtenido DEFAULT SYSDATETIME() FOR FechaObtenido;
END
GO

-- Default para CompraUsuario.FechaCompra si falta
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('CompraUsuario') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('CompraUsuario'), 'FechaCompra', 'ColumnId'))
BEGIN
    ALTER TABLE CompraUsuario ADD CONSTRAINT DF_CompraUsuario_FechaCompra DEFAULT SYSDATETIME() FOR FechaCompra;
END
GO


-- =====================================================
-- 4. PROCEDIMIENTOS ALMACENADOS NUEVOS Y MEJORADOS
-- =====================================================

PRINT 'Creando/Actualizando Procedimientos Almacenados...';
GO

-- ─────────────────────────────────────────────────────
-- sp_Docente_CrearGrupo
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Docente_CrearGrupo
    @IdDocente INT,
    @Nombre NVARCHAR(100),
    @IdGradoEscolar INT,
    @CodigoAcceso NVARCHAR(20) = NULL,
    @IdGrupo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Docente WHERE IdUsuario = @IdDocente)
    BEGIN
        RAISERROR(N'El usuario especificado no es un docente válido.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM GradoEscolar WHERE IdGradoEscolar = @IdGradoEscolar)
    BEGIN
        RAISERROR(N'Grado escolar no válido.', 16, 1);
        RETURN;
    END

    -- Si no se provee código de acceso, generar uno alfanumérico corto
    IF @CodigoAcceso IS NULL OR LTRIM(RTRIM(@CodigoAcceso)) = ''
    BEGIN
        SET @CodigoAcceso = UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8));
    END

    IF EXISTS (SELECT 1 FROM Grupo WHERE CodigoAcceso = @CodigoAcceso)
    BEGIN
        RAISERROR(N'El código de acceso ya está en uso. Proporcione otro o intente de nuevo.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        INSERT INTO Grupo (IdDocente, Nombre, IdGradoEscolar, CodigoAcceso)
        VALUES (@IdDocente, @Nombre, @IdGradoEscolar, @CodigoAcceso);

        SET @IdGrupo = SCOPE_IDENTITY();

        SELECT 
            @IdGrupo AS IdGrupo,
            @Nombre AS Nombre,
            @IdGradoEscolar AS IdGradoEscolar,
            @CodigoAcceso AS CodigoAcceso
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Docente_ObtenerGrupos
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Docente_ObtenerGrupos
    @IdDocente INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        g.IdGrupo,
        g.Nombre AS NombreGrupo,
        g.CodigoAcceso,
        ge.IdGradoEscolar,
        ge.Nombre AS GradoEscolar,
        COUNT(gest.IdEstudiante) AS TotalEstudiantes
    FROM Grupo g
    INNER JOIN GradoEscolar ge ON g.IdGradoEscolar = ge.IdGradoEscolar
    LEFT JOIN GrupoEstudiante gest ON g.IdGrupo = gest.IdGrupo
    WHERE g.IdDocente = @IdDocente
    GROUP BY g.IdGrupo, g.Nombre, g.CodigoAcceso, ge.IdGradoEscolar, ge.Nombre
    ORDER BY g.Nombre
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Docente_AgregarEstudianteGrupo
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Docente_AgregarEstudianteGrupo
    @IdGrupo INT,
    @AliasEstudiante NVARCHAR(50) = NULL,
    @CodigoAcceso NVARCHAR(20) = NULL,
    @IdEstudiante INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Si se pasó código de acceso, resolver IdGrupo
    IF @IdGrupo IS NULL OR @IdGrupo = 0
    BEGIN
        SELECT @IdGrupo = IdGrupo FROM Grupo WHERE CodigoAcceso = @CodigoAcceso;
    END

    IF @IdGrupo IS NULL OR NOT EXISTS (SELECT 1 FROM Grupo WHERE IdGrupo = @IdGrupo)
    BEGIN
        RAISERROR(N'El grupo especificado no existe.', 16, 1);
        RETURN;
    END

    -- Resolver IdEstudiante por Alias si no vino directo
    IF @IdEstudiante IS NULL AND @AliasEstudiante IS NOT NULL
    BEGIN
        SELECT @IdEstudiante = u.IdUsuario
        FROM Usuario u
        INNER JOIN Estudiante e ON u.IdUsuario = e.IdUsuario
        WHERE u.Alias = @AliasEstudiante AND u.Activo = 1;
    END

    IF @IdEstudiante IS NULL OR NOT EXISTS (SELECT 1 FROM Estudiante WHERE IdUsuario = @IdEstudiante)
    BEGIN
        RAISERROR(N'El estudiante no fue encontrado o no está activo.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM GrupoEstudiante WHERE IdGrupo = @IdGrupo AND IdEstudiante = @IdEstudiante)
    BEGIN
        RAISERROR(N'El estudiante ya pertenece a este grupo.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        INSERT INTO GrupoEstudiante (IdGrupo, IdEstudiante, FechaIncorporacion)
        VALUES (@IdGrupo, @IdEstudiante, SYSDATETIME());

        SELECT 
            N'Estudiante agregado exitosamente al grupo.' AS Mensaje,
            @IdGrupo AS IdGrupo,
            @IdEstudiante AS IdEstudiante
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Docente_RemoverEstudianteGrupo
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Docente_RemoverEstudianteGrupo
    @IdGrupo INT,
    @IdEstudiante INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM GrupoEstudiante
    WHERE IdGrupo = @IdGrupo AND IdEstudiante = @IdEstudiante;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(N'El estudiante no pertenecía al grupo especificado.', 16, 1);
        RETURN;
    END

    SELECT N'Estudiante removido del grupo exitosamente.' AS Mensaje
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Padre_VincularEstudiante
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Padre_VincularEstudiante
    @IdPadre INT,
    @AliasEstudiante NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM PadreTutor WHERE IdUsuario = @IdPadre)
    BEGIN
        RAISERROR(N'El usuario especificado no es un padre/tutor válido.', 16, 1);
        RETURN;
    END

    DECLARE @IdEstudiante INT;
    SELECT @IdEstudiante = u.IdUsuario
    FROM Usuario u
    INNER JOIN Estudiante e ON u.IdUsuario = e.IdUsuario
    WHERE u.Alias = @AliasEstudiante AND u.Activo = 1;

    IF @IdEstudiante IS NULL
    BEGIN
        RAISERROR(N'No se encontró ningún estudiante activo con el alias proporcionado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM PadreEstudiante WHERE IdPadre = @IdPadre AND IdEstudiante = @IdEstudiante)
    BEGIN
        RAISERROR(N'El estudiante ya se encuentra vinculado a este tutor.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        INSERT INTO PadreEstudiante (IdPadre, IdEstudiante, FechaVinculacion)
        VALUES (@IdPadre, @IdEstudiante, SYSDATETIME());

        SELECT 
            N'Estudiante vinculado exitosamente.' AS Mensaje,
            @IdEstudiante AS IdEstudiante,
            @AliasEstudiante AS Alias
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Padre_DesvincularEstudiante
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Padre_DesvincularEstudiante
    @IdPadre INT,
    @IdEstudiante INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM PadreEstudiante
    WHERE IdPadre = @IdPadre AND IdEstudiante = @IdEstudiante;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(N'No existe vinculación entre este padre y el estudiante.', 16, 1);
        RETURN;
    END

    SELECT N'Vinculación eliminada exitosamente.' AS Mensaje
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Nivel_ObtenerPorUsuario
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Nivel_ObtenerPorUsuario
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Puntos INT = 0;
    SELECT @Puntos = ISNULL(PuntosAcumulados, 0) FROM Billetera WHERE IdUsuario = @IdUsuario;

    -- Nivel actual alcanzado
    DECLARE @IdNivelActual INT, @NumeroActual INT, @TituloActual NVARCHAR(100), @PuntosReqActual INT;
    SELECT TOP 1 
        @IdNivelActual = IdNivel,
        @NumeroActual = Numero,
        @TituloActual = Titulo,
        @PuntosReqActual = PuntosRequeridos
    FROM Nivel
    WHERE PuntosRequeridos <= @Puntos
    ORDER BY Numero DESC;

    -- Si aún no alcanza el nivel 1, asignar nivel 1 por defecto
    IF @IdNivelActual IS NULL
    BEGIN
        SELECT TOP 1 
            @IdNivelActual = IdNivel,
            @NumeroActual = Numero,
            @TituloActual = Titulo,
            @PuntosReqActual = PuntosRequeridos
        FROM Nivel
        ORDER BY Numero ASC;
    END

    -- Siguiente nivel
    DECLARE @NumeroSiguiente INT, @TituloSiguiente NVARCHAR(100), @PuntosReqSiguiente INT;
    SELECT TOP 1
        @NumeroSiguiente = Numero,
        @TituloSiguiente = Titulo,
        @PuntosReqSiguiente = PuntosRequeridos
    FROM Nivel
    WHERE Numero = @NumeroActual + 1;

    DECLARE @PorcentajeAvance DECIMAL(5,2) = 100.00;
    DECLARE @PuntosRestantes INT = 0;

    IF @PuntosReqSiguiente IS NOT NULL AND @PuntosReqSiguiente > @PuntosReqActual
    BEGIN
        SET @PuntosRestantes = @PuntosReqSiguiente - @Puntos;
        IF @PuntosRestantes < 0 SET @PuntosRestantes = 0;
        SET @PorcentajeAvance = CAST((CAST(@Puntos - @PuntosReqActual AS DECIMAL(9,2)) / CAST(@PuntosReqSiguiente - @PuntosReqActual AS DECIMAL(9,2))) * 100 AS DECIMAL(5,2));
        IF @PorcentajeAvance > 100.00 SET @PorcentajeAvance = 100.00;
        IF @PorcentajeAvance < 0.00 SET @PorcentajeAvance = 0.00;
    END

    SELECT 
        @IdNivelActual AS IdNivel,
        @NumeroActual AS NivelNumero,
        @TituloActual AS NivelTitulo,
        @Puntos AS PuntosActuales,
        @PuntosReqActual AS PuntosNivelBase,
        @NumeroSiguiente AS NivelSiguienteNumero,
        @TituloSiguiente AS NivelSiguienteTitulo,
        @PuntosReqSiguiente AS PuntosRequeridosSiguiente,
        @PuntosRestantes AS PuntosParaSubir,
        @PorcentajeAvance AS PorcentajeAvance
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Gamificacion_ObtenerRanking
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Gamificacion_ObtenerRanking
    @Top INT = 20,
    @IdGrupo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Top IS NULL OR @Top <= 0 SET @Top = 20;

    SELECT TOP (@Top)
        ROW_NUMBER() OVER (ORDER BY b.PuntosAcumulados DESC, u.FechaRegistro ASC) AS Posicion,
        u.IdUsuario,
        u.Alias,
        g.Nombre AS GradoEscolar,
        b.PuntosAcumulados,
        b.MonedasVirtuales,
        b.RachaActualDias,
        av.Nombre AS AvatarEquipado,
        m.Url AS AvatarUrl,
        ISNULL((
            SELECT TOP 1 niv.Titulo 
            FROM Nivel niv 
            WHERE niv.PuntosRequeridos <= b.PuntosAcumulados 
            ORDER BY niv.Numero DESC
        ), N'Explorador') AS RangoNivel
    FROM Usuario u
    INNER JOIN Estudiante e ON u.IdUsuario = e.IdUsuario
    INNER JOIN GradoEscolar g ON e.IdGradoEscolar = g.IdGradoEscolar
    INNER JOIN Billetera b ON u.IdUsuario = b.IdUsuario
    LEFT JOIN UsuarioAvatar ua ON u.IdUsuario = ua.IdUsuario AND ua.Equipado = 1
    LEFT JOIN Avatar av ON ua.IdAvatar = av.IdAvatar
    LEFT JOIN Multimedia m ON av.IdMultimedia = m.IdMultimedia
    WHERE u.Activo = 1
      AND (@IdGrupo IS NULL OR EXISTS (
          SELECT 1 FROM GrupoEstudiante ge WHERE ge.IdGrupo = @IdGrupo AND ge.IdEstudiante = u.IdUsuario
      ))
    ORDER BY b.PuntosAcumulados DESC, u.FechaRegistro ASC
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Tienda_ObtenerItems
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Tienda_ObtenerItems
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        it.IdItem,
        it.Nombre,
        it.Descripcion,
        it.Categoria,
        it.CostoMonedas,
        it.Activo,
        m.Url AS MultimediaUrl,
        m.TipoArchivo AS MultimediaTipo,
        CASE WHEN cu.IdCompra IS NOT NULL THEN 1 ELSE 0 END AS Comprado,
        cu.FechaCompra
    FROM ItemTienda it
    LEFT JOIN Multimedia m ON it.IdMultimedia = m.IdMultimedia
    LEFT JOIN CompraUsuario cu ON it.IdItem = cu.IdItem AND cu.IdUsuario = @IdUsuario
    WHERE it.Activo = 1
    ORDER BY it.Categoria, it.CostoMonedas ASC
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Avatar_ObtenerTodos
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Avatar_ObtenerTodos
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.IdAvatar,
        a.Nombre,
        a.CostoMonedas,
        a.Activo,
        m.Url AS MultimediaUrl,
        m.TipoArchivo AS MultimediaTipo,
        CASE WHEN ua.IdAvatar IS NOT NULL THEN 1 ELSE 0 END AS Desbloqueado,
        ISNULL(ua.Equipado, 0) AS Equipado,
        ua.FechaObtenido
    FROM Avatar a
    LEFT JOIN Multimedia m ON a.IdMultimedia = m.IdMultimedia
    LEFT JOIN UsuarioAvatar ua ON a.IdAvatar = ua.IdAvatar AND ua.IdUsuario = @IdUsuario
    WHERE a.Activo = 1
    ORDER BY a.CostoMonedas ASC, a.Nombre ASC
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Notificacion_ObtenerPorUsuario
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Notificacion_ObtenerPorUsuario
    @IdUsuario INT,
    @SoloNoLeidas BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        IdNotificacion,
        IdUsuarioDestino,
        Tipo,
        Mensaje,
        Leida,
        FechaCreacion
    FROM Notificacion
    WHERE IdUsuarioDestino = @IdUsuario
      AND (@SoloNoLeidas = 0 OR Leida = 0)
    ORDER BY FechaCreacion DESC
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_PreferenciaUsuario_Actualizar
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_PreferenciaUsuario_Actualizar
    @IdUsuario INT,
    @AltoContraste BIT,
    @LecturaVozActiva BIT,
    @TamanoFuente TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM PreferenciaUsuario WHERE IdUsuario = @IdUsuario)
    BEGIN
        UPDATE PreferenciaUsuario
        SET AltoContraste = @AltoContraste,
            LecturaVozActiva = @LecturaVozActiva,
            TamanoFuente = @TamanoFuente
        WHERE IdUsuario = @IdUsuario;
    END
    ELSE
    BEGIN
        INSERT INTO PreferenciaUsuario (IdUsuario, AltoContraste, LecturaVozActiva, TamanoFuente)
        VALUES (@IdUsuario, @AltoContraste, @LecturaVozActiva, @TamanoFuente);
    END

    SELECT N'Preferencias actualizadas con éxito.' AS Mensaje
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Catalogo_ObtenerAsignaturas
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Catalogo_ObtenerAsignaturas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdAsignatura, Nombre, Activo
    FROM Asignatura
    WHERE Activo = 1
    ORDER BY IdAsignatura
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Catalogo_ObtenerGradosEscolares
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Catalogo_ObtenerGradosEscolares
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdGradoEscolar, Nombre
    FROM GradoEscolar
    ORDER BY IdGradoEscolar
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Catalogo_ObtenerRoles
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Catalogo_ObtenerRoles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdRol, Nombre
    FROM Rol
    ORDER BY IdRol
    FOR JSON PATH;
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Reto_ObtenerPreguntas (MEJORADO con Retroalimentacion e IdMultimedia)
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Reto_ObtenerPreguntas
    @IdReto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdPregunta,
        p.Enunciado,
        p.Retroalimentacion,
        p.Orden,
        m.Url             AS MultimediaUrl,
        m.TipoArchivo     AS MultimediaTipo,
        m.TextoAlternativo,
        (
            SELECT 
                o.IdOpcion, 
                o.Texto,
                o.IdMultimedia,
                mo.Url AS MultimediaOpcionUrl
            FROM OpcionRespuesta o
            LEFT JOIN Multimedia mo ON o.IdMultimedia = mo.IdMultimedia
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

-- ─────────────────────────────────────────────────────
-- sp_Progreso_RegistrarIntento (MEJORADO con Racha y Retroalimentacion)
-- ─────────────────────────────────────────────────────
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

    DECLARE @EsCorrecta          BIT;
    DECLARE @Retroalimentacion   NVARCHAR(500);
    DECLARE @YaCompletado        BIT = 0;
    DECLARE @RetoCompletadoAhora BIT = 0;
    DECLARE @PuntosGanados       INT = 0;
    DECLARE @MonedasGanadas      INT = 0;

    -- Validar que la pregunta pertenezca al reto
    SELECT @Retroalimentacion = Retroalimentacion
    FROM Pregunta 
    WHERE IdPregunta = @IdPregunta AND IdReto = @IdReto;

    IF @@ROWCOUNT = 0
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
    DECLARE @Hoy DATE = CAST(@FechaActualizacion AS DATE);

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

                -- Acreditar puntos (con multiplicador) y monedas
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

        -- 4. Actualizar Racha de Estudio Diaria
        DECLARE @UltimaFecha DATE, @RachaActual INT, @MejorRacha INT;
        SELECT 
            @UltimaFecha = UltimaFechaActividad,
            @RachaActual = RachaActualDias,
            @MejorRacha = MejorRachaDias
        FROM Billetera 
        WHERE IdUsuario = @IdUsuario;

        IF @UltimaFecha IS NULL OR @UltimaFecha < @Hoy
        BEGIN
            IF @UltimaFecha = DATEADD(DAY, -1, @Hoy)
            BEGIN
                SET @RachaActual = @RachaActual + 1;
            END
            ELSE IF @UltimaFecha IS NULL OR @UltimaFecha < DATEADD(DAY, -1, @Hoy)
            BEGIN
                SET @RachaActual = 1;
            END

            IF @RachaActual > @MejorRacha
            BEGIN
                SET @MejorRacha = @RachaActual;
            END

            UPDATE Billetera
            SET RachaActualDias = @RachaActual,
                MejorRachaDias = @MejorRacha,
                UltimaFechaActividad = @Hoy,
                FechaActualizacion = @FechaActualizacion
            WHERE IdUsuario = @IdUsuario;
        END

        COMMIT TRANSACTION;

        -- Retornar resultado integral
        SELECT
            @EsCorrecta           AS EsCorrecta,
            @Retroalimentacion    AS Retroalimentacion,
            @RetoCompletadoAhora  AS RetoCompletado,
            @PuntosGanados        AS PuntosGanados,
            @MonedasGanadas       AS MonedasGanadas,
            @RachaActual          AS RachaActualDias
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────
-- sp_Estudiante_ObtenerPerfil (MEJORADO con Nivel y Racha)
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Estudiante_ObtenerPerfil
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Puntos INT = 0;
    SELECT @Puntos = ISNULL(PuntosAcumulados, 0) FROM Billetera WHERE IdUsuario = @IdUsuario;

    SELECT
        u.IdUsuario,
        u.Alias,
        r.Nombre          AS NombreRol,
        e.FechaNacimiento,
        g.Nombre          AS GradoEscolar,
        b.PuntosAcumulados,
        b.MonedasVirtuales,
        b.RachaActualDias,
        b.MejorRachaDias,
        ISNULL((
            SELECT TOP 1 niv.Titulo 
            FROM Nivel niv 
            WHERE niv.PuntosRequeridos <= b.PuntosAcumulados 
            ORDER BY niv.Numero DESC
        ), N'Explorador') AS NivelTitulo,
        ISNULL((
            SELECT TOP 1 niv.Numero 
            FROM Nivel niv 
            WHERE niv.PuntosRequeridos <= b.PuntosAcumulados 
            ORDER BY niv.Numero DESC
        ), 1) AS NivelNumero,
        av.Nombre         AS AvatarEquipado,
        m_av.Url          AS AvatarUrl,
        p.AltoContraste,
        p.LecturaVozActiva,
        p.TamanoFuente,
        (
            SELECT i.IdInsignia, i.Nombre, i.Descripcion, m_i.Url AS InsigniaUrl, ui.FechaObtencion
            FROM UsuarioInsignia ui
            INNER JOIN Insignia i ON ui.IdInsignia = i.IdInsignia
            LEFT JOIN Multimedia m_i ON i.IdMultimedia = m_i.IdMultimedia
            WHERE ui.IdUsuario = u.IdUsuario
            FOR JSON PATH
        ) AS Insignias
    FROM Usuario u
    INNER JOIN Rol            r    ON u.IdRol = r.IdRol
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
-- sp_Sync_SubirProgresoOffline (SUBIDA PUSH DESDE SQLITE)
-- ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_Sync_SubirProgresoOffline
    @IdUsuario INT,
    @JsonIntentos NVARCHAR(MAX),
    @IdDispositivoOrigen NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @JsonIntentos IS NULL OR ISJSON(@JsonIntentos) = 0
    BEGIN
        RAISERROR(N'Formato JSON inválido para sincronización de intentos.', 16, 1);
        RETURN;
    END

    DECLARE @TotalProcesados INT = 0;
    DECLARE @RetosNuevosCompletados INT = 0;
    DECLARE @PuntosTotalesAcreditados INT = 0;
    DECLARE @MonedasTotalesAcreditadas INT = 0;

    -- Tabla temporal con los intentos a sincronizar
    DECLARE @IntentosBatch TABLE (
        IdReto INT,
        IdPregunta INT,
        IdOpcion INT,
        FechaIntento DATETIME2,
        TiempoRespuestaSegundos INT
    );

    INSERT INTO @IntentosBatch (IdReto, IdPregunta, IdOpcion, FechaIntento, TiempoRespuestaSegundos)
    SELECT 
        IdReto,
        IdPregunta,
        IdOpcion,
        ISNULL(FechaIntento, SYSDATETIME()),
        TiempoRespuestaSegundos
    FROM OPENJSON(@JsonIntentos)
    WITH (
        IdReto INT '$.IdReto',
        IdPregunta INT '$.IdPregunta',
        IdOpcion INT '$.IdOpcion',
        FechaIntento DATETIME2 '$.FechaIntento',
        TiempoRespuestaSegundos INT '$.TiempoRespuestaSegundos'
    );

    SET @TotalProcesados = (SELECT COUNT(*) FROM @IntentosBatch);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Procesamiento de los intentos
        DECLARE @CurReto INT, @CurPregunta INT, @CurOpcion INT, @CurFecha DATETIME2, @CurTiempo INT;
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR 
        SELECT IdReto, IdPregunta, IdOpcion, FechaIntento, TiempoRespuestaSegundos FROM @IntentosBatch;

        OPEN cur;
        FETCH NEXT FROM cur INTO @CurReto, @CurPregunta, @CurOpcion, @CurFecha, @CurTiempo;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @EsCorrecta BIT = 0;
            SELECT @EsCorrecta = EsCorrecta FROM OpcionRespuesta WHERE IdOpcion = @CurOpcion AND IdPregunta = @CurPregunta;

            -- Insertar en Historial si no está repetido exactamente en esa fecha
            IF NOT EXISTS (SELECT 1 FROM HistorialIntento WHERE IdUsuario = @IdUsuario AND IdPregunta = @CurPregunta AND FechaIntento = @CurFecha)
            BEGIN
                INSERT INTO HistorialIntento (
                    IdUsuario, IdReto, IdPregunta, IdOpcionSeleccionada, 
                    EsCorrecta, FechaIntento, TiempoRespuestaSegundos, 
                    FechaActualizacion, IdDispositivoOrigen
                )
                VALUES (
                    @IdUsuario, @CurReto, @CurPregunta, @CurOpcion,
                    ISNULL(@EsCorrecta, 0), @CurFecha, @CurTiempo,
                    SYSDATETIME(), @IdDispositivoOrigen
                );

                -- Upsert ProgresoAcademico
                IF EXISTS (SELECT 1 FROM ProgresoAcademico WHERE IdUsuario = @IdUsuario AND IdReto = @CurReto)
                BEGIN
                    UPDATE ProgresoAcademico
                    SET Intentos = Intentos + 1,
                        FechaActualizacion = SYSDATETIME(),
                        IdDispositivoOrigen = @IdDispositivoOrigen
                    WHERE IdUsuario = @IdUsuario AND IdReto = @CurReto;
                END
                ELSE
                BEGIN
                    INSERT INTO ProgresoAcademico (
                        IdUsuario, IdReto, Intentos, Completado, 
                        FechaActualizacion, IdDispositivoOrigen
                    )
                    VALUES (
                        @IdUsuario, @CurReto, 1, 0,
                        SYSDATETIME(), @IdDispositivoOrigen
                    );
                END
            END

            FETCH NEXT FROM cur INTO @CurReto, @CurPregunta, @CurOpcion, @CurFecha, @CurTiempo;
        END

        CLOSE cur;
        DEALLOCATE cur;

        -- Evaluar retos que ahora quedaron completados
        DECLARE @RetosParaEvaluar TABLE (IdReto INT);
        INSERT INTO @RetosParaEvaluar (IdReto)
        SELECT DISTINCT IdReto FROM @IntentosBatch;

        DECLARE @EvalReto INT;
        DECLARE curEval CURSOR LOCAL FAST_FORWARD FOR SELECT IdReto FROM @RetosParaEvaluar;
        OPEN curEval;
        FETCH NEXT FROM curEval INTO @EvalReto;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @YaComp BIT = 0;
            SELECT @YaComp = Completado FROM ProgresoAcademico WHERE IdUsuario = @IdUsuario AND IdReto = @EvalReto;

            IF @YaComp = 0
            BEGIN
                DECLARE @TotP INT, @CorrP INT;
                SELECT @TotP = COUNT(*) FROM Pregunta WHERE IdReto = @EvalReto;
                SELECT @CorrP = COUNT(DISTINCT hi.IdPregunta) FROM HistorialIntento hi WHERE hi.IdUsuario = @IdUsuario AND hi.IdReto = @EvalReto AND hi.EsCorrecta = 1;

                IF @TotP > 0 AND @CorrP >= @TotP
                BEGIN
                    UPDATE ProgresoAcademico
                    SET Completado = 1,
                        FechaSuperacion = SYSDATETIME(),
                        FechaActualizacion = SYSDATETIME()
                    WHERE IdUsuario = @IdUsuario AND IdReto = @EvalReto;

                    DECLARE @Pts INT, @Mnd INT;
                    SELECT 
                        @Pts = CAST(r.PuntosOtorgados * d.MultiplicadorPuntos AS INT),
                        @Mnd = r.MonedasOtorgadas
                    FROM Reto r
                    INNER JOIN Dificultad d ON r.IdDificultad = d.IdDificultad
                    WHERE r.IdReto = @EvalReto;

                    SET @PuntosTotalesAcreditados = @PuntosTotalesAcreditados + @Pts;
                    SET @MonedasTotalesAcreditadas = @MonedasTotalesAcreditadas + @Mnd;
                    SET @RetosNuevosCompletados = @RetosNuevosCompletados + 1;
                END
            END

            FETCH NEXT FROM curEval INTO @EvalReto;
        END

        CLOSE curEval;
        DEALLOCATE curEval;

        IF @PuntosTotalesAcreditados > 0 OR @MonedasTotalesAcreditadas > 0
        BEGIN
            UPDATE Billetera
            SET PuntosAcumulados = PuntosAcumulados + @PuntosTotalesAcreditados,
                MonedasVirtuales = MonedasVirtuales + @MonedasTotalesAcreditadas,
                FechaActualizacion = SYSDATETIME(),
                IdDispositivoOrigen = @IdDispositivoOrigen
            WHERE IdUsuario = @IdUsuario;
        END

        -- Registrar Sincronización
        INSERT INTO RegistroSincronizacion (IdUsuario, FechaSincronizacion, CantidadRegistros, Estado)
        VALUES (@IdUsuario, SYSDATETIME(), @TotalProcesados, N'Exitoso');

        COMMIT TRANSACTION;

        SELECT 
            N'Sincronización procesada con éxito.' AS Mensaje,
            @TotalProcesados AS IntentosProcesados,
            @RetosNuevosCompletados AS RetosCompletados,
            @PuntosTotalesAcreditados AS PuntosAcreditados,
            @MonedasTotalesAcreditadas AS MonedasAcreditadas
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '=====================================================';
PRINT 'REFACTORIZACIÓN DE BASE DE DATOS COMPLETADA CON ÉXITO';
PRINT '=====================================================';
GO
