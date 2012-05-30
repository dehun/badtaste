-module(proxy_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-include("../src/origin.hrl").
-compile(export_all).
-import(meck).

%%==================================================
%% Testing setup
%%==================================================
proxy_srv_test_() ->
    {setup, fun setup/0, 
     {inorder, [
                fun should_register_origin/0,
                fun should_get_origin/0,
                fun should_get_non_existant_origin/0,
                fun should_route_to_origin/0,
                fun should_drop_origin/0
               ]}}.

setup() ->
    mock_patch(),
    guid_srv:start_link(),
    auth_srv:start_link(),
    proxy_srv:start_link(),
    proxy_srv:drop_all().

mock_patch() ->
    %% patching for gateway server
    meck:new(gateway_srv),
    meck:expect(gateway_srv, disconnect_origin, fun(Origin) -> ok end),
    meck:expect(gateway_srv, route_messages, fun(Origin, Messages) -> ok end),
    ok.

%%==================================================
%% Testing functions
%%==================================================
should_register_origin() ->
    {ok, Guid} =  get_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())).

should_get_origin() ->
    {ok, Guid} = get_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())),
    ?assertEqual({ok, get_test_origin()}, proxy_srv:get_origin(Guid)).

should_get_non_existant_origin() ->
    {ok, Guid} = get_test_guid(),
    ?assert(unknown_origin == proxy_srv:get_origin(Guid)).

should_route_to_origin() ->
    {ok, Guid} = get_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())).

should_drop_origin() ->
    {ok, Guid} = get_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())),
    ?assert(ok == proxy_srv:drop_origin(Guid)),
    ?assert(unknown = proxy_srv:get_origin(Guid)).

%%==================================================
%% Helper functions
%%==================================================
get_test_guid() ->
    ok = auth_srv:drop_all_users(),
    ok = auth_srv:register("test", "test"),
    {ok, Guid} = auth_srv:auth("test", "test").


get_test_origin() ->
    #origin{node = node(), sock = dumb_socket}.
