using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Cultura;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CulturaController : ControllerBase
    {
        private readonly ICulturaService _culturaService;

        public CulturaController(ICulturaService culturaService)
        {
            _culturaService = culturaService;
        }

        /// <summary>
        /// Obtiene el contenido cultural (historias, fauna, flora, tradiciones) de un municipio.
        /// </summary>
        [HttpGet("municipio/{idMunicipio:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<ContenidoCulturalDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetContenidoCultural(int idMunicipio)
        {
            var result = await _culturaService.ObtenerContenidoPorMunicipioAsync(idMunicipio);
            return Ok(result);
        }
    }
}
