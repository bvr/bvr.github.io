
class Program
{
    public static SafeUsage()
    {
        // Assume Database class from earlier, built on top of Dapper
        string connStr = "Server=.;Database=MyApp;Trusted_Connection=True;";
        using var db = new Database("System.Data.SqlClient", connStr);

        // --- 1. Non-transactional (safe, short-lived connections) ---
        var customers = db.Query<Customer>(
            "SELECT Id, Name FROM Customers WHERE Country = @country",
            new { country = "USA" });

        foreach (var c in customers)
        {
            Console.WriteLine($"{c.Id} - {c.Name}");
        }

        // Each query here opens + closes a connection immediately (pooling makes it fast).
    }

    public static void TransactionalUsage()
    {
        // --- 2. Transactional block (persistent connection until Commit/Rollback) ---
        using var db = new Database("System.Data.SqlClient", connStr);

        db.BeginTransaction();
        try
        {
            // deduct funds
            db.Execute(
                "UPDATE Accounts SET Balance = Balance - @amount WHERE Id = @id",
                new { id = 1, amount = 500 });

            // add funds
            db.Execute(
                "UPDATE Accounts SET Balance = Balance + @amount WHERE Id = @id",
                new { id = 2, amount = 500 });

            // log transfer
            db.Execute(
                "INSERT INTO Transfers (FromAccount, ToAccount, Amount) VALUES (@from, @to, @amt)",
                new { from = 1, to = 2, amt = 500 });

            // commit the entire block
            db.Commit();
        }
        catch
        {
            // rollback if anything fails
            db.Rollback();
            throw;
        }
    }
}
