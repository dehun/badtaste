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
-include("kissbang_messaging.hrl").
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

-record(swinger_select_mode_state, {last_swinger}).
-record(swing_bottle_mode_state, {current_swinger}).
-record(kiss_mode_state, {kisser, victim, last_swinger}).

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
    NewCurrentState = #swinger_select_mode_state{last_swinger = inner_select_random_user(male, State#state.users)},
    {reply, Reply, swinger_select_mode, State#state{current_state = NewCurrentState}, 0};
pending({on_room_death}, _From, State) ->
    Reply = ok,
    {stop, normal, Reply, State};
pending({on_user_join, UserGuid}, _From, State) ->
    {Reply, NewState} = inner_user_join(State, UserGuid),
    {reply, Reply, pending, NewState};
pending({on_user_leave, UserGuid}, _From, State) ->
    {Reply, NewState} = inner_user_leave(State, UserGuid),
    {reply, Reply, pending, NewState}.



swinger_select_mode(timeout, State) ->
    NewSwinger = inner_select_swinger(State),
    room_srv:broadcast_message(State#state.room_pid, 
                               #on_new_bottle_swinger{swinger_guid = element(2, NewSwinger)}),
    NewState = State#state{current_state = 
                               #swing_bottle_mode_state{current_swinger = NewSwinger}},
    log_srv:debug("selecting new swinger. new swinger is ~p", [NewSwinger]).
    {next_state, swing_bottle_mode, NewState, 15000};
swinger_select_mode(_Msg, State) ->
    {next_state, swinger_select_mode, State, 0}.

swing_bottle_mode(timeout, State) ->
    log_srv:debug("swing bottle timed out. selecting new swinger"),
    CurrentState = State#state.current_state,
    CurrentSwinger = CurrentState#swing_bottle_mode_state.current_swinger,
    NewState = State#state{current_state = #swinger_select_mode_state{last_swinger = CurrentSwinger}},
    {next_state, swinger_select_mode, NewState, 0};
swing_bottle_mode({handle_extension_message, {swing_bottle, SwingPretenderGuid}}, State) ->
    log_srv:debug("on trying to swing bottle"),
    {Res, NewState} = inner_swing_bottle(State, SwingPretenderGuid),
    case Res of 
        ok ->
            log_srv:debug("bottle swinged successfully by ~p", [SwingPretenderGuid]),
            {next_state, kiss_mode, NewState, 15000};
        fail ->
            log_srv:debug("bottle swing fail by ~p ", [SwingPretenderGuid]),
            {next_state, swing_bottle_mode, NewState, 15000}
    end;
swing_bottle_mode(_Msg, State) ->
    {next_state, swing_bottle_mode, State, 15000}.


kiss_mode(timeout, State) ->
    log_srv:info("kiss mode timeout"),
    CurrentState = State#state.current_state,
    LastSwinger = CurrentState#kiss_mode_state.last_swinger,
    NewState = State#state{current_state = #swinger_select_mode_state{last_swinger = LastSwinger}},
    {next_state, swinger_select_mode, NewState, 0};
kiss_mode({handle_extension_message, {kiss_action, KisserGuid, Action}}, State) ->
    log_srv:debug("kiss action is performed by ~p", [KissedGuid]),
    NewState = inner_kiss_action(State, Action, KisserGuid),
    NewCurrentState = NewState#state.current_state,
    log_srv:error("checking are all kissed"),
    AreAllKissed = lists:all(fun(Kisser) -> element(1, Kisser) end, 
                             [NewCurrentState#kiss_mode_state.kisser, NewCurrentState#kiss_mode_state.victim]),
    if
        AreAllKissed ->
            log_srv:error("[room ~p] all are kissed. moving to next roung ", [self()]),
            sympathy_srv:add_sympathy(element(2, NewCurrentState#kiss_mode_state.kisser),
                                      element(2, NewCurrentState#kiss_mode_state.victim)),
            LastSwinger = NewCurrentState#kiss_mode_state.last_swinger,
            {next_state, swinger_select_mode, 
             NewState#state{current_state = #swinger_select_mode_state{last_swinger = LastSwinger}}, 0};
        true ->
            log_srv:error("not all are kissed. keep kissing"),
            {next_state, kiss_mode, NewState, 15000}
    end;
kiss_mode(_, State) ->
    log_srv:debug("invalid message in kiss mode"),
    {next_state, kiss_mode, State, 15000}.

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
    NewMaleParity = calculate_male_parity(State#state.users),
    AreParityOverflow = abs(NewMaleParity) > application:get_env(kissbang, room_sex_parity),
    if 
        AreParityOverflow ->
            spawn_link(fun() ->room_srv:drop(State#state.room_pid) end);
        true ->
            []
    end,
    {reply, Reply, StateName, NewState};

handle_sync_event({on_room_death}, _From, _StateName, State) ->
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
    log_srv:debug("on user joined game~n"),
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
    CurrentState = State#state.current_state,
    LastSwinger = CurrentState#swinger_select_mode_state.last_swinger,
    OppositeSex = get_sex_opposite(element(1, LastSwinger)),
    inner_select_random_user(OppositeSex, State#state.users).

inner_swing_bottle(State, SwingPretenderGuid) ->
    CurrentState = State#state.current_state,
    CurrentSwinger = CurrentState#swing_bottle_mode_state.current_swinger,
    case element(2, CurrentSwinger) of
        SwingPretenderGuid ->
            log_srv:debug("user ~p is swinging bottle ", [SwingPretenderGuid]),
            Victim = inner_select_random_user(get_sex_opposite(element(1, CurrentSwinger)), 
                                              State#state.users),
            NewCurrentState = #kiss_mode_state{kisser = {false, CurrentSwinger}, 
                                               victim = {false, Victim},
                                               last_swinger = CurrentSwinger},
            room_srv:broadcast_message(State#state.room_pid,
                                       #on_bottle_swinged{swinger_guid = element(2, CurrentSwinger),
                                                          victim_guid = element(2, Victim)}),
            {ok, State#state{current_state = NewCurrentState}};
        _Other ->
            log_srv:debug("user ~p is tryed to swing bottle non in order", [SwingPretenderGuid]),
            {fail, State}
    end.
            


inner_kiss_action(State, Action, KisserPretenderGuid) ->
    log_srv:debug("User ~p is trying to do kiss action ~p", [KisserPretenderGuid, Action]),
    CurrentState = State#state.current_state,
    Kisser = CurrentState#kiss_mode_state.kisser,
    Victim = CurrentState#kiss_mode_state.victim,
    KisserGuid = element(2, element(2, Kisser)),
    VictimGuid = element(2, element(2, Victim)),
    case KisserPretenderGuid of
        KisserGuid ->
            log_srv:debug("User ~p is kisser", [KisserGuid]),
            NewVictim = kiss_action(Kisser, Victim, Action, State),
            NewCurrentState = CurrentState#kiss_mode_state{victim = NewVictim};
        VictimGuid ->
            log_srv:debug("User ~p is victim", [VictimGuid]),
            NewKisser = kiss_action(Victim, Kisser, Action, State),
            NewCurrentState = CurrentState#kiss_mode_state{kisser = NewKisser};
        _Other ->
            log_srv:debug("User ~p is trying to kiss out of order", [KisserPretenderGuid]),
            NewCurrentState = State#state.current_state
    end,
    State#state{current_state = NewCurrentState}.

kiss_action(Kisser, Victim, Action, State) ->
    log_srv:debug("User ~p is goint to perfom kiss action on ~p, action = ~p", [Kisser, Victim, Action]),
    case element(1, Victim) of
        true -> % are already kissed
            log_srv:debug("User ~p are already kissed", [Victim]),
            Victim;
        false ->
            log_srv:debug("User ~p is perfoming kiss action on ~p, action = ~p", [Kisser, Victim, Action]),
            KisserGuid = element(2, element(2, Kisser)),
            VictimGuid = element(2, element(2, Victim)),
            case Action of
                kiss ->
                    room_srv:broadcast_message(State#state.room_pid,
                                               #on_kiss{kisser_guid = KisserGuid, 
                                                        kissed_guid = VictimGuid});
                refuse ->
                    room_srv:broadcast_message(State#state.room_pid,
                                               #on_refuse_to_kiss{refuser_guid = KisserGuid, 
                                                                  refused_guid = VictimGuid})
            end,
            setelement(1, Victim, true)
    end.
    
inner_select_random_user(Sex, Users) ->
    SexUsers = [User || User <- Users, element(1, User) == Sex],
    lists:nth(random:uniform(length(SexUsers)), SexUsers).

get_sex_opposite(male) ->
    female;
get_sex_opposite(female) ->
    male.
