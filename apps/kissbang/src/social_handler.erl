-module(social_handler).

-export([handle_social_data/2]).

handle_social_data(HandlerPid, Data) ->
    gen_server:cast(HandlerPid, {handle_social_callback, Data}).
