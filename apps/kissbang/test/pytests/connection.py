from twisted.internet import protocol, reactor
from twisted.protocols.basic import Int32StringReceiver
from twisted.internet.endpoints import TCP4ClientEndpoint


class Connection:
    def __init__(self, serverUri, testCase):
        self._serverUri = serverUri
        self._testCase = testCase
        self._open_connection()

    def _open_connection(self):
        reactor.

    def send_message(self, message):
        self._protocol.sendString(message)

        
class ClientProtocolFactory(protocol.ClientFactory):
    protocol = ClientProtocol

    def __init__(self, testCase):
        pass
    
    def clientConnectionFailed(self, connector, reason):
        print "failed connection"

    def clientConnectionLost(self, connector, reason):
        print "lost connection"

    def buildProtocol(self, addr):
        return ClientProtocol(self._testCase)


class ClientProtocol(Int32StringReceiver):
    def __init__(self, testCase):
        Int32StringReceiver.__init__(self)
        self._testCase = testCase

    def stringReceived(self, message):
        self._testCase.on_got_message(message)
