namespace ElCaminoGuardabarranco.API.DTOs.Sync
{
    public class IntentoOfflineDto
    {
        public int IdReto { get; set; }
        public int IdPregunta { get; set; }
        public int IdOpcion { get; set; }
        public DateTime FechaIntento { get; set; }
        public int? TiempoRespuestaSegundos { get; set; }
    }

    public class SyncPushRequest
    {
        public int IdUsuario { get; set; }
        public string? IdDispositivoOrigen { get; set; }
        public List<IntentoOfflineDto> Intentos { get; set; } = new();
    }

    public class SyncPushResponse
    {
        public string Mensaje { get; set; } = string.Empty;
        public int IntentosProcesados { get; set; }
        public int RetosCompletados { get; set; }
        public int PuntosAcreditados { get; set; }
        public int MonedasAcreditadas { get; set; }
    }
}
