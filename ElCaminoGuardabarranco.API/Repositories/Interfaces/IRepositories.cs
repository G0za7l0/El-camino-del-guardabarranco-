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

namespace ElCaminoGuardabarranco.API.Repositories.Interfaces
{
    public interface IUsuarioRepository
    {
        Task<int> RegistrarUsuarioAsync(string alias, string contrasenaHash, string nombreRol, int? idGradoEscolar, DateTime? fechaNacimiento, string? institucion, string? telefono);
        Task<UsuarioLoginDb?> ObtenerPorAliasAsync(string alias);
    }

    public interface IPerfilRepository
    {
        Task<EstudiantePerfilDto?> ObtenerPerfilEstudianteAsync(int idUsuario);
        Task<bool> ActualizarPreferenciasAsync(UpdatePreferenciasRequest request);
    }

    public interface IMapaRepository
    {
        Task<List<DepartamentoDto>> ObtenerDepartamentosAsync(int idUsuario);
        Task<List<MunicipioDto>> ObtenerMunicipiosAsync(int idUsuario, int idDepartamento);
    }

    public interface ICulturaRepository
    {
        Task<List<ContenidoCulturalDto>> ObtenerContenidoPorMunicipioAsync(int idMunicipio);
    }

    public interface IRetosRepository
    {
        Task<List<RetoDto>> ObtenerRetosPorMunicipioAsync(int idMunicipio, int idUsuario, int? idAsignatura = null);
        Task<List<PreguntaDto>> ObtenerPreguntasRetoAsync(int idReto);
    }

    public interface IProgresoRepository
    {
        Task<ResultadoIntentoDto?> RegistrarIntentoAsync(RegistrarIntentoRequest request);
    }

    public interface IGamificacionRepository
    {
        Task<List<InsigniaOtorgadaDto>> EvaluarYOtorgarInsigniasAsync(int idUsuario);
        Task<NivelProgresoDto?> ObtenerNivelUsuarioAsync(int idUsuario);
        Task<List<RankingEstudianteDto>> ObtenerRankingAsync(int top = 20, int? idGrupo = null);
    }

    public interface ITiendaRepository
    {
        Task<List<ItemTiendaDto>> ObtenerItemsAsync(int idUsuario);
        Task<CompraItemResponse?> ComprarItemAsync(int idUsuario, int idItem);
    }

    public interface IAvatarRepository
    {
        Task<List<AvatarDto>> ObtenerAvataresAsync(int idUsuario);
        Task<OperacionAvatarResponse?> ComprarAvatarAsync(int idUsuario, int idAvatar);
        Task<OperacionAvatarResponse?> EquiparAvatarAsync(int idUsuario, int idAvatar);
    }

    public interface IDocenteRepository
    {
        Task<GrupoDocenteDto?> CrearGrupoAsync(CrearGrupoRequest request);
        Task<List<GrupoDocenteDto>> ObtenerGruposAsync(int idDocente);
        Task<bool> AgregarEstudianteGrupoAsync(AgregarEstudianteGrupoRequest request);
        Task<bool> RemoverEstudianteGrupoAsync(int idGrupo, int idEstudiante);
        Task<List<ProgresoGrupoEstudianteDto>> ObtenerProgresoGrupoAsync(int idGrupo);
    }

    public interface IPadreRepository
    {
        Task<List<ProgresoHijoDto>> ObtenerProgresoHijosAsync(int idPadre);
        Task<bool> VincularEstudianteAsync(int idPadre, string aliasEstudiante);
        Task<bool> DesvincularEstudianteAsync(int idPadre, int idEstudiante);
    }

    public interface INotificacionRepository
    {
        Task<List<NotificacionDto>> ObtenerNotificacionesAsync(int idUsuario, bool soloNoLeidas = false);
        Task<int> CrearNotificacionAsync(CrearNotificacionRequest request);
        Task<bool> MarcarLeidaAsync(int idNotificacion);
    }

    public interface ICatalogoRepository
    {
        Task<List<CatalogoItemDto>> ObtenerAsignaturasAsync();
        Task<List<CatalogoItemDto>> ObtenerGradosEscolaresAsync();
        Task<List<CatalogoItemDto>> ObtenerRolesAsync();
    }

    public interface ISyncRepository
    {
        Task<string> ObtenerContenidoActualizadoAsync(DateTime fechaDesde);
        Task<SyncPushResponse?> SubirProgresoOfflineAsync(SyncPushRequest request);
    }
}
