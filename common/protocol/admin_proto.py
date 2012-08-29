from protogen.messaging.types import pgMessage, pgInteger, pgFloat, pgString, pgList

protocolName = "admin"

# user registration (touch and update info)
class UserInfo(pgMessage):
    userId = pgString()
    name = pgString()
    profileUrl = pgString()
    isMan = pgInteger()
    birthDate = pgString()
    city = pgString()
    avatarUrl = pgString()
    hideSocialInfo = pgString()
    hideName = pgString()
    hideCity = pgString()

class TouchUserInfo(pgMessage):
    userInfo = pgMessage()
    
class TouchUserInfoResult(pgMessage):
    result = pgString() # ok | error


class UploadNewUserAvatar(pgMessage):
    userGuid = pgString()
    imageFormatName = pgString()
    imageDataBase64 = pgString()

class UploadNewUserAvatarResult(pgMessage):
    result = pgString()

# money
class BuyGold(pgMessage):
    amount = pgInteger()

class BuyGoldResult(pgMessage):
    result = pgString() # ok | error

# 
