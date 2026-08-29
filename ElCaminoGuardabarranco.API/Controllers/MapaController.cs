using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Mapa;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MapaController : ControllerBase
    {
        private readonly IMapaService _mapaService;

        public MapaController(IMapaService mapaService)
        {
            _mapaService = mapaService;
        }

        /// <summary>
        /// Lista los 17 departamentos de Nicaragua con su estado (Bloqueado/Desbloqueado/Completado) para el estudiante.
        /// </summary>
        [HttpGet("departamentos/{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<DepartamentoDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetDepartamentos(int idUsuario)
        {
            var result = await _mapaService.ObtenerDepartamentosAsync(idUsuario);
            return Ok(result);
        }

        /// <summary>
        /// Lista los municipios de un departamento con el avance de retos del estudiante.
        /// </summary>
        [HttpGet("municipios/{idDepartamento:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<MunicipioDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetMunicipios(int idDepartamento, [FromQuery] int idUsuario)
        {
            var result = await _mapaService.ObtenerMunicipiosAsync(idUsuario, idDepartamento);
            return Ok(result);
        }
    }
}
