@include once "src/electric-imp-stubs/common.stub.nut"
@include once "src/libraries/JSONParser.class.nut"

// Imp stub API

// Agent-only objects
class device {
    static handlers = {};
    static connectionHandlers = {};

    static stub = {
        connect = true,
        function connected() {
            connect = true;
        },
        function disconnected() {
            connect = false;
        }
    }

    static capture = {
        sendMessage = null,
        sendData = null,
    };

    function reset() {
        stub.connected();
        capture.sendMessage = null;
        capture.sendData = null;
    }

    //===============================
    function info() {
        return {
            id = "5000a0c9a012345e",
            isconnected = isconnected(),
            ipaddress = "192.168.0.20"
        }
    }

    function isconnected() {
        return stub.connect;
    }

    function on(messageName, callback) {
        handlers[messageName] <- callback;
    }

    function onconnect(callback) {
        connectionHandlers["onConnect"] <- callback;
    }

    function ondisconnect(callback) {
        connectionHandlers["onDisconnect"] <- callback;
    }

    function send(messageName, data) {
        capture.sendMessage = messageName;
        capture.sendData = data;
    }
}

class server {
    handler = {
        shutdown = null
    };

    stub = {
        connected = true,
        function reset() {
            connected = true;
        }
    };

    capture = {
        data = {},
        restarted = false,
        function reset() {
            data = {};
            restarted = false;
        }
    };
    function reset() {
        stub.reset();
        capture.reset();
    }
//====================================

    function bless(testSuccess, callback) {
        throw "Unsupported on agent";
    }
    function connect(onConnectedCallback, timeout) {
        throw "Unsupported on agent";
    }
    function disconnect() {
        throw "Unsupported on agent";
    }
    function error(message) {
        print("ERROR: " + message + "\n");
        return 0;
    }
    function factoryblinkup(SSID, password, pin, flags) {
        throw "Unsupported on agent";
    }
    function flush(timeout) {
        throw "Unsupported on agent";
    }
    function isconnected() {
        throw "Unsupported on agent";
    }
    function load() {
        return server.capture.data;
    }
    function log(message) {
        print(message + "\n");
        return 0;
    }
    function onshutdown(callback) {
        throw "Unsupported on agent";
    }
    function onunexpecteddisconnect(callback) {
        throw "Unsupported on agent";
    }
    function restart() {
        server.capture.restarted = true;
    }
    function save(dataToSave) {
        if( typeof dataToSave == "table" ) {
            server.capture.data = dataToSave;
        } else {
            throw "Data is not a table";
        }
    }
    function setsendtimeoutpolicy(onError, waitFor, timeout) {
        throw "Unsupported on agent";
    }
    function sleepfor(sleepTime) {
        throw "Unsupported on agent and imp005";
    }
    function sleepuntil(hour, minute, second, dayOfWeek) {
        throw "Unsupported on agent and imp005";
    }
}

class ftp {
    function get(URL) {
        return "todo";
    }

    function put(URL, body) {
        return "todo";
    }
}

class http {

    stub = {
        _pauseNewRequests = false,
        function pauseNewRequests( onOff ) {
            _pauseNewRequests = onOff;
        }
    }

    callback = {
        onrequest = null
    }

    capture = {
        postUrl = null,
        postHeaders = null,
        postBody = null
    };

    captureHistory = [];
    requests = [];
    pauseRequests = false;

    hash = {
        // Key/data shared across hash functions, in a fit of optimism
        stub = {
            hmacsha1 = null
        },

        function hmacsha1(dataToHash, key) {return stub.hmacsha1;},

        function hmacsha256(dataToHash, key) {return "todo";},

        function hmacsha512(dataToHash, key) {return "todo";},

        function md5(dataToHash) {return "todo";},

        function sha1(dataToHash) {return "todo";},

        function sha256(dataToHash) {return "todo";},

        function sha512(dataToHash) {return "todo";},
    };

    function reset() {
        capture.postUrl = null;
        capture.postHeaders = null;
        capture.postBody = null;
        captureHistory.clear();
        requests.clear();
    }

    function agenturl() {
        return "todo";
    }

    function base64decode(dataToDecode) {
        return dataToDecode;
    }

    function base64encode(dataToEncode) {
        return dataToEncode;
    }

    function get(URL, headers) {
        local request = httprequest("get", URL, headers);
        if( stub._pauseNewRequests ) { request.stub.pause(); }
        requests.push(request);
        return request;
    }

    function httpdelete(URL, headers) {
        local request = httprequest("delete", URL, headers);
        if( stub._pauseNewRequests ) { request.stub.pause(); }
        requests.push(request);
        return request;
    }

    /*
    NOTE: jsondecode/jsonencode
    currently in test, json is a table that is set to a request's body, not as a string
    for now, just return json (that is not string) back ... until we have code to decode json string here
     */
    function jsondecode(json) {
        return JSONParser.parse(json);
    }

    function jsonencode(value) {
        return value;
    }

    function onrequest(cb) {
        callback.onrequest = cb;
    }

    function post(URL, headers, body) {
        capture.postUrl = URL;
        capture.postBody = body;
        capture.postHeaders = headers;
        captureHistory.push( {
            postUrl = deepClone(URL),
            postHeaders = deepClone(body),
            postBody = deepClone(headers)
        });
        local request = httprequest("post", URL, headers, body);
        if( stub._pauseNewRequests ) { request.stub.pause(); }
        requests.push(request);
        return request;
    }

    function put(URL, headers, body) {
        // todo capture=
        local request = httprequest("put", URL, headers body);
        if( stub._pauseNewRequests ) { request.stub.pause(); }
        requests.push(request);
        return request;
    }

    function request(method, URL, headers, body) {
        return "todo";
    }

    function urldecode(URLdataString) {
        return "todo";
    }

    function urlencode(dataTable) {
        return "todo";
    }
}

const VALIDATE_NONE = 0;
const VALIDATE_USING_SYSTEM_CA_CERTS = 1;

class httprequest {

    stub = null;
    _method = null;
    _postUrl = null;
    _postHeaders = null;
    _postBody = null;

    constructor( method, URL, headers, body = null ) {
        _method = method;
        _postUrl = URL;
        _postHeaders = deepClone(headers);
        _postBody = deepClone(body);

        stub = {
            isPaused = false,
            asyncCallback = null,
            sendResult = {statuscode = 200,headers = {},body = ""},
            function pause() {
                isPaused = true;
            },
            function unpause() {
                isPaused = false;
                asyncCallback(sendResult);
            },
            function sendSuccess() {
                sendResult = {statuscode = 200,headers = {},body = ""};
            },
            function sendFailed(statusCode=500) {
                sendResult = {statuscode = statusCode,headers = {},body = ""};
            }
        };
    }

    function reset() {
        if( stub ) { 
            stub.asyncCallback = null;
            stub.isPaused = false;
            stub.sendSuccess();
        }
    }

    //===========================
    function cancel() {}

    function sendasync(doneCallback, streamCallback=null, timeout=null) {
        if(stub.isPaused) {
            stub.asyncCallback = doneCallback;
        } else {
            doneCallback(stub.sendResult);
        }
    }

    function sendsync() {
        return stub.sendResult;
    }

    function setvalidation(validation) {
    }
}

class httpresponse {
    capture = {
        status = null,
        body = null
    }

    function reset() {
        httpresponse.capture.status = null;
        httpresponse.capture.body = null;
    }
    //================
    function header(headerName, headerValue) {
    }

    function send(statusCode, responseBody) {
        httpresponse.capture.status = statusCode;
        httpresponse.capture.body = responseBody;
    }
}

class regexp2 {
    _regexp = null;

    constructor(expression) {

        while( true ) {
            local startIndex = expression.find( "\\x{", 0 );
            if(startIndex == null) { break; }
            local endIndex = expression.find( "}", startIndex );
            if(endIndex == null) { break; }

            local start = expression.slice( 0, startIndex );
            local middle = expression.slice( startIndex+3, endIndex );

            switch( middle )
            {
                case "0009": middle = @"\t"; break;
                case "00A0": middle = @"\n"; break;
                case "00C0": middle = @"\f"; break;
                case "00D0": middle = @"\r"; break;
                case "0020": middle = @"\s"; break;
                default: break;
            }
            
            local end = expression.slice( endIndex+1, expression.len() );

            expression = start + middle + end;
        }

        _regexp = regexp(expression);
    }

    function capture(comparisonString, startIndex) {
        local captives = _regexp.capture(comparisonString, startIndex);

        if(captives != null) {
            foreach(captive in captives) {
                if( captive.begin == 0 && captive.end == 0 ) {
                    captive.begin = -1;
                    captive.end = -1;
                }
            }
        }

        return captives;
    }

    function match(comparisonString) {
        return _regexp.match(comparisonString);
    }

    function search(comparisonString, startIndex) {
        return _regexp.search(comparisonString, startIndex);
    }
}