import ballerina/io;

function processFuelRecords(string inputFile, string outputFile) returns error? {
    map<FillUp[]> employeeFillUps = check readEmployeeFuleFillUpJson(inputFile);

    table<FillUpSummary> fuleFillUpSummary = table [];
    employeeFillUps.'forEach(records => fuleFillUpSummary.add(summurizeEmployeeFillUps(records)));

    FillUpSummary[] summary = from var employeeSummary in fuleFillUpSummary
        order by employeeSummary.employeeId
        select employeeSummary;

    check io:fileWriteJson(outputFile, summary.toJson());
}

function readEmployeeFuleFillUpJson(string inputFile) returns map<FillUp[]>|error {
    json payload = check io:fileReadJson(inputFile);
    FillUp[] fillUps = check payload.cloneWithType();
    map<FillUp[]> employeeFillUps = {};

    while fillUps.length() > 0 {
        FillUp fillUp = fillUps.shift();
        string employeeId = fillUp.employeeId.toString();
        if !employeeFillUps.hasKey(employeeId) {
            employeeFillUps[employeeId] = [];
        }
        employeeFillUps.get(employeeId).push(fillUp);
    }
    return employeeFillUps;
}

function summurizeEmployeeFillUps(FillUp[] fillUps) returns FillUpSummary {
    int gasFillUpCount = fillUps.length();
    [decimal, decimal] [totalCost, totalGallons] = fillUps.reduce(summarizedTotalCostAndGallons, [0, 0]);
    int totalMilesAccrued = fillUps[gasFillUpCount - 1].odometerReading - fillUps[0].odometerReading;

    return {
        employeeId: fillUps[0].employeeId,
        gasFillUpCount,
        totalFuelCost: totalCost,
        totalGallons,
        totalMilesAccrued
    };
}

function summarizedTotalCostAndGallons([decimal, decimal] total, FillUp fillUp) returns [decimal, decimal] {
    [decimal, decimal] [totalCost, totalGallons] = total;
    return [totalCost + (fillUp.gallons * fillUp.gasPrice), totalGallons + fillUp.gallons];
};

type FillUp record {|
    int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
|};

type FillUpSummary record {|
    int employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
|};
