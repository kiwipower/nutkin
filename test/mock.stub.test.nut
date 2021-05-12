@include once "src/mock/mock.stub.nut"


@include once "src/nutkin.nut"


// Test class used for getting/setting
class MockStubTestClass
{

}

// Test class used to test Mock.Instance
class MockInstanceType1 { }


// Test our mock class
describe( "TestMock", function()
{
    it("Sets and Gets Variable", function()
    {
        local m = Mock();
        
        // Set a value and check its valid
        m.thisVal <- 22.03;
        expect(m.thisVal).toBe(22.03);

        // Set another value
        m.secondVal <- "hello";
        expect(m.secondVal).toBe("hello");

        // Create an instance of a class, set it and check we get the same back
        local testClass = MockStubTestClass();

        m.classVal <- testClass;
        local y = m.classVal;
        expect(y).to.equal(testClass);
    });

    it("Checks that assigning is on an instance basis", function()
    {
        local m = Mock();
        local n = Mock();

        // Assign a variable in the first class
        m.whatever <- 33;

        expect(m.whatever).toBe(33);
        expect(m.whatever).to.not.equal(n.whatever);
    });


    it("Records that a function was called", function()
    {
        local m = Mock();

        // Call an arbitrary function with an arbitrary set of arguments
        m.hello("what", 57);

        // Check to see if it was called
        expect(m.hello.called).to.be.truthy();

        // Check that it was called once
        expect(m.hello.callCount).toBe(1);

        // And get the last arguments
       local callArgs = m.hello.callArgs;

       expect(callArgs[0]).toBe("what");
       expect(callArgs[1]).toBe(57);

    });

    
    it("Check the call args are null without any calls", function()
    {
        local m = Mock();

        expect(m.rand.callArgs).toBe(null);
    });


    it("Records call args for repeated calls", function()
    {
        local m = Mock();

        // Call the same arbitrary function a few times
        m.whassup("this", "is", 1);

        m.whassup("now", "its", 2);

        local callArgs = m.whassup.callArgsList;

        expect(callArgs[0][0]).toBe("this");
        expect(callArgs[0][1]).toBe("is");
        expect(callArgs[0][2]).toBe(1);

        expect(callArgs[1][0]).toBe("now");
        expect(callArgs[1][1]).toBe("its");
        expect(callArgs[1][2]).toBe(2);

    });

    it("hasCallCount passes when call count correct", function()
    {
        local m = Mock();

        // Call an arbritrary function
        m.hello(18, "this is a string");
        m.hello(54, "so is this");

        expect(m.hello.hasCallCount(2)).toBe(null);
    });

    it("hasCallCount fails when call count incorrect", function()
    {
        local m = Mock();

        // Call an arbritrary function
        m.hello(18, "this is a string");
        m.hello(54, "so is this");

        expect(m.hello.hasCallCount(1)).to.be.ofType("string");

    });

    it("wasCalledWithAtIndex passed when given valid parameters", function()
    {
        local m = Mock();

        // Call an arbritrary function
        m.hello(18, "this is a string");
        m.hello(54, "so is this");

        local res1 = m.hello.wasCalledWithAtIndex(0, [18, Mock.Type("string")]);
        local res2 = m.hello.wasCalledWithAtIndex(1, [Mock.Type("integer"), "so is this"]);

        expect(res1).toBe(null);
        expect(res2).toBe(null);

        // Try again with different types and arg count - it shouldn't matter for the MockFunction
        m.whatsit(false, true, 99, "this is a string");
        m.whatsit(11, "goop", "fewer args");
        m.whatsit();

        expect(m.whatsit.wasCalledWithAtIndex(0, [false, Mock.Type("bool"), 99, "this is a string"])).toBe(null);
        expect(m.whatsit.wasCalledWithAtIndex(1, [Mock.Type("integer"), Mock.Type("string"), "fewer args"])).toBe(null);
        expect(m.whatsit.wasCalledWithAtIndex(2)).toBe(null);
        
        // Check that ignoring the arguments passes
        expect(m.whatsit.wasCalledWithAtIndex(0, [false, Mock.Type("bool"), Mock.Ignore(), Mock.Ignore()])).toBe(null);

    });

    it("wasCalledWithAtIndex recognises common types", function()
    {
        local m = Mock();
        // Call an arbitrary function with a range of types

        // integer
        m.callInt(1);
        expect(m.callInt.wasCalledWithAtIndex(0, [Mock.Type("integer")])).toBe(null);

        // float
        m.callFloat(98.234);
        expect(m.callFloat.wasCalledWithAtIndex(0, [Mock.Type("float")])).toBe(null);

        m.callString("am I a string?");
        expect(m.callString.wasCalledWithAtIndex(0, [Mock.Type("string")])).toBe(null);


        m.callBool(false);
        expect(m.callBool.wasCalledWithAtIndex(0, [Mock.Type("bool")])).toBe(null);


        m.callBlob(blob());
        expect(m.callBlob.wasCalledWithAtIndex(0, [Mock.Type("blob")])).toBe(null);


        local quickClass = class { };
        m.callInstance(quickClass);
        expect(m.callInstance.wasCalledWithAtIndex(0, [Mock.Type("instance")]));
        
    });

    it("wasCalledWithAtIndex recognise class instances", function()
    {
        local m = Mock();

        m.callMyType1(MockInstanceType1());

        expect(m.callMyType1.wasCalledWithAtIndex(0, [Mock.Instance(MockInstanceType1)])).toBe(null);

    })



    it("wasCalledWithAtIndex fails when given non-matching parameters", function()
    {
        local m = Mock();

        // Call an arbritrary function with some different kinds of args
        m.whatsit();
        m.whatsit(false, true);
        m.whatsit(11);
        m.whatsit(33.42);
        m.whatsit("stringy");

        // Expect it to fail on too-big-call-number
        expect(m.whatsit.wasCalledWithAtIndex(5)).to.be.ofType("string");

        // Sanity check - it should pass here
        expect(m.whatsit.wasCalledWithAtIndex(1, [false, true])).toBe(null);

        // Expect it to fail if the value doesn't match
        expect(m.whatsit.wasCalledWithAtIndex(1, [true, true])).to.be.ofType("string");

        expect(m.whatsit.wasCalledWithAtIndex(2, [12])).to.be.ofType("string");

        // Expect it to fail if calls out of order
        expect(m.whatsit.wasCalledWithAtIndex(3, ["stringy"])).to.be.ofType("string");
        expect(m.whatsit.wasCalledWithAtIndex(4, [33.42])).to.be.ofType("string");

        // Expect it to fail if parameters given for a function call with no arguments
        expect(m.whatsit.wasCalledWithAtIndex(0, [1, 2])).to.be.ofType("string");

        // Expect it to fail if no expectation given for a function call with arguments
        expect(m.whatsit.wasCalledWithAtIndex(1)).to.be.ofType("string");

    });

    it("wasLastCalledWith passes when last call is given", function() {
        local m = Mock();

        m.hello(32, "arg2");

        expect(m.hello.wasLastCalledWith(32, "arg2")).toBe(null);
        expect(m.hello.wasLastCalledWith(Mock.Type("integer"), Mock.Type("string"))).toBe(null);

        // Make a second call
        m.hello("new args");

        // Now we expect that call
        expect(m.hello.wasLastCalledWith("new args")).toBe(null);

        // And the previous call should be broken
        expect(m.hello.wasLastCalledWith(32, "arg2")).to.be.ofType("string");

    })

    it("anyCallWith passes when any call is matched", function() {
        local m = Mock();

        m.myFunc("call1", "is", 42);
        m.myFunc("call2", "is", 18);
        m.myFunc(22.354, 987, "call3");

        // Now check that we match in any order
        expect(m.myFunc.anyCallWith(22.354, 987, "call3")).toBe(null);
        expect(m.myFunc.anyCallWith("call1", "is", 42)).toBe(null);
        expect(m.myFunc.anyCallWith("call2", "is", 18)).toBe(null);
        expect(m.myFunc.anyCallWith(Mock.Type("float"), Mock.Type("integer"), "call3")).toBe(null);


        // And check that we don't match a call that wasn't made
       expect(m.myFunc.anyCallWith(24, 900, "call3")).to.be.ofType("string");
       expect(m.myFunc.anyCallWith()).to.be.ofType("string");

    });


    it("Mock.Type doesn't recognise invalid types", function()
    {
        // todo: Mock.Type tests could be separated from Mock tests...
        local excepted = false;

        try{
            local t = Mock.Type("fakeType");
        } catch (exception) {
            excepted = true;
        }

        expect(excepted).to.be.truthy();
    });

    it("Passes the pre-set function return value", function()
    {
        local m = Mock();

        // Set the function return value
        m.hello.returnValue <- 13;

        // Call an arbitrary function with an arbitrary set of arguments
        expect(m.hello("what", 57)).toBe(13);

    });

    it("sideEffect function is called when set", function()
    {
        local m = Mock();

        local calledArg1 = null;
        local calledArg2 = null;

        local function sideEffectFunc(arg1, arg2)
        {
            calledArg1 = arg1;
            calledArg2 = arg2;

            return 99.99;
        };


        m.rand.sideEffect <- sideEffectFunc;

        // Expect our function call to hit the side effect function and return its value
        expect(m.rand(33, "hello")).toBe(99.99);

        expect(calledArg1).toBe(33);
        expect(calledArg2).toBe("hello");
    });

    it("sideEffect function can have no arguments", function()
    {
        local m = Mock();

        m.boo.sideEffect <- function() {
            return "hello you";
        };

        expect(m.boo()).toBe("hello you");
    })

    it("sideEffect function return ignored when MockDefault", function()
    {
        local m = Mock();

        local called = false;

        local function sideEffectFunc(arg1, arg2)
        {
            called = true;

            return MockFunction.DefaultReturn();
        };


        m.newFunc.sideEffect <- sideEffectFunc;

        local resp = m.newFunc(["bleep", "boop"], 0.01);
               
        expect(resp).to.be.ofClass(Mock);

        // Check that the sideEffect function was called
        expect(called).to.be.truthy();
    });

    it("sideEffect array elements returned one at a time", function()
    {
        local m = Mock();

        local sideEffect = [22, 33, 44, 55, 66, 77, 88];

        m.thisFunc.sideEffect <- sideEffect;

        foreach (effect in sideEffect)
        {
            expect(m.thisFunc("arbitrary")).toBe(effect);
        }

        // Now we check that the last element is returned on subsequent calls
        expect(m.thisFunc("arbitrary")).toBe(sideEffect.top());

    });


    it("Gets a mock object when no return value set", function()
    {
        local m = Mock();

        // Call an arbitrary function and check it returns a mock
        local shouldBeMock = m.arbitraryFunction();

        expect(shouldBeMock).to.be.ofClass(Mock);

        // Check the Mock function returned can be accessed 
        local returnValueAfter = m.arbitraryFunction.returnValue;
        expect(shouldBeMock).toBe(returnValueAfter);

    });


    it("The mock object for a given function should be consistent", function()
    {
        local m = Mock();

        local returnValueBefore = m.arbitraryFunction.returnValue;

        // Call an arbitrary function and check it returns a mock
        local shouldBeMock = m.arbitraryFunction();

        // Check the Mock function returned can be accessed 
        expect(shouldBeMock).toBe(returnValueBefore);

    });


    it("Each function returns a different mock", function()
    {
        local p = Mock();

        // Call an arbitrary function and check it returns a mock
        local mock1 = p.arbitraryFunction();

        local mock2 = p.arbitraryFunction2();

        expect(mock1).to.not.equal(mock2);

    });

    it("Resetting a mock clears all parameters", function()
    {
        local m = Mock();

        // Set some values and call some functions
        m.randomData <- 7673;
        m.randomFunction("hi", false);

        expect(m.randomFunction.callCount).toBe(1);
        expect(m.randomData).toBe(7673);

        // Reset
        m.resetMock();

        expect(m.randomFunction.callCount).toBe(0);

        // We're reset, so accessing an undefined variable should give us a new MockFunction class
        expect(m.randomData).to.be.ofClass(MockFunction);

    });
});
