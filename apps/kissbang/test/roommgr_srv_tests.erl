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
    {setup, fun setup/0,
     {foreach, fun foreach/0, 
      [
                {"should_spawn_room", fun should_spawn_room/0},
                {"should_spawn_multiply_rooms", fun should_spawn_multiply_rooms/0},
                {"should_get_room_by_room_guid", fun should_get_room_by_room_guid/0},
                {"should_get_room_by_user_guid", fun should_get_room_by_owner_guid/0},
                {"should_join_room", fun should_join_room/0},
                {"should_get_room_by_user_guid", fun should_get_room_by_user_guid/0}
                %% {"should_join_room", fun should_join_room/0},
                %% {"should_multiply_join_room", fun should_multiply_join_room/0},
                %% {"should_join_room_to_active", fun should_join_room_to_active/0},
                %% {"should_touch_join_limit", fun should_touch_join_limit/0},
                %% {"should_press_join_limit", fun should_press_join_limit/0},
                %% {"should_left_room_on_pending", fun should_left_room_on_pending/0},
                %% {"should_left_room_to_death", fun should_left_room_to_death/0},
      ]}}.

setup() ->
    mock_patch(),
    application:load(kissbang),
    guid_srv:start_link(),
    roommgr_srv:start_link(),
    roommgr_srv:setup_db().

mock_patch() ->
    meck:new(proxy_srv),
    meck:expect(proxy_srv, route_messages, fun(_UserGuid, _Messages) -> ok end).


foreach() ->
    roommgr_srv:drop_all().
    

should_spawn_room() ->
    ?assertMatch({ok, _RoomGuid}, roommgr_srv:spawn_room(random_guid())).

should_spawn_multiply_rooms() ->
    lists:foreach(fun (_) -> should_spawn_room() end, lists:seq(0, 1000)).

should_get_room_by_room_guid() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(random_guid()),
    {ok, Room} = roommgr_srv:get_room(RoomGuid),
    ?assertMatch(RoomGuid, Room#room.room_guid).

should_get_room_by_owner_guid() ->
    OwnerGuid = random_guid(),
    {ok, RoomGuid} = roommgr_srv:spawn_room(OwnerGuid),
    {ok, Room} = roommgr_srv:get_room_for(OwnerGuid),
    ?assertMatch({ok, RoomGuid}, Room#room.room_guid),
    ?assert(roommgr_srv:are_in_room(Room#room.room_pid, OwnerGuid)).

should_join_room() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(random_guid()),
    UserGuid = random_guid(),
    ?assertMatch(ok, roommgr_srv:join_room(RoomGuid, UserGuid)),
    {ok, Room} = roommgr_srv:get_room(RoomGuid),
    ?assert(room_srv:are_in_room(Room#room.room_pid, UserGuid)).

should_get_room_by_user_guid() ->
    {ok, RoomGuid} = roommgr_srv:spawn_room(random_guid()),
    UserGuid = random_guid(),
    ?assertMatch(ok, roommgr_srv:join_room(RoomGuid, UserGuid)),
    {ok, Room} = roommgr_srv:get_room_for(UserGuid),
    ?assertMatch(RoomGuid, Room#room.room_guid).
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% helper funs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
random_guid() ->
    element(2, guid_srv:create()).
