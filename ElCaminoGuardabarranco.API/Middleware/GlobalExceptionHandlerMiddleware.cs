using System.Net;
using System.Text.Json;
using ElCaminoGuardabarranco.API.DTOs.Common;
using Microsoft.Data.SqlClient;

namespace ElCaminoGuardabarranco.API.Middleware
{
    public class GlobalExceptionHandlerMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionHandlerMiddleware> _logger;

        public GlobalExceptionHandlerMiddleware(RequestDelegate next, ILogger<GlobalExceptionHandlerMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Excepción no controlada detectada: {Message}", ex.Message);
                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            var response = new ApiResponse<object>
            {
                Success = false,
                Message = exception.Message,
                Errors = new List<string> { exception.Message }
            };

            if (exception is SqlException sqlEx)
            {
                // Errores lanzados por RAISERROR o THROW en Stored Procedures
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                response.Message = sqlEx.Message;
            }
            else if (exception is ArgumentException || exception is InvalidOperationException)
            {
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            else
            {
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                response.Message = "Ocurrió un error inesperado en el servidor.";
            }

            var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
            await context.Response.WriteAsync(JsonSerializer.Serialize(response, options));
        }
    }
}
