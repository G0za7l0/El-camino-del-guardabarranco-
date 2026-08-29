namespace ElCaminoGuardabarranco.API.DTOs.Notificacion
{
    public class NotificacionDto
    {
        public int IdNotificacion { get; set; }
        public int IdUsuarioDestino { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public bool Leida { get; set; }
        public DateTime FechaCreacion { get; set; }
    }

    public class CrearNotificacionRequest
    {
        public int IdUsuarioDestino { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
    }
}
