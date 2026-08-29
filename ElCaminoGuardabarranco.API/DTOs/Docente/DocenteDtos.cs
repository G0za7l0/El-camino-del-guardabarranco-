namespace ElCaminoGuardabarranco.API.DTOs.Docente
{
    public class CrearGrupoRequest
    {
        public int IdDocente { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int IdGradoEscolar { get; set; }
        public string? CodigoAcceso { get; set; }
    }

    public class GrupoDocenteDto
    {
        public int IdGrupo { get; set; }
        public string NombreGrupo { get; set; } = string.Empty;
        public string CodigoAcceso { get; set; } = string.Empty;
        public int IdGradoEscolar { get; set; }
        public string GradoEscolar { get; set; } = string.Empty;
        public int TotalEstudiantes { get; set; }
    }

    public class AgregarEstudianteGrupoRequest
    {
        public int IdGrupo { get; set; }
        public string? AliasEstudiante { get; set; }
        public string? CodigoAcceso { get; set; }
        public int? IdEstudiante { get; set; }
    }

    public class ProgresoGrupoEstudianteDto
    {
        public int IdEstudiante { get; set; }
        public string Alias { get; set; } = string.Empty;
        public int PuntosAcumulados { get; set; }
        public int MonedasVirtuales { get; set; }
        public int RetosCompletados { get; set; }
        public int TotalRetos { get; set; }
        public int InsigniasObtenidas { get; set; }
        public string? UltimoDepartamento { get; set; }
    }
}
