-module(utils).

-export([acall/2, unix_time/0]).

acall(Fun, From) ->
    spawn_link(fun() ->
                       Reply = Fun(),
                       gen_server:reply(From, Reply)
               end).


unix_time() ->
    {_, CurrentTime, _} = erlang:now(),
    CurrentTime.
