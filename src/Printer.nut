@include once "src/PrettyPrinter.class.nut";

class Printer {

    prettyPrinter = PrettyPrinter();

    function prettyPrint(object) {
        prettyPrinter.print(object);
    }

    function print(text) {
        ::print(text)
    }

    function println(text) {
        print(text + "\n")
    }
}
