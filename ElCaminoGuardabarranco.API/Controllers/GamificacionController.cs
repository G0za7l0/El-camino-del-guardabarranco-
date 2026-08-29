using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Gamificacion;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GamificacionController : ControllerBase
    {
        private readonly IGamificacionService _gamificacionService;

        public GamificacionController(IGamificacionService gamificacionService)
        {
            _gamificacionService = gamificacionService;
        }

        /// <summary>
        /// Evalúa las reglas de juego y otorga insignias automáticas pendientes (primer reto, guardián de departamento, etc.).
        /// </summary>
        [HttpPost("evaluar-insignias/{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<InsigniaOtorgadaDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> EvaluarInsignias(int idUsuario)
        {
            var result = await _gamificacionService.EvaluarYOtorgarInsigniasAsync(idUsuario);
            return Ok(result);
        }

        /// <summary>
        /// Obtiene el nivel actual del estudiante, rango del Guardabarranco y porcentaje de avance hacia el siguiente nivel.
        /// </summary>
        [HttpGet("nivel/{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<NivelProgresoDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<NivelProgresoDto>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetNivel(int idUsuario)
        {
            var result = await _gamificacionService.ObtenerNivelUsuarioAsync(idUsuario);
            if (!result.Success)
                return NotFound(result);

            return Ok(result);
        }

        /// <summary>
        /// Obtiene la tabla de posiciones / Leaderboard de los mejores estudiantes.
        /// </summary>
        [HttpGet("ranking")]
        [ProducesResponseType(typeof(ApiResponse<List<RankingEstudianteDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRanking([FromQuery] int top = 20, [FromQuery] int? idGrupo = null)
        {
            var result = await _gamificacionService.ObtenerRankingAsync(top, idGrupo);
            return Ok(result);
        }
    }
}
