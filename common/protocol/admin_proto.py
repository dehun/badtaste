from protogen.messaging.types import pgMessage, pgInteger, pgFloat, pgString, pgList

protocolName = "kissbang"

# user register
class TouchUserInfo(pgMessage):
    userId = pgString()
    firstName = pgString()
    lastName = pgString()
    profileUrl = pgString()
    isMan = pgString()
    smallAvatarUrl = pgString()
    mediumAvatarUrl = pgString()
    bigAvatarUrl = pgString()
