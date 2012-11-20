-module(userinfo_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../src/origin.hrl").
-include("../src/kissbang_messaging.hrl").
-compile(export_all).
-import(meck).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Testing setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userinfo_srv_test_() ->
    {setup, fun setup/0,
     {foreach, fun foreach/0,
      [
       {"should_update_non_existant_user_info", fun should_update_non_existant_user_info/0},
       {"should_update_existant_user_info", fun should_update_existant_user_info/0},
       {"should_get_existant_user_info", fun should_get_existant_user_info/0},
       {"should_get_non_existant_user_info", fun should_get_non_existant_user_info/0},
       {"should_drop_user_info", fun should_drop_user_info/0}
      ]}}.

setup() ->
    mnesia:change_table_copy_type(schema, node(), disc_copies),
    guid_srv:start_link(),
    userinfo_srv:setup_db(),
    userinfo_srv:start_link().


foreach() ->
    ok.
%%    userinfo_srv:drop_all().


should_update_non_existant_user_info() ->
    ok.

should_update_existant_user_info() ->
    ok.

should_get_existant_user_info() ->
    ok.

should_get_non_existant_user_info() ->
    ok.

should_drop_user_info() ->
    ok.


create_user_info() ->
    ok.

create_guid() ->
    element(2, guid_srv:create()).
