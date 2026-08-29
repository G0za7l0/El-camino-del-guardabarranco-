using System.ComponentModel.DataAnnotations;

namespace ElCaminoGuardabarranco.API.DTOs.Auth
{
    public class RegisterRequest
    {
        [Required(ErrorMessage = "El alias es obligatorio.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "El alias debe tener entre 3 y 50 caracteres.")]
        public string Alias { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres.")]
        public string Contrasena { get; set; } = string.Empty;

        [Required(ErrorMessage = "El rol es obligatorio ('Estudiante', 'Docente', 'PadreTutor').")]
        public string NombreRol { get; set; } = "Estudiante";

        // Estudiante
        public int? IdGradoEscolar { get; set; }
        public DateTime? FechaNacimiento { get; set; }

        // Docente
        public string? Institucion { get; set; }

        // Padre
        public string? Telefono { get; set; }
    }

    public class LoginRequest
    {
        [Required(ErrorMessage = "El alias es obligatorio.")]
        public string Alias { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        public string Contrasena { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public int IdUsuario { get; set; }
        public string Alias { get; set; } = string.Empty;
        public int IdRol { get; set; }
        public string NombreRol { get; set; } = string.Empty;
    }

    public class UsuarioLoginDb
    {
        public int IdUsuario { get; set; }
        public string Alias { get; set; } = string.Empty;
        public string ContrasenaHash { get; set; } = string.Empty;
        public int IdRol { get; set; }
        public string NombreRol { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }
}
