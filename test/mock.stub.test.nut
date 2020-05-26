@include once "src/mock/mock.stub.nut"


@include once "src/nutkin.nut"


// Test class used for getting/setting
class MockStubTestClass
{

}

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
