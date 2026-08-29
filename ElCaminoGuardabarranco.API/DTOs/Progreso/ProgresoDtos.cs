using System.ComponentModel.DataAnnotations;

namespace ElCaminoGuardabarranco.API.DTOs.Progreso
{
    public class RegistrarIntentoRequest
    {
        [Required]
        public int IdUsuario { get; set; }

        [Required]
        public int IdReto { get; set; }

        [Required]
        public int IdPregunta { get; set; }

        [Required]
        public int IdOpcionSeleccionada { get; set; }

        public int? TiempoRespuestaSegundos { get; set; }
        public string? IdDispositivoOrigen { get; set; }
    }

    public class ResultadoIntentoDto
    {
        public bool EsCorrecta { get; set; }
        public string? Retroalimentacion { get; set; }
        public bool RetoCompletado { get; set; }
        public int PuntosGanados { get; set; }
        public int MonedasGanadas { get; set; }
        public int RachaActualDias { get; set; }
    }
}
