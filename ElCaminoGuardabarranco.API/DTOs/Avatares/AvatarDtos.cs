namespace ElCaminoGuardabarranco.API.DTOs.Avatares
{
    public class AvatarDto
    {
        public int IdAvatar { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int CostoMonedas { get; set; }
        public bool Activo { get; set; }
        public string? MultimediaUrl { get; set; }
        public string? MultimediaTipo { get; set; }
        public bool Desbloqueado { get; set; }
        public bool Equipado { get; set; }
        public DateTime? FechaObtenido { get; set; }
    }

    public class ComprarAvatarRequest
    {
        public int IdUsuario { get; set; }
        public int IdAvatar { get; set; }
    }

    public class EquiparAvatarRequest
    {
        public int IdUsuario { get; set; }
        public int IdAvatar { get; set; }
    }

    public class OperacionAvatarResponse
    {
        public string Mensaje { get; set; } = string.Empty;
        public int? NuevoSaldo { get; set; }
    }
}
