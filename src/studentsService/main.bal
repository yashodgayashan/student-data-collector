import manageStudents;
import ballerina/http;
import ballerina/io;
import ballerina/jsonutils;
import ballerina/lang.'int as ints;

http:Client clientEP = new ("http://localhost:9090");

@http:ServiceConfig {
    basePath: "/student",
    cors: {
        allowOrigins: ["*"]
    }
}

service studentService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/getAllStudents"
    }
    resource function getAllStudents(http:Caller caller, http:Request req) {

        table<record {}> | error allStudents = manageStudents:getAllStudents();
        http:Response response = new;

        if (allStudents is table<record {}>) {
            json retValJson = jsonutils:fromTable(allStudents);
            io:println("JSON: ", retValJson.toJsonString());

            response.setTextPayload(retValJson.toJsonString());
            response.statusCode = 200;
        } else {
            response.setPayload("Error in constructing a json from student!");
            response.statusCode = 500;
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/getStudent/{studentId}"
    }
    resource function getStudent(http:Caller caller, http:Request req, int studentId) {

        manageStudents:Student | error student = manageStudents:getStudent(studentId);
        http:Response response = new;

        if (student is manageStudents:Student) {
            json | error retValJson = json.constructFrom(student);

            if (retValJson is json) {
                io:println("JSON: ", retValJson.toJsonString());
                response.setTextPayload(<@untained>retValJson.toJsonString());
                response.statusCode = 200;
            } else {
                response.setPayload("Error in constructing a json from student!");
                response.statusCode = 500;
            }
        } else {
            response.setPayload("Error in constructing a json from student!");
            response.statusCode = 500;
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/insertStudent"
    }
    resource function insertStudent(http:Caller caller, http:Request
    request) {

        http:Response response = new;
        var jsonPaylon = request.getJsonPayload();

        if (jsonPaylon is json) {

            int | error studentId = ints:fromString(jsonPaylon.student.id.toString());
            string fullName = jsonPaylon.student.fullName.toString();
            int | error age = ints:fromString(jsonPaylon.student.age.toString());
            string address = jsonPaylon.student.address.toString();

            boolean | error insertionStatus;

            if (studentId is int && age is int) {
                insertionStatus = manageStudents:insertStudent(studentId, fullName, age, address);

                if (insertionStatus is boolean && insertionStatus == true) {
                    io:print("Student inserted successfully!");
                    response.setPayload("Student inserted successfully!");
                    response.statusCode = 200;
                } else {
                    io:print("Student inserted failed!");
                    response.setPayload("Student insertion failed!");
                    response.statusCode = 500;
                }
            } else {
                io:print("Invalid inputs!");
                response.setPayload("Invalid inputs!");
                response.statusCode = 500;
            }

        } else {
            response.statusCode = 400;
            io:print("Invalid payload received!");
            response.setPayload("Invalid payload received");
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/updateStudent"
    }
    resource function updateStudent(http:Caller caller, http:Request
    request) {

        http:Response response = new;
        var jsonPaylon = request.getJsonPayload();

        if (jsonPaylon is json) {

            int | error studentId = ints:fromString(jsonPaylon.student.id.toString());
            string fullName = jsonPaylon.student.fullName.toString();
            int | error age = ints:fromString(jsonPaylon.student.age.toString());
            string address = jsonPaylon.student.address.toString();

            boolean | error updationStatus;

            if (studentId is int && age is int) {
                updationStatus = manageStudents:updateStudent(studentId, fullName, age, address);

                if (updationStatus is boolean && updationStatus == true) {
                    response.setPayload("Student updated successfully!");
                    response.statusCode = 200;
                } else {
                    response.setPayload("Student updation failed!");
                    response.statusCode = 500;
                }
            } else {
                response.setPayload("Invalid inputs!");
                response.statusCode = 500;
            }

        } else {
            response.statusCode = 400;
            response.setPayload("Invalid payload received");
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/deleteStudent/{studentId}"
    }
    resource function deleteStudent(http:Caller caller, http:Request req, int studentId) {

        boolean | error status = manageStudents:deleteStudent(studentId);
        http:Response response = new;

        if (status is boolean && status == true) {
            response.setPayload("Student deleted successfully!");
            response.statusCode = 200;
        } else {
            response.setPayload("Could not delete the specified student!");
            response.statusCode = 500;
        }

        error? respond = caller->respond(response);
    }
}
