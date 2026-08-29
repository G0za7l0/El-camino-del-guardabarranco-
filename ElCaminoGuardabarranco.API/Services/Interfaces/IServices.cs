using ElCaminoGuardabarranco.API.DTOs.Auth;
using ElCaminoGuardabarranco.API.DTOs.Avatares;
using ElCaminoGuardabarranco.API.DTOs.Catalogo;
using ElCaminoGuardabarranco.API.DTOs.Common;
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

namespace ElCaminoGuardabarranco.API.Services.Interfaces
{
    public interface IAuthService
    {
        Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
        Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
    }

    public interface IPerfilService
    {
        Task<ApiResponse<EstudiantePerfilDto>> ObtenerPerfilEstudianteAsync(int idUsuario);
        Task<ApiResponse<bool>> ActualizarPreferenciasAsync(UpdatePreferenciasRequest request);
    }

    public interface IMapaService
    {
        Task<ApiResponse<List<DepartamentoDto>>> ObtenerDepartamentosAsync(int idUsuario);
        Task<ApiResponse<List<MunicipioDto>>> ObtenerMunicipiosAsync(int idUsuario, int idDepartamento);
    }

    public interface ICulturaService
    {
        Task<ApiResponse<List<ContenidoCulturalDto>>> ObtenerContenidoPorMunicipioAsync(int idMunicipio);
    }

    public interface IRetosService
    {
        Task<ApiResponse<List<RetoDto>>> ObtenerRetosPorMunicipioAsync(int idMunicipio, int idUsuario, int? idAsignatura = null);
        Task<ApiResponse<List<PreguntaDto>>> ObtenerPreguntasRetoAsync(int idReto);
    }

    public interface IProgresoService
    {
        Task<ApiResponse<ResultadoIntentoDto>> RegistrarIntentoAsync(RegistrarIntentoRequest request);
    }

    public interface IGamificacionService
    {
        Task<ApiResponse<List<InsigniaOtorgadaDto>>> EvaluarYOtorgarInsigniasAsync(int idUsuario);
        Task<ApiResponse<NivelProgresoDto>> ObtenerNivelUsuarioAsync(int idUsuario);
        Task<ApiResponse<List<RankingEstudianteDto>>> ObtenerRankingAsync(int top = 20, int? idGrupo = null);
    }

    public interface ITiendaService
    {
        Task<ApiResponse<List<ItemTiendaDto>>> ObtenerItemsAsync(int idUsuario);
        Task<ApiResponse<CompraItemResponse>> ComprarItemAsync(ComprarItemRequest request);
    }

    public interface IAvatarService
    {
        Task<ApiResponse<List<AvatarDto>>> ObtenerAvataresAsync(int idUsuario);
        Task<ApiResponse<OperacionAvatarResponse>> ComprarAvatarAsync(ComprarAvatarRequest request);
        Task<ApiResponse<OperacionAvatarResponse>> EquiparAvatarAsync(EquiparAvatarRequest request);
    }

    public interface IDocenteService
    {
        Task<ApiResponse<GrupoDocenteDto>> CrearGrupoAsync(CrearGrupoRequest request);
        Task<ApiResponse<List<GrupoDocenteDto>>> ObtenerGruposAsync(int idDocente);
        Task<ApiResponse<bool>> AgregarEstudianteGrupoAsync(AgregarEstudianteGrupoRequest request);
        Task<ApiResponse<bool>> RemoverEstudianteGrupoAsync(int idGrupo, int idEstudiante);
        Task<ApiResponse<List<ProgresoGrupoEstudianteDto>>> ObtenerProgresoGrupoAsync(int idGrupo);
    }

    public interface IPadreService
    {
        Task<ApiResponse<List<ProgresoHijoDto>>> ObtenerProgresoHijosAsync(int idPadre);
        Task<ApiResponse<bool>> VincularEstudianteAsync(VincularEstudianteRequest request);
        Task<ApiResponse<bool>> DesvincularEstudianteAsync(int idPadre, int idEstudiante);
    }

    public interface INotificacionService
    {
        Task<ApiResponse<List<NotificacionDto>>> ObtenerNotificacionesAsync(int idUsuario, bool soloNoLeidas = false);
        Task<ApiResponse<int>> CrearNotificacionAsync(CrearNotificacionRequest request);
        Task<ApiResponse<bool>> MarcarLeidaAsync(int idNotificacion);
    }

    public interface ICatalogoService
    {
        Task<ApiResponse<List<CatalogoItemDto>>> ObtenerAsignaturasAsync();
        Task<ApiResponse<List<CatalogoItemDto>>> ObtenerGradosEscolaresAsync();
        Task<ApiResponse<List<CatalogoItemDto>>> ObtenerRolesAsync();
    }

    public interface ISyncService
    {
        Task<string> ObtenerContenidoActualizadoAsync(DateTime fechaDesde);
        Task<ApiResponse<SyncPushResponse>> SubirProgresoOfflineAsync(SyncPushRequest request);
    }
}
