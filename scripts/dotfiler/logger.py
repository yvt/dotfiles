
notice_enabled = False

class bcolors:
    OKGREEN = '\033[92m'
    FATAL = '\033[31m'
    NOTICE = '\033[32m'
    WARN = '\033[33m'
    ENDC = '\033[0m'

def notice(msg):
    if notice_enabled:
        print("[ " + bcolors.NOTICE + "NOTICE" + bcolors.ENDC + " ] " + msg)

def fatal(msg):
    print("[ " + bcolors.FATAL + "FATAL" + bcolors.ENDC + " ] " + msg)

def error(msg):
    print("[ " + bcolors.FATAL + "ERROR" + bcolors.ENDC + " ] " + msg)

def warn(msg):
    print("[ " + bcolors.WARN + "WARN" + bcolors.ENDC + " ] " + msg)

def success(msg):
    print("[ " + bcolors.OKGREEN + "OK" + bcolors.ENDC + " ] " + msg)
