import logger

class TestsRegistry:
    def __init__(self):
        self._allTests = []

    def register(self, test):
        logger.debug("registering new test with name " + test.testname)
        self._allTests.append(test)

    def get_all_tests(self):
        return self._allTests


globalTestsRegistry = TestsRegistry()

def get_global_tests_registry():
    return globalTestsRegistry
    
