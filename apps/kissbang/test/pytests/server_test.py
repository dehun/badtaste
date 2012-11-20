import sys
import config
import tests_registry
import logger
from connection_factory import ConnectionFactory

class ServerTestCreator(type):
    def __init__(cls, name, bases, attrs):
        attrs["_connectionFactory"] = ServerTestCreator.create_new_connection_factory()
        if name not in sys.modules[__name__].__dict__:
            ServerTestCreator.register_in_tests_registry(cls)
        super(ServerTestCreator, cls).__init__(name, bases, attrs)

    @staticmethod
    def create_new_connection_factory():
        return ConnectionFactory(config.get_global_config())

    @staticmethod
    def register_in_tests_registry(cls):
        tests_registry.get_global_tests_registry().register(cls)


class ServerTest:
    __metaclass__ = ServerTestCreator
    testname = "unkown"

    def run(self):
        try:
            self.inner_run()
            logger.info("test " + self.__class__.testname + " passed")
        except:
            logger.error("test " + self.__class__.testname + " failed")

    def inner_run(self):
        pass

    def new_connection(login, password):
        return _connectionFactory.create_new_connection()

        
class AuthenticatedTest(ServerTest):
    def inner_run(self):
        self._connection = self.__class__._connectionFactory.create_new_connection()
