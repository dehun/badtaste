-module(handlermgr_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
-import(meck).

%%==================================================
%% Testing setup
%%==================================================
hanglermgr_srv_test_() ->
    {setup, fun setup/0, 
     {inorder, [
                {"should_register_handler", fun should_register_handler/0},
                {"should_reregister_handler", fun should_reregister_handler/0},
                {"should_handle_registered_message", fun should_handle_registered_message/0},
                {"should_handle_unregistered_message", fun should_handle_unregistered_message/0},
                {"should_handle_registered_message_with_invalid_handler", fun should_handle_registered_message_with_invalid_handler/0}
               ]}}.

setup() ->
    ok = handlermgr_srv:setup_db(),
    handlermgr_srv:start_link().


%%==================================================
%% Testing functions
%%==================================================
should_register_handler() ->
    handlermgr_srv:register_handler("somemessage", fun() -> ok end).

should_reregister_handler() ->
    lists:foreach(fun (X) -> should_register_handler() end, lists:seq(0, 10)).

should_handle_registered_message() ->
    should_register_handler(),
    handlermgr_srv:handle_message("randomguid", {somemessage, rand1, rand2}).

should_handle_unregistered_message() ->
    handlermgr_srv:handle_message("unknown", {unregistered, rand1, rand2, rand3}).

should_handle_registered_message_with_invalid_handler() ->
    handlermgr_srv:register_handler("invalidmessage", fun() -> X = 0, X/X end),
    handlermgr_srv:handle_message("unknown", {invalidmessage, rand3}).


