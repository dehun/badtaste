-module(social_handler).

-include("social_handlers/item.hrl").
-export([handle_social_data/2]).

handle_social_data(HandlerPid, Req) ->
    gen_server:cast(HandlerPid, {handle_social_callback, Req}).

on_item_bought(UserId, Item) ->
    ItemId = Item#item.item_id,
    {true, Guid} = auth_srv:is_registered(UserId),
    case Item#item.type of
        "gold" ->
            log_srv:info("user ~p bought item ~p", [UserId, ItemId]),
            bank_srv:deposit(Guid, Item#item.count),
            ok;
        _Other ->
            log_srv:error("unknown type ~p on user buy ~p", [ItemId, Guid]),
            fail
    end.

