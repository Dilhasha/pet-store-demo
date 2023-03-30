import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

type Pet record {|
    string id;
    string name;
    @sql:Column {name: "is_available"}
    boolean isAvailable;
|};

configurable int port = 9090;
configurable string hostEp = "localhost";

type DataBaseConfig record {|
    string host;
    int port;
    string user;
    string password;
    string database;
|};

configurable DataBaseConfig databaseConfig = ?;
final mysql:Client petstoreDbClient = check initDbClient();

function initDbClient() returns mysql:Client|error => new (...databaseConfig);

listener http:Listener petstoreListener = new (port, config = {host: hostEp});

service / on petstoreListener {

    # Retrieve the pet details for a given pet id.
    #
    # + petId - Parameter Description
    # + return - pet details if the pet with given id exists
    # or http:NotFound if the pet with given id does not exist
    # or http:BadRequest if the request format is incorrect
    resource isolated function get pet/[string petId]() returns Pet|http:NotFound|error {
        Pet|error result = petstoreDbClient->queryRow(`SELECT * FROM pets WHERE ID = ${petId}`);
        if result is sql:NoRowsError {
            http:NotFound response = {body: "No pet is listed with the given pet id " + petId};
            return response.clone();
        }
        return result;
    }

    # Add the pet details passed in json format to the pet store.
    #
    # + payload - Pet details
    # + return - http:Created if the pet addition was successful
    # or http:MethodNotAllowed if pet with given id already exists
    # or http:BadRequest if the request format is incorrect
    resource isolated function post pet(@http:Payload Pet payload) returns Pet|http:MethodNotAllowed|error {

        Pet|error result = petstoreDbClient->queryRow(`SELECT * FROM pets WHERE ID = ${payload.id}`);
        if result is Pet {
            http:MethodNotAllowed response = {body: "A pet with given pet id " + payload.id + " already exists in the inventory."};
            return response.clone();
        } else if result is sql:NoRowsError {
            _ = check petstoreDbClient->execute(`
            INSERT INTO pets(id, name, is_available)
            VALUES (${payload.id}, ${payload.name}, ${payload.isAvailable});`);
            return payload;
        } else {
            return result;
        }
    }

}
