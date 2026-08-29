namespace ElCaminoGuardabarranco.API.DTOs.Mapa
{
    public class DepartamentoDto
    {
        public int IdDepartamento { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int OrdenDesbloqueo { get; set; }
        public int TotalRetos { get; set; }
        public int RetosCompletados { get; set; }
        public string Estado { get; set; } = "Bloqueado"; // Bloqueado, Desbloqueado, Completado
    }

    public class MunicipioDto
    {
        public int IdMunicipio { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int TotalRetos { get; set; }
        public int RetosCompletados { get; set; }
    }
}
