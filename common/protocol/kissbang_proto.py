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

# authentication
class Authenticate(pgMessage):
    login = pgString()
    password = pgString()


class Authenticated(pgMessage):
    guid = pgString()


class AuthenticationFailed(pgMessage):
    reason = pgString()

# chat
class SendChatMessage(pgMessage):
    message = pgString()


class OnGotChatMessage(pgMessage):
    senderGuid = pgString()
    message = pgString()

# rooms
class FindNextRoom(pgMessage):
    pass


class OnRoomFound(pgMessage):
    pass

class OnAlreadyInThisRoom(pgMessage):
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


