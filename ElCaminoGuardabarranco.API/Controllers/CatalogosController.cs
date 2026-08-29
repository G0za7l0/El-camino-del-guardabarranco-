using ElCaminoGuardabarranco.API.DTOs.Catalogo;
using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CatalogosController : ControllerBase
    {
        private readonly ICatalogoService _catalogoService;

        public CatalogosController(ICatalogoService catalogoService)
        {
            _catalogoService = catalogoService;
        }

        /// <summary>
        /// Catálogo de asignaturas educativas activas.
        /// </summary>
        [HttpGet("asignaturas")]
        [ProducesResponseType(typeof(ApiResponse<List<CatalogoItemDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAsignaturas()
        {
            var result = await _catalogoService.ObtenerAsignaturasAsync();
            return Ok(result);
        }

        /// <summary>
        /// Catálogo de grados escolares (4to, 5to, 6to).
        /// </summary>
        [HttpGet("grados")]
        [ProducesResponseType(typeof(ApiResponse<List<CatalogoItemDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetGrados()
        {
            var result = await _catalogoService.ObtenerGradosEscolaresAsync();
            return Ok(result);
        }

        /// <summary>
        /// Catálogo de roles de usuario en el sistema.
        /// </summary>
        [HttpGet("roles")]
        [ProducesResponseType(typeof(ApiResponse<List<CatalogoItemDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRoles()
        {
            var result = await _catalogoService.ObtenerRolesAsync();
            return Ok(result);
        }
    }
}
