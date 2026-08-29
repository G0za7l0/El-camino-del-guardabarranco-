using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Perfil;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PerfilController : ControllerBase
    {
        private readonly IPerfilService _perfilService;

        public PerfilController(IPerfilService perfilService)
        {
            _perfilService = perfilService;
        }

        /// <summary>
        /// Obtiene el perfil integral del estudiante (datos, avatar, nivel, racha, billetera e insignias).
        /// </summary>
        [HttpGet("{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<EstudiantePerfilDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<EstudiantePerfilDto>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetPerfil(int idUsuario)
        {
            var result = await _perfilService.ObtenerPerfilEstudianteAsync(idUsuario);
            if (!result.Success)
                return NotFound(result);

            return Ok(result);
        }

        /// <summary>
        /// Actualiza las preferencias de accesibilidad del usuario.
        /// </summary>
        [HttpPut("preferencias")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UpdatePreferencias([FromBody] UpdatePreferenciasRequest request)
        {
            var result = await _perfilService.ActualizarPreferenciasAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
