namespace ElCaminoGuardabarranco.API.DTOs.Perfil
{
    public class InsigniaObtenidaDto
    {
        public int IdInsignia { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string? InsigniaUrl { get; set; }
        public DateTime FechaObtencion { get; set; }
    }

    public class EstudiantePerfilDto
    {
        public int IdUsuario { get; set; }
        public string Alias { get; set; } = string.Empty;
        public string NombreRol { get; set; } = string.Empty;
        public DateTime? FechaNacimiento { get; set; }
        public string GradoEscolar { get; set; } = string.Empty;
        public int PuntosAcumulados { get; set; }
        public int MonedasVirtuales { get; set; }
        public int RachaActualDias { get; set; }
        public int MejorRachaDias { get; set; }
        public string NivelTitulo { get; set; } = string.Empty;
        public int NivelNumero { get; set; }
        public string? AvatarEquipado { get; set; }
        public string? AvatarUrl { get; set; }
        public bool AltoContraste { get; set; }
        public bool LecturaVozActiva { get; set; }
        public byte TamanoFuente { get; set; }
        public List<InsigniaObtenidaDto> Insignias { get; set; } = new();
    }

    public class UpdatePreferenciasRequest
    {
        public int IdUsuario { get; set; }
        public bool AltoContraste { get; set; }
        public bool LecturaVozActiva { get; set; }
        public byte TamanoFuente { get; set; } = 2;
    }
}
