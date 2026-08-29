using System.Data;

namespace ElCaminoGuardabarranco.API.Data
{
    public interface IDbConnectionFactory
    {
        IDbConnection CreateConnection();
    }
}
