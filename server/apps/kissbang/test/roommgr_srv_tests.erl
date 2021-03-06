-module(roommgr_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../src/room.hrl").
-include("../src/kissbang_messaging.hrl").
-compile(export_all).
-import(meck).


%%==================================================
%% Testing setup
%%==================================================
roommgr_srv_test_() ->
    {setup, fun setup/0, fun teardown/1,
     {foreach, fun foreach/0, 
      [
                {"should_spawn_room", fun should_spawn_room/0},
                {"should_spawn_multiply_rooms", fun should_spawn_multiply_rooms/0},
                {"should_get_room_by_room_guid", fun should_get_room_by_room_guid/0},
                {"should_join_room", fun should_join_room/0},
                {"should_get_room_by_user_guid", fun should_get_room_by_user_guid/0},
                {"should_leave_room", fun should_leave_room/0}
      ]}}.

setup() ->
    mock_patch(),
    application:load(kissbang),
    guid_srv:start_link(),
    roommgr_srv:start_link(),
    mnesia:stop(),
    mnesia:create_schema([node()]),
    mnesia:start(),
    sex_srv:start_link(),
    sex_srv:setup_db(),
    roommgr_srv:setup_db().

mock_patch() ->
    meck:new(proxy_srv),
    meck:expect(proxy_srv, route_messages, fun(_UserGuid, _Messages) -> ok end),
    meck:expect(proxy_srv, async_route_messages, fun(_UserGuid, _Messages) -> ok end).

teardown(_) ->
    mock_unpatch().

mock_unpatch() ->
    meck:unload(proxy_srv).

foreach() ->
    roommgr_srv:drop_all().
    

should_spawn_room() ->
    ?assertMatch({ok, _RoomGuid}, roommgr_srv:spawn_room()).

should_spawn_multiply_rooms() ->
    lists:foreach(fun (_) -> should_spawn_room() end, lists:seq(0, 1000)).

should_get_room_by_room_guid() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(),
    {ok, Room} = roommgr_srv:get_room(RoomGuid),
    ?assertMatch(RoomGuid, Room#room.room_guid).

should_join_room() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(),
    UserGuid = random_guid(),
    ?assertMatch(ok, roommgr_srv:join_room(RoomGuid, UserGuid)),
    {ok, Room} = roommgr_srv:get_room(RoomGuid),
    ?assert(room_srv:are_in_room(Room#room.room_pid, UserGuid)).

should_get_room_by_user_guid() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(),
    UserGuid = random_guid(),
    ?assertMatch(ok, roommgr_srv:join_room(RoomGuid, UserGuid)),
    {ok, Room} = roommgr_srv:get_room_for(UserGuid),
    ?assertMatch(RoomGuid, Room#room.room_guid).
    

should_leave_room() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(),
    UserGuid = random_guid(),
    ?assertMatch(ok, roommgr_srv:join_room(RoomGuid, UserGuid)),
    ?assertMatch(ok, roommgr_srv:leave_room(UserGuid)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% helper funs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
random_guid() ->
    element(2, guid_srv:create()).
