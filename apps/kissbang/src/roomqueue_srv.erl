%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created :  9 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(roomqueue_srv).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([join/2, tick/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%%-define(SERVER, ?MODULE). 

-record(state, {rooms, full_rooms, pending_users}).
%%-record(roominfo, {room_guid}).

%%%===================================================================
%%% API
%%%===================================================================
join(QueuePid, Guid) ->
    gen_server:cast(QueuePid, {join, Guid}).

tick(QueuePid) ->
    reinit_ticker(),
    gen_server:cast(QueuePid, {tick}).
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link(?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    %% set timer
    reinit_ticker(),
    %% init state
    {ok, #state{rooms = [],
                full_rooms = [],
                pending_users = []}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({tick}, State) ->
    lists:foreach(fun (UserGuid) -> 
                      gen_server:cast(self(), {push_user, UserGuid})
              end, State#state.pending_users),
    {noreply, State#state{pending_users = []}};
handle_cast({push_user, UserGuid}, State) ->
    NewState = inner_push_user(UserGuid, State),
    {noreply, NewState};
handle_cast({join, UserGuid}, State) ->
    {noreply, State#state{pending_users = [UserGuid | State#state.pending_users]}};
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
inner_push_user(UserGuid, State) -> %% NewState
    case inner_find_room_for(UserGuid, State) of
        {ok, NewRooms} ->
            State#state{rooms = NewRooms};
        no_free_room ->
            NewRoom = inner_spawn_room_for(UserGuid),
            State#state{rooms = [NewRoom], 
                        full_rooms = State#state.rooms};
        Error ->
            Error
    end.

inner_find_room_for(UserGuid, State) -> %% {ok, NewRooms} | no_free_room
    {NewRooms, FullRooms} = inner_find_room_for(UserGuid, State#state.rooms, [], [], false),
    State#state{full_rooms = State#state.full_rooms ++ FullRooms,
                rooms = NewRooms}.


inner_find_room_for(UserGuid, [RoomGuid | RestRooms], NewRooms, FullRooms, _AlreadyJoined) ->
    case roommgr_srv:join_room(RoomGuid, UserGuid) of
        no_such_room ->
            inner_find_room_for(UserGuid, RestRooms, NewRooms, FullRooms, false);
        {error, room_already_full} ->
            inner_find_room_for(UserGuid, RestRooms, NewRooms, [RoomGuid | FullRooms], false);
        {error, already_in_room} ->
            inner_find_room_for(UserGuid, [], NewRooms ++ RestRooms, FullRooms, true);
        ok ->
            inner_find_room_for(UserGuid, [],  RestRooms ++ [RoomGuid | NewRooms], FullRooms, true)
    end;
inner_find_room_for(UserGuid, [], NewRooms, FullRooms, AlreadyJoined) ->
    if 
        AlreadyJoined ->
            {NewRooms, FullRooms};
        true ->
            {[inner_spawn_room_for(UserGuid) |  NewRooms], FullRooms}
    end.

inner_spawn_room_for(UserGuid) ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(UserGuid),
    RoomGuid.

reinit_ticker() ->
        {ok, _TRef} = timer:apply_after(5000, roomqueue_srv, tick, [self()]).
