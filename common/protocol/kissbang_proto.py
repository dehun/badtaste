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
    isNameHidden = pgString()
    isSocialInfoHidden = pgString()
    isCityHidden = pgString()

class TouchUserInfoByUser(pgMessage):
    name = pgString()
    hideName = pgString() # bool
    hideUserId = pgString() # bool
    hideCity = pgString() # bool 

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

# room queues
class JoinMainRoomQueue(pgMessage):
    pass

class OnJoinedToMainRoomQueue(pgMessage):
    pass

class JoinTaggedRoomQueue(pgMessage):
    tag = pgString()

class OnJoinedToTaggedRoomQueue(pgMessage):
    tag = pgString()


# rooms

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


# rates
## rate user
class RateUser(pgMessage):
    targetUserGuid = pgString()
    rate = pgInteger()

class OnUserRatedSuccessfully(pgMessage):
    ratedUserGuid = pgString()

class OnUserRateFailed(pgMessage):
    ratedUserGuid = pgString()

## get user rate
class GetUserRate(pgMessage):
    targetUserGuid = pgString()

class RatePoint(pgMessage):
    raterGuid = pgString()
    rate = pgInteger()

class OnGotUserRate(pgMessage):
    userGuid = pgString()
    averateRate = pgFloat()
    lastRaters = pgList(pgMessage()) # RatePoint

## rate point delete
class DeleteRatePoint(pgMessage):
    raterGuid = pgString()

class OnRatePointDeleted(pgMessage):
    raterGuid = pgString()

class OnRatePointDeleteFailed(pgMessage):
    raterGuid = pgString()

## are user rated
class AreUserRated(pgMessage):
    targetUserGuid = pgString()

class OnGotAreUserRated(pgMessage):
    targetUserGuid = pgString()
    areRated = pgString() # bool

# gifts
## present gift
class PresentGift(pgMessage):
    targetUserGuid = pgString()
    giftGuid = pgString()

class OnGotGift(pgMessage):
    giftSenderGuid = pgString()
    giftGuid = pgString()

class OnGiftReceivedInGame(pgMessage):
    giftSenderGuid = pgString()
    giftReceiverGuid = pgString()
    giftGuid = pgString()

## get my gifts
class SendedGift(pgMessage):
    senderGuid = pgString()
    giftGuid = pgString()
    
class GetMyGifts(pgMessage):
    pass

class OnGotMyGifts(pgMessage):
    gifts = pgList(pgMessage())

# vip
## get vip points
class GetVipPoints(pgMessage):
    targetUserGuid = pgString()

class OnGotVipPoints(pgMessage):
    ownerUserGuid = pgString()
    points = pgInteger()

# sympathy
## get user sympathies
class GetUserSympathies(pgMessage):
    targetUserGuid = pgString()

class Sympathy(pgMessage):
    kisserGuid = pgString()
    kisses = pgInteger()

class OnGotUserSympathies(pgMessage):
    ownerUserGuid = pgString()
    sympathies = pgList(pgMessage())

#decore
## buy decore
class BuyDecore(pgMessage):
    decoreGuid = pgString()

class OnDecoreBoughtSuccessfully(pgMessage):
    buyedDecoreGuid = pgString()

class OnDecoreBuyFail(pgMessage):
    failedDecoreGuid = pgString()
    reason = pgString()

## get decore for
class GetDecorationsFor(pgMessage):
    targetUserGuid = pgString()

class OnGotDecorations(pgMessage):
    ownerUserGuid = pgString()
    decorations = pgList(pgString())

# mail
## send mail
class SendMail(pgMessage):
    receiverGuid = pgString()
    subject = pgString()
    body = pgString()

class OnGotNewMail(pgMessage):
    senderGuid = pgString()
    subject = pgString()
    body = pgString()

## read mail
### mailbox
class CheckMailbox(pgMessage):
    pass

class Mail(pgMessage):
    mailGuid = pgString()
    senderGuid = pgString()
    receiverGuid = pgString()
    dateSend = pgInteger()
    type = pgString()
    subject = pgString()
    body = pgString()
    isRead = pgString()

class OnGotMailbox(pgMessage):
    mails = pgList(pgMessage())

### mark as read
class MarkMailAsRead(pgMessage):
    targetMailGuid = pgString()

class OnMailMarkedAsRead(pgMessage):
    markedMailGuid = pgString()

# followers
## buy following
class BuyFollowing(pgMessage):
    targetUserGuid = pgString()

class OnFollowingBought(pgMessage):
    boughtUserGuid = pgString()

class OnFollowingBuyingFail(pgMessage):
    targetedUserGuid = pgString()
    reason = pgString()


## get user followers
class GetUserFollowers(pgMessage):
    targetUserGuid = pgString()

class OnGotUserFollowers(pgMessage):
    ownerUserGuid = pgString()
    rebuyPrice = pgInteger()
    followers = pgList(pgString())
