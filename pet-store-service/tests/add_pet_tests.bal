import ballerina/http;
import ballerina/test;

# Add a pet that does not already exist.
#
# + return - Return an error or nil if there is no error  
@test:Config {}
function addNewPet() returns error? {
    http:Response response = check petStoreClient->/pet.post({id: "PARROT0009", name: "Dakota", isAvailable: false});
    test:assertEquals(response.statusCode, 201, "The expected status code was not returned.");
    test:assertEquals(response.getJsonPayload(), {"id": "PARROT0009", "name": "Dakota", "isAvailable": false},
    "The expected success message was not returned.");
}

# Add a pet that already exists.
#
# + return - Return an error or nil if there is no error   
@test:Config {
    dependsOn: [addNewPet]
}
function addPetWithExistingId() returns error? {
    http:Response response = check petStoreClient->/pet.post({id: "PARROT0009", name: "Dakota", isAvailable: false});
    test:assertEquals(response.statusCode, 405, "The expected status code was not returned.");
    test:assertEquals(response.getTextPayload(), "A pet with given pet id PARROT0009 already exists in the inventory.",
    "The expected error message was not returned.");
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
