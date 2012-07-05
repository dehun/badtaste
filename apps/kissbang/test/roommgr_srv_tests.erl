-module(roommgr_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../src/origin.hrl").
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
                {"should_spawn_room", fun should_spawn_room/0}  %%,
                %% {"should_join_room", fun should_join_room/0},
                %% {"should_multiply_join_room", fun should_multiply_join_room/0},
                %% {"should_join_room_to_active", fun should_join_room_to_active/0},
                %% {"should_touch_join_limit", fun should_touch_join_limit/0},
                %% {"should_press_join_limit", fun should_press_join_limit/0},
                %% {"should_left_room_on_pending", fun should_left_room_on_pending/0},
                %% {"should_left_room_to_death", fun should_left_room_to_death/0},
      ]}}.

setup() ->
    guid_srv:start_link(),
    roommgr_srv:setup_db().

foreach() ->
    roommgr_srv:drop_all().
    

should_spawn_room() ->
    ok.
