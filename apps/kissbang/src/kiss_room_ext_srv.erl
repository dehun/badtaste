%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 24 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(kiss_room_ext_srv).

-behaviour(gen_fsm).

%% API
-export([start_link/0, start/0]).
%% gen_fsm callbacks
-export([init/1, pending/2, pending/3,
         %% active/2, active/3,
         handle_event/3,
         handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-export([swinger_select_mode/2,
         swing_bottle_mode/2, 
         kiss_mode/2]). %% modes



-define(SERVER, ?MODULE).

-record(state, {users = [], 
                room_pid,
                current_state}).

-record(swing_bottle_mode_state, {current_swinger}).
-record(kiss_mode_state, {kissers = []}).

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
    gen_fsm:start_link(?MODULE, [], []).

start() ->
    gen_fsm:start(?MODULE, [], []).
    

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
init([]) ->
    {ok, pending, #state{users = []}}.

pending(_Event, State) ->
    {next_state, pending, State}.
pending({on_room_became_active}, _From, State) ->
    Reply = ok,
    {reply, Reply, swinger_select_mode, State};
pending({on_room_death}, _From, State) ->
    Reply = ok,
    {stop, normal, Reply, State};
pending({on_user_join, UserGuid}, _From, State) ->
    {Reply, NewState} = inner_user_join(State, UserGuid),
    {reply, Reply, active, NewState};
pending({on_user_leave, UserGuid}, _From, State) ->
    {Reply, NewState} = inner_user_leave(State, UserGuid),
    {reply, Reply, active, NewState}.



swinger_select_mode({select_swinger}, State) ->
    NewState = State#state{current_state = 
                               #swing_bottle_mode_state{current_swinger = inner_select_swinger(State)}},
    {next_state, swing_bottle_mode, NewState, 15000}.

swing_bottle_mode(timeout, State) ->
    NewState = State#state{current_state = {}},
    {next_state, select_swinger_mode, NewState};
swing_bottle_mode({handle_extension_message, {swing_bottle}}, State) ->
    NewState = inner_swing_bottle(State),
    {next_state, kiss_mode, NewState, 15000}.

kiss_mode(timeout, State) ->
    NewState = State#state{current_state = {}},
    {next_state, select_swinger_mode, NewState};
kiss_mode({handle_extension_message, {kiss_action, UserGuid, Action}}, State) ->
    NewState = inner_kiss_action(State, Action, UserGuid),
    NewCurrentState = NewState#state.current_state,
    case NewCurrentState#kiss_mode_state.kissers of
        [] ->
            {next_state, select_swinger_mode, NewState#state{current_state = unknown}};
        _Other ->
            {next_state, kiss_mode, NewState, 15000}
    end.

%% active({on_room_death}, _From, State) ->
%%     Reply = ok,
%%     {stop, normal, Reply, State};
%% active({on_user_join, UserGuid}, _From, State) ->
%%     {Reply, NewState} = inner_user_join(State, UserGuid),
%%     {reply, Reply, active, NewState};
%% active({on_user_leave, UserGuid}, _From, State) ->
%%     {Reply, NewState} = inner_user_leave(State, UserGuid),
%%     {reply, Reply, active, NewState}.




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
handle_sync_event({link_room, RoomPid}, _From, StateName, State) ->
    {Reply, NewState} = inner_link_room(State, RoomPid),
    {reply, Reply, StateName, NewState};
handle_sync_event({on_user_join, UserGuid}, _From, StateName, State) ->
    {Reply, NewState} = inner_user_join(State, UserGuid),
    {reply, Reply, StateName, NewState};
handle_sync_event({on_user_leave, UserGuid}, _From, StateName, State) ->
    {Reply, NewState} = inner_user_leave(State, UserGuid),
    {reply, Reply, StateName, NewState};
handle_sync_event({on_room_death}, _From, StateName, State) ->
    Reply = ok,
    {stop, normal ,Reply, State}.

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
inner_link_room(State, RoomPid) ->
    {ok, State#state{room_pid = RoomPid}}.

calculate_male_parity(Users) ->
    lists:foldl(fun(User, Acc) ->
                        case element(1, User) of
                            male ->
                                Acc + 1;
                            female ->
                                Acc - 1;
                            unknown ->
                                Acc + 0
                        end
                end, 0, Users).

inner_user_join(State, UserGuid) ->
    NewComerSex = sex_srv:get_sex(UserGuid),
    NewUsers = [{NewComerSex, UserGuid} | State#state.users],
    NewMaleParity = calculate_male_parity(NewUsers),
    AreParityOverflow = abs(NewMaleParity) > application:get_env(kissbang, room_sex_parity),
    if
        AreParityOverflow ->
            {male_parity_overflow, State};
        true ->
            {ok, State#state{users = NewUsers}}
    end.

inner_user_leave(State, UserGuid) ->
    NewUsers = [User || User <- State#state.users, element(2,User) /= UserGuid],
    {ok, State#state{users = NewUsers}}.


inner_select_swinger(State) ->
    lists:last(State#state.users). %% TODO : implement me

inner_swing_bottle(State) ->
    CurrentState = State#state.current_state,
    NewCurrentState = #kiss_mode_state{kissers = [CurrentState#swing_bottle_mode_state.current_swinger]},
    State#state{current_state = NewCurrentState}.


inner_kiss_action(State, Action, UserGuid) ->
    % take an action (kiss, refuse to kiss) 
    case Action of
        kiss ->
            ok; % TODO : implement me
        refuse ->
            ok
    end,
    % form new status
    CurrentState = State#state.current_state,
    NewKissers = [User || User <- CurrentState#kiss_mode_state.kissers, 
                          element(2, User) /= UserGuid],
    NewCurrentState = CurrentState#kiss_mode_state{kissers = NewKissers},
    State#state{current_state = NewCurrentState}.
    
    
