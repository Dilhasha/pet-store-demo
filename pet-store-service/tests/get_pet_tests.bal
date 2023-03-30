import ballerina/test;
import ballerina/http;
import ballerina/sql;

http:Client petStoreClient = check new ("http://localhost:9090"); 

# Get pet details for a non existent pet id
# + return - Return an error or nil if there is no error  
@test:Config {}
function getNonExistentPet() returns error?{
    test:prepare(petstoreDbClient).when("queryRow").thenReturn(<sql:NoRowsError>error("No rows found"));
    http:Response response = check petStoreClient->get("/pet/FISH0028");
    // Asserts the expected status code
    test:assertEquals(response.statusCode, 404, "The response contains unexpected status code.");
    // Asserts the expected payload
    test:assertEquals(response.getTextPayload(), "No pet is listed with the given pet id FISH0028", "The returned response does not match the expected");
}

# Get pet details for an existing pet id
# + return - Return an error or nil if there is no error
@test:Config {}
function getExistingPet() returns error? {
    test:prepare(petstoreDbClient).when("queryRow").thenReturn(<Pet>{id:"PARROT0009",name:"Dakota", isAvailable:false});
    http:Response response = check petStoreClient->get("/pet/PARROT0009");
    // Asserts the expected status code
    test:assertEquals(response.statusCode, 200, "The response contains unexpected status code.");
    // Asserts the expected JSON payload
    test:assertEquals(response.getJsonPayload(), {"id": "PARROT0009", "name": "Dakota", "isAvailable": false}, "The returned response does not match the expected");
}
