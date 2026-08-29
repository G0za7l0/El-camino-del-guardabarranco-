namespace ElCaminoGuardabarranco.API.DTOs.Gamificacion
{
    public class InsigniaOtorgadaDto
    {
        public int IdInsignia { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
    }

    public class NivelProgresoDto
    {
        public int IdNivel { get; set; }
        public int NivelNumero { get; set; }
        public string NivelTitulo { get; set; } = string.Empty;
        public int PuntosActuales { get; set; }
        public int PuntosNivelBase { get; set; }
        public int? NivelSiguienteNumero { get; set; }
        public string? NivelSiguienteTitulo { get; set; }
        public int? PuntosRequeridosSiguiente { get; set; }
        public int PuntosParaSubir { get; set; }
        public decimal PorcentajeAvance { get; set; }
    }

    public class RankingEstudianteDto
    {
        public long Posicion { get; set; }
        public int IdUsuario { get; set; }
        public string Alias { get; set; } = string.Empty;
        public string GradoEscolar { get; set; } = string.Empty;
        public int PuntosAcumulados { get; set; }
        public int MonedasVirtuales { get; set; }
        public int RachaActualDias { get; set; }
        public string? AvatarEquipado { get; set; }
        public string? AvatarUrl { get; set; }
        public string RangoNivel { get; set; } = string.Empty;
    }
}
