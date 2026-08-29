using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Notificacion;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificacionesController : ControllerBase
    {
        private readonly INotificacionService _notificacionService;

        public NotificacionesController(INotificacionService notificacionService)
        {
            _notificacionService = notificacionService;
        }

        /// <summary>
        /// Obtiene las notificaciones del usuario (con filtro opcional para solo no leídas).
        /// </summary>
        [HttpGet("{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<NotificacionDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetNotificaciones(int idUsuario, [FromQuery] bool soloNoLeidas = false)
        {
            var result = await _notificacionService.ObtenerNotificacionesAsync(idUsuario, soloNoLeidas);
            return Ok(result);
        }

        /// <summary>
        /// Envía una nueva notificación a un usuario.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(ApiResponse<int>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ApiResponse<int>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CrearNotificacion([FromBody] CrearNotificacionRequest request)
        {
            var result = await _notificacionService.CrearNotificacionAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetNotificaciones), new { idUsuario = request.IdUsuarioDestino }, result);
        }

        /// <summary>
        /// Marca una notificación como leída.
        /// </summary>
        [HttpPut("{idNotificacion:int}/leida")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> MarcarLeida(int idNotificacion)
        {
            var result = await _notificacionService.MarcarLeidaAsync(idNotificacion);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
