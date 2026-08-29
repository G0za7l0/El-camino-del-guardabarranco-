using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Tienda;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TiendaController : ControllerBase
    {
        private readonly ITiendaService _tiendaService;

        public TiendaController(ITiendaService tiendaService)
        {
            _tiendaService = tiendaService;
        }

        /// <summary>
        /// Lista todos los ítems de la tienda indicando si el estudiante ya los compró.
        /// </summary>
        [HttpGet("items/{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<ItemTiendaDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetItems(int idUsuario)
        {
            var result = await _tiendaService.ObtenerItemsAsync(idUsuario);
            return Ok(result);
        }

        /// <summary>
        /// Compra un artículo de la tienda descontando monedas de la billetera.
        /// </summary>
        [HttpPost("comprar")]
        [ProducesResponseType(typeof(ApiResponse<CompraItemResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<CompraItemResponse>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ComprarItem([FromBody] ComprarItemRequest request)
        {
            var result = await _tiendaService.ComprarItemAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
