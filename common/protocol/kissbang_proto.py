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


# user info
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


class OnBottleStoped(pgMessage):
    swingerGuid = pgString()
    pointedGuid = pgString()


class OnKiss(pgMessage):
    kisserGuid = pgString()
    kissedGuid = pgString()


class OnRefuseToKiss(pgMessage):
    refuserGuid = pgString()
    refusedGuid = pgString()


class Kiss(pgMessage):
    victimGuid = pgString()


class RefuseToKiss(pgMessage):
    victimGuid = pgString()


