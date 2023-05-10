import ballerinax/java.jdbc;

configurable string username = "root";
configurable string password = "root";

function getHighPaymentEmployees(string dbFilePath, decimal amount) returns string[]|error {
    jdbc:Client dbClient = check new ("jdbc:h2:file:" + dbFilePath, username, password);
    stream<PaymentData, error?> employeeStream = dbClient->query(
        `SELECT P.payment_id, P.amount, E.name 
        FROM PAYMENT P LEFT JOIN EMPLOYEE E 
        on E.employee_id = P.employee_id`);

    table<PaymentData> key(payment_id) paymentTable = table [];
    check from PaymentData paymentData in employeeStream
        do {
            paymentTable.add(paymentData);
        };

    table<PaymentData> highPayments = from PaymentData payment in paymentTable
        where payment.amount > amount
        order by payment.name
        select payment;

    map<()> names = {};
    foreach PaymentData paymentData in highPayments {
        names[paymentData.name] = ();
    }
    return names.keys();
}

type PaymentData record {
    readonly int payment_id;
    decimal amount;
    string name;
};
