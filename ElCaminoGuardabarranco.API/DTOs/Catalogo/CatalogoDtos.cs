namespace ElCaminoGuardabarranco.API.DTOs.Catalogo
{
    public class CatalogoItemDto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool? Activo { get; set; }
    }
}
