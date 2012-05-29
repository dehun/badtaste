-module(guid_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%%==================================================
%% Testing setup
%%==================================================
guid_srv_tests_() ->
    {setup, fun setup/0,
     {inorder, [
                fun should_create_guid/0
               ]}}.

setup() ->
    guid_srv:start_link().

%%==================================================
%% Testing functions
%%==================================================
should_create_guid() ->
    ?assertMatch({ok, _Guid}, guid_srv:create()).
