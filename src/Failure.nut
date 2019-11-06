class Failure {
    message = ""
    description = ""

    constructor(failureMessage, descriptionMessage = "") {
        message = failureMessage
        description = descriptionMessage
    }

    _tostring = function() {
        local descriptionPart = ""
        if (description != "") {
            descriptionPart = ": " + description
        }
        return message + descriptionPart
    }
}
