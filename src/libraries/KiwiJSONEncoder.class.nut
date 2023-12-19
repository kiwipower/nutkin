// Copyright (c) 2017 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class KiwiJSONEncoder {

  static VERSION = "2.0.0";

  // max structure depth
  // anything above probably has a cyclic ref
  static _maxDepth = 32;

  /**
   * Encode value to JSON
   * @param {table|array|*} value
   * @returns {string}
   */
  function encode(value) {
    return this._encode(value);
  }

  /**
   * @param {table|array} val
   * @param {integer=0} depth – current depth level
   * @private
   */
  function _encode(val, depth = 0) {

    // detect cyclic reference
    if (depth > this._maxDepth) {
      throw "Possible cyclic reference";
    }

    local
      r = "",
      s = "",
      i = 0;

    switch (typeof val) {

      case "table":
      case "class":
        s = "";

        // serialize properties, but not functions
        foreach (k, v in val) {
          if (typeof v != "function") {
            s += ",\"" + k + "\":" + this._encode(v, depth + 1);
          }
        }

        s = s.len() > 0 ? s.slice(1) : s;
        r += "{" + s + "}";
        break;

      case "array":
        s = "";

        for (i = 0; i < val.len(); i++) {
          s += "," + this._encode(val[i], depth + 1);
        }

        s = (i > 0) ? s.slice(1) : s;
        r += "[" + s + "]";
        break;

      case "integer":
      case "float":
      case "bool":
        r += val;
        break;

      case "null":
        r += "null";
        break;

      case "instance":

        if ("_serializeRaw" in val && typeof val._serializeRaw == "function") {

            // include value produced by _serializeRaw()
            r += val._serializeRaw().tostring();

        } else if ("_serialize" in val && typeof val._serialize == "function") {

          // serialize instances by calling _serialize method
          r += this._encode(val._serialize(), depth + 1);

        } else {

          s = "";

          try {
            // iterate through instances which implement _nexti meta-method
            foreach (k, v in val) {
              s += ",\"" + k + "\":" + this._encode(v, depth + 1);
            }

          } catch (e) {
            try {
              // iterate through instances w/o _nexti
              // serialize properties, but not functions
              foreach (k, v in val.getclass()) {
                if (typeof v != "function") {
                  s += ",\"" + k + "\":" + this._encode(val[k], depth + 1);
                }
              }
            } catch (e) {
              // We're here because we STILL couldn't iterate (normally a _nexti error)
              // It seems that if we just silently fail we end up with usable JSON most of the time
              // So let's do that
            }


          }

          s = s.len() > 0 ? s.slice(1) : s;
          r += "{" + s + "}";
        }

        break;

      case "blob":
        // This is a workaround for a known bug:
        // on device side Blob.tostring() returns null
        // (instaead of an empty string)
        //r += "\"" + (val.len() ? this._escape(val.tostring()) : "") + "\"";
        r += "\"" + _blobToHexString(val) + "\"";
        break;

      case "function":
        // Functions break things
        // So insert just the name
        r += "\"function()\""
        break;

      // strings and all other
      default:
        if ("tostring" in val)
        {
          r += "\"" + this._escape(val.tostring()) + "\"";
        } else {
          r += "\"\"";
        }
        break;
    }

    return r;
  }


  function _blobToHexString(blb)
  {
    local hexStr = "";
    for (local i = 0; i < blb.len(); i++)
    {
      hexStr += format("%x", blb[i]);
    }
    return hexStr;
  }

  /**
   * Escape strings according to http://www.json.org/ spec
   * @param {string} str
   */
  function _escape(str) {
    local res = "";

    for (local i = 0; i < str.len(); i++) {

      local ch1 = (str[i] & 0xFF);

      if ((ch1 & 0x80) == 0x00) {
        // 7-bit Ascii

        ch1 = format("%c", ch1);

        if (ch1 == "\"") {
          res += "\\\"";
        } else if (ch1 == "\\") {
          res += "\\\\";
        } else if (ch1 == "/") {
          res += "\\/";
        } else if (ch1 == "\b") {
          res += "\\b";
        } else if (ch1 == "\f") {
          res += "\\f";
        } else if (ch1 == "\n") {
          res += "\\n";
        } else if (ch1 == "\r") {
          res += "\\r";
        } else if (ch1 == "\t") {
          res += "\\t";
        } else if (ch1 == "\0") {
          res += "\\u0000";
        } else {
          res += ch1;
        }

      } else {

        if ((ch1 & 0xE0) == 0xC0) {
          // 110xxxxx = 2-byte unicode
          local ch2 = (str[++i] & 0xFF);
          res += format("%c%c", ch1, ch2);
        } else if ((ch1 & 0xF0) == 0xE0) {
          // 1110xxxx = 3-byte unicode
          local ch2 = (str[++i] & 0xFF);
          local ch3 = (str[++i] & 0xFF);
          res += format("%c%c%c", ch1, ch2, ch3);
        } else if ((ch1 & 0xF8) == 0xF0) {
          // 11110xxx = 4 byte unicode
          local ch2 = (str[++i] & 0xFF);
          local ch3 = (str[++i] & 0xFF);
          local ch4 = (str[++i] & 0xFF);
          res += format("%c%c%c%c", ch1, ch2, ch3, ch4);
        }

      }
    }

    return res;
  }
}