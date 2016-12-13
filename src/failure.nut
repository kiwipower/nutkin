class Failure {
    message = ""
    description = ""

    constructor(failureMessage, descriptionMessage = "") {
        message = failureMessage
        description = descriptionMessage
    }

    _tostring = function() {
        return message + ": " + description
    }
}
