using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Sync;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SyncController : ControllerBase
    {
        private readonly ISyncService _syncService;

        public SyncController(ISyncService syncService)
        {
            _syncService = syncService;
        }

        /// <summary>
        /// Sincronización PULL: Descarga catálogos y contenidos modificados para almacenar en SQLite.
        /// </summary>
        [HttpGet("pull")]
        [Produces("application/json")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> SyncPull([FromQuery] DateTime? fechaDesde)
        {
            var fecha = fechaDesde ?? DateTime.MinValue;
            var json = await _syncService.ObtenerContenidoActualizadoAsync(fecha);
            return Content(json, "application/json");
        }

        /// <summary>
        /// Sincronización PUSH: Sube el lote de intentos registrados offline en SQLite al servidor SQL Server.
        /// </summary>
        [HttpPost("push")]
        [ProducesResponseType(typeof(ApiResponse<SyncPushResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<SyncPushResponse>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> SyncPush([FromBody] SyncPushRequest request)
        {
            var result = await _syncService.SubirProgresoOfflineAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
