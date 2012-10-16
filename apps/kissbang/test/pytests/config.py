import logger

class Config:
    def __init__(self):
        self.serverUrl = "127.0.0.1:8080"
        self.verbosity = logger.levels["debug"]

def get_global_config():
    return Config()
