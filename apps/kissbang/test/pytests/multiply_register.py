import admin_messaging
from admin_json_messaging import jsonSerializer
import urllib2
import string
import random
import math

def send_register_user(Info):
    req = urllib2.Request("http://178.162.190.208:5223",
                          jsonSerializer.serialize(admin_messaging.TouchUserInfo(userInfo = Info)),
                          {})
    response = urllib2.urlopen(req)
    print response.read()


def print_info(Info):
    print "=================================================="
    print jsonSerializer.serialize(Info)

def random_string():
    chars=string.ascii_uppercase + string.digits
    size = int(math.floor(random.uniform(0, 16)))
    return ''.join(random.choice(chars) for x in range(size))

def random_bool():
    if random.random() < 0.5:
        return "true"
    else:
        return "false"
        

def random_date():
    return random_string()

def register_user():
    Info = admin_messaging.UserInfo(city = random_string(),
                                    name = random_string(),
                                    avatarUrl = random_string(),
                                    userId = random_string(),
                                    birthDate = random_date(),
                                    profileUrl = random_string(),
                                    isMan = random_bool())
    print_info(Info)
    send_register_user(Info)

def main():
    UsersToRegister = 100
    for i in range(1, UsersToRegister):
        register_user()

if __name__ == '__main__':
    main()
