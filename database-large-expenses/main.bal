import ballerinax/java.jdbc;
import ballerina/sql;

configurable string username = "root";
configurable string password = "root";

function getHighPaymentDetails(string dbFilePath, decimal amount) returns HighPayment[]|error {
    jdbc:Client dbClient = check new (string `jdbc:h2:file:${dbFilePath}`, username, password);

    sql:ParameterizedQuery query = `SELECT E.name AS name, E.department AS department, P.amount AS amount,
                                    P.reason AS reason
                                    FROM Employee AS E INNER JOIN Payment AS P ON E.employee_id = P.employee_id
                                    WHERE P.amount > ${amount} ORDER BY P.payment_id`;
    stream<HighPayment, error?> results = dbClient->query(query);
    check dbClient.close();

    HighPayment[]? highPayments = check from var payments in results
        select payments;
    check results.close();

    return highPayments ?: [];
}

type HighPayment record {
    string name;
    string department;
    decimal amount;
    string reason;
};
