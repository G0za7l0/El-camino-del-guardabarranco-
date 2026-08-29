using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCrypt.Net;
using ElCaminoGuardabarranco.API.Configuration;
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
using ElCaminoGuardabarranco.API.Repositories.Interfaces;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace ElCaminoGuardabarranco.API.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly IUsuarioRepository _usuarioRepo;
        private readonly JwtSettings _jwtSettings;

        public AuthService(IUsuarioRepository usuarioRepo, IOptions<JwtSettings> jwtSettings)
        {
            _usuarioRepo = usuarioRepo;
            _jwtSettings = jwtSettings.Value;
        }

        public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
        {
            var validRoles = new[] { "Estudiante", "Docente", "PadreTutor", "Administrador" };
            if (!validRoles.Contains(request.NombreRol, StringComparer.OrdinalIgnoreCase))
            {
                return ApiResponse<AuthResponse>.Fail($"El rol '{request.NombreRol}' no es válido. Roles permitidos: Estudiante, Docente, PadreTutor.");
            }

            if (request.NombreRol.Equals("Estudiante", StringComparison.OrdinalIgnoreCase) && !request.IdGradoEscolar.HasValue)
            {
                return ApiResponse<AuthResponse>.Fail("El grado escolar (IdGradoEscolar) es obligatorio para registrar un estudiante.");
            }

            // Hashear contraseña de forma segura con BCrypt
            string hash = BCrypt.Net.BCrypt.HashPassword(request.Contrasena);

            int idUsuario = await _usuarioRepo.RegistrarUsuarioAsync(
                request.Alias.Trim(),
                hash,
                request.NombreRol,
                request.IdGradoEscolar,
                request.FechaNacimiento,
                request.Institucion,
                request.Telefono
            );

            if (idUsuario <= 0)
            {
                return ApiResponse<AuthResponse>.Fail("No se pudo completar el registro del usuario.");
            }

            var tokenInfo = GenerateJwtToken(idUsuario, request.Alias, request.NombreRol);

            return ApiResponse<AuthResponse>.Ok(new AuthResponse
            {
                Token = tokenInfo.Token,
                Expiration = tokenInfo.Expiration,
                IdUsuario = idUsuario,
                Alias = request.Alias,
                NombreRol = request.NombreRol
            }, "Usuario registrado exitosamente.");
        }

        public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
        {
            var user = await _usuarioRepo.ObtenerPorAliasAsync(request.Alias.Trim());
            if (user == null || !user.Activo)
            {
                return ApiResponse<AuthResponse>.Fail("Credenciales inválidas o usuario inactivo.");
            }

            bool isPasswordValid = false;
            try
            {
                isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Contrasena, user.ContrasenaHash);
            }
            catch
            {
                // Soporte de compatibilidad en caso de migración
                isPasswordValid = false;
            }

            if (!isPasswordValid)
            {
                return ApiResponse<AuthResponse>.Fail("Credenciales inválidas.");
            }

            var tokenInfo = GenerateJwtToken(user.IdUsuario, user.Alias, user.NombreRol);

            return ApiResponse<AuthResponse>.Ok(new AuthResponse
            {
                Token = tokenInfo.Token,
                Expiration = tokenInfo.Expiration,
                IdUsuario = user.IdUsuario,
                Alias = user.Alias,
                IdRol = user.IdRol,
                NombreRol = user.NombreRol
            }, "Inicio de sesión exitoso.");
        }

        private (string Token, DateTime Expiration) GenerateJwtToken(int idUsuario, string alias, string rol)
        {
            var expiration = DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes);
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, idUsuario.ToString()),
                new Claim(JwtRegisteredClaimNames.UniqueName, alias),
                new Claim(ClaimTypes.NameIdentifier, idUsuario.ToString()),
                new Claim(ClaimTypes.Name, alias),
                new Claim(ClaimTypes.Role, rol),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: expiration,
                signingCredentials: creds
            );

            return (new JwtSecurityTokenHandler().WriteToken(token), expiration);
        }
    }

    public class PerfilService : IPerfilService
    {
        private readonly IPerfilRepository _perfilRepo;

        public PerfilService(IPerfilRepository perfilRepo)
        {
            _perfilRepo = perfilRepo;
        }

        public async Task<ApiResponse<EstudiantePerfilDto>> ObtenerPerfilEstudianteAsync(int idUsuario)
        {
            var perfil = await _perfilRepo.ObtenerPerfilEstudianteAsync(idUsuario);
            if (perfil == null)
                return ApiResponse<EstudiantePerfilDto>.Fail("Perfil de estudiante no encontrado.");

            return ApiResponse<EstudiantePerfilDto>.Ok(perfil);
        }

        public async Task<ApiResponse<bool>> ActualizarPreferenciasAsync(UpdatePreferenciasRequest request)
        {
            if (request.TamanoFuente < 1 || request.TamanoFuente > 5)
            {
                return ApiResponse<bool>.Fail("El tamaño de fuente debe estar entre 1 y 5.");
            }

            var success = await _perfilRepo.ActualizarPreferenciasAsync(request);
            if (!success)
                return ApiResponse<bool>.Fail("No se pudieron actualizar las preferencias.");

            return ApiResponse<bool>.Ok(true, "Preferencias actualizadas con éxito.");
        }
    }

    public class MapaService : IMapaService
    {
        private readonly IMapaRepository _mapaRepo;

        public MapaService(IMapaRepository mapaRepo)
        {
            _mapaRepo = mapaRepo;
        }

        public async Task<ApiResponse<List<DepartamentoDto>>> ObtenerDepartamentosAsync(int idUsuario)
        {
            var list = await _mapaRepo.ObtenerDepartamentosAsync(idUsuario);
            return ApiResponse<List<DepartamentoDto>>.Ok(list);
        }

        public async Task<ApiResponse<List<MunicipioDto>>> ObtenerMunicipiosAsync(int idUsuario, int idDepartamento)
        {
            var list = await _mapaRepo.ObtenerMunicipiosAsync(idUsuario, idDepartamento);
            return ApiResponse<List<MunicipioDto>>.Ok(list);
        }
    }

    public class CulturaService : ICulturaService
    {
        private readonly ICulturaRepository _culturaRepo;

        public CulturaService(ICulturaRepository culturaRepo)
        {
            _culturaRepo = culturaRepo;
        }

        public async Task<ApiResponse<List<ContenidoCulturalDto>>> ObtenerContenidoPorMunicipioAsync(int idMunicipio)
        {
            var list = await _culturaRepo.ObtenerContenidoPorMunicipioAsync(idMunicipio);
            return ApiResponse<List<ContenidoCulturalDto>>.Ok(list);
        }
    }

    public class RetosService : IRetosService
    {
        private readonly IRetosRepository _retosRepo;

        public RetosService(IRetosRepository retosRepo)
        {
            _retosRepo = retosRepo;
        }

        public async Task<ApiResponse<List<RetoDto>>> ObtenerRetosPorMunicipioAsync(int idMunicipio, int idUsuario, int? idAsignatura = null)
        {
            var list = await _retosRepo.ObtenerRetosPorMunicipioAsync(idMunicipio, idUsuario, idAsignatura);
            return ApiResponse<List<RetoDto>>.Ok(list);
        }

        public async Task<ApiResponse<List<PreguntaDto>>> ObtenerPreguntasRetoAsync(int idReto)
        {
            var list = await _retosRepo.ObtenerPreguntasRetoAsync(idReto);
            return ApiResponse<List<PreguntaDto>>.Ok(list);
        }
    }

    public class ProgresoService : IProgresoService
    {
        private readonly IProgresoRepository _progresoRepo;

        public ProgresoService(IProgresoRepository progresoRepo)
        {
            _progresoRepo = progresoRepo;
        }

        public async Task<ApiResponse<ResultadoIntentoDto>> RegistrarIntentoAsync(RegistrarIntentoRequest request)
        {
            var res = await _progresoRepo.RegistrarIntentoAsync(request);
            if (res == null)
                return ApiResponse<ResultadoIntentoDto>.Fail("No se pudo registrar el intento.");

            string msg = res.EsCorrecta 
                ? (res.RetoCompletado ? "¡Excelente! Has completado el reto y ganado monedas/puntos." : "¡Respuesta correcta!") 
                : "Respuesta incorrecta. ¡Sigue intentando!";

            return ApiResponse<ResultadoIntentoDto>.Ok(res, msg);
        }
    }

    public class GamificacionService : IGamificacionService
    {
        private readonly IGamificacionRepository _gamificacionRepo;

        public GamificacionService(IGamificacionRepository gamificacionRepo)
        {
            _gamificacionRepo = gamificacionRepo;
        }

        public async Task<ApiResponse<List<InsigniaOtorgadaDto>>> EvaluarYOtorgarInsigniasAsync(int idUsuario)
        {
            var list = await _gamificacionRepo.EvaluarYOtorgarInsigniasAsync(idUsuario);
            return ApiResponse<List<InsigniaOtorgadaDto>>.Ok(list, list.Any() ? "Nuevas insignias desbloqueadas." : "No hay nuevas insignias pendientes.");
        }

        public async Task<ApiResponse<NivelProgresoDto>> ObtenerNivelUsuarioAsync(int idUsuario)
        {
            var nivel = await _gamificacionRepo.ObtenerNivelUsuarioAsync(idUsuario);
            if (nivel == null)
                return ApiResponse<NivelProgresoDto>.Fail("Nivel no encontrado.");

            return ApiResponse<NivelProgresoDto>.Ok(nivel);
        }

        public async Task<ApiResponse<List<RankingEstudianteDto>>> ObtenerRankingAsync(int top = 20, int? idGrupo = null)
        {
            var list = await _gamificacionRepo.ObtenerRankingAsync(top, idGrupo);
            return ApiResponse<List<RankingEstudianteDto>>.Ok(list);
        }
    }

    public class TiendaService : ITiendaService
    {
        private readonly ITiendaRepository _tiendaRepo;

        public TiendaService(ITiendaRepository tiendaRepo)
        {
            _tiendaRepo = tiendaRepo;
        }

        public async Task<ApiResponse<List<ItemTiendaDto>>> ObtenerItemsAsync(int idUsuario)
        {
            var list = await _tiendaRepo.ObtenerItemsAsync(idUsuario);
            return ApiResponse<List<ItemTiendaDto>>.Ok(list);
        }

        public async Task<ApiResponse<CompraItemResponse>> ComprarItemAsync(ComprarItemRequest request)
        {
            var res = await _tiendaRepo.ComprarItemAsync(request.IdUsuario, request.IdItem);
            if (res == null)
                return ApiResponse<CompraItemResponse>.Fail("No se pudo completar la compra.");

            return ApiResponse<CompraItemResponse>.Ok(res, res.Mensaje);
        }
    }

    public class AvatarService : IAvatarService
    {
        private readonly IAvatarRepository _avatarRepo;

        public AvatarService(IAvatarRepository avatarRepo)
        {
            _avatarRepo = avatarRepo;
        }

        public async Task<ApiResponse<List<AvatarDto>>> ObtenerAvataresAsync(int idUsuario)
        {
            var list = await _avatarRepo.ObtenerAvataresAsync(idUsuario);
            return ApiResponse<List<AvatarDto>>.Ok(list);
        }

        public async Task<ApiResponse<OperacionAvatarResponse>> ComprarAvatarAsync(ComprarAvatarRequest request)
        {
            var res = await _avatarRepo.ComprarAvatarAsync(request.IdUsuario, request.IdAvatar);
            if (res == null)
                return ApiResponse<OperacionAvatarResponse>.Fail("No se pudo desbloquear el avatar.");

            return ApiResponse<OperacionAvatarResponse>.Ok(res, res.Mensaje);
        }

        public async Task<ApiResponse<OperacionAvatarResponse>> EquiparAvatarAsync(EquiparAvatarRequest request)
        {
            var res = await _avatarRepo.EquiparAvatarAsync(request.IdUsuario, request.IdAvatar);
            if (res == null)
                return ApiResponse<OperacionAvatarResponse>.Fail("No se pudo equipar el avatar.");

            return ApiResponse<OperacionAvatarResponse>.Ok(res, res.Mensaje);
        }
    }

    public class DocenteService : IDocenteService
    {
        private readonly IDocenteRepository _docenteRepo;

        public DocenteService(IDocenteRepository docenteRepo)
        {
            _docenteRepo = docenteRepo;
        }

        public async Task<ApiResponse<GrupoDocenteDto>> CrearGrupoAsync(CrearGrupoRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Nombre))
                return ApiResponse<GrupoDocenteDto>.Fail("El nombre del grupo es obligatorio.");

            var grupo = await _docenteRepo.CrearGrupoAsync(request);
            if (grupo == null)
                return ApiResponse<GrupoDocenteDto>.Fail("No se pudo crear el grupo escolar.");

            return ApiResponse<GrupoDocenteDto>.Ok(grupo, "Grupo escolar creado exitosamente.");
        }

        public async Task<ApiResponse<List<GrupoDocenteDto>>> ObtenerGruposAsync(int idDocente)
        {
            var list = await _docenteRepo.ObtenerGruposAsync(idDocente);
            return ApiResponse<List<GrupoDocenteDto>>.Ok(list);
        }

        public async Task<ApiResponse<bool>> AgregarEstudianteGrupoAsync(AgregarEstudianteGrupoRequest request)
        {
            var success = await _docenteRepo.AgregarEstudianteGrupoAsync(request);
            if (!success)
                return ApiResponse<bool>.Fail("No se pudo agregar el estudiante al grupo.");

            return ApiResponse<bool>.Ok(true, "Estudiante agregado al grupo exitosamente.");
        }

        public async Task<ApiResponse<bool>> RemoverEstudianteGrupoAsync(int idGrupo, int idEstudiante)
        {
            var success = await _docenteRepo.RemoverEstudianteGrupoAsync(idGrupo, idEstudiante);
            if (!success)
                return ApiResponse<bool>.Fail("No se pudo remover el estudiante del grupo.");

            return ApiResponse<bool>.Ok(true, "Estudiante removido exitosamente.");
        }

        public async Task<ApiResponse<List<ProgresoGrupoEstudianteDto>>> ObtenerProgresoGrupoAsync(int idGrupo)
        {
            var list = await _docenteRepo.ObtenerProgresoGrupoAsync(idGrupo);
            return ApiResponse<List<ProgresoGrupoEstudianteDto>>.Ok(list);
        }
    }

    public class PadreService : IPadreService
    {
        private readonly IPadreRepository _padreRepo;

        public PadreService(IPadreRepository padreRepo)
        {
            _padreRepo = padreRepo;
        }

        public async Task<ApiResponse<List<ProgresoHijoDto>>> ObtenerProgresoHijosAsync(int idPadre)
        {
            var list = await _padreRepo.ObtenerProgresoHijosAsync(idPadre);
            return ApiResponse<List<ProgresoHijoDto>>.Ok(list);
        }

        public async Task<ApiResponse<bool>> VincularEstudianteAsync(VincularEstudianteRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.AliasEstudiante))
                return ApiResponse<bool>.Fail("El alias del estudiante es obligatorio.");

            var success = await _padreRepo.VincularEstudianteAsync(request.IdPadre, request.AliasEstudiante.Trim());
            if (!success)
                return ApiResponse<bool>.Fail("No se pudo realizar la vinculación del estudiante.");

            return ApiResponse<bool>.Ok(true, "Estudiante vinculado exitosamente.");
        }

        public async Task<ApiResponse<bool>> DesvincularEstudianteAsync(int idPadre, int idEstudiante)
        {
            var success = await _padreRepo.DesvincularEstudianteAsync(idPadre, idEstudiante);
            if (!success)
                return ApiResponse<bool>.Fail("No se pudo remover la vinculación.");

            return ApiResponse<bool>.Ok(true, "Vinculación eliminada exitosamente.");
        }
    }

    public class NotificacionService : INotificacionService
    {
        private readonly INotificacionRepository _notificacionRepo;

        public NotificacionService(INotificacionRepository notificacionRepo)
        {
            _notificacionRepo = notificacionRepo;
        }

        public async Task<ApiResponse<List<NotificacionDto>>> ObtenerNotificacionesAsync(int idUsuario, bool soloNoLeidas = false)
        {
            var list = await _notificacionRepo.ObtenerNotificacionesAsync(idUsuario, soloNoLeidas);
            return ApiResponse<List<NotificacionDto>>.Ok(list);
        }

        public async Task<ApiResponse<int>> CrearNotificacionAsync(CrearNotificacionRequest request)
        {
            var id = await _notificacionRepo.CrearNotificacionAsync(request);
            if (id <= 0)
                return ApiResponse<int>.Fail("No se pudo crear la notificación.");

            return ApiResponse<int>.Ok(id, "Notificación creada con éxito.");
        }

        public async Task<ApiResponse<bool>> MarcarLeidaAsync(int idNotificacion)
        {
            var success = await _notificacionRepo.MarcarLeidaAsync(idNotificacion);
            if (!success)
                return ApiResponse<bool>.Fail("Notificación no encontrada.");

            return ApiResponse<bool>.Ok(true, "Notificación marcada como leída.");
        }
    }

    public class CatalogoService : ICatalogoService
    {
        private readonly ICatalogoRepository _catalogoRepo;

        public CatalogoService(ICatalogoRepository catalogoRepo)
        {
            _catalogoRepo = catalogoRepo;
        }

        public async Task<ApiResponse<List<CatalogoItemDto>>> ObtenerAsignaturasAsync()
        {
            var list = await _catalogoRepo.ObtenerAsignaturasAsync();
            return ApiResponse<List<CatalogoItemDto>>.Ok(list);
        }

        public async Task<ApiResponse<List<CatalogoItemDto>>> ObtenerGradosEscolaresAsync()
        {
            var list = await _catalogoRepo.ObtenerGradosEscolaresAsync();
            return ApiResponse<List<CatalogoItemDto>>.Ok(list);
        }

        public async Task<ApiResponse<List<CatalogoItemDto>>> ObtenerRolesAsync()
        {
            var list = await _catalogoRepo.ObtenerRolesAsync();
            return ApiResponse<List<CatalogoItemDto>>.Ok(list);
        }
    }

    public class SyncService : ISyncService
    {
        private readonly ISyncRepository _syncRepo;

        public SyncService(ISyncRepository syncRepo)
        {
            _syncRepo = syncRepo;
        }

        public async Task<string> ObtenerContenidoActualizadoAsync(DateTime fechaDesde)
        {
            return await _syncRepo.ObtenerContenidoActualizadoAsync(fechaDesde);
        }

        public async Task<ApiResponse<SyncPushResponse>> SubirProgresoOfflineAsync(SyncPushRequest request)
        {
            if (request.Intentos == null || !request.Intentos.Any())
                return ApiResponse<SyncPushResponse>.Fail("No se proporcionaron intentos para sincronizar.");

            var res = await _syncRepo.SubirProgresoOfflineAsync(request);
            if (res == null)
                return ApiResponse<SyncPushResponse>.Fail("Error al procesar la sincronización en el servidor.");

            return ApiResponse<SyncPushResponse>.Ok(res, "Progreso offline sincronizado con éxito.");
        }
    }
}
