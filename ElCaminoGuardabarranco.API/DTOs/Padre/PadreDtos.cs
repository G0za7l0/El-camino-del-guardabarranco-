namespace ElCaminoGuardabarranco.API.DTOs.Padre
{
    public class VincularEstudianteRequest
    {
        public int IdPadre { get; set; }
        public string AliasEstudiante { get; set; } = string.Empty;
    }

    public class ProgresoHijoDto
    {
        public int IdEstudiante { get; set; }
        public string Alias { get; set; } = string.Empty;
        public string GradoEscolar { get; set; } = string.Empty;
        public int PuntosAcumulados { get; set; }
        public int MonedasVirtuales { get; set; }
        public int RetosCompletados { get; set; }
        public int InsigniasObtenidas { get; set; }
        public string? UltimoDepartamento { get; set; }
    }
}
