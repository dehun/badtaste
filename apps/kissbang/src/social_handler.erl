-module(social_handler).

-include("social_handlers/item.hrl").
-export([handle_social_data/4]).

handle_social_data(HandlerPid, Body, Get, Post) ->
    gen_server:call(HandlerPid, {handle_social_callback, Body, Get, Post}).

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

