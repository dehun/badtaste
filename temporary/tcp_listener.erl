%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 31 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(tcp_listener).

-export([start_link/0]).

-include("origin.hrl").

-record(state, {accept_sock}).

start_link(Port) ->
    spawn_link(tcp_listener, init, [self()]).

init(From, Port) ->
    {ok, LSocket} = gen_tcp:listen(Port, []),
    State = #state{accept_sock = LSocket},
    loop(From, State).

loop(From, State) ->
    {ok, Sock} = gen_tcp:accept(State#state.accept_sock),
    sock_sattelite_srv:on_new_connection(Sock),
    loop(From, State).
