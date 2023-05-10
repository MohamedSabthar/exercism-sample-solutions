import ballerina/io;
import ballerina/xmldata;

xmlns "http://www.so2w.org" as s;

function processFuelRecords(string inputFile, string outputFile) returns error? {
    map<FuelEvent[]> employeeFillUps = check readEmployeeFuleFillUpXml(inputFile);
    map<EmployeeFuelRecord> fuleFillUpSummary = employeeFillUps.'map(records => summurizeEmployeeFillUps(records));

    EmployeeFuelRecord[] summary = from var employeeSummary in fuleFillUpSummary
        order by employeeSummary.employeeId
        select employeeSummary;

    check writeToXmlFile(outputFile, summary);
}

function readEmployeeFuleFillUpXml(string inputFile) returns map<FuelEvent[]>|error {
    xml content = check io:fileReadXml(inputFile);
    FuelEvents fuleEvents = check xmldata:fromXml(content);
    map<FuelEvent[]> employeeFillUps = {};

    foreach FuelEvent event in fuleEvents.s\:FuelEvent {
        string employeeId = event.employeeId.toString();
        if !employeeFillUps.hasKey(employeeId) {
            employeeFillUps[employeeId] = [];
        }
        employeeFillUps.get(employeeId).push(event);
    }
    return employeeFillUps;
}

function summurizeEmployeeFillUps(FuelEvent[] fillUps) returns EmployeeFuelRecord {
    int gasFillUpCount = fillUps.length();

    var reduceTotal = function([decimal, decimal] total, FuelEvent fillUp) returns [decimal, decimal] {
        [decimal, decimal] [totalCost, totalGallons] = total;
        return [totalCost + (fillUp.s\:gallons * fillUp.s\:gasPrice), totalGallons + fillUp.s\:gallons];
    };
    [decimal, decimal] [totalCost, totalGallons] = fillUps.reduce(reduceTotal, [0, 0]);
    int totalMilesAccrued = fillUps[gasFillUpCount - 1].s\:odometerReading - fillUps[0].s\:odometerReading;

    return {
        employeeId: fillUps[0].employeeId,
        s\:gasFillUpCount: gasFillUpCount,
        s\:totalFuelCost: totalCost,
        s\:totalGallons: totalGallons,
        s\:totalMilesAccrued: totalMilesAccrued
    };
}

function writeToXmlFile(string outputFile, EmployeeFuelRecord[] summary) returns error? {
    employeeFuelRecords records = {s\:employeeFuelRecord: summary};
    xml content = check xmldata:toXml(records);
    check io:fileWriteXml(outputFile, content);
}

@xmldata:Namespace {
    prefix: "s",
    uri: "http://www.so2w.org"
}
type FuelEvents record {|
    FuelEvent[] s\:FuelEvent;
|};

type FuelEvent record {|
    @xmldata:Attribute
    int employeeId;
    int s\:odometerReading;
    decimal s\:gallons;
    decimal s\:gasPrice;
|};

@xmldata:Namespace {
    prefix: "s",
    uri: "http://www.so2w.org"
}
type employeeFuelRecords record {|
    EmployeeFuelRecord[] s\:employeeFuelRecord;
|};

type EmployeeFuelRecord record {|
    @xmldata:Attribute
    int employeeId;
    int s\:gasFillUpCount;
    decimal s\:totalFuelCost;
    decimal s\:totalGallons;
    int s\:totalMilesAccrued;
|};
