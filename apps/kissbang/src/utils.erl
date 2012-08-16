-module(utils).

-export([acall/2, 
         acast/1,
         unix_time/0]).


acall(Fun, From) ->
    spawn_link(fun() ->
                       Reply = Fun(),
                       gen_server:reply(From, Reply)
               end).


acast(Fun) ->
    spawn_link(Fun).

unix_time() ->
    {_, CurrentTime, _} = erlang:now(),
    CurrentTime.
