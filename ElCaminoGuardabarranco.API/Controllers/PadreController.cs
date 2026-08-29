using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Padre;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PadreController : ControllerBase
    {
        private readonly IPadreService _padreService;

        public PadreController(IPadreService padreService)
        {
            _padreService = padreService;
        }

        /// <summary>
        /// Obtiene el reporte de progreso de los estudiantes vinculados al padre/tutor.
        /// </summary>
        [HttpGet("hijos/{idPadre:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<ProgresoHijoDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProgresoHijos(int idPadre)
        {
            var result = await _padreService.ObtenerProgresoHijosAsync(idPadre);
            return Ok(result);
        }

        /// <summary>
        /// Vincula un estudiante a la cuenta del padre/tutor mediante el Alias del hijo.
        /// </summary>
        [HttpPost("vincular")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> VincularHijo([FromBody] VincularEstudianteRequest request)
        {
            var result = await _padreService.VincularEstudianteAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        /// <summary>
        /// Desvincula a un estudiante del tutor.
        /// </summary>
        [HttpDelete("vincular/{idPadre:int}/{idEstudiante:int}")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> DesvincularHijo(int idPadre, int idEstudiante)
        {
            var result = await _padreService.DesvincularEstudianteAsync(idPadre, idEstudiante);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
