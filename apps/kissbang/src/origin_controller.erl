-module(origin_controller).

-export([start/1]).

-record(state, {socket, authenticated}).

start(ClientSocket) ->
    spawn(origin_controller, origin_work_loop, [#state{socket = ClientSocket,
                                                       authenticated = false
                                                      }]).
origin_work_loop(State) ->
    receive 
        {got_packet, Packet} ->
            NewState = on_got_packet(Packet, State),
            origin_work_loop(NewState);
        {disconnected} ->   
%            proxy_srv:drop_origin();
            ok
        end.

on_got_packet(Packet, State) ->
    State.
    

    
