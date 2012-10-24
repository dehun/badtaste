-module(items_loader).

-export([load_items/1]).
-include("item.hrl").

load_items(Url) ->
    inets:start(),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
        httpc:request(get, {Url, []}, [], []),
    {struct, ItemsJson} = mochijson2:decode(Body),
    [load_item(ItemJson) || ItemJson <- proplists:get_value(<<"item">>, ItemsJson)].

load_item({struct, ItemJson}) ->
    #item{name = proplists:get_value(<<"name">>, ItemJson),
          description = proplists:get_value(<<"description">>, ItemJson),
          image_url = proplists:get_value(<<"image_url">>, ItemJson),
          price = list_to_integer(binary_to_list(proplists:get_value(<<"price">>, ItemJson))),
          type = binary_to_list(proplists:get_value(<<"type">>)),
          count = list_to_integer(binary_to_list(proplists:get_value(<<"count">>, ItemJson)))}.

