from server_test import ServerTest
import logger

class case1(ServerTest):
    testname = "case1"

    def inner_run(self):
        logger.debug("wohoooo")
