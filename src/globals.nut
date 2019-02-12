stackTrace <- function() {
    local level = 1
    local output = ""
    local stackInfo = getstackinfos(level)

    while (stackInfo) {
        output += "\n" + stackInfo.func + "() in " + stackInfo.src + ":" + stackInfo.line

        if (level > 0) {
            output += ", "
        }

        level++
        stackInfo = getstackinfos(level)
    }

    return output
}

reporters <- {}

enum Outcome {
    PASSED,
    FAILED,
    SKIPPED
}

local env = getenv("NUTKIN_ENV")

testPattern  <- (vargv.len() > 0 ? vargv[0].tolower() : "")
