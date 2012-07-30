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
-export([start_link/0, start/0, start/1, start_link/1]).
-export([join/2, broadcast_message/3, are_in_room/2, leave/2, drop/1, is_active/1, get_number_of_users/1,
         send_message_to_extensions/2]).

%% gen_fsm callbacks
-export([init/1, pending/2, pending/3, active/2, active/3, handle_event/3,
         handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-define(SERVER, ?MODULE).

%%-record(pending_state, {users}).
%%-record(active_state, {users}).
-record(state, {users, extensions}).

%%%===================================================================
%%% API
%%%===================================================================
send_message_to_extensions(RoomPid, Message) ->
    gen_fsm:send_all_state_event(RoomPid, {send_message_to_extensions, Message}).

get_number_of_users(RoomPid) ->
    gen_fsm:sync_send_event(RoomPid, {get_number_of_users}).

is_active(RoomPid) ->
    gen_fsm:sync_send_event(RoomPid, {is_active}).

drop(RoomPid) ->
    gen_fsm:sync_send_event(RoomPid, {drop}).

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
start_link() ->
    start_link([]).
start_link(Extensions) ->
    gen_fsm:start_link(?MODULE, [Extensions], []).

start() ->
    start([]).
start(Extensions) ->
    gen_fsm:start(?MODULE, [Extensions], []).
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
init([Extensions]) ->
    % form state
    State = #state{users=sets:new(), extensions = Extensions},
    % link extensions
    lists:foreach(fun(ExtensionPid) -> room_ext:link_room(ExtensionPid, self()) end, Extensions),
    % return result
    {ok, pending, State}.

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
pending({broadcast_message, Sender, Message}, State) ->
    inner_broadcast_message(Sender, Message, sets:to_list(State#state.users)),
    {next_state, pending, State};
pending(_Event, State) ->
    {next_state, pending, State}.


active({broadcast_message, Sender, Message}, State) ->
    inner_broadcast_message(Sender, Message, sets:to_list(State#state.users)),
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
pending({get_number_of_users}, _From, State) ->
    {reply, sets:size(State#state.users), pending, State};
pending({is_active}, _From, State) ->
    {reply, false, pending, State};
pending({leave_room, UserGuid}, _From, State) ->
    % drop user
    OriginalUsersSize = sets:size(State#state.users),
    NewUsers = sets:del_element(UserGuid, State#state.users),
    % form new state
    NewState = State#state{users = NewUsers},
    % are somebody droped?
    case sets:size(NewUsers) of
        0 -> 
            ok = call_extensions(fun(Extension) -> room_ext:on_user_leave(Extension, UserGuid) end, State#state.extensions),
            ok = call_extensions(fun(Extension) -> room_ext:on_room_death(Extension) end, State#state.extensions),
            inner_broadcast_message(#on_room_death{}, sets:to_list(NewUsers)),
            case OriginalUsersSize of
                0 ->
                    {reply, nobody_droped, pending, State};
                _Other ->
                    {stop, normal, ok, NewState}
            end;
        OriginalUsersSize -> 
            {reply, nobody_droped, pending, NewState};
        _Other ->
            ok = call_extensions(fun(Extension) -> room_ext:on_user_leave(Extension, UserGuid) end, State#state.extensions),
            inner_broadcast_message(#on_room_user_list_changed{users = sets:to_list(NewUsers)}, 
                                    sets:to_list(NewUsers)),
            {reply, ok, pending, NewState}
    end;
pending({drop}, _From, State) ->
    Reply = inner_drop(State#state.users),
    {stop, normal, Reply, State};
pending({are_in_room, Guid}, _From, State) ->
    Reply = sets:is_element(Guid, State#state.users),
    {reply, Reply, pending, State};

pending({join, Guid}, _From, State) ->
    % join it to room
    case inner_join(Guid, State, "pending") of
        {ok, NewUsers} ->
            AreReadyToStart = sets:size(NewUsers) >= element(2, application:get_env(kissbang, room_limit_to_start)),
            if
                AreReadyToStart ->
                    inner_broadcast_message(#on_room_state_changed{state = "active"}, sets:to_list(NewUsers)),
                    ok = call_extensions(fun(Extension) -> room_ext:on_room_became_active(Extension) end, State#state.extensions),
                    {reply, ok, active, State#state{users = NewUsers}};
                true ->
                    {reply, ok, pending, State#state{users = NewUsers}}
                end;
        Error ->
              {reply, Error, pending, State}
        end;
    
pending(_Event, _From, State) ->
    Reply = invalid_call,
    {reply, Reply, pending, State}.


active({drop}, _From, State) ->
    {stop, normal, inner_drop(State#state.users), State};
active({are_in_room, UserGuid}, _From, State) ->
    {reply, sets:is_element(UserGuid, State#state.users), active, State};
active({get_number_of_users}, _From, State) ->
    {reply, sets:size(State#state.users), active, State};
active({is_active}, _From, State) ->
    {reply, true, active, State};
active({leave_room, UserGuid}, _From, State) ->
    % drop user
    NewUsers = sets:del_element(UserGuid, State#state.users),
    % form state
    NewState = State#state{users = NewUsers},
    % are somebody droped?
    OriginalUsersSize = sets:size(State#state.users),
    case sets:size(NewUsers) of
        1 ->
            ok = call_extensions(fun(Extension) -> room_ext:on_user_leave(Extension, UserGuid) end, State#state.extensions),
            ok = call_extensions(fun(Extension) -> room_ext:on_room_death(Extension) end, State#state.extensions),
            inner_broadcast_message(#on_room_death{}, sets:to_list(NewUsers)),
            inner_broadcast_message(#on_room_user_list_changed{users = sets:to_list(NewUsers)}, 
                                    sets:to_list(NewUsers)),
            {stop, normal, ok, NewState};
        OriginalUsersSize ->
            {reply, nobody_droped, active, NewState};
        _Other ->
            ok = call_extensions(fun(Extension) -> room_ext:on_user_leave(Extension, UserGuid) end, State#state.extensions),
            inner_broadcast_message(#on_room_user_list_changed{users = sets:to_list(NewUsers)}, 
                                    sets:to_list(NewUsers)),
            {reply, ok, active, NewState}
    end;
active({join, UserGuid}, _From, State) ->
    case inner_join(UserGuid, State, "active") of
        {ok, NewUsers} ->
            {reply, ok, active, State#state{users = NewUsers}};
        Error ->
            {reply, Error, active, State}
    end; 
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
handle_event({send_message_to_extensions, Message}, StateName, State) ->
    lists:foreach(fun(ExtensionPid) -> room_ext:handle_extension_message(ExtensionPid, Message) end,
                  State#state.extensions),
    {next_state, StateName, State}; 
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
inner_broadcast_message(Message, [User | RestUsers]) ->
    proxy_srv:async_route_messages(User, [Message]),
    inner_broadcast_message(Message, RestUsers);
inner_broadcast_message(_Message, []) ->
    ok.

inner_broadcast_message(_Sender, Message, Users) ->
    inner_broadcast_message(Message, Users).

inner_join(Guid, State, StateName) ->
    Users = State#state.users,
    AreAlreadyInSet = sets:is_element(Guid, Users),
    if 
        AreAlreadyInSet -> %% are user already here?
            proxy_srv:async_route_messages(Guid, [#on_already_in_this_room{}]),
            {error, already_in_room};
        true -> %% if this is new user
            AreMaximumReached = sets:size(Users) == element(2, application:get_env(kissbang, room_maximum_users)),
            if 
                AreMaximumReached ->
                    proxy_srv:async_route_messages(Guid, [#on_room_is_full{}]),
                    {error, room_already_full};
                true ->
                    ExtensionsResult = call_extensions(fun(ExtensionPid) -> room_ext:on_user_join(ExtensionPid, Guid) end, State#state.extensions),
                    case ExtensionsResult of
                        ok ->
                            inner_broadcast_message(Guid, #on_room_user_list_changed{users = sets:to_list(Users)}, sets:to_list(Users)),
                            proxy_srv:async_route_messages(Guid, [#on_joined_to_room{users = sets:to_list(Users), state = StateName}]),
                            {ok, sets:add_element(Guid, Users)};
                        Error ->
                            {error, Error}
                    end
            end
    end.

inner_drop(Users) ->
    lists:foreach(fun (UserGuid) -> ok = roommgr_srv:async_leave_room(UserGuid) end,
                  sets:to_list(Users)),
    ok.

    
call_extensions(Call, [Extension | RestExtensions]) ->
    CallResult = Call(Extension),
    case CallResult of 
        ok ->
            call_extensions(Call, RestExtensions);
        Error ->
            Error
    end;
call_extensions(_Call, []) ->
    ok.

