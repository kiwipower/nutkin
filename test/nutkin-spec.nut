@include "../build/nutkin.nut"

describe("Nutkin expectations", function() {

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

        it("toBeNull is an alias for to.equal(null)", function() {
            expect(null).toBeNull()
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

        it("toBeTruthy is an alias for truthy", function() {
            expect(true).toBeTruthy()
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

        it("toBeFalsy is an alias for truthy", function() {
            expect(false).toBeFalsy()
        })
    })

    describe("Contains", function() {

        it("works for arrays", function() {
            expect([1, 2, 3]).to.contain(2)
            expect(["1", "2", "3"]).to.contain("3")
            expect([true, false]).to.contain(true)
            expect([{a = 1}, {b = 2}]).to.contain({b = 2})
        })

        it("contains is an alias for contain", function() {
            expect([1, 2, 3]).contains(2)
        })

        it("toContain is an alias for contain", function() {
            expect([1, 2, 3]).toContain(2)
        })
    })

    describe("Match", function() {

        it("matches given regular expression against value", function() {
            expect("a").to.match("[a-z]")
            expect("aA").to.match("[a-zA-Z]+")
        })

        it("matches is an alias for contain", function() {
            expect("a").matches("[a-z]")
        })

        it("toMatch is an alias for contain", function() {
            expect("a").toMatch("[a-z]")
        })
    })

    describe("Less than", function() {

        it("works with numbers", function() {
            expect(3).to.be.lessThan(4)
        })

        it("toBeLessThan is an alias for lessThan", function() {
            expect(3).toBeLessThan(4)
        })
    })

    describe("Greater than", function() {

        it("works with numbers", function() {
            expect(3).to.be.greaterThan(2)
        })

        it("toBeGreaterThan is an alias for greaterThan", function() {
            expect(3).toBeGreaterThan(2)
        })
    })

    describe("Throws", function() {

        it("asserts that an exception was thrown", function() {
            expect(function() { throw "BANG!" }).throws("BANG!")
        })

        it("toThrow is an alias for throws", function() {
            expect(function() { throw "BANG!" }).toThrow("BANG!")
        })

        it("expectException is an alias for throw", function() {
            expectException("BANG!", function() { throw "BANG!" })
        })
    })
})