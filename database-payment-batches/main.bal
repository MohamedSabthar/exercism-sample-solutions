import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/io;

configurable string username = "root";
configurable string password = "root";

function addPayments(string dbFilePath, string paymentFilePath) returns error|int[] {
    json payload = check io:fileReadJson(paymentFilePath);
    Payments[] payments = check payload.cloneWithType();

    jdbc:Client dbClient = check new (string `jdbc:h2:file:${dbFilePath}`, username, password);
    sql:ParameterizedQuery[] insertQueries = from var row in payments
        select `INSERT INTO PAYMENT (employee_id, amount, reason, date)
                VALUES (${row.employee_id}, ${row.amount}, ${row.reason}, ${row.date})`;

    sql:ExecutionResult[] results = check dbClient->batchExecute(insertQueries);
    check dbClient.close();
   
    return results.'map(getId);
}

function getId(sql:ExecutionResult result) returns int {
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    }
    if lastInsertId is () {
        return -1;
    }
    int|error id = int:fromString(lastInsertId);
    return id is error ? -1 : id;
}

type Payments record {
    int employee_id;
    decimal amount;
    string reason;
    string date;
};
