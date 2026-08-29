using System.Reflection;
using System.Text;
using ElCaminoGuardabarranco.API.Data;
using ElCaminoGuardabarranco.API.Repositories.Implementations;
using ElCaminoGuardabarranco.API.Repositories.Interfaces;
using ElCaminoGuardabarranco.API.Services.Implementations;
using ElCaminoGuardabarranco.API.Services.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

namespace ElCaminoGuardabarranco.API.Configuration
{
    public static class ServiceExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
        {
            // Base de Datos
            services.AddSingleton<IDbConnectionFactory, DbConnectionFactory>();

            // Repositorios
            services.AddScoped<IUsuarioRepository, UsuarioRepository>();
            services.AddScoped<IPerfilRepository, PerfilRepository>();
            services.AddScoped<IMapaRepository, MapaRepository>();
            services.AddScoped<ICulturaRepository, CulturaRepository>();
            services.AddScoped<IRetosRepository, RetosRepository>();
            services.AddScoped<IProgresoRepository, ProgresoRepository>();
            services.AddScoped<IGamificacionRepository, GamificacionRepository>();
            services.AddScoped<ITiendaRepository, TiendaRepository>();
            services.AddScoped<IAvatarRepository, AvatarRepository>();
            services.AddScoped<IDocenteRepository, DocenteRepository>();
            services.AddScoped<IPadreRepository, PadreRepository>();
            services.AddScoped<INotificacionRepository, NotificacionRepository>();
            services.AddScoped<ICatalogoRepository, CatalogoRepository>();
            services.AddScoped<ISyncRepository, SyncRepository>();

            // Servicios de Negocio
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IPerfilService, PerfilService>();
            services.AddScoped<IMapaService, MapaService>();
            services.AddScoped<ICulturaService, CulturaService>();
            services.AddScoped<IRetosService, RetosService>();
            services.AddScoped<IProgresoService, ProgresoService>();
            services.AddScoped<IGamificacionService, GamificacionService>();
            services.AddScoped<ITiendaService, TiendaService>();
            services.AddScoped<IAvatarService, AvatarService>();
            services.AddScoped<IDocenteService, DocenteService>();
            services.AddScoped<IPadreService, PadreService>();
            services.AddScoped<INotificacionService, NotificacionService>();
            services.AddScoped<ICatalogoService, CatalogoService>();
            services.AddScoped<ISyncService, SyncService>();

            return services;
        }

        public static IServiceCollection AddJwtAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            var jwtSection = configuration.GetSection("JwtSettings");
            services.Configure<JwtSettings>(jwtSection);
            var jwtSettings = jwtSection.Get<JwtSettings>() ?? new JwtSettings();

            var key = Encoding.UTF8.GetBytes(jwtSettings.SecretKey);

            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.RequireHttpsMetadata = false;
                options.SaveToken = true;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = !string.IsNullOrWhiteSpace(jwtSettings.Issuer),
                    ValidIssuer = jwtSettings.Issuer,
                    ValidateAudience = !string.IsNullOrWhiteSpace(jwtSettings.Audience),
                    ValidAudience = jwtSettings.Audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };
            });

            return services;
        }

        public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
        {
            services.AddEndpointsApiExplorer();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "El Camino del Guardabarranco API",
                    Version = "v1",
                    Description = "API REST Educativa y Gamificada de Nicaragua para Educación Primaria (4to a 6to Grado).",
                    Contact = new OpenApiContact
                    {
                        Name = "Equipo El Camino del Guardabarranco",
                        Email = "contacto@elcaminodelguardabarranco.edu.ni"
                    }
                });

                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "Autenticación JWT usando el esquema Bearer. Ejemplo: 'Bearer {token}'",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        Array.Empty<string>()
                    }
                });

                // Cargar comentarios XML para Swagger
                var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
                var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
                if (File.Exists(xmlPath))
                {
                    c.IncludeXmlComments(xmlPath);
                }
            });

            return services;
        }
    }
}
