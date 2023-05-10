import ballerina/io;

function processFuelRecords(string inputFile, string outputFile) returns error? {
    map<FillUp[]> employeeFillUps = check readEmployeeFuleFillUpCsv(inputFile);
    table<FillUpSummary> fuleFillUpSummary = table [];
    employeeFillUps.'forEach(records => fuleFillUpSummary.add(summurizeEmployeeFillUps(records)));

    string[][] summary = from var employeeSummary in fuleFillUpSummary
        order by employeeSummary.employee_id
        select [
            employeeSummary.employee_id.toString(),
            employeeSummary.gas_fill_up_count.toString(),
            employeeSummary.total_fuel_cost.toString(),
            employeeSummary.total_gallons.toString(),
            employeeSummary.total_miles_accrued.toString()
        ];

    check io:fileWriteCsv(outputFile, summary);
}

function readEmployeeFuleFillUpCsv(string inputFile) returns map<FillUp[]>|error {
    string[][] fillUps = check io:fileReadCsv(inputFile);
    map<FillUp[]> employeeFillUps = {};

    foreach string[] fillUp in fillUps {
        FillUp fillUpRecord = {
            employee_id: check int:fromString(fillUp[0].trim()),
            odometer_reading: check int:fromString(fillUp[1].trim()),
            gallons: check decimal:fromString(fillUp[2].trim()),
            gas_price: check decimal:fromString(fillUp[3].trim())
        };
        string employeeId = fillUp[0];
        if !employeeFillUps.hasKey(employeeId) {
            employeeFillUps[employeeId] = [];
        }
        employeeFillUps.get(employeeId).push(fillUpRecord);
    }
    return employeeFillUps;
}

function summurizeEmployeeFillUps(FillUp[] fillUps) returns FillUpSummary {
    int gas_fill_up_count = fillUps.length();
    [decimal, decimal] [totalCost, total_gallons] = fillUps.reduce(summarizedTotalCostAndGallons, [0, 0]);
    int total_miles_accrued = fillUps[gas_fill_up_count - 1].odometer_reading - fillUps[0].odometer_reading;

    return {
        employee_id: fillUps[0].employee_id,
        gas_fill_up_count,
        total_fuel_cost: totalCost,
        total_gallons,
        total_miles_accrued
    };
}

function summarizedTotalCostAndGallons([decimal, decimal] total, FillUp fillUp) returns [decimal, decimal] {
    [decimal, decimal] [totalCost, total_gallons] = total;
    return [totalCost + (fillUp.gallons * fillUp.gas_price), total_gallons + fillUp.gallons];
};

type FillUp record {|
    int employee_id;
    int odometer_reading;
    decimal gallons;
    decimal gas_price;
|};

type FillUpSummary record {|
    readonly & int employee_id;
    int gas_fill_up_count;
    decimal total_fuel_cost;
    decimal total_gallons;
    int total_miles_accrued;
|};
