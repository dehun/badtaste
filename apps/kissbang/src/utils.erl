-module(utils).

-export([acall/2]).

acall(Fun, From) ->
    spawn_link(fun() ->
                       Reply = Fun(),
                       gen_server:reply(From, Reply)
               end).


