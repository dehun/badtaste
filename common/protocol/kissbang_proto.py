from protogen.messaging.types import pgMessage, pgInteger, pgFloat, pgString, pgList

protocolName = "kissbang"

# service messages
class PingMessage(pgMessage):
    data = pgString()

class PongMessage(pgMessage):
    data = pgString()

# global
class ProtocolMissmatch(pgMessage):
    pass


# bank
class CheckBankBalance(pgMessage):
    pass

class OnBankBalanceChecked(pgMessage):
    gold = pgInteger()

class OnBankBalanceChanged(pgMessage):
    newGold = pgInteger()

# time
class GetCurrentTime(pgMessage):
    pass

class OnGotCurrentTime(pgMessage):
    time = pgInteger() # number of secconds passed from 1900...

# user info
class GetFriendInfo(pgMessage):
    targetUserGuid = pgString()

class GetUserInfo(pgMessage):
    targetUserGuid = pgString()

class OnGotUserInfo(pgMessage):
    infoOwnerGuid = pgString()
    userId = pgString()
    name = pgString()
    profileUrl = pgString()
    birthDate = pgString()
    isMan = pgString()
    pictureUrl = pgString()
    isOnline = pgInteger()
    coins = pgInteger()
    kisses = pgInteger()
    city = pgString()

class TouchUserInfoByUser(pgMessage):
    name = pgString()

class TouchUserInfoByUserResult(pgMessage):
    result = pgString()

class OnUserInfoChanged(pgMessage):
    userGuid = pgString()


# authentication
class Authenticate(pgMessage):
    login = pgString()
    password = pgString()


class Authenticated(pgMessage):
    guid = pgString()


class AuthenticationFailed(pgMessage):
    reason = pgString()

# chat
class SendChatMessageToRoom(pgMessage):
    message = pgString()

class OnGotChatMessageFromRoom(pgMessage):
    senderGuid = pgString()
    message = pgString()

# rooms
class JoinMainRoomQueue(pgMessage):
    pass

class OnJoinedToMainRoomQueue(pgMessage):
    pass

class OnJoinedToRoom(pgMessage):
    users = pgList(pgString()) # user guids
    state = pgString()

class GetRoomState(pgMessage):
    pass

class OnRoomStateChanged(pgMessage):
    state = pgString()

class OnRoomUserListChanged(pgMessage):
    users = pgList(pgString()) # userGuids

class OnRoomIsFull(pgMessage):
    pass

class OnAlreadyInThisRoom(pgMessage):
    pass

class OnRoomDeath(pgMessage):
    pass

# bottle game
class OnNewBottleSwinger(pgMessage):
    swingerGuid = pgString()


class SwingBottle(pgMessage):
    pass

class OnBottleSwinged(pgMessage):
    swingerGuid = pgString()
    victimGuid = pgString()


class OnKiss(pgMessage):
    kisserGuid = pgString()
    kissedGuid = pgString()


class OnRefuseToKiss(pgMessage):
    refuserGuid = pgString()
    refusedGuid = pgString()


class Kiss(pgMessage):
    pass

class RefuseToKiss(pgMessage):
    pass


