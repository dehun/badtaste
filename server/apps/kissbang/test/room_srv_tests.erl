-module(room_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../src/origin.hrl").
-include("../src/kissbang_messaging.hrl").
-compile(export_all).
-import(meck).

%%==================================================
%% Testing setup
%%==================================================
room_srv_test_() ->
    {setup, fun setup/0, fun teardown/1, {inorder, 
     [{"should_spawn_room", fun should_spawn_room/0},
      {"should_spawn_multiple_rooms", fun should_spawn_multiply_rooms/0},
      {"should_join_room", fun should_join_room/0},
      {"should_double_join_room", fun should_double_join_room/0},
      {"should_leave_room", fun should_leave_room/0},
      {"should_leave_room_non_participant", fun should_leave_room_non_participant/0},
      {"should_leave_and_destroy_room", fun should_leave_and_destroy_room/0},
      {"should_reach_start_limit", fun should_reach_start_limit/0},
      {"should_check_for_non_existant_user", fun should_check_for_non_existant_user/0},
      {"should_reach_max_users_limit", fun should_reach_max_users_limit/0},
      {"should_push_max_users_limit", fun should_push_max_users_limit/0},
      {"should_death_from_active_state", fun should_death_from_active_state/0},
      {"should_drop", fun should_drop/0}
     ]}
    }.

setup() ->
    mock_patch(),
    application:load(kissbang).

teardown(_) ->
    mock_unpatch().

mock_patch() ->
    meck:new(proxy_srv),
    meck:new(roommgr_srv),
    meck:expect(proxy_srv, route_messages, fun(_UserGuid, _Messages) -> ok end),
    meck:expect(proxy_srv, async_route_messages, fun(_UserGuid, _Messages) -> ok end),
    meck:expect(roommgr_srv, async_leave_room, fun(_UserGuid) -> ok end).

mock_unpatch() ->
    meck:unload(proxy_srv),
    meck:unload(roommgr_srv).

%%==================================================
%% Testing functions
%%==================================================
should_spawn_room() ->
    {ok, Pid} = room_srv:start_link().

should_spawn_multiply_rooms() ->
    lists:foreach(fun (_) -> {ok, Pid} = room_srv:start_link() end, lists:seq(0, 100)).

should_join_room() ->
    {ok, RoomPid} =  room_srv:start_link(),
    {ok, UserGuid} = guid_srv:create(),
    PredictedUsersNumber = room_srv:get_number_of_users(RoomPid) + 1,
    ?assert(ok == room_srv:join(RoomPid, UserGuid)),
    ?assertMatch(PredictedUsersNumber, room_srv:get_number_of_users(RoomPid)),
    ?assert(true == room_srv:are_in_room(RoomPid, UserGuid)).

should_double_join_room() ->
    {ok, RoomPid} = room_srv:start_link(),
    {ok, UserGuid} = guid_srv:create(),
    ?assertMatch(ok, room_srv:join(RoomPid, UserGuid)),
    ?assertMatch(1, room_srv:get_number_of_users(RoomPid)),
    ?assertMatch(true, room_srv:are_in_room(RoomPid, UserGuid)),
    ?assertMatch({error, already_in_room}, room_srv:join(RoomPid, UserGuid)),
    ?assertMatch(1, room_srv:get_number_of_users(RoomPid)).
    

should_leave_room() ->
    {ok, RoomPid} = room_srv:start_link(),
    {ok, UserGuid} = guid_srv:create(),
    ?assertMatch(ok, room_srv:join(RoomPid, UserGuid)),
    lists:foreach(fun(_) ->?assertMatch(ok, room_srv:join(RoomPid,  element(2, guid_srv:create()))) end,
                                        lists:seq(1, element(2, application:get_env(kissbang, room_limit_to_start)))),
    PredictedUsersNumber = room_srv:get_number_of_users(RoomPid) - 1,
    ?assertMatch(ok, room_srv:leave(RoomPid, UserGuid)),
    ?assertMatch(PredictedUsersNumber, room_srv:get_number_of_users(RoomPid)).

should_leave_room_non_participant() ->
    {ok, RoomPid} = room_srv:start_link(),
    PredictedUsersNumber = room_srv:get_number_of_users(RoomPid),
    ?assertMatch(nobody_droped, room_srv:leave(RoomPid, element(2, guid_srv:create()))),
    ?assertMatch(PredictedUsersNumber, room_srv:get_number_of_users(RoomPid)).

should_leave_and_destroy_room() ->
    {ok, OwnerGuid} =  guid_srv:create(),
    {ok, RoomPid} = room_srv:start_link(),
    room_srv:join(RoomPid, OwnerGuid),
    ?assertMatch(ok, room_srv:leave(RoomPid, OwnerGuid)),
    ?assert(false == is_process_alive(RoomPid)).
    
reach_start_limit() ->
    {ok, RoomPid} = room_srv:start_link(),
    ?assertNot(room_srv:is_active(RoomPid)),
    PredictedUsersNumber = room_srv:get_number_of_users(RoomPid) + 2,
    UsersGuids = lists:map(fun(_) -> element(2, guid_srv:create()) end, 
                           lists:seq(1, element(2, application:get_env(kissbang, room_limit_to_start)))),
    lists:foreach(fun(UserGuid) -> ?assert(ok == room_srv:join(RoomPid, UserGuid)) end, UsersGuids),
    ?assertMatch(PredictedUsersNumber, room_srv:get_number_of_users(RoomPid)),
    ?assert(room_srv:is_active(RoomPid)),
    {RoomPid, UsersGuids}.

should_reach_start_limit() ->    
    reach_start_limit().

should_check_for_non_existant_user() ->
    {ok, RoomPid} = room_srv:start_link(),
    ?assert(false == room_srv:are_in_room(RoomPid, element(2, guid_srv:create()))).

reach_max_users_limit() ->
    {ok, RoomPid} = room_srv:start_link(),
    MaxUsers = element(2, application:get_env(kissbang, room_maximum_users)),
    lists:foreach(fun(_) -> 
                          ?assertMatch(ok, room_srv:join(RoomPid, element(2, guid_srv:create()))) end,
                  lists:seq(1, MaxUsers)),
    ?assertMatch(MaxUsers, room_srv:get_number_of_users(RoomPid)),
    RoomPid.

should_reach_max_users_limit() ->
    reach_max_users_limit().

should_push_max_users_limit() ->
    RoomPid = reach_max_users_limit(),
    ?assertMatch({error, room_already_full}, room_srv:join(RoomPid, element(2, guid_srv:create()))).

should_death_from_active_state() ->
    {RoomPid, UserGuids} = reach_start_limit(),
    lists:foreach(fun(UserGuid) -> ?assertMatch(ok, room_srv:leave(RoomPid, UserGuid)) end, 
                  lists:sublist(UserGuids, length(UserGuids) - 1)),
    ?assertNot(is_process_alive(RoomPid)).

should_drop() ->
    RoomPid = reach_max_users_limit(),
    ?assertMatch(ok, room_srv:drop(RoomPid)).
