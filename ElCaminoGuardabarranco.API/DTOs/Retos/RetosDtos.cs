namespace ElCaminoGuardabarranco.API.DTOs.Retos
{
    public class RetoDto
    {
        public int IdReto { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Asignatura { get; set; } = string.Empty;
        public string TipoReto { get; set; } = string.Empty;
        public string Dificultad { get; set; } = string.Empty;
        public int PuntosOtorgados { get; set; }
        public int MonedasOtorgadas { get; set; }
        public int Orden { get; set; }
        public bool Completado { get; set; }
        public int? Intentos { get; set; }
    }

    public class OpcionDto
    {
        public int IdOpcion { get; set; }
        public string Texto { get; set; } = string.Empty;
        public int? IdMultimedia { get; set; }
        public string? MultimediaOpcionUrl { get; set; }
    }

    public class PreguntaDto
    {
        public int IdPregunta { get; set; }
        public string Enunciado { get; set; } = string.Empty;
        public string? Retroalimentacion { get; set; }
        public int Orden { get; set; }
        public string? MultimediaUrl { get; set; }
        public string? MultimediaTipo { get; set; }
        public string? TextoAlternativo { get; set; }
        public List<OpcionDto> Opciones { get; set; } = new();
    }
}
