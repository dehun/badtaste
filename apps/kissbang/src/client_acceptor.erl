-module(client_acceptor).

-export([start_link/1, accept_loop/1, client_sock_process/1]).

start_link(Port) ->
    {ok, ListenSocket} = gen_tcp:listen(Port, [{reuseaddr, true}]),
    spawn_link(client_acceptor, accept_loop, [ListenSocket]).

accept_loop(ListenSock) ->
    {ok, ClientSock} = gen_tcp:accept(ListenSock),
    log_srv:debug("got new connection"),
    spawn_client_sock_processes(ClientSock),
    accept_loop(ListenSock).


-record(cstate, {socket, origin_pid, buff}).    
spawn_client_sock_processes(ClientSock) ->
    OriginPid = origin_controller:start(ClientSock),
    SockProcessPid = spawn(client_acceptor, client_sock_process, [#cstate{socket = ClientSock,
                                                                          origin_pid = OriginPid,
                                                                              buff = []}]),
    gen_tcp:controlling_process(ClientSock, SockProcessPid).

client_sock_process(State) ->
    link(State#cstate.origin_pid),
    client_sock_process_loop(State).

client_sock_process_loop(State) ->
        inet:setopts(State#cstate.socket, [list, {active, once}, {packet, 4}]),
    receive
        {tcp, ClientSock, Packet} ->
            State#cstate.origin_pid ! {got_packet, Packet},
            client_sock_process_loop(State);
        {tcp_closed, ClientSock} ->
            State#cstate.origin_pid ! {disconnected};
        {tcp_error, ClientSock, Reason} ->
            log_srv:error("socket error with ~w reason", [Reason]),
            State#cstate.origin_pid ! {disconnected}
    end.

    
    
