import ballerina/io;
import ballerina/h2;
import ballerina/sql;

// Create an endpoint for the first database named testdb1. Since this endpoint
// participates in a distributed transaction, the `isXA` property should be true.
h2:Client testDB1 = new({
    path: "./xa-transactions/",
    name: "Testdb1",
    username: "test",
    password: "test",
    poolOptions: { maximumPoolSize: 5, isXA: true }
});

// Create an endpoint for the second database named testdb2. Since this endpoint
// participates in a distributed transaction, the `isXA` property should be true.
h2:Client testDB2 = new({
    path: "./xa-transactions/",
    name: "Testdb2",
    username: "test",
    password: "test",
    poolOptions: { maximumPoolSize: 5, isXA: true }
});

public function main() {
    // Create the table named CUSTOMER in the first database.
    var ret = testDB1->update("CREATE TABLE CUSTOMER (ID INTEGER
                    AUTO_INCREMENT, NAME VARCHAR(30))");
    handleUpdate(ret, "Create CUSTOMER table");
    // Create the table named SALARY in the second database.
    ret = testDB2->update("CREATE TABLE SALARY (ID INT, VALUE FLOAT)");
    handleUpdate(ret, "Create SALARY table");

    // Begins the transaction.
    transaction {
        // This is the first remote function to participate in the transaction. It inserts
        // customer name to the first DB and gets the generated key.
        var result = testDB1->update("INSERT INTO CUSTOMER(NAME)
                                        VALUES ('Anne')");
        int key = -1;
        if (result is sql:UpdateResult) {
            int count = result.updatedRowCount;
            key = <int>result.generatedKeys.ID;
            io:println("Inserted row count: " + count);
            io:println("Generated key: " + key);
        } else {
            io:println("Insert to student table failed: " + result.reason());
        }

        // This is the second remote function to participate in the transaction. It inserts the
        // salary info to the second DB along with the key generated in the first DB.
        ret = testDB2->update("INSERT INTO SALARY (ID, VALUE) VALUES (?, ?)",
                                    key, 2500);
        handleUpdate(ret, "Insert to SALARY table");
    } onretry {
        io:println("Retrying transaction");
    } committed {
        io:println("Transaction committed");
    } aborted {
        io:println("Transaction aborted");
    }

    // Drop the tables created for this sample.
    ret = testDB1->update("DROP TABLE CUSTOMER");
    handleUpdate(ret, "Drop Table CUSTOMER");

    ret = testDB2->update("DROP TABLE SALARY");
    handleUpdate(ret, "Drop Table SALARY");

    // Stop database clients.
    stopClient(testDB1);
    stopClient(testDB2);
}

function onCommitFunction(string transactionId) {
    io:println("Transaction: " + transactionId + " committed");
}

function onAbortFunction(string transactionId) {
    io:println("Transaction: " + transactionId + " aborted");
}

// Function to handle return values of the `update()` remote function.
function handleUpdate(sql:UpdateResult|error returned, string message) {
    if (returned is sql:UpdateResult) {
        io:println(message + " status: " + returned.updatedRowCount);
    } else {
        io:println(message + " failed: " + returned.reason());
    }
}

function stopClient(h2:Client db) {
    var stopRet = db.stop();
    if (stopRet is error) {
        io:println(stopRet.detail().message);
    }
}
