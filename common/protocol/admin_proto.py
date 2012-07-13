from protogen.messaging.types import pgMessage, pgInteger, pgFloat, pgString, pgList

protocolName = "admin"

# user registration (touch and update info)
class TouchUserInfo(pgMessage):
    userId = pgString()
    firstName = pgString()
    lastName = pgString()
    profileUrl = pgString()
    isMan = pgString()
    smallAvatarUrl = pgString()
    mediumAvatarUrl = pgString()
    bigAvatarUrl = pgString()

class TouchUserInfoResult(pgMessage):
    result = pgString() # ok | error


# money
class BuyGold(pgMessage):
    amount = pgInteger()

class BuyGoldResult(pgMessage):
    result = pgString() # ok | error

# 
