from twisted.internet import protocol, reactor, threads
from twisted.protocols.basic import Int32StringReceiver
from twisted.internet.endpoints import TCP4ClientEndpoint
from threading import Thread

class ClientProtocol(Int32StringReceiver):
    def stringReceived(self, message):
        print message
#        for subscriber in self.factory.subscribers:
#            subscriber.on_got_message(message)

    def connectionLost(self, reason):
        print "[!!!] lost connection cos of " 

    def connectionMade(self):
        print "[iii] successfully connected"


class ClientProtocolFactory(protocol.ClientFactory):
    # def __init__(self, subscribers):
    #     self.subscribers = subscribers
    def init(self, subscribers):
        self.subscribers = subscribers

    def buildProtocol(self, addr):
        print "new proto\n" * 20
        return ClientProtocol()


class Connection:
    def __init__(self, serverAddr, serverPort, subscribers):
        self._serverAddr = serverAddr
        self._serverPort = serverPort
        self._subscribers = subscribers

    def got_protocol(self, protocol):
        self._protocol = protocol

    def connect(self):
        point = TCP4ClientEndpoint(reactor, self._serverAddr, self._serverPort)
        self._factory = ClientProtocolFactory()
        self._factory.init(self._subscribers)
        d = point.connect(self._factory)
        d.addCallback(lambda proto : self.got_protocol(proto))
#        reactor.run()
        Thread(target = lambda : reactor.run(installSignalHandlers=0)).start()

    def send_message(self, message):
        reactor.callFromThread(lambda : self._protocol.sendString(message))
