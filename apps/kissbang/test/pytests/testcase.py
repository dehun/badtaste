from connection import Connection

class TestCase:
    def __init__(self, config):
        self._config = config
        self._connection = Connection(config.serverUri)

    def send_message(self, message):
        self._connection.send_message(message)

    @abstractmethod
    def on_got_message(self, message):
        pass

    @abstractmethod
    def run(self):
        pass

    def get_name(self):
        return self.__class__.__name__
