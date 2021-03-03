@include once "src/NutkinPrettyPrinter.class.nut";

class Printer {

    prettyPrinter = NutkinPrettyPrinter();

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
