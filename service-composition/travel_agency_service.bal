import ballerina/http;

final http:Client airlineReservationEP = check new ("http://localhost:9091/airline");
final http:Client hotelReservationEP = check new ("http://localhost:9092/hotel");
final http:Client carRentalEP = check new ("http://localhost:9093/car");

service /travel on new http:Listener(9090) {

    resource function post arrangeTour(TourArrangement arrangement) returns http:BadRequest|http:Created {
        TourArrangement {name, arrivalDate, departureDate, preference} = arrangement;
        Preference {car, accomodation, airline} = preference;
        Reservation reservation = {name, arrivalDate, departureDate, preference: airline};
        ServiceResponse|error response = airlineReservationEP->post("/reserve", reservation);
        if response is error || response.status == FAILED {
            return createBadRequestResponse("Failed to reserve airline! Provide a valid 'preference' for 'airline' and try again");
        }

        reservation.preference = car;
        response = carRentalEP->post("/rent", reservation);
        if response is error || response.status == FAILED {
            return createBadRequestResponse("Failed to rent car! Provide a valid 'preference' for 'car' and try again");
        }

        reservation.preference = accomodation;
        response = hotelReservationEP->post("/reserve", reservation);
        if response is error || response.status == FAILED {
            return createBadRequestResponse("Failed to reserve hotel! Provide a valid 'preference' for 'accommodation' and try again");
        }

        http:Created success = {body: {message: "Congratulations! Your journey is ready!!"}};
        return success;
    }
}

function createBadRequestResponse(string message) returns http:BadRequest {
    http:BadRequest badRequest = {body: {"message": message}};
    return badRequest;
}

# The payload type received from the tour arrangement service.
#
# + name - Name of the tourist
# + arrivalDate - The arrival date of the tourist
# + departureDate - The departure date of the tourist
# + preference - The preferences for the airline, hotel, and the car rental
type TourArrangement record {|
    string name;
    string arrivalDate;
    string departureDate;
    Preference preference;
|};

# The different prefenrences for the tour.
#
# + airline - The preference for airline ticket. Can be `First`, `Bussiness`, `Economy`
# + accomodation - The prefenerece for the hotel reservarion. Can be `delux` or `superior`
# + car - The preference for the car rental. Can be `air conditioned`, or `normal`
type Preference record {|
    string airline;
    string accomodation;
    string car;
|};

// Define a record type to send requests to the reservation services.
type Reservation record {|
    string name;
    string arrivalDate;
    string departureDate;
    string preference;
|};

// The response type received from the reservation services
type ServiceResponse record {|
    Status status;
|};

// Possible statuses of the reservation service responses
enum Status {
    SUCCESS = "Success",
    FAILED = "Failed"
}

