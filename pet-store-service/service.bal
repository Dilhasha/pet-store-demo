import ballerina/http;

type Pet record {|
    string id;
    string name;
    boolean isAvailable;
|};

configurable int port = 9090;
configurable string hostEp = "localhost";

listener http:Listener petstoreListener = new (port, config = {host: hostEp});

service / on petstoreListener {

    private map<Pet> petInventory = {};

    # Retrieve the pet details in for a given pet id.
    #
    # + petId - pet id
    # + return - pet details if the pet with given id exists
    # or http:NotFound if the pet with given id does not exist
    resource isolated function get pet/[string petId]() returns Pet|http:NotFound {
        lock {
            Pet? pet = self.petInventory[petId];
            if (pet is Pet) {
                return pet.clone();
            } else {
                http:NotFound response = {body: "No pet is listed with the given pet id " + petId};
                return response.clone();
            }
        }
    }

    # Add the pet details to the pet store.
    #
    # + payload - Pet details
    # + return - Pet details if the operation was successful
    # or http:MethodNotAllowed if pet with given id already exists
    resource isolated function post pet(@http:Payload Pet payload) returns Pet|http:MethodNotAllowed {
        lock {
            if (self.petInventory[payload.id] is ()) {
                self.petInventory[payload.id] = payload.clone();
                return payload.clone();
            } else {
                http:MethodNotAllowed response = {body: "A pet with given pet id " + payload.id + " already exists in the inventory."};
                return response.clone();
            }
        }
    }

}
