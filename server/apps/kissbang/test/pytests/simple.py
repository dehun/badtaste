import sys
from twisted.internet import protocol, reactor
from twisted.protocols.basic import Int32StringReceiver

addr = "192.168.1.177"
port = 8080

class ClientProtocol(Int32StringReceiver):
    def connectionMade(self):
        msg = sys.argv[1]
        print "[>>>]" + msg
        self.sendString(msg)

    def stringReceived(self, msg):
        print "[<<<]" + msg


class ClientProtocolFactory(protocol.ClientFactory):
    protocol = ClientProtocol
    def clientConnectionFailed(self, connector, reason):
        print "[e] connection failed"
        exit(-1)

    def clientConnectionLost(self, connector, reason):
        print "[e] connection lost"


def main():
    factory = ClientProtocolFactory()
    reactor.connectTCP(addr, port, factory)
    reactor.run()

if __name__ == '__main__':
    print sys.argv[1]
    main()


