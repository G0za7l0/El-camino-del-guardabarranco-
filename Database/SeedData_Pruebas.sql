USE [ElCaminoDelGuardabarranco]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON
GO
SET XACT_ABORT ON
GO

BEGIN TRANSACTION

-- 1. LIMPIEZA DE DATOS PREVIOS EN ORDEN DE DEPENDENCIAS FK
DELETE FROM HistorialIntento
DELETE FROM ProgresoAcademico
DELETE FROM Notificacion
DELETE FROM UsuarioAvatar
DELETE FROM CompraUsuario
DELETE FROM UsuarioInsignia
DELETE FROM GrupoEstudiante
DELETE FROM PadreEstudiante
DELETE FROM Grupo
DELETE FROM Billetera
DELETE FROM PreferenciaUsuario
DELETE FROM Docente
DELETE FROM PadreTutor
DELETE FROM Estudiante
DELETE FROM Usuario WHERE Alias NOT IN ('admin')

DELETE FROM OpcionRespuesta
DELETE FROM Pregunta
DELETE FROM Reto
DELETE FROM ContenidoCultural
DELETE FROM ItemTienda
DELETE FROM Avatar
DELETE FROM Insignia
DELETE FROM Nivel
DELETE FROM Multimedia
DELETE FROM Municipio

-- 2. RECURSOS MULTIMEDIA
SET IDENTITY_INSERT Multimedia ON

INSERT INTO Multimedia (IdMultimedia, Url, TipoArchivo, TextoAlternativo) VALUES
(1, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/guardabarranco_explorador.png', N'image/png', N'Guardabarranco con sombrero de explorador y mapa'),
(2, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/gueguense_ilustre.png', N'image/png', N'Personaje tradicional del Güegüense con máscara festiva'),
(3, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/xolo_guardian.png', N'image/png', N'Perro Xoloitzcuintle con collar de flores de Sacuanjoche'),
(4, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/princesa_zulema.png', N'image/png', N'Princesa indígena de la leyenda de Tiscapa'),
(5, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/avatares/cacique_diriangen.png', N'image/png', N'Guerrero Cacique Diriangén con lanza y penacho de plumas'),
(6, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/semilla_germinada.png', N'image/png', N'Semilla germinando en tierra nicaragüense'),
(7, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/guardian_managua.png', N'image/png', N'Escudo protector con el lago de Managua'),
(8, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/maestro_gueguense.png', N'image/png', N'Máscara dorada del Güegüense'),
(9, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/gran_guardian_nacional.png', N'image/png', N'Guardabarranco dorado sobrevolando los lagos y volcanes'),
(10, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/insignias/racha_imparable.png', N'image/png', N'Llama ardiente con escudo azul y blanco'),
(11, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/tienda/sombrero_pita.png', N'image/png', N'Sombrero tradicional tejido de pita'),
(12, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/tienda/cinta_patria.png', N'image/png', N'Cinta con los colores nacionales'),
(13, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/tienda/pocion_pistas.png', N'image/png', N'Frasco de elixir con pistas mágicas'),
(14, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/tienda/fondo_volcan_masaya.png', N'image/png', N'Cráter Santiago iluminado por la lava'),
(15, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/cultura/el_gueguense.png', N'image/png', N'Representación teatral folclórica en Diriamba'),
(16, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/cultura/aguizotes_masaya.png', N'image/png', N'Procesión nocturna de mitos y leyendas'),
(17, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/cultura/laguna_tiscapa.png', N'image/png', N'Laguna volcánica en el centro histórico de Managua'),
(18, N'https://cdn.elcaminodelguardabarranco.edu.ni/img/cultura/ruben_dario.png', N'image/png', N'Príncipe de las Letras Castellanas en León')

SET IDENTITY_INSERT Multimedia OFF

-- 3. NIVELES DE PROGRESIÓN (GAMIFICACIÓN)
SET IDENTITY_INSERT Nivel ON

INSERT INTO Nivel (IdNivel, Numero, Titulo, PuntosRequeridos, MonedasRecompensa, IdMultimedia) VALUES
(1, 1, N'Chavalito Explorador', 0, 10, 1),
(2, 2, N'Caminante del Güegüense', 150, 25, 2),
(3, 3, N'Guardián de Lagos y Volcanes', 350, 50, 3),
(4, 4, N'Centinela del Sacuanjoche', 650, 75, 4),
(5, 5, N'Gran Guardián Nacional', 1000, 150, 5)

SET IDENTITY_INSERT Nivel OFF

-- 4. AVATARES DE LA TIENDA Y RECOMPENSAS
SET IDENTITY_INSERT Avatar ON

INSERT INTO Avatar (IdAvatar, Nombre, CostoMonedas, IdMultimedia, Activo) VALUES
(1, N'Guardabarranco Clásico', 0, 1, 1),
(2, N'Güegüense de Fiesta', 50, 2, 1),
(3, N'Xoloitzcuintle Sabio', 80, 3, 1),
(4, N'Princesa de Tiscapa', 120, 4, 1),
(5, N'Cacique Diriangén', 200, 5, 1)

SET IDENTITY_INSERT Avatar OFF

-- 5. ARTÍCULOS DE LA TIENDA
SET IDENTITY_INSERT ItemTienda ON

INSERT INTO ItemTienda (IdItem, Nombre, Descripcion, Categoria, CostoMonedas, IdMultimedia, Activo) VALUES
(1, N'Sombrero de Pita Tradicional', N'Elegante sombrero típico de Camoapa y Monimbó.', N'Accesorio', 25, 11, 1),
(2, N'Cinta Patria Azul y Blanco', N'Cinta honorífica para tu avatar.', N'Accesorio', 30, 12, 1),
(3, N'Poción de Pista Extra (Pack x3)', N'Revela una pista durante los retos de Matemática y Lengua.', N'Potenciador', 15, 13, 1),
(4, N'Fondo Volcán Masaya', N'Fondo interactivo de perfil con la lava del Volcán Masaya.', N'Fondo', 60, 14, 1)

SET IDENTITY_INSERT ItemTienda OFF

-- 6. INSIGNIAS DEL JUEGO
SET IDENTITY_INSERT Insignia ON

INSERT INTO Insignia (IdInsignia, Nombre, Descripcion, IdMultimedia) VALUES
(1, N'Semilla Germinada', N'Completaste tu primer reto. ¡El camino ha comenzado!', 6),
(2, N'Guardián de Managua', N'Superaste todos los retos pedagógicos del departamento de Managua.', 7),
(3, N'Maestro del Güegüense', N'Alcanzaste una racha de 5 días de estudio consecutivos.', 8),
(4, N'Gran Guardián Nacional', N'Alcanzaste el Nivel 5 completando el mapa de Nicaragua.', 9),
(5, N'Cerebro Matemático', N'Respondiste correctamente 10 retos de Matemática sin fallar.', 10)

SET IDENTITY_INSERT Insignia OFF

-- 7. ACTUALIZACIÓN DE COORDENADAS GPS EN DEPARTAMENTOS
UPDATE Departamento SET Latitud = 12.136389, Longitud = -86.251389 WHERE IdDepartamento = 1
UPDATE Departamento SET Latitud = 11.974444, Longitud = -86.094167 WHERE IdDepartamento = 2
UPDATE Departamento SET Latitud = 11.929880, Longitud = -85.956020 WHERE IdDepartamento = 3
UPDATE Departamento SET Latitud = 11.854000, Longitud = -86.199000 WHERE IdDepartamento = 4
UPDATE Departamento SET Latitud = 11.437160, Longitud = -85.826320 WHERE IdDepartamento = 5
UPDATE Departamento SET Latitud = 12.437870, Longitud = -86.878040 WHERE IdDepartamento = 6
UPDATE Departamento SET Latitud = 12.629370, Longitud = -87.131050 WHERE IdDepartamento = 7
UPDATE Departamento SET Latitud = 13.091850, Longitud = -86.353840 WHERE IdDepartamento = 8
UPDATE Departamento SET Latitud = 13.484340, Longitud = -86.582080 WHERE IdDepartamento = 9
UPDATE Departamento SET Latitud = 13.633890, Longitud = -86.475280 WHERE IdDepartamento = 10
UPDATE Departamento SET Latitud = 13.092000, Longitud = -85.998000 WHERE IdDepartamento = 11
UPDATE Departamento SET Latitud = 12.925590, Longitud = -85.917470 WHERE IdDepartamento = 12
UPDATE Departamento SET Latitud = 12.043800, Longitud = -85.403200 WHERE IdDepartamento = 13
UPDATE Departamento SET Latitud = 12.188900, Longitud = -85.127000 WHERE IdDepartamento = 14
UPDATE Departamento SET Latitud = 11.130833, Longitud = -84.777778 WHERE IdDepartamento = 15
UPDATE Departamento SET Latitud = 14.030000, Longitud = -83.380000 WHERE IdDepartamento = 16
UPDATE Departamento SET Latitud = 12.013000, Longitud = -83.764000 WHERE IdDepartamento = 17

-- 8. MUNICIPIOS DE NICARAGUA
SET IDENTITY_INSERT Municipio ON

INSERT INTO Municipio (IdMunicipio, IdDepartamento, Nombre, Latitud, Longitud) VALUES
(1, 1, N'Managua (Capital)', 12.136389, -86.251389),
(2, 1, N'Tipitapa', 12.197778, -86.096389),
(3, 1, N'Ciudad Sandino', 12.158333, -86.344444),
(4, 1, N'Mateare', 12.235556, -86.428611),
(5, 2, N'Masaya', 11.974444, -86.094167),
(6, 2, N'Catarina', 11.913056, -86.074722),
(7, 2, N'Niquinohomo', 11.905556, -86.095000),
(8, 2, N'Nindirí', 12.004167, -86.121667),
(9, 3, N'Granada', 11.929880, -85.956020),
(10, 3, N'Nandaime', 11.757778, -85.826320),
(11, 3, N'Diriomo', 11.875556, -86.051944),
(12, 6, N'León', 12.437870, -86.878040),
(13, 6, N'Nagarote', 12.266389, -86.564722),
(14, 12, N'Matagalpa', 12.925590, -85.917470),
(15, 12, N'Sébaco', 12.855000, -86.096667),
(16, 15, N'San Carlos', 11.130833, -84.777778),
(17, 15, N'El Castillo', 11.018611, -84.398611)

SET IDENTITY_INSERT Municipio OFF

-- 9. CONTENIDO CULTURAL
SET IDENTITY_INSERT ContenidoCultural ON

INSERT INTO ContenidoCultural (IdContenido, IdMunicipio, IdTipoContenidoCultural, Titulo, Descripcion, IdMultimedia) VALUES
(1, 1, 4, N'La Leyenda de la Mocuana en Managua', N'Relato tradicional sobre una princesa indígena cuyo espíritu vaga por los senderos y quebradas de Managua.', 17),
(2, 1, 1, N'El Centro Histórico y la Plaza de la Revolución', N'Corazón histórico de Nicaragua, rodeado por la antigua Catedral, el Palacio Nacional de la Cultura y el Teatro Rubén Darío.', 17),
(3, 5, 4, N'El Güegüense: Patrimonio de la Humanidad', N'Comedia bailete satírica prehispánica y colonial, primera obra teatral de la literatura nicaragüense reconocida por la UNESCO.', 15),
(4, 5, 4, N'La Fiesta de los Agüizotes en Monimbó', N'Celebración nocturna donde los habitantes se disfrazan de personajes de mitos nicaragüenses como La Cegua, El Cadejo y La Carreta Nagua.', 16),
(5, 12, 1, N'León: Cuna de Rubén Darío', N'Ciudad universitaria donde vivió y descansan los restos del insigne poeta universal Félix Rubén García Sarmiento (Rubén Darío).', 18)

SET IDENTITY_INSERT ContenidoCultural OFF

-- 10. RETOS PEDAGÓGICOS (4TO A 6TO GRADO)
SET IDENTITY_INSERT Reto ON

INSERT INTO Reto (IdReto, IdMunicipio, IdAsignatura, IdTipoReto, IdDificultad, Descripcion, PuntosOtorgados, MonedasOtorgadas, Orden, Activo) VALUES
(1, 1, 1, 1, 1, N'Fracciones con Frutas Nicas en el Oriental', 50, 15, 1, 1),
(2, 1, 2, 1, 1, N'Poemas de Rubén Darío en Tiscapa', 50, 15, 2, 1),
(3, 5, 4, 2, 2, N'Volcanes y Lagunas de Masaya', 60, 20, 1, 1),
(4, 5, 3, 1, 2, N'English Wildlife in Masaya', 60, 20, 2, 1),
(5, 9, 4, 1, 2, N'Geografía del Gran Lago Cocibolca e Isletas', 70, 25, 1, 1),
(6, 12, 2, 1, 3, N'Acentuación y Rima en León', 80, 30, 1, 1)

SET IDENTITY_INSERT Reto OFF

-- 11. PREGUNTAS Y RETROALIMENTACIÓN PEDAGÓGICA
SET IDENTITY_INSERT Pregunta ON

INSERT INTO Pregunta (IdPregunta, IdReto, Enunciado, Retroalimentacion, Orden) VALUES
(1, 1, N'Si en un canasto hay 20 pitahayas y doña Juana vende 1/4 de ellas, ¿cuántas pitahayas vendió?', N'Para calcular 1/4 de 20, dividimos 20 entre 4 = 5 pitahayas.', 1),
(2, 1, N'¿Cuánto resulta sumar 2/5 + 1/5 de un atol de maíz?', N'Al tener el mismo denominador (5), solo sumamos los numeradores: 2 + 1 = 3/5.', 2),
(3, 2, N'¿En qué famoso poema Darío escribió: "Margarita está linda la mar, y el viento lleva esencia sutil de azahar"?', N'El poema "A Margarita Debayle" fue escrito por Rubén Darío en la Isla del Cardón, Corinto.', 1),
(4, 2, N'¿Qué tipo de palabra según su acento es "Guardabarranco"?', N'La mayor fuerza de voz está en la penúltima sílaba (rran), por tanto es palabra Grave o Llana.', 2),
(5, 3, N'El Volcán Masaya es un volcán activo que cuenta con un lago de lava en el Cráter Santiago.', N'¡Verdadero! Es uno de los pocos volcanes en el mundo con lago de lava activo y accesible.', 1),
(6, 3, N'La Flor Nacional de Nicaragua es la Rosa.', N'¡Falso! La flor nacional es el Sacuanjoche (Plumeria rubra).', 2),
(7, 4, N'How do you say "ave nacional" in English?', N'"National bird" significa ave nacional (como nuestro Guardabarranco).', 1),
(8, 4, N'Which animal swims in the Great Lake of Nicaragua?', N'The Bull Shark (Tiburón Toro) is famous for swimming in Lake Cocibolca.', 2),
(9, 5, N'¿Cuál es la isla más grande del mundo situada dentro de un lago de agua dulce con dos volcanes?', N'La Isla de Ometepe está en el Lago Cocibolca y alberga los volcanes Concepción y Maderas.', 1)

SET IDENTITY_INSERT Pregunta OFF

-- 12. OPCIONES DE RESPUESTA
SET IDENTITY_INSERT OpcionRespuesta ON

INSERT INTO OpcionRespuesta (IdOpcion, IdPregunta, Texto, EsCorrecta) VALUES
(33, 1, N'5 pitahayas', 1),
(34, 1, N'4 pitahayas', 0),
(35, 1, N'10 pitahayas', 0),
(36, 1, N'2 pitahayas', 0),
(37, 2, N'3/5', 1),
(38, 2, N'3/10', 0),
(39, 2, N'2/10', 0),
(40, 2, N'1/5', 0),
(41, 3, N'A Margarita Debayle', 1),
(42, 3, N'Sonatina', 0),
(43, 3, N'Caupolicán', 0),
(44, 3, N'Marcha Triunfal', 0),
(45, 4, N'Grave o Llana', 1),
(46, 4, N'Aguda', 0),
(47, 4, N'Esdrújula', 0),
(48, 4, N'Sobreesdrújula', 0),
(49, 5, N'Verdadero', 1),
(50, 5, N'Falso', 0),
(51, 6, N'Falso', 1),
(52, 6, N'Verdadero', 0),
(53, 7, N'National bird', 1),
(54, 7, N'National tree', 0),
(55, 7, N'National flower', 0),
(56, 7, N'Wild eagle', 0),
(57, 8, N'Freshwater Bull Shark (Tiburón Toro)', 1),
(58, 8, N'Polar Bear', 0),
(59, 8, N'Dolphin of the Arctic', 0),
(60, 8, N'Sea Lion', 0),
(61, 9, N'Isla de Ometepe', 1),
(62, 9, N'Isla de Zapatera', 0),
(63, 9, N'Isla de Solentiname', 0),
(64, 9, N'Isla de Maíz', 0)

SET IDENTITY_INSERT OpcionRespuesta OFF

-- 13. USUARIOS DEL SISTEMA CON CONTRASEÑA BCRYPT
DECLARE @BcryptPass NVARCHAR(255) = N'$2a$11$wK1GvQ3eR5Lz.UoY3P4L1uTq1qL4YpU0R7E6N0S7Z9E8N0S7Z9E8N' -- Seguridad123!

SET IDENTITY_INSERT Usuario ON

INSERT INTO Usuario (IdUsuario, IdRol, Alias, ContrasenaHash, Activo) VALUES
(2, 2, N'profesor_carlos', @BcryptPass, 1),
(3, 3, N'padre_roberto', @BcryptPass, 1),
(4, 3, N'madre_elena', @BcryptPass, 1),
(5, 1, N'josue_guardabarranco', @BcryptPass, 1),
(6, 1, N'maria_masaya', @BcryptPass, 1),
(7, 1, N'pedro_granada', @BcryptPass, 1),
(8, 1, N'ana_leon', @BcryptPass, 1)

SET IDENTITY_INSERT Usuario OFF

-- 14. PERFILES ESPECÍFICOS
INSERT INTO Docente (IdUsuario, Institucion) VALUES
(2, N'Colegio Público República de Cuba, Managua')

INSERT INTO PadreTutor (IdUsuario, Telefono) VALUES
(3, N'+505 8888-1234'),
(4, N'+505 8777-5678')

INSERT INTO Estudiante (IdUsuario, IdGradoEscolar, FechaNacimiento) VALUES
(5, 1, '2016-05-14'),
(6, 1, '2016-09-20'),
(7, 2, '2015-03-11'),
(8, 3, '2014-11-05')

-- 15. BILLETERA, PREFERENCIAS Y VINCULACIONES
INSERT INTO Billetera (IdUsuario, PuntosAcumulados, MonedasVirtuales, RachaActualDias, MejorRachaDias, UltimaFechaActividad) VALUES
(5, 480, 95, 5, 8, GETDATE()),
(6, 320, 60, 3, 5, GETDATE()),
(7, 510, 110, 7, 7, GETDATE()),
(8, 150, 25, 1, 2, GETDATE())

INSERT INTO PreferenciaUsuario (IdUsuario, AltoContraste, LecturaVozActiva, TamanoFuente) VALUES
(5, 0, 0, 2),
(6, 1, 0, 3),
(7, 0, 1, 2),
(8, 0, 0, 2)

INSERT INTO PadreEstudiante (IdPadre, IdEstudiante) VALUES
(3, 5),
(3, 6),
(4, 7)

-- 16. GRUPOS ESCOLARES (AULAS)
SET IDENTITY_INSERT Grupo ON

INSERT INTO Grupo (IdGrupo, IdDocente, Nombre, IdGradoEscolar, CodigoAcceso) VALUES
(1, 2, N'4to Grado A - Los Guardabarrancos', 1, N'4TOA-GUA'),
(2, 2, N'5to Grado B - Los Güegüenses', 2, N'5TOB-GUE')

SET IDENTITY_INSERT Grupo OFF

INSERT INTO GrupoEstudiante (IdGrupo, IdEstudiante) VALUES
(1, 5),
(1, 6),
(2, 7)

-- 17. AVATARES Y ARTÍCULOS ADQUIRIDOS
INSERT INTO UsuarioAvatar (IdUsuario, IdAvatar, Equipado) VALUES
(5, 1, 1),
(5, 2, 0),
(6, 1, 1),
(7, 3, 1),
(8, 1, 1)

INSERT INTO CompraUsuario (IdUsuario, IdItem) VALUES
(5, 1),
(5, 3),
(7, 4)

-- 18. LOGROS E INSIGNIAS
INSERT INTO UsuarioInsignia (IdUsuario, IdInsignia, FechaObtencion) VALUES
(5, 1, '2026-07-15'),
(5, 2, '2026-08-01'),
(6, 1, '2026-07-20'),
(7, 1, '2026-07-10'),
(7, 3, '2026-08-12')

-- 19. HISTORIAL DE INTENTOS Y RETOS COMPLETADOS
INSERT INTO HistorialIntento (IdUsuario, IdReto, IdPregunta, IdOpcionSeleccionada, EsCorrecta, TiempoRespuestaSegundos, IdDispositivoOrigen) VALUES
(5, 1, 1, 33, 1, 4, N'Android-Tablet-Colegio'),
(5, 1, 2, 37, 1, 5, N'Android-Tablet-Colegio'),
(5, 2, 3, 41, 1, 6, N'Android-Tablet-Colegio'),
(5, 2, 4, 45, 1, 3, N'Android-Tablet-Colegio'),
(5, 3, 5, 49, 1, 4, N'Android-Tablet-Colegio'),
(6, 1, 1, 33, 1, 8, N'Android-Phone-Casa'),
(6, 1, 2, 37, 1, 7, N'Android-Phone-Casa'),
(7, 1, 1, 33, 1, 5, N'Android-Tablet-Casa'),
(7, 1, 2, 37, 1, 6, N'Android-Tablet-Casa'),
(7, 5, 9, 61, 1, 4, N'Android-Tablet-Casa')

-- 20. NOTIFICACIONES INICIALES
INSERT INTO Notificacion (IdUsuarioDestino, Tipo, Mensaje, Leida, FechaCreacion) VALUES
(5, N'Logro', N'¡Felicidades Josué! Has desbloqueado la insignia: Guardián de Managua.', 0, DATEADD(DAY, -2, GETDATE())),
(5, N'Racha', N'¡Llevas 5 días consecutivos de estudio! Sigue así para ganar el sombrero de pita.', 0, DATEADD(DAY, -1, GETDATE())),
(6, N'Docente', N'El Profesor Carlos ha asignado un nuevo reto de lectura para el aula 4to A.', 1, DATEADD(DAY, -3, GETDATE())),
(2, N'Reporte', N'2 estudiantes de tu grupo 4to A han completado los retos de la semana.', 0, GETDATE())

COMMIT TRANSACTION
