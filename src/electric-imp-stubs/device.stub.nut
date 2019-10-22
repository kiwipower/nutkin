@include once "src/electric-imp-stubs/common.stub.nut"

// Imp stub API

// Device-only objects
// ===================

const DIGITAL_IN = 256;
const DIGITAL_IN_PULLUP = 512;
const DIGITAL_IN_PULLDOWN = 768;
const DIGITAL_IN_WAKEUP = 2560;

const DIGITAL_OUT = 1024;
const DIGITAL_OUT_OD = 1280;
const DIGITAL_OUT_OD_PULLUP = 1536;

const PARITY_NONE = 42;
const NO_TX = 42;
const NO_RX = 43;
const NO_CTSRTS = 44;

const SUSPEND_ON_ERROR = 42;
const RETURN_ON_ERROR = 43;
const RETURN_ON_ERROR_NO_DISCONNECT = 44;
const WAIT_TIL_SENT = 42;
const WAIT_FOR_ACK = 43;

local __EI = {}
__EI.DEVICEGROUP_NAME <- "stub-group"
__EI.DEVICEGROUP_TYPE <- "stub-group-type"
__EI.DEVICEGROUP_ID <- "stub-group-id"
__EI.PRODUCT_NAME <- "stub-product-name"

class fixedfrequencydac {
    addbufferNewBuffer = null;
    function addbuffer(newBuffer) {
        addBufferNewBuffer = newBuffer;
    }
    function getLastAddbufferNewBuffer() {
        return addBufferNewBuffer;
    }

    configurePin = null;
    configureSampleRate = 0;
    configureBuffers = null;
    configureCallback = null;
    configureFlags = null;
    function configure(pin, sampleRate, buffers, callback) {
        configurePin = pin;
        configureSampleRate = sampleRate;
        configureBuffers = buffers;
        configureCallback = callback;
    }
    function configure(pin, sampleRate, buffers, callback, flags) {
        configure(pin, sampleRate, buffers, callback);
        configureFlags = flags;
    }
    function getLastConfigurePin() {
        return configurePin;
    }
    function getLastConfigureSampleRate() {
        return configureSampleRate;
    }
    function getLastConfigureBuffers() {
        return configureBuffers;
    }
    function getLastConfigureCallback() {
        return configureCallback;
    }
    function getLastConfigureFlags() {
        return configureFlags;
    }

    function start() {}

    stopFlag = null;
    function stop() {}
    function stop(flag) {
        stopFlag = flag;
    }
    function getLastStopFlag() {
        return stopFlag;
    }
}

const WAKEREASON_POWER_ON = 0;
const WAKEREASON_TIMER = 1;
const WAKEREASON_SW_RESET = 2;
const WAKEREASON_PIN = 3;
const WAKEREASON_NEW_SQUIRREL = 4;
const WAKEREASON_SQUIRREL_ERROR = 5;
const WAKEREASON_NEW_FIRMWARE = 6;
const WAKEREASON_SNOOZE = 7;
const WAKEREASON_HW_RESET = 8;
const WAKEREASON_BLINKUP = 9;
const WAKEREASON_SW_RESTART = 10;

const SERVER_CONNECTED = 5;
const NOT_CONNECTED = 0;
const NO_WIFI = 1;
const NO_LINK = 1;
const NOT_RESOLVED = 3;	
const NO_SERVER = 4;
const NO_PROXY = 6;
const NOT_AUTHORISED = 7;
const NO_MODEM = 8;
const SIM_ERROR = 9;
const NO_REGISTRATION = 10;
const REGISTRATION_DENIED = 11;
const NO_PPP_CONNECTION = 12;
const PPP_NO_CONNECTIVITY = 13;

class net {
    function info() {
        return null;
    }
}

const SHUTDOWN_NEWSQUIRREL = 1;
const SHUTDOWN_NEWFIRMWARE = 2;
const SHUTDOWN_OTHER = 3;

class server {
    handler = {
        shutdown = null
    };

    stub = {
        onunexpecteddisconnectcallback = null,
        connected = true,
        function reset() {
            connected = true;
        }
        function connect() {
            connected = true;
            if( onunexpecteddisconnectcallback ) {
                onunexpecteddisconnectcallback( SERVER_CONNECTED );
            }
        }
        function disconnect() {
            connected = false;
            if( onunexpecteddisconnectcallback ) {
                onunexpecteddisconnectcallback( NOT_CONNECTED );
            }
        }
    };

    capture = {
        data = null,
        restarted = false,
        function reset() {
            data = null;
            restarted = false;
        }
    };
    function reset() {
        stub.reset();
        capture.reset();
    }
    //====================================

    function bless(testSuccess, callback) {
        print("Attempting to bless this device");
    }
    function connect(onConnectedCallback, timeout) {}
    function disconnect() {}
    function error(message) {
        print("ERROR: " + message);
        return 0;
    }
    function factoryblinkup(SSID, password, pin, flags) {}
    function flush(timeout) {}
    function isconnected() {
        return stub.connected;
    }
    function load() {
        throw "Unsupported on device";
    }
    function log(message) {
        print(message + "\n");
        return 0;
    }
    function onshutdown(callback) {
        handler.shutdown = callback;
    }
    function onunexpecteddisconnect(callback) {
        stub.onunexpecteddisconnectcallback = callback;
    }
    function restart() {
        capture.restarted = true;
    }
    function save(dataToSave) {
        throw "Unsupported on device";
    }
    function setsendtimeoutpolicy(onError, waitFor, timeout) {}
    function sleepfor(sleepTime) {
        throw "Unsupported for imp005";
    }
    function sleepuntil(hour, minute, second, dayOfWeek) {
        throw "Unsupported for imp005";
    }
}

nv <- {};

const CLOCK_SPEED_10_KHZ = 10000;
const CLOCK_SPEED_50_KHZ = 50000;
const CLOCK_SPEED_100_KHZ = 100000;
const CLOCK_SPEED_400_KHZ = 400000;

const NO_ERROR = 0;
const MASTER_SELECT_ERROR = -1;
const TRANSMIT_SELECT_ERROR = -2;
const TRANSMIT_ERROR = -3;
const BTF_ERROR = -4;
const STOP_ERROR = -5;
const ADDR_CLEAR_ERROR = -6;
const ADDR_RXNE_ERROR = -7;
const DATA_RXNE_ERROR = -8;
const SLAVE_NACKED_ERROR = -9;
const MASTER_RECEIVE_SELECT_ERROR = -10;
const RECEIVE_ERROR = -11;
const RESELECT_ERROR = -12;
const NOT_ENABLED = -13;

class i2c {
    function isAStub() {}

    stub = {
        clockSpeed = CLOCK_SPEED_400_KHZ,
        disabled = false,
        readReturn = null,
        readError = NO_ERROR,
        writeReturn = NO_ERROR,
        function setReadReturn(byteArray) {
            readReturn = byteArray;
        },
        function reset() {
            clockSpeed = CLOCK_SPEED_400_KHZ;
            disabled = false;
            readReturn = null;
            readError = NO_ERROR;
            writeReturn = 0;
        }
    }

    capture = {
        write = {
            deviceAddress = null,
            registerPlusData = null
        },
        function reset() {
            write.deviceAddress = null;
            write.registerPlusData = null;
        }
    }

    function reset() {
        i2c.stub.reset();
        i2c.capture.reset();
    }
    //==================

    function configure(clockSpeed) {
        i2c.stub.clockSpeed = clockSpeed;
    }

    function disable() {
        i2c.stub.disabled = true;
    }

    /*
    Electric imp: read returns a string with [numberOfBytes] length
    and each index in the string holds a charactor (int) which is a byte
    Stub Hack!!!: stub.readReturn will instead returns an array of integers
    This is because char.tointeger() on squirrel when running unit tests returns a signed integer,
    whereas it will be unsigned integer when running on the imp device.
    For example, "\xC0"[0].tointeger() gives -64 on squirrel, but 192 on the imp device.
     */
    function read(deviceAddress, registerAddress, numberOfBytes) {
        if(i2c.stub.readError == NO_ERROR) {
            if(i2c.stub.readReturn == null) {
                return array(numberOfBytes, 0);
            } else {
                return i2c.stub.readReturn;
            }
        } else {
            return null;
        }
    }

    function readerror() {
        return i2c.stub.readError;
    }

    function write(deviceAddress, registerPlusData) {
        return i2c.stub.writeReturn;
    }
}

// No stub state is maintained for pin, so if you're trying to mock behaviours here then you're doing it wrong
class pin {
    capture = {
        writeCount = 0,
        lastWrite  = null,
        function reset() {
            writeCount = 0;
            lastWrite  = null;
        }
    }

    onPinStateChangeCallback = null;
    onPinStateChangeValue = 0;

    function reset() {
        pin.capture.reset();
        onPinStateChangeValue = 0;
    }

    function configure(pinType, ...) {
        if (pinType == DIGITAL_IN || pinType == DIGITAL_IN_PULLUP || pinType == DIGITAL_IN_PULLDOWN || pinType == DIGITAL_IN_WAKEUP) {
            onPinStateChangeCallback = vargv.len() ? vargv[0] : null;
        }
    }

    function getdelay() {
        return 0.0;
    }
    function getperiod() {
        return 0.0;
    }
    function getsteps() {
        return 0;
    }

    function read() {
        if (onPinStateChangeCallback) {
            return onPinStateChangeValue;
        }
        return pin.capture.writeCount;
    }

    function write(value) {
        if (onPinStateChangeCallback) {
            onPinStateChangeValue = value;
            onPinStateChangeCallback();
        } else {
            pin.capture.lastWrite = value;
            pin.capture.writeCount = pin.capture.writeCount + 1;
        }
    }
}

class sampler {
    function configure(pins, sampleRate, buffers, callback, filters) {}
    function getsampleratehz() {
        return 48000;
    }
    function reset() {}
    function start() {}
    function stop() {}
}

const SIMPLEX_RX = 1;
const SIMPLEX_TX = 2;
const CLOCK_IDLE_HIGH = 4;
const CLOCK_IDLE_LOW = 0;
const CLOCK_2ND_EDGE = 8;
const MSB_FIRST = 0;
const LSB_FIRST = 16;
const NO_SCLK = 32;
const USE_CS_L = 64;

class spi {
    function chipselect(select) {}
    function configure(modeFlags, dataRate) {}
    function disable();
    function readblob(nubmerOfBytes) {
        return null;
    }
    function readstring(numberOfChars) {
        return "";
    }
    function write(data) {}
    function writeread(data) {
        return blob(0);
    }
}

const SPIFLASH_PREVERIFY = 2;
const SPIFLASH_POSTVERIFY = 1;

class spiflash {

    stub = {
        data = blob(0xC00000),
        emptyData = blob(0xC00000),
        emptySector = blob(0x1000),
        enabled = false,
        function reset() {
            enabled = false;
            data = clone emptyData;
        }
    };

    constructor()
    {
        if(stub.emptySector[0] == 0x00) {
            local emptySector = stub.emptySector;
            while( !emptySector.eos() ) { emptySector.writen( 0xFF, 'b' ); }
            emptySector.seek( 0, 'b' );
            local emptyData = stub.emptyData;
            local data = stub.data;
            while( !emptyData.eos() ) { emptyData.writeblob( emptySector ); }
            emptyData.seek( 0, 'b' );
            data = clone emptyData;
        }
    }

    function chipid() {
        return 0;
    }
    function disable() {
        if(!stub.enabled) { throw "spiflash already disabled"; }
        stub.enabled = false;
    }
    function enable() {
        if(stub.enabled) { throw "spiflash already enabled"; }
        stub.enabled = true;
    }
    function erasesector(sectorAddress) {
        stub.data.seek(sectorAddress, 'b');
        stub.data.writeblob(stub.emptySector);
    }
    function info() {
        return null;
    }
    function read(address, numberOfBytes) {
        if(numberOfBytes == 0) { return blob(); }
        stub.data.seek(address, 'b');
        return stub.data.readblob(numberOfBytes);
    }
    function readintoblob(address, targetBlob, numberOfBytes) {
        if(numberOfBytes == 0) { return blob(); }
        stub.data.seek(address, 'b');
        local newBlob = stub.data.readblob(numberOfBytes);
        targetBlob.writeblob( newBlob );
    }
    function setspeed(speed) {
        return 4500000;
    }
    function size() {
        return 12582912;
    }
    function write(address, dataSource, writeFlags = null, startIndex = null, endIndex = null) {
        local blobToWrite = dataSource;

        if(startIndex != null) {
            blobToWrite.seek(startIndex, 'b');
        } else {
            blobToWrite.seek( 0, 'b' );
        }
        if(endIndex != null) {
            blobToWrite = dataSource.readblob(endIndex-startIndex);
        }

        stub.data.seek(address, 'b');

        local i = address;
        while(!blobToWrite.eos()) {
            local currentByte = stub.data[i++];
            local newByte = blobToWrite.readn( 'b' );
            stub.data.writen( newByte & currentByte , 'b' );
        }

        return 0;
    }
}

const READ_READY = 1;
const WRITE_DONE = 2;
const NOISE_ERROR = 4;
const FRAME_ERROR = 8;
const PARITY_ERROR = 16;
const OVERRUN_ERROR = 32;
const LINE_IDLE = 64;

class uart {
    function configure(baudRate, wordSize, parity, stopBits, flags, callback) {
        return 0;
    }
    function disable() {}
    function flags() {
        return READ_READY;
    }
    function flush() {}
    function read() {
        return -1;
    }
    function readblob(numberOfBytes) {
        return blob(0);
    }
    function readstring(numberOfChars) {
        return "";
    }
    function setrxfifosize(newInputFifoSize) {}
    function settxactive(pin, polarity, predelay, postdelay) {}
    function settxfifosize(newOutputFifoSize) {}
    function write(dataToWrite) {}
}

class usb {
    function configure(callback) {}
    function controltransfer(speed, deviceAddress, endpointAddress, requestType, request, value, index, maxpacketsize, data) {}
    function disable() {}
    function generaltransfer(deviceAddress, endpointAddress, type, data) {}
    function openendpoint(speed, deviceAddress, interface, type, maxpacketsize, endpointAddress, interval) {
        return null;
    }
}

class hardware {
// imp005 definitions only, for now
    i2c0 = i2c();
    i2cJK = i2c();
    pinA = pin();
    pinB = pin();
    pinE = pin();
    pinF = pin();
    pinH = pin();
    pinL = pin();
    pinN = pin();
    pinT = pin();
    pinW = pin();
    pinXA = pin();
    pinXB = pin();
    pinXE = pin();
    pinY = pin();
    pinM = pin();
    spiflash = spiflash();
    uart0 = uart;
    uart1 = uart;
    uart2 = uart;
    spi0 = spi();

    stub = {
        deviceid = "ABCD1234",
        lightlevel = 0,
        millis = 0,
        micros = 0,
        vbat = 0.0,
        voltage = 0.0,
        wakereason = WAKEREASON_POWER_ON,
        function setDeviceid(id) {
            deviceid = id;
        },
        function setLightlevel(level) {
            lightlevel = level;
        },
        function setMillis(ms) {
            millis = ms;
        },
        function millisIncrement(by) {
            millis = millis + by;
        },
        function setMicros(us) {
            micros = us;
        },
        function microsIncrement(by) {
            micros = micros + by;
        },
        function setVbat(v) {
            vbat = v;
        },
        function setVoltage(v) {
            voltage = v;
        },
        function setWakereason(reason) {
            wakereason = reason;
        }

        function reset() {
            deviceid = "ABCD1234";
            lightlevel = 0;
            millis = 0;
            micros = 0;
            vbat = 0.0;
            voltage = 0.0;
            wakereason = WAKEREASON_POWER_ON;
        }
    };

    function getdeviceid() {
        return stub.deviceid;
    }

    function lightlevel() {
        return stub.lightlevel;
    }

    function micros() {
        if(typeof(stub.micros) != "integer") {
            return stub.micros.tointeger();
        } else {
            return stub.micros;
        }
    }

    function millis() {
        if(typeof(stub.millis) != "integer") {
            return stub.millis.tointeger();
        } else {
            return stub.millis;
        }
    }

    function vbat() {
        return stub.vbat;
    }

    function voltage() {
        return stub.voltage;
    }

    function wakereason() {
        return stub.wakereason;
    }
}

class agent {
    static handlers = {};

    capture = {
        sent = [],
        sentName = null,
        sentData = null,
        function lastSentName() {
            return sentName;
        },
        function lastSentData() {
            return sentData;
        },
        function lastSent(name) {
            local items = sent.filter(function(index, value){
                return value[0] == name;
            });

            if(items.len() > 0) {
                local last = items.top();
                return last[1];
            } else {
                return null;
            }
        },
        function countSentWithName(name) {
            return sent.filter(function(index, value){
                return value[0] == name;
            }).len();
        },
        function reset() {
            sent.clear();
            sentName = null;
            sentData = null;
        }
    }

    stub = {
        sendReturn = 0,
        function nextSendFail() {
            sendReturn = 1;
        },
        function nextSendOk() {
            sendReturn = 0;
        },
        function reset() {
            nextSendOk();
        }
    }

    function reset() {
        stub.reset();
        capture.reset();
    }

    //====================================
    function on(messageName, callback) {
        handlers[messageName] <- callback;
    }

    function send(messageName, data) {
        if (messageName != "logger.log"){
            capture.sentName = messageName;
            capture.sentData = data;
            capture.sent.append([messageName, data]);
        }
        return stub.sendReturn;
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
            local middle = @"\u" + expression.slice( startIndex+3, endIndex );
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