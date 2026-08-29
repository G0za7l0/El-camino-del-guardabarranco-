using System.Data;
using Dapper;
using ElCaminoGuardabarranco.API.Data;
using ElCaminoGuardabarranco.API.DTOs.Auth;
using ElCaminoGuardabarranco.API.DTOs.Avatares;
using ElCaminoGuardabarranco.API.DTOs.Catalogo;
using ElCaminoGuardabarranco.API.DTOs.Cultura;
using ElCaminoGuardabarranco.API.DTOs.Docente;
using ElCaminoGuardabarranco.API.DTOs.Gamificacion;
using ElCaminoGuardabarranco.API.DTOs.Mapa;
using ElCaminoGuardabarranco.API.DTOs.Notificacion;
using ElCaminoGuardabarranco.API.DTOs.Padre;
using ElCaminoGuardabarranco.API.DTOs.Perfil;
using ElCaminoGuardabarranco.API.DTOs.Progreso;
using ElCaminoGuardabarranco.API.DTOs.Retos;
using ElCaminoGuardabarranco.API.DTOs.Sync;
using ElCaminoGuardabarranco.API.DTOs.Tienda;
using ElCaminoGuardabarranco.API.Repositories.Interfaces;

namespace ElCaminoGuardabarranco.API.Repositories.Implementations
{
    public class UsuarioRepository : IUsuarioRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public UsuarioRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<int> RegistrarUsuarioAsync(string alias, string contrasenaHash, string nombreRol, int? idGradoEscolar, DateTime? fechaNacimiento, string? institucion, string? telefono)
        {
            using var db = _dbFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@Alias", alias);
            p.Add("@ContrasenaHash", contrasenaHash);
            p.Add("@NombreRol", nombreRol);
            p.Add("@IdGradoEscolar", idGradoEscolar);
            p.Add("@FechaNacimiento", fechaNacimiento);
            p.Add("@Institucion", institucion);
            p.Add("@Telefono", telefono);
            p.Add("@IdUsuario", dbType: DbType.Int32, direction: ParameterDirection.Output);

            await db.ExecuteAsync("sp_Usuario_Registrar", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@IdUsuario");
        }

        public async Task<UsuarioLoginDb?> ObtenerPorAliasAsync(string alias)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<UsuarioLoginDb>(db, "sp_Usuario_Login", new { Alias = alias });
        }
    }

    public class PerfilRepository : IPerfilRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public PerfilRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<EstudiantePerfilDto?> ObtenerPerfilEstudianteAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<EstudiantePerfilDto>(db, "sp_Estudiante_ObtenerPerfil", new { IdUsuario = idUsuario });
        }

        public async Task<bool> ActualizarPreferenciasAsync(UpdatePreferenciasRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_PreferenciaUsuario_Actualizar", new
            {
                IdUsuario = request.IdUsuario,
                AltoContraste = request.AltoContraste,
                LecturaVozActiva = request.LecturaVozActiva,
                TamanoFuente = request.TamanoFuente
            });
            return !string.IsNullOrWhiteSpace(json);
        }
    }

    public class MapaRepository : IMapaRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public MapaRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<DepartamentoDto>> ObtenerDepartamentosAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<DepartamentoDto>(db, "sp_Mapa_ObtenerDepartamentos", new { IdUsuario = idUsuario });
        }

        public async Task<List<MunicipioDto>> ObtenerMunicipiosAsync(int idUsuario, int idDepartamento)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<MunicipioDto>(db, "sp_Mapa_ObtenerMunicipios", new { IdUsuario = idUsuario, IdDepartamento = idDepartamento });
        }
    }

    public class CulturaRepository : ICulturaRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public CulturaRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<ContenidoCulturalDto>> ObtenerContenidoPorMunicipioAsync(int idMunicipio)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<ContenidoCulturalDto>(db, "sp_ContenidoCultural_ObtenerPorMunicipio", new { IdMunicipio = idMunicipio });
        }
    }

    public class RetosRepository : IRetosRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public RetosRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<RetoDto>> ObtenerRetosPorMunicipioAsync(int idMunicipio, int idUsuario, int? idAsignatura = null)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<RetoDto>(db, "sp_Reto_ObtenerPorMunicipio", new
            {
                IdMunicipio = idMunicipio,
                IdUsuario = idUsuario,
                IdAsignatura = idAsignatura
            });
        }

        public async Task<List<PreguntaDto>> ObtenerPreguntasRetoAsync(int idReto)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<PreguntaDto>(db, "sp_Reto_ObtenerPreguntas", new { IdReto = idReto });
        }
    }

    public class ProgresoRepository : IProgresoRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public ProgresoRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<ResultadoIntentoDto?> RegistrarIntentoAsync(RegistrarIntentoRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<ResultadoIntentoDto>(db, "sp_Progreso_RegistrarIntento", new
            {
                IdUsuario = request.IdUsuario,
                IdReto = request.IdReto,
                IdPregunta = request.IdPregunta,
                IdOpcionSeleccionada = request.IdOpcionSeleccionada,
                TiempoRespuestaSegundos = request.TiempoRespuestaSegundos,
                IdDispositivoOrigen = request.IdDispositivoOrigen
            });
        }
    }

    public class GamificacionRepository : IGamificacionRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public GamificacionRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<InsigniaOtorgadaDto>> EvaluarYOtorgarInsigniasAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<InsigniaOtorgadaDto>(db, "sp_Insignia_EvaluarYOtorgar", new { IdUsuario = idUsuario });
        }

        public async Task<NivelProgresoDto?> ObtenerNivelUsuarioAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<NivelProgresoDto>(db, "sp_Nivel_ObtenerPorUsuario", new { IdUsuario = idUsuario });
        }

        public async Task<List<RankingEstudianteDto>> ObtenerRankingAsync(int top = 20, int? idGrupo = null)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<RankingEstudianteDto>(db, "sp_Gamificacion_ObtenerRanking", new { Top = top, IdGrupo = idGrupo });
        }
    }

    public class TiendaRepository : ITiendaRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public TiendaRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<ItemTiendaDto>> ObtenerItemsAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<ItemTiendaDto>(db, "sp_Tienda_ObtenerItems", new { IdUsuario = idUsuario });
        }

        public async Task<CompraItemResponse?> ComprarItemAsync(int idUsuario, int idItem)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<CompraItemResponse>(db, "sp_Tienda_ComprarItem", new { IdUsuario = idUsuario, IdItem = idItem });
        }
    }

    public class AvatarRepository : IAvatarRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public AvatarRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<AvatarDto>> ObtenerAvataresAsync(int idUsuario)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<AvatarDto>(db, "sp_Avatar_ObtenerTodos", new { IdUsuario = idUsuario });
        }

        public async Task<OperacionAvatarResponse?> ComprarAvatarAsync(int idUsuario, int idAvatar)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<OperacionAvatarResponse>(db, "sp_Avatar_Comprar", new { IdUsuario = idUsuario, IdAvatar = idAvatar });
        }

        public async Task<OperacionAvatarResponse?> EquiparAvatarAsync(int idUsuario, int idAvatar)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonSingleAsync<OperacionAvatarResponse>(db, "sp_Avatar_Equipar", new { IdUsuario = idUsuario, IdAvatar = idAvatar });
        }
    }

    public class DocenteRepository : IDocenteRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public DocenteRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<GrupoDocenteDto?> CrearGrupoAsync(CrearGrupoRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@IdDocente", request.IdDocente);
            p.Add("@Nombre", request.Nombre);
            p.Add("@IdGradoEscolar", request.IdGradoEscolar);
            p.Add("@CodigoAcceso", request.CodigoAcceso);
            p.Add("@IdGrupo", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Docente_CrearGrupo", p);
            if (string.IsNullOrWhiteSpace(json)) return null;

            return System.Text.Json.JsonSerializer.Deserialize<GrupoDocenteDto>(json, SqlHelper.JsonOptions);
        }

        public async Task<List<GrupoDocenteDto>> ObtenerGruposAsync(int idDocente)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<GrupoDocenteDto>(db, "sp_Docente_ObtenerGrupos", new { IdDocente = idDocente });
        }

        public async Task<bool> AgregarEstudianteGrupoAsync(AgregarEstudianteGrupoRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Docente_AgregarEstudianteGrupo", new
            {
                IdGrupo = request.IdGrupo,
                AliasEstudiante = request.AliasEstudiante,
                CodigoAcceso = request.CodigoAcceso,
                IdEstudiante = request.IdEstudiante
            });
            return !string.IsNullOrWhiteSpace(json);
        }

        public async Task<bool> RemoverEstudianteGrupoAsync(int idGrupo, int idEstudiante)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Docente_RemoverEstudianteGrupo", new { IdGrupo = idGrupo, IdEstudiante = idEstudiante });
            return !string.IsNullOrWhiteSpace(json);
        }

        public async Task<List<ProgresoGrupoEstudianteDto>> ObtenerProgresoGrupoAsync(int idGrupo)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<ProgresoGrupoEstudianteDto>(db, "sp_Docente_ObtenerProgresoGrupo", new { IdGrupo = idGrupo });
        }
    }

    public class PadreRepository : IPadreRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public PadreRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<ProgresoHijoDto>> ObtenerProgresoHijosAsync(int idPadre)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<ProgresoHijoDto>(db, "sp_Padre_ObtenerProgresoHijos", new { IdUsuario = idPadre });
        }

        public async Task<bool> VincularEstudianteAsync(int idPadre, string aliasEstudiante)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Padre_VincularEstudiante", new { IdPadre = idPadre, AliasEstudiante = aliasEstudiante });
            return !string.IsNullOrWhiteSpace(json);
        }

        public async Task<bool> DesvincularEstudianteAsync(int idPadre, int idEstudiante)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Padre_DesvincularEstudiante", new { IdPadre = idPadre, IdEstudiante = idEstudiante });
            return !string.IsNullOrWhiteSpace(json);
        }
    }

    public class NotificacionRepository : INotificacionRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public NotificacionRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<NotificacionDto>> ObtenerNotificacionesAsync(int idUsuario, bool soloNoLeidas = false)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonListAsync<NotificacionDto>(db, "sp_Notificacion_ObtenerPorUsuario", new { IdUsuario = idUsuario, SoloNoLeidas = soloNoLeidas });
        }

        public async Task<int> CrearNotificacionAsync(CrearNotificacionRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@IdUsuarioDestino", request.IdUsuarioDestino);
            p.Add("@Tipo", request.Tipo);
            p.Add("@Mensaje", request.Mensaje);

            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Notificacion_Crear", p);
            if (string.IsNullOrWhiteSpace(json)) return 0;

            using var doc = System.Text.Json.JsonDocument.Parse(json);
            if (doc.RootElement.TryGetProperty("IdNotificacion", out var idProp))
                return idProp.GetInt32();

            return 0;
        }

        public async Task<bool> MarcarLeidaAsync(int idNotificacion)
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Notificacion_MarcarLeida", new { IdNotificacion = idNotificacion });
            return !string.IsNullOrWhiteSpace(json);
        }
    }

    public class CatalogoRepository : ICatalogoRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public CatalogoRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<List<CatalogoItemDto>> ObtenerAsignaturasAsync()
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Catalogo_ObtenerAsignaturas");
            if (string.IsNullOrWhiteSpace(json)) return new List<CatalogoItemDto>();

            using var doc = System.Text.Json.JsonDocument.Parse(json);
            var list = new List<CatalogoItemDto>();
            foreach (var el in doc.RootElement.EnumerateArray())
            {
                list.Add(new CatalogoItemDto
                {
                    Id = el.GetProperty("IdAsignatura").GetInt32(),
                    Nombre = el.GetProperty("Nombre").GetString() ?? "",
                    Activo = el.GetProperty("Activo").GetBoolean()
                });
            }
            return list;
        }

        public async Task<List<CatalogoItemDto>> ObtenerGradosEscolaresAsync()
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Catalogo_ObtenerGradosEscolares");
            if (string.IsNullOrWhiteSpace(json)) return new List<CatalogoItemDto>();

            using var doc = System.Text.Json.JsonDocument.Parse(json);
            var list = new List<CatalogoItemDto>();
            foreach (var el in doc.RootElement.EnumerateArray())
            {
                list.Add(new CatalogoItemDto
                {
                    Id = el.GetProperty("IdGradoEscolar").GetInt32(),
                    Nombre = el.GetProperty("Nombre").GetString() ?? ""
                });
            }
            return list;
        }

        public async Task<List<CatalogoItemDto>> ObtenerRolesAsync()
        {
            using var db = _dbFactory.CreateConnection();
            var json = await SqlHelper.QueryJsonRawAsync(db, "sp_Catalogo_ObtenerRoles");
            if (string.IsNullOrWhiteSpace(json)) return new List<CatalogoItemDto>();

            using var doc = System.Text.Json.JsonDocument.Parse(json);
            var list = new List<CatalogoItemDto>();
            foreach (var el in doc.RootElement.EnumerateArray())
            {
                list.Add(new CatalogoItemDto
                {
                    Id = el.GetProperty("IdRol").GetInt32(),
                    Nombre = el.GetProperty("Nombre").GetString() ?? ""
                });
            }
            return list;
        }
    }

    public class SyncRepository : ISyncRepository
    {
        private readonly IDbConnectionFactory _dbFactory;

        public SyncRepository(IDbConnectionFactory dbFactory)
        {
            _dbFactory = dbFactory;
        }

        public async Task<string> ObtenerContenidoActualizadoAsync(DateTime fechaDesde)
        {
            using var db = _dbFactory.CreateConnection();
            return await SqlHelper.QueryJsonRawAsync(db, "sp_Sync_ObtenerContenidoActualizado", new { FechaDesde = fechaDesde });
        }

        public async Task<SyncPushResponse?> SubirProgresoOfflineAsync(SyncPushRequest request)
        {
            using var db = _dbFactory.CreateConnection();
            var jsonIntentos = System.Text.Json.JsonSerializer.Serialize(request.Intentos);
            return await SqlHelper.QueryJsonSingleAsync<SyncPushResponse>(db, "sp_Sync_SubirProgresoOffline", new
            {
                IdUsuario = request.IdUsuario,
                JsonIntentos = jsonIntentos,
                IdDispositivoOrigen = request.IdDispositivoOrigen
            });
        }
    }
}
