%%%-------------------------------------------------------------------
%%% @author  <dehun>
%%% @copyright (C) 2012, 
%%% @doc
%%% roommgr service. manages rooms
%%% @end
%%% Created :  3 Jul 2012 by  <dehun>
%%%-------------------------------------------------------------------
-module(roommgr_srv).

-behaviour(gen_server).

%% API
-export([spawn_room/0, get_room/1, get_room_for/1, join_room/2, leave_room/1, async_leave_room/1, drop_room/1, drop_all/0]).
%-export([on_user_joined/1, on_user_leave/1, on_new_room_spawned/1]).
-export([start_link/0, setup_db/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(user_room, {user_guid, room_guid}).
-include("room.hrl").

%%%===================================================================
%%% API
%%%===================================================================
drop_room(RoomGuid) ->
    gen_server:call(?SERVER, {drop_room, RoomGuid}).

drop_all() ->
    gen_server:call(?SERVER, {drop_all}).
%%--------------------------------------------------------------------
%% @doc
%% spawns a new room
%% @spec
%% spawn_room() -> {ok, RoomGuid} | fail
%% @end
%%--------------------------------------------------------------------
spawn_room() ->
    gen_server:call(?SERVER, {spawn_room}).

%%--------------------------------------------------------------------
%% @doc
%% gets room by user guid. implementation of user -> room mapping
%% @spec
%% get_room_for(UserGuid) -> {ok, RoomGuid} | no_such_room
%% @end
%%--------------------------------------------------------------------
get_room_for(UserGuid) ->
    gen_server:call(?SERVER, {get_room_for, UserGuid}).

get_room(RoomGuid) ->
    gen_server:call(?SERVER, {get_room, RoomGuid}).

%%--------------------------------------------------------------------
%% @doc
%% joins user to the room
%% @spec
%% join_room(RoomGuid, UserGuid) -> ok | no_such_room
%% @end
%%--------------------------------------------------------------------
join_room(RoomGuid, UserGuid) ->
    gen_server:call(?SERVER, {join_room, UserGuid, RoomGuid}).

%%--------------------------------------------------------------------
%% @doc
%% makes user to leave room
%% @spec
%% leave_room(UserGuid, RoomGuid) ok | not_in_room | no_such_room
%% @end
%%--------------------------------------------------------------------
leave_room(UserGuid) ->
    gen_server:call(?SERVER, {leave_room, UserGuid}).
async_leave_room(UserGuid) ->
    gen_server:cast(?SERVER, {leave_room, UserGuid}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%--------------------------------------------------------------------
%% @doc
%%
%% @spec
%% setup_db - setups db for service
%% @end
%%--------------------------------------------------------------------
setup_db() ->
    mnesia:start(),
    mnesia:create_table(room, [{ram_copies, [node() | nodes()]},
                                             {attributes, record_info(fields, room)}]),
    mnesia:create_table(user_room, [{ram_copies, [node() | nodes()]},
                                             {attributes, record_info(fields, user_room)}]),
    ok = mnesia:wait_for_tables([user_room, room], 5000).
    %% case Result of 
    %%     {atomic, ok} ->
            
    %%         ok;
    %%     {aborted, {already_exists, _}} ->
    %%         mnesia:wait_for_tables([user_room, room], 5000),
    %%         ok;
    %%     {aborted, Reason} ->
    %%         erlang:error(Reason)
    %% end.    


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
    {ok, #state{}}.

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
handle_call({drop_room, RoomGuid}, From, State) ->
    utils:acall(fun() -> inner_drop_room(RoomGuid) end, From),
    {noreply, State};
handle_call({drop_all}, From, State) ->
    utils:acall(fun() -> inner_drop_all() end, From),
    {noreply, State};
handle_call({spawn_room}, From, State) ->
    utils:acall(fun() -> inner_spawn_room() end, From),
    {noreply, State};
handle_call({join_room, UserGuid, RoomGuid}, From, State) ->
    utils:acall(fun() -> inner_join_room(UserGuid, RoomGuid) end, From),
    {noreply, State};
handle_call({leave_room, UserGuid}, From, State) ->
    utils:acall(fun() -> inner_leave_room(UserGuid) end, From),
    {noreply, State};
handle_call({get_room_for, UserGuid}, From, State) ->
    utils:acall(fun () -> inner_get_room_for(UserGuid) end, From),
    {noreply, State};
handle_call({get_room, RoomGuid}, From, State) ->
    utils:acall(fun() -> Reply = inner_get_room(RoomGuid) end, From),
    {noreply, State}.

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
handle_cast({leave_room, UserGuid}, State) ->
    inner_leave_room(UserGuid),
    {noreply, State}.
%handle_cast(_Msg, State) ->
%    {noreply, State}.

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
inner_spawn_room() ->
    Trans = fun() ->
                    {ok, RoomGuid} = guid_srv:create(),
                    {ok, Extension} = kiss_room_ext_srv:start(),
                    {ok, RoomPid} = room_srv:start([Extension]),
                    NewRoom = #room{room_guid = RoomGuid,
                                    room_pid = RoomPid},
                    mnesia:write(NewRoom),
                    {ok, NewRoom#room.room_guid}
            end,
    {ok, _RoomGuid} = mnesia:activity(sync_dirty, Trans).

inner_join_room(UserGuid, RoomGuid) ->
    RoomRes = inner_get_room(RoomGuid),
    case RoomRes of
        {ok, Room} ->
            case room_srv:join(Room#room.room_pid, UserGuid) of
                ok ->
                    Trans = fun() -> 
                                    mnesia:write(#user_room{user_guid = UserGuid,
                                                            room_guid = Room#room.room_guid}) 
                            end,
                    mnesia:activity(sync_dirty, Trans);
                Error ->
                    Error
            end;
        Error ->
            Error
    end.

inner_get_room(RoomGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read(room, RoomGuid),
                    case Existance of
                        [] ->
                            no_such_room;
                        [Room] ->
                            case check_room_heart(Room) of
                            ok ->
			       {ok, Room};
			    _ ->
			      no_such_room
			    end
                    end
            end,
    mnesia:activity(async_dirty, Trans).

inner_leave_room(UserGuid) ->
    RoomRes = inner_get_room_for(UserGuid),
    case RoomRes of
        {ok, Room} ->
            Trans = fun() ->
                            mnesia:delete({user_room, UserGuid})
                    end,
            mnesia:activity(async_dirty, Trans),
            LeaveResult = room_srv:leave(Room#room.room_pid, UserGuid),
	    check_room_heart(Room),
            LeaveResult;
        Error ->
            Error
    end.

inner_get_room_for(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read(user_room, UserGuid),
                    case Existance of
                        [] ->
                            no_such_room;
                        [UserRoom] ->
                            RoomRes = mnesia:read(room, UserRoom#user_room.room_guid),
                            case RoomRes of 
                                [Room] ->
                                    case check_room_heart(Room) of
                                        ok ->
                                            {ok, Room};
                                        dead ->
                                            no_such_room
                                    end;
                                [] ->
                                    no_such_room
                            end
                    end
            end,
    mnesia:activity(async_dirty, Trans).

inner_drop_all() ->
        Trans = fun() ->
                    lists:foreach(fun(RoomGuid) -> inner_drop_room(RoomGuid) end,
                                  mnesia:all_keys(room)),
                    ok
            end,
    ok = mnesia:activity(sync_dirty, Trans).

inner_drop_room(RoomGuid) ->
    RoomRes =  inner_get_room(RoomGuid),
    case RoomRes of
        {ok, Room} ->
            spawn(fun() -> room_srv:drop(Room#room.room_pid) end),
            ok;
        Error ->
            Error
    end.




    %% Trans = fun() ->
    %%                 Existance = mnesia:read(room, RoomGuid),
    %%                 case Existance of
    %%                     [] ->
    %%                         no_such_room;
    %%                     [Room] ->
    %%                         mnesia:delete({room, RoomGuid}),
    %%                         {ok, Room}
    %%                 end
    %%         end,
    %% RoomRes = mnesia:activity(sync_dirty, Trans),
    %% case RoomRes of
    %%     {ok, Room} ->
    %%         spawn(fun() -> room_srv:drop(Room#room.room_pid) end),
    %%         ok;
    %%     Error ->
    %%         Error
    %% end.
    
check_room_heart(Room) ->
    IsRoomAlive = is_process_alive(Room#room.room_pid),
    case IsRoomAlive of
        true ->
            ok;
        false ->
            DelTrans = fun() -> mnesia:delete({room, Room#room.room_guid}) end,
            mnesia:activity(async_dirty, DelTrans),
            dead
    end.
