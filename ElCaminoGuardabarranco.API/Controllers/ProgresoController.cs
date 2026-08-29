using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Progreso;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProgresoController : ControllerBase
    {
        private readonly IProgresoService _progresoService;

        public ProgresoController(IProgresoService progresoService)
        {
            _progresoService = progresoService;
        }

        /// <summary>
        /// Registra la respuesta a una pregunta, evalúa acierto, actualiza la racha y acredita monedas/puntos si el reto se completa.
        /// </summary>
        [HttpPost("intento")]
        [ProducesResponseType(typeof(ApiResponse<ResultadoIntentoDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<ResultadoIntentoDto>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RegistrarIntento([FromBody] RegistrarIntentoRequest request)
        {
            var result = await _progresoService.RegistrarIntentoAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
