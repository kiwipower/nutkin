class TestPrinter extends Printer {
    lines = null

    constructor() {
        lines = []
    }

    function print(text) {
        lines.push(text)
    }

    function getLines() {
        return lines
    }

    function lastLine() {
        return lines.top()
    }

    function reset() {
        lines = []
    }
}
