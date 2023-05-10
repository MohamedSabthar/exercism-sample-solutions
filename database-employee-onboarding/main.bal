import ballerinax/java.jdbc;
import ballerina/sql;

configurable string username = "root";
configurable string password = "root";

function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {
    do {
        sql:ExecutionResult result = check addEmployeeRecord(dbFilePath, name, city, department, age);
        string|int lastInsertId = result.lastInsertId ?: -1;
        return lastInsertId is string ? check int:fromString(lastInsertId) : lastInsertId;
    } on fail {
        return -1;
    }
}

function addEmployeeRecord(string dbFilePath, string name, string city, string department, int age)
returns sql:ExecutionResult|sql:Error {
    jdbc:Client dbClient = check new (string `jdbc:h2:file:${dbFilePath}`, username, password);

    sql:ParameterizedQuery query = `INSERT INTO EMPLOYEE (name, city, department,age) 
                                    VALUES (${name}, ${city}, ${department}, ${age})`;
    sql:ExecutionResult result = check dbClient->execute(query);
    check dbClient.close();
    return result;
}
