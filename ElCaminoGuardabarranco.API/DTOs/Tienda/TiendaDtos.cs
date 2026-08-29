namespace ElCaminoGuardabarranco.API.DTOs.Tienda
{
    public class ItemTiendaDto
    {
        public int IdItem { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Categoria { get; set; } = string.Empty;
        public int CostoMonedas { get; set; }
        public bool Activo { get; set; }
        public string? MultimediaUrl { get; set; }
        public string? MultimediaTipo { get; set; }
        public bool Comprado { get; set; }
        public DateTime? FechaCompra { get; set; }
    }

    public class ComprarItemRequest
    {
        public int IdUsuario { get; set; }
        public int IdItem { get; set; }
    }

    public class CompraItemResponse
    {
        public string Mensaje { get; set; } = string.Empty;
        public int NuevoSaldo { get; set; }
    }
}
