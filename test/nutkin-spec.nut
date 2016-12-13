@include "../build/nutkin.nut"

describe("Assert Nutkin expectations", function() {

    describe("equal", function() {

        it("works with strings", function() {
            expect("A String").to.equal("A String", "strings should be equal");
        })

        it("works with numbers", function() {
            expect(123).to.equal(123, "numbers should be equal");
        })

        it("works with floats", function() {
            expect(123.456).to.equal(123.456, "numbers should be equal");
        })

        it("works with arrays", function() {
            expect([1, 2, 3]).to.equal([1, 2, 3], "arrays should be equal");
        })

        it("works with tables", function() {
            expect({
                foo = "bar",
                baz = 101
            }).to.equal({
                foo = "bar",
                baz = 101
            }, "tables should be equal");
        })

        it("to.be.equal is an alias for to.equal", function() {
            expect("A String").to.be.equal("A String");
        })

        it("toBe is an alias for to.equal", function() {
            expect("A String").toBe("A String");
        })

        it("can be used with not", function() {
            expect("A String").to.not.equal("Another String")
        })
    })

    describe("Truthy", function() {

        it("works for true", function() {
            expect(true).to.be.truthy()
        })

        it("works for 1", function() {
            expect(1).to.be.truthy()
        })

        it("works for a string", function() {
            expect("").to.be.truthy()
        })

        it("works for an array", function() {
            expect([]).to.be.truthy()
        })

        it("works for a table", function() {
            expect({}).to.be.truthy()
        })

        it("can be used with not", function() {
            expect(false).to.not.be.truthy()
        })
    })

    describe("Falsy", function() {

        it("works for false", function() {
            expect(false).to.be.falsy()
        })

        it("works for 0", function() {
            expect(0).to.be.falsy()
        })

        it("works for null", function() {
            expect(null).to.be.falsy()
        })

        it("can be used with not", function() {
            expect(true).to.not.be.falsy()
        })
    })
})