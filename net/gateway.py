from twisted.internet import reactor
import gateway_protocol
import logging

logger = logging.getLogger('[net::gateway]')
gatewayPort = 1080

class Gateway:
    def launch(self):
        logger.info("launching reactor on %s port" % gatewayPort)
        reactor.listen(gatewayPort, gateway_protocol.GatewayProtocolFactory)
        reactor.run()

if __name__ == '__main__':
    Gateway().launch()
