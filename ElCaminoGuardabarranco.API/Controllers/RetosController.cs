using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Retos;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RetosController : ControllerBase
    {
        private readonly IRetosService _retosService;

        public RetosController(IRetosService retosService)
        {
            _retosService = retosService;
        }

        /// <summary>
        /// Obtiene los retos disponibles en un municipio con filtro opcional por asignatura.
        /// </summary>
        [HttpGet("municipio/{idMunicipio:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<RetoDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRetosPorMunicipio(int idMunicipio, [FromQuery] int idUsuario, [FromQuery] int? idAsignatura = null)
        {
            var result = await _retosService.ObtenerRetosPorMunicipioAsync(idMunicipio, idUsuario, idAsignatura);
            return Ok(result);
        }

        /// <summary>
        /// Obtiene las preguntas y opciones de un reto pedagógico (sin revelar la respuesta correcta).
        /// </summary>
        [HttpGet("{idReto:int}/preguntas")]
        [ProducesResponseType(typeof(ApiResponse<List<PreguntaDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetPreguntasReto(int idReto)
        {
            var result = await _retosService.ObtenerPreguntasRetoAsync(idReto);
            return Ok(result);
        }
    }
}
