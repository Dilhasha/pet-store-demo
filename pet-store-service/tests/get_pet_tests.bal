import ballerina/test;
import ballerina/http;

http:Client petStoreClient = check new ("http://localhost:9090");

# Get pet details for a non existent pet id.
#
# + return - Return an error or nil if there is no error  
@test:Config {}
function getNonExistentPet() returns error? {
    http:Response response = check petStoreClient->get("/pet/FISH0028");
    // Asserts the expected status code
    test:assertEquals(response.statusCode, 404, "The response contains unexpected status code.");
    // Asserts the expected payload
    test:assertEquals(response.getTextPayload(), "No pet is listed with the given pet id FISH0028", "The returned response does not match the expected");
}

# Get pet details for an existing pet id.
#
# + return - Return an error or nil if there is no error
@test:Config {
    dependsOn: [addNewPet]
}
function getExistingPet() returns error? {
    // Get resource function returns http:Response or http:ClientError
    // The check expression is used to proceed if there is no error returned
    http:Response response = check petStoreClient->get("/pet/PARROT0009");
    // Asserts the expected status code
    test:assertEquals(response.statusCode, 200, "The response contains unexpected status code.");
    // Asserts the expected JSON payload
    test:assertEquals(response.getJsonPayload(), {"id": "PARROT0009", "name": "Dakota", "isAvailable": false},
    "The returned response does not match the expected");
}
