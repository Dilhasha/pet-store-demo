import ballerina/http;
import ballerina/test;

@test:Config {
    dataProvider:  petData
}
function testPetData(json petDetails, int expectedStatusCode, string|json expectedMsg) returns error? {
    http:Response response = check petStoreClient->/pet.post(petDetails);
    test:assertEquals(response.statusCode, expectedStatusCode, "The expected status code was not returned.");
    if expectedMsg is string {
        test:assertEquals(response.getTextPayload(), expectedMsg, "The expected error message was not returned.");
    } else {
        test:assertEquals(response.getJsonPayload(), expectedMsg, "The expected success message was not returned.");
    }
}

# Pet details to be added to petstore.
# 
# + return - map of tuple with pet details or error
function petData() returns map<[json, int, string|json]>|error {
    map<[json, int, string|json]> dataSet = {
        "addNewPet": [{id: "PARROT0009", name: "Dakota", isAvailable: false}, 201, 
        {"id": "PARROT0009", "name": "Dakota", "isAvailable": false}],
        "addPetWithExistingId": [{id: "PARROT0009", name: "Dakota", isAvailable: false}, 405, 
        "A pet with given pet id PARROT0009 already exists in the inventory."]
    };
    return dataSet;
}

# Add pet details in an invalid data type.
#
# + return - Return an error or nil if there is no error   
@test:Config {}
function addPetAsString() returns error? {
    // Pass pet details in string format
    http:Response response = check petStoreClient->/pet.post("Invalid pet details in string format");
    test:assertEquals(response.statusCode, 400, "The expected status code was not returned.");
    // The response payload can be a string or http:ClientError.
    // Using the check expression, we will handle only if it is a string.
    string errorResponse = check response.getTextPayload();
    // The response message contains the position details as well. 
    // We can verify whether it is a data binding issue by checking 
    // if the error starts with that information as follows
    test:assertTrue(errorResponse.startsWith("data binding failed"));
}