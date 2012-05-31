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
                {"should_register_origin", fun should_register_origin/0},
                {"should_get_origin", fun should_get_origin/0},
                {"should_get_non_existant_origin", fun should_get_non_existant_origin/0},
                {"should_route_to_origin", fun should_route_to_origin/0},
                {"should_drop_origin", fun should_drop_origin/0},
                {"should_drop_nonexistant_origin", fun should_drop_nonexistant_origin/0},
                {"should_reregister_origin", fun should_reregister_origin/0}
               ]}}.

setup() ->
    mock_patch(),
    guid_srv:start_link(),
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
    {ok, Guid} =  get_next_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())).

should_get_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())),
    ?assertEqual({ok, get_test_origin()}, proxy_srv:get_origin(Guid)).

should_get_non_existant_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(unknown_origin == proxy_srv:get_origin(Guid)).

should_route_to_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())).

should_drop_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())),
    ?assert(ok == proxy_srv:drop_origin(Guid)),
    ?assert(unknown_origin == proxy_srv:get_origin(Guid)).

should_drop_nonexistant_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(unknown_origin == proxy_srv:drop_origin(get_next_test_guid())).
    
should_reregister_origin() ->
    {ok, Guid} = get_next_test_guid(),
    ?assert(ok == proxy_srv:register_origin(Guid, get_test_origin())),
    ?assert(ok == proxy_srv:register_origin(Guid, get_another_test_origin())).

%%==================================================
%% Helper functions
%%==================================================
get_next_test_guid() ->
    guid_srv:create().

get_test_origin() ->
    #origin{node = node(), client_process = dumb_process}.

get_another_test_origin() ->
    #origin{node = another_node, client_process = another_dumb_process}.
