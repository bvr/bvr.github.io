
public class Database : IDisposable
{
    private readonly string _providerName;
    private readonly string _connectionString;
    private DbConnection? _connection;
    private DbTransaction? _transaction;

    public Database(string providerName, string connectionString)
    {
        _providerName = providerName;
        _connectionString = connectionString;
    }

    private DbConnection GetConnection()
    {
        if (_transaction != null)
        {
            // In transaction: keep the same connection
            if (_connection == null)
                throw new InvalidOperationException("Transaction connection missing.");
            return _connection;
        }
        else
        {
            // Non-transaction: open, use, dispose immediately
            var factory = DbProviderFactories.GetFactory(_providerName);
            var conn = factory.CreateConnection()!;
            conn.ConnectionString = _connectionString;
            conn.Open();
            return conn;
        }
    }

    // Dapper helpers
    public IEnumerable<T> Query<T>(string sql, object? param = null)
    {
        if (_transaction != null)
            return _connection!.Query<T>(sql, param, _transaction);

        using var conn = GetConnection();
        return conn.Query<T>(sql, param);
    }

    public int Execute(string sql, object? param = null)
    {
        if (_transaction != null)
            return _connection!.Execute(sql, param, _transaction);

        using var conn = GetConnection();
        return conn.Execute(sql, param);
    }

    // Transactions
    public void BeginTransaction()
    {
        if (_transaction != null)
            throw new InvalidOperationException("Transaction already started.");

        var factory = DbProviderFactories.GetFactory(_providerName);
        _connection = factory.CreateConnection()!;
        _connection.ConnectionString = _connectionString;
        _connection.Open();
        _transaction = _connection.BeginTransaction();
    }

    public void Commit()
    {
        _transaction?.Commit();
        CleanupTransaction();
    }

    public void Rollback()
    {
        _transaction?.Rollback();
        CleanupTransaction();
    }

    private void CleanupTransaction()
    {
        _transaction?.Dispose();
        _transaction = null;
        _connection?.Dispose();
        _connection = null;
    }

    public void Dispose() => CleanupTransaction();
}
