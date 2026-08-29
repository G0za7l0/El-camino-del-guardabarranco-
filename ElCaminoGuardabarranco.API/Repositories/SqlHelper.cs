using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Dapper;

namespace ElCaminoGuardabarranco.API.Repositories
{
    public class FlexibleBooleanConverter : JsonConverter<bool>
    {
        public override bool Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType == JsonTokenType.True)
                return true;
            if (reader.TokenType == JsonTokenType.False)
                return false;
            if (reader.TokenType == JsonTokenType.Number)
                return reader.GetInt64() != 0;
            if (reader.TokenType == JsonTokenType.String)
            {
                var str = reader.GetString();
                if (bool.TryParse(str, out var b))
                    return b;
                if (long.TryParse(str, out var num))
                    return num != 0;
            }
            return false;
        }

        public override void Write(Utf8JsonWriter writer, bool value, JsonSerializerOptions options)
        {
            writer.WriteBooleanValue(value);
        }
    }

    public static class SqlHelper
    {
        public static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true,
            Converters = { new FlexibleBooleanConverter() }
        };

        public static async Task<string> QueryJsonRawAsync(IDbConnection db, string spName, object? parameters = null)
        {
            if (db.State != ConnectionState.Open)
            {
                if (db is DbConnection dbConn)
                    await dbConn.OpenAsync();
                else
                    db.Open();
            }

            using var reader = await db.ExecuteReaderAsync(spName, parameters, commandType: CommandType.StoredProcedure);
            var sb = new StringBuilder();
            while (reader.Read())
            {
                if (!reader.IsDBNull(0))
                {
                    sb.Append(reader.GetString(0));
                }
            }
            return sb.ToString();
        }

        public static async Task<T?> QueryJsonSingleAsync<T>(IDbConnection db, string spName, object? parameters = null) where T : class
        {
            var json = await QueryJsonRawAsync(db, spName, parameters);
            if (string.IsNullOrWhiteSpace(json) || json == "null")
                return null;

            return JsonSerializer.Deserialize<T>(json, JsonOptions);
        }

        public static async Task<List<T>> QueryJsonListAsync<T>(IDbConnection db, string spName, object? parameters = null)
        {
            var json = await QueryJsonRawAsync(db, spName, parameters);
            if (string.IsNullOrWhiteSpace(json) || json == "null")
                return new List<T>();

            return JsonSerializer.Deserialize<List<T>>(json, JsonOptions) ?? new List<T>();
        }
    }
}
