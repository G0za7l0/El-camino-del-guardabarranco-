using ElCaminoGuardabarranco.API.DTOs.Avatares;
using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AvataresController : ControllerBase
    {
        private readonly IAvatarService _avatarService;

        public AvataresController(IAvatarService avatarService)
        {
            _avatarService = avatarService;
        }

        /// <summary>
        /// Lista los avatares disponibles, cuáles están desbloqueados y cuál está actualmente equipado.
        /// </summary>
        [HttpGet("{idUsuario:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<AvatarDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAvatares(int idUsuario)
        {
            var result = await _avatarService.ObtenerAvataresAsync(idUsuario);
            return Ok(result);
        }

        /// <summary>
        /// Desbloquea un avatar utilizando monedas virtuales.
        /// </summary>
        [HttpPost("comprar")]
        [ProducesResponseType(typeof(ApiResponse<OperacionAvatarResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<OperacionAvatarResponse>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ComprarAvatar([FromBody] ComprarAvatarRequest request)
        {
            var result = await _avatarService.ComprarAvatarAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        /// <summary>
        /// Equipa un avatar que el estudiante ya posea.
        /// </summary>
        [HttpPost("equipar")]
        [ProducesResponseType(typeof(ApiResponse<OperacionAvatarResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<OperacionAvatarResponse>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> EquiparAvatar([FromBody] EquiparAvatarRequest request)
        {
            var result = await _avatarService.EquiparAvatarAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }
    }
}
