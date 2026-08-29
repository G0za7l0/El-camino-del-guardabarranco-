namespace ElCaminoGuardabarranco.API.DTOs.Cultura
{
    public class ContenidoCulturalDto
    {
        public int IdContenido { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string TipoContenido { get; set; } = string.Empty;
        public string? MultimediaUrl { get; set; }
        public string? MultimediaTipo { get; set; }
        public string? TextoAlternativo { get; set; }
    }
}
