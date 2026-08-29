using ElCaminoGuardabarranco.API.Configuration;
using ElCaminoGuardabarranco.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

// 1. Controladores
builder.Services.AddControllers();

// 2. CORS para Flutter (Permitir desarrollo móvil y web)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterDev", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 3. Inyección de Dependencias (Data, Repositorios, Servicios)
builder.Services.AddApplicationServices(builder.Configuration);

// 4. Autenticación JWT
builder.Services.AddJwtAuthentication(builder.Configuration);

// 5. Swagger OpenAPI con soporte JWT
builder.Services.AddSwaggerDocumentation();

var app = builder.Build();

// Middleware Global de Manejo de Excepciones
app.UseMiddleware<GlobalExceptionHandlerMiddleware>();

// Swagger UI disponible en /swagger y en la raíz /
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "El Camino del Guardabarranco API v1");
    c.RoutePrefix = "swagger";
});

// Redirigir la raíz "/" a "/swagger" para que funcione siempre
app.MapGet("/", () => Results.Redirect("/swagger"));

app.UseCors("AllowFlutterDev");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
