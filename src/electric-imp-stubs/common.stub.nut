// Imp stub API
// Common definitions, shared by both device and agent

local clock_s = 0;
local clock_subs = 0.0;
local timerUID = 0;

function time() {
    return clock_s;
}

function date(timestamp = null) {
    // default 1-Jan-2000 00:00:00
    local date = {};
    date.usec <- 0;
    date.sec <- 0;
    date.min <- 0;
    date.hour <- 0;
    date.day <- 1;
    date.month <- 0;
    date.year <- 2000;
    date.wday <- 0;
    date.yday <- 0;
    date.time <- 946684800;

    return date;
}

const ENVIRONMENT_CARD = 0;
const ENVIRONMENT_MODULE = 1;
const ENVIRONMENT_AGENT = 2;

// No stub state is maintained for the imp object, as behaviour is very much Electric Imp's concern
class imp {
    configparams = {};
    _environment = ENVIRONMENT_MODULE;
    poweren = false;
    powersave = false;
    country = "037F3045"; // Europe, for an imp005 connected via Ethernet
    timerArray = [];
    timerTable = {};

    stub = {
        function addConfigParams(name, value) {
            imp.configparams[name] <- value;
        },
        function resetTimer() {
            imp.timerArray.clear();
            imp.timerTable.clear();
            timerUID = 0;
            clock_s = 0;
            clock_subs = 0.0;
        },
        function setTimer(seconds,subseconds) {
            clock_s = seconds;

            if( typeof subseconds == "integer" ) {
                clock_subs = subseconds.tofloat();
            }
            else {
                clock_subs = subseconds;
            }
        },
        function sleepFor(seconds) {
            for( local i = 0; i < seconds; i += 0.01 ) {
                imp.sleep( 0.01 );
            }
        }
    };

    function clearconfiguration(action) {}
    function deepsleepfor(sleepTime) {}
    function deepsleepuntil(hour, minute, second, day) {}
    function enableblinkup(enable) {}
    function environment() {
        return _environment;
    }
    function setEnvironment(environment) {
        _environment <- environment;
    }
    function getbootromversion() {
        return "?";
    }
    function getbssid() {
        return "000000000000";
    }
    function getchannel() {
        return 0;
    }
    function getcountry() {
        return country;
    }
    function getethernetspeed() {
        return 100;
    }
    function getmacaddress() {
        return "010203040506";
    }
    function getmemoryfree() {
        return 32768;
    }
    function getpoweren() {
        return poweren;
    }
    function getpowersave() {
        return powersave;
    }
    function getrssi() {
        return 0;
    }
    function getsoftwareversion() {
        return "34";
    }
    function getssid() {
        return "kiwi";
    }
    function info() {
        return null;
    }
    function onidle(callback) {}
    function rssi() {
        return 0;
    }
    function scanwifinetworks(callback) {
        return null;
    }
    function setcountry(regionCode) {
        country = regionCode;
    }
    function setenroltokens(planID, token) {}
    function setnvramimage(settings) {}
    function setpoweren(state) {
        poweren = state;
    }
    function setpowersave(state) {
        powersave = state;
    }
    function setproxy(proxyType, address, port, username, password) {}
    function setrescuepin(pin, polarity) {}
    function setsendbuffersize(newSize) {}
    function setstaticnetworkconfiguration(ip, netmask, gateway, dns) {}
    function setwificonfiguration(SSID, password) {}
    function sleep(sleepTime) {
        local toCall = [];
        local toKeepArray = [];
    
        local sleepTimeInt = math.floor(sleepTime).tointeger();
        clock_s += sleepTimeInt;
        clock_subs += sleepTime - sleepTimeInt;
        clock_s += clock_subs.tointeger();
        clock_subs -= math.floor(clock_subs);

        foreach (index, value in timerArray) {
            if(clock_s > value.activationTime_s ||
               (clock_s == value.activationTime_s &&
               clock_subs >= value.activationTime_subs)) {
                toCall.append(value);
            } else {
                toKeepArray.append(value);
            }
        }

        foreach (index, value in timerTable) {
            if (clock_s > value.activationTime_s ||
               (clock_s == value.activationTime_s &&
               clock_subs >= value.activationTime_subs)) {
                toCall.append(value);
            } else {
                toKeepTable[key] <- value;
            }
        }        

        timerArray.clear();
        timerArray.extend(toKeepArray);
        timerTable.clear();
        foreach (index, value in timerTable) {
            timerTable[index] = value;
        }

        local function sortTime(first, second) {
 
            switch(first.activationTime_s <=> second.activationTime_s)
            {
                case -1: return -1;
                case 1: return 1;
                case 0:
                    switch( first.activationTime_subs <=> second.activationTime_subs)
                    {
                        case -1: return -1;
                        case 1: return 1;
                        case 0: return (first.uid <=> second.uid);
                        default: return 0;
                    }
                default: return 0;
            }
        }
        if(toCall.len() > 1) {toCall.sort(sortTime);}

        foreach (value in toCall) {
            value.callback();
        }
    }
    function wakeup(interval, callback, name = null) {
        local timer = {};

        local activationTime_s = clock_s + interval.tointeger();
        local activationTime_subs = clock_subs + (interval - math.floor(interval));
        activationTime_s += activationTime_subs.tointeger();
        activationTime_subs -= activationTime_subs.tointeger();

        timer.activationTime_s <- activationTime_s;
        timer.activationTime_subs <- activationTime_subs;
        timer.callback <- callback;
        timer.uid <- timerUID++;
 
        if( typeof name == "string" ) {
            timerTable[name] <- timer;
        } else {
            timerArray.append(timer);
        }
        
        return timer;
    }

    function cancelwakeup(timer) {
        // https://electricimp.com/docs/api/imp/cancelwakeup/
        // If the timer has not yet fired, once cancelled it never will.
        // Cancelling a timer that has already fired has no effect.

        if( typeof timer == "string" ) {
            if( timer in timerTable ) {
                delete timerTable[timer];
            }
        }
        else {
            local found = timerArray.find(timer);
            if(found != null) {
                timerArray.remove(found);
            }
        }
    }
}

function blob::flush() {
    throw "Unsupported: not listed on imp's ducoumentation";
}

function blob::readstring(numberOfBytes) {
    throw "Not yet implemented by stub";
}

function blob::tostring() {
    local s = "";
    for(local i = 0; i < len(); ++i) {
        s += this[i].tochar();
    }
    return s;
}

function blob::writestring( string ) {
    foreach( character in string ) {
        this.writen( character, 'c' );
    }
}

class math {
    function abs(x) {
        return ::abs(x);
    }
    function acos(x) {
        return ::acos(x);
    }
    function asin(x) {
        return ::asin(x);
    }
    function atan(x) {
        return ::atan(x);
    }
    function atan2(x,y) {
        return ::atan2(x,y);
    }
    function ceil(x) {
        return ::ceil(x);
    }
    function cos(x) {
        return ::cos(x);
    }
    function exp(x) {
        return ::exp(x);
    }
    function fabs(x) {
        return ::fabs(x);
    }
    function floor(x) {
        return ::floor(x);
    }
    function log(x) {
        return ::log(x);
    }
    function log10(x) {
        return ::log10(x);
    }
    function pow(x,y) {
        return ::pow(x,y);
    }
    function rand() {
        return ::rand();
    }
    function sin(x) {
        return ::sin(x);
    }
    function sqrt(x) {
        return ::sqrt(x);
    }
    function tan(x) {
        return ::tan(x);
    }
}

class crypto {
    function equals(hashOne, hashTwo) {
        return ( hashOne == hashTwo );
    }
    function hmacsha256(dataToHash, key) {
        local seed = 0;
        foreach( item in key ) {
            seed += item;
        }
        ::srand(seed);
        local hash = blob(32);
        local encValue = rand();
        local increment = 1.0 * dataToHash.len() / 32;
        for( local i = 0, u = 0; i < 32; ++i, u += increment )
        {
            hash.writen( dataToHash[u], 'b' );
        }
        return hash;
    }
    function sha256() {
        ::srand(1203572305);
        local hash = blob(32);
        local encValue = rand();
        local increment = 1.0 * dataToHash.len() / 32;
        for( local i = 0, u = 0; i < 32; ++i, u += increment )
        {
            hash.writen( dataToHash[u], 'b' );
        }
        return hash;
    }
    function sign() {
        // todo
    }
    function verify() {
        // todo
    }
}

function deepClone( container )
{
    switch( typeof( container ) )
    {
        case "table":
            local result = clone container;
            foreach( k, v in container ) result[k] = deepClone( v );
            return result;
        case "array":
            return container.map( deepClone );
        default: return container;
    }
}