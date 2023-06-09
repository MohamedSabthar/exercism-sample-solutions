# Instructions

Calling APIs can be error-prone when using raw text or JSON. In this exercise, you will use Ballerina Records to organize the request payloads and ensure successful communication with external reservation endpoints.

## Objectives

- Modify the provided code.
- Reserve an airline ticket for the user by calling the Airline reservation service. Send a post request to airlineReservationService with the appropriate payload and get a response
- Reserve a hotel room for the user by calling the Hotel reservation service. Send a post request to hotelReservationService with the appropriate payload and get a response
- Rent a car for the user by calling the Car rental service. Send a post request to carRentalService with the appropriate payload and check the response
- If everything is successful, return a body with a message attribute of "Congratulations! Your journey is ready!!"
