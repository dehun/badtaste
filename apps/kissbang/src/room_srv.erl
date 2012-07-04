%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%% bottle game logic goes here. broadcasting and other logic also lives here
%%% @end
%%% Created : 25 Jun 2012 by  <>
%%%-------------------------------------------------------------------
-module(room_srv).

-behaviour(gen_fsm).
-include("kissbang_messaging.hrl").

%% API
-export([start_link/1, start/1]).
-export([join/2, broadcast_message/3, are_in_room/2, leave/2]).

%% gen_fsm callbacks
-export([init/1, pending/2, pending/3, active/2, active/3, handle_event/3,
         handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-define(SERVER, ?MODULE).

-record(pending_state, {users}).
-record(active_state, {users}).

%%%===================================================================
%%% API
%%%===================================================================
broadcast_message(RoomPid, Sender, Message) ->
    gen_fsm:send_event(RoomPid, {broadcast_message, Sender, Message}).

join(RoomPid, Guid) ->
    gen_fsm:sync_send_event(RoomPid, {join, Guid}).

are_in_room(RoomPid, Guid) ->
    gen_fsm:sync_send_event(RoomPid, {are_in_room, Guid}).

leave(RoomPid, UserGuid) ->
    gen_fsm:sync_send_event(RoomPid, {leave_room, UserGuid}).

%%--------------------------------------------------------------------
%% @doc
%% Creates a gen_fsm process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(OwnerGuid) ->
    gen_fsm:start_link(?MODULE, [OwnerGuid], []).

start(OwnerGuid) ->
    gen_fsm:start(?MODULE, [OwnerGuid], []).
%%%===================================================================
%%% gen_fsm callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm is started using gen_fsm:start/[3,4] or
%% gen_fsm:start_link/[3,4], this function is called by the new
%% process to initialize.
%%
%% @spec init(Args) -> {ok, StateName, State} |
%%                     {ok, StateName, State, Timeout} |
%%                     ignore |
%%                     {stop, StopReason}
%% @end
%%--------------------------------------------------------------------
init([Owner]) ->
    Users = sets:from_list([Owner]),
    {ok, pending, #pending_state{users=Users}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_event/2, the instance of this function with the same
%% name as the current state name StateName is called to handle
%% the event. It is also called if a timeout occurs.
%%
%% @spec pending(Event, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
pending({leave_room, UserGuid}, State) ->
    NewUsers = sets:del_element(UserGuid, State#pending_state.users),
    NewState = State#pending_state{users = NewUsers},
    case sets:size(NewUsers) of
        0 ->
            {stop, normal, NewState};
        _Other ->
            {next_state, pending, NewState}
        end;
pending({broadcast_message, Sender, Message}, State) ->
    inner_broadcast_message(Sender, Message, sets:to_list(State#pending_state.users)),
    {next_state, pending, Message};
pending(_Event, State) ->
    {next_state, pending, State}.


active({leave_room, UserGuid}, State) ->
    NewUsers = sets:del_element(UserGuid, State#active_state.users),
    NewState = State#active_state{users = NewUsers},
    case sets:size(NewUsers) of
        1 ->
            {stop, normal, NewState};
        _Other ->
            {next_state, active, NewState}
    end;
active({broadcast_message, Sender, Message}, State) ->
    inner_broadcast_message(Sender, Message, sets:to_list(State#active_state.users)),
    {next_state, active, State};
active(_Event, State) ->
    {next_state, active, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_event/[2,3], the instance of this function with
%% the same name as the current state name StateName is called to
%% handle the event.
%%
%% @spec state_name(Event, From, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {reply, Reply, NextStateName, NextState} |
%%                   {reply, Reply, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState} |
%%                   {stop, Reason, Reply, NewState}
%% @end
%%--------------------------------------------------------------------
pending({are_in_room, Guid}, _From, State) ->
    Reply = sets:is_element(Guid, State#pending_state.users),
    {reply, Reply, pending, State};

pending({join, Guid}, _From, State) ->
    case inner_join(Guid, State#pending_state.users) of
        {ok, NewUsers} ->
            AreReadyToStart = sets:size(State#pending_state.users) >= application:get_env(kissbang, room_limit),
            if
                AreReadyToStart ->
                    {reply, ok, active, #active_state{users = State#pending_state.users}};
                true ->
                    {reply, ok, pending, State#pending_state{users=NewUsers}}
                end;
        Error ->
            Error
        end;
    
pending(_Event, _From, State) ->
    Reply = invalid_call,
    {reply, Reply, pending, State}.


active({join, _Guid}, _From, State) ->
    {reply, cant_join, active, State};
active(_Event, _From, State) ->
    Reply = invalid_call,
    {reply, Reply, active, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_all_state_event/2, this function is called to handle
%% the event.
%%
%% @spec handle_event(Event, StateName, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
handle_event(_Event, StateName, State) ->
    {next_state, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_all_state_event/[2,3], this function is called
%% to handle the event.
%%
%% @spec handle_sync_event(Event, From, StateName, State) ->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {reply, Reply, NextStateName, NextState} |
%%                   {reply, Reply, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState} |
%%                   {stop, Reason, Reply, NewState}
%% @end
%%--------------------------------------------------------------------
handle_sync_event(_Event, _From, StateName, State) ->
    Reply = ok,
    {reply, Reply, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it receives any
%% message other than a synchronous or asynchronous event
%% (or a system message).
%%
%% @spec handle_info(Info,StateName,State)->
%%                   {next_state, NextStateName, NextState} |
%%                   {next_state, NextStateName, NextState, Timeout} |
%%                   {stop, Reason, NewState}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, StateName, State) ->
    {next_state, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_fsm terminates with
%% Reason. The return value is ignored.
%%
%% @spec terminate(Reason, StateName, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _StateName, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, StateName, State, Extra) ->
%%                   {ok, StateName, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
inner_broadcast_message(Sender, Message, [User | RestUsers]) when User =:= Sender -> %% don't broadcast to self
    inner_broadcast_message(Sender, Message, RestUsers);
inner_broadcast_message(Sender, Message, [User | RestUsers]) -> 
    proxy_srv:route_messages(User, [Message]),
    inner_broadcast_message(Sender, Message, RestUsers);
inner_broadcast_message(_Sender, _Message, []) ->
    ok.

inner_join(Guid, Users) ->
    AreAlreadyInSet = sets:is_element(Guid, Users),
    if 
        AreAlreadyInSet -> %% are user already here?
            proxy_srv:route_messages(Guid, #on_already_in_this_room{}),
            {error, already_in_this_room};
        true -> %% if this is new user
            {ok, sets:add_element(Guid, Users)}
    end.
