println <- @(line) ::print(line + "\n")

stackTrace <- function() {
    local level = 1
    local output = ""
    local stackInfo = getstackinfos(level)

    while (stackInfo) {
        output += "\n" + stackInfo.func + "() at " + stackInfo.src + " line [" + stackInfo.line + "]"

        if (level > 0) {
            output += ", "
        }

        level++
        stackInfo = getstackinfos(level)
    }

    return output
}

reporters <- {}

