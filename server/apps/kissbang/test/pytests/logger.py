import config

levels = {"debug" : 0,
          "info" : 1,
          "warning" : 2,
          "error" : 3}

def log(level, message):
    if levels[level] > config.get_global_config().verbosity:
        print "[%s] %s" % (level, message)

def debug(message):
    log("debug", message)

def info(message):
    log("info", message)

def warn(message):
    log("warning", message)

def error(message):
    log("error", message)

    
