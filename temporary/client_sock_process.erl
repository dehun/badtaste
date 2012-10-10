-module(client_sock_process).

start(ClientSock) ->
    WorkPid = spawn_link(client_sock_process, sock_work_loop, [ClientSock]),
    ReceiverPid = spawn_link(client_sock_process, receiver_loop, [ClientSock, Pid, receiving_length]),
    #origin{node = node(), client_process = WorkPid}.

stop(Origin) ->
    Origin#origin.client_process ! {stop}.

send_messages(Origin, Messages) ->
    Origin#origin.client_process ! {send_messages, Messages}.

sock_work_loop(ClientSock) ->
    receive 
        {stop} ->
            ok;
        {send_messages, Messages} ->
            gen_tcp:send(ClientSock, serialize_message(Messages)),
            sock_work_loop(ClientSock)
    end.
    
receiver_loop(ClientSock, WorkPid, State) ->
    case State of
        receiving_length ->
            RecvResult = gen_tcp:recv(ClientSock, 4);
        {receiving_message, MessageLength} ->
            RecvResult = gen_tcp:recv(ClientSock, MessageLength)
    end,
    case RecvResult of
        {ok, Packet} ->
            case State of
                receiving_length ->
                    receiver_loop(ClientSock, WorkPid, receiving_message);
                {receiving_message, _}->
                    gateway_srv:handle_origin_message(deserialize_message(Packet)),
                    receiver_loop(ClientSock, WorkPid, receiving_length)
            end;
        {error, _} ->
            WorkPid ! {stop},
            gateway_srv:lost_origin()


serialize_message(Message) ->
    none.

deserialize_message(Message) ->
    none.
