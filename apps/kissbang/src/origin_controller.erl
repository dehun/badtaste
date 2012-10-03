-module(origin_controller).

-include("kissbang_messaging.hrl").
-include("origin.hrl").

-export([start/1, origin_work_loop/1, 
         disconnect/1, send_message/2]).

-record(state, {socket, authenticated}).

start(ClientSocket) ->
    spawn(origin_controller, origin_work_loop, [#state{socket = ClientSocket,
                                                       authenticated = false
                                                      }]).
get_my_origin() ->
    #origin{pid=self(), node=node()}.

disconnect(Origin) ->
    Origin#origin.pid ! {disconnect}.

send_message(Origin, Message) ->
    Origin#origin.pid ! {send_message, Message}.

origin_work_loop(State) ->
    receive
        {send_message, Message} ->
%            log_srv:debug("sending ~p message to origin ~p", [Message, self()]),
            gen_tcp:send(State#state.socket, list_to_binary(kissbang_json_messaging:serialize_message(Message))),
            origin_work_loop(State);
        {got_packet, Packet} ->
            NewState = on_got_packet(Packet, State),
            origin_work_loop(NewState);
        {disconnected} ->   
            proxy_srv:drop_origin(get_my_origin());
        {disconnect} ->
            gen_tcp:close(State#state.socket),
            State
    end.

on_got_packet(Packet, State) ->
%    log_srv:info("got ~p packet", [Packet]),
    Msg = kissbang_json_messaging:deserialize_message(Packet),
    case State#state.authenticated of
        {true, _Guid} ->
            on_got_authorized_message(Msg, State);
        false ->
            on_got_unauthorized_message(Msg, State)
    end.

on_got_authorized_message(Message, State) ->
    gateway_srv:handle_message(element(2, State#state.authenticated), Message),
    State.

on_got_unauthorized_message(Message, State) when is_record(Message, authenticate) ->
    Result = auth_srv:auth(Message#authenticate.login, Message#authenticate.password),
    case Result of 
        {ok, Guid} ->
            proxy_srv:register_origin(Guid, get_my_origin()),
            send_message(get_my_origin(), #authenticated{guid = Guid}),
            job_srv:try_complete_job(Guid, <<"1">>),
            State#state{authenticated = {true, Guid}};
        FailReason ->
            send_message(get_my_origin(), #authentication_failed{reason=atom_to_list(FailReason)}),
            disconnect(get_my_origin()),
            State
        end;
on_got_unauthorized_message(_Message, State) ->
    send_message(get_my_origin(), #protocol_missmatch{}),
    disconnect(get_my_origin()),
    State.

