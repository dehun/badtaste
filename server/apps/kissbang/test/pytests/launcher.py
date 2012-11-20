from cases import *
from tests_registry import get_global_tests_registry

if __name__ == '__main__':
    for testClass in get_global_tests_registry().get_all_tests():
        test = testClass()
        test.run()
        
