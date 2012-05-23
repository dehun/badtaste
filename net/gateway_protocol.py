from twisted.protocols import Int32StringReceiver
from twisted.internet import protocol
import logging

logger = logging.getLogger("[net::gateway]")

class GatewayProtocol(Int32StringReceiver):
    def stringReceived(self, data):
        logger.debug("got data : %s" % (id(self)))

    def connectionLost(self, reason):
        logger.debug("lost connection %s" % (id(self)))

    def connectionMade(self):
        logger.debug("got connection %s" % (id(self)))


class GatewayProtocolFactory(protocol.Factory):
    protocol = GatewayProtocol

    def __init__(self):
        self.users = {}

    def buildProtocol(self, addr):
        logger.debug("building protocol for addr %s" % (addr))
        return GatewayProtocol(self)

