using ElCaminoGuardabarranco.API.DTOs.Common;
using ElCaminoGuardabarranco.API.DTOs.Docente;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ElCaminoGuardabarranco.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DocenteController : ControllerBase
    {
        private readonly IDocenteService _docenteService;

        public DocenteController(IDocenteService docenteService)
        {
            _docenteService = docenteService;
        }

        /// <summary>
        /// Lista los grupos escolares administrados por un docente.
        /// </summary>
        [HttpGet("grupos/{idDocente:int}")]
        [ProducesResponseType(typeof(ApiResponse<List<GrupoDocenteDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetGrupos(int idDocente)
        {
            var result = await _docenteService.ObtenerGruposAsync(idDocente);
            return Ok(result);
        }

        /// <summary>
        /// Crea una nueva aula o grupo escolar con código de acceso para los alumnos.
        /// </summary>
        [HttpPost("grupos")]
        [ProducesResponseType(typeof(ApiResponse<GrupoDocenteDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ApiResponse<GrupoDocenteDto>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CrearGrupo([FromBody] CrearGrupoRequest request)
        {
            var result = await _docenteService.CrearGrupoAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetGrupos), new { idDocente = request.IdDocente }, result);
        }

        /// <summary>
        /// Inscribe un estudiante a un grupo mediante su Alias o código.
        /// </summary>
        [HttpPost("grupos/estudiantes")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> AgregarEstudiante([FromBody] AgregarEstudianteGrupoRequest request)
        {
            var result = await _docenteService.AgregarEstudianteGrupoAsync(request);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        /// <summary>
        /// Remueve un estudiante de un grupo escolar.
        /// </summary>
        [HttpDelete("grupos/{idGrupo:int}/estudiantes/{idEstudiante:int}")]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RemoverEstudiante(int idGrupo, int idEstudiante)
        {
            var result = await _docenteService.RemoverEstudianteGrupoAsync(idGrupo, idEstudiante);
            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        /// <summary>
        /// Obtiene el reporte pedagógico de progreso de los alumnos del grupo escolar.
        /// </summary>
        [HttpGet("grupos/{idGrupo:int}/progreso")]
        [ProducesResponseType(typeof(ApiResponse<List<ProgresoGrupoEstudianteDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProgresoGrupo(int idGrupo)
        {
            var result = await _docenteService.ObtenerProgresoGrupoAsync(idGrupo);
            return Ok(result);
        }
    }
}
