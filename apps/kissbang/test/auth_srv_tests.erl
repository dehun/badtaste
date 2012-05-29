-module(auth_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%%==================================================
%% Testing setup
%%==================================================
setup() ->
    auth_srv:start_link().

auth_test_() ->
    {setup,fun setup/0,
     {inorder, [fun should_drop_all/0,
     fun should_register/0,
     fun should_try_to_register_existant/0,
     fun should_try_to_auth_non_existant/0,
     fun should_auth_with_existant/0,
     fun should_auth_with_existant_but_invalid_password/0
    ]}}.

%%==================================================
%% Testing functions
%%==================================================
prepare_for_testing() ->
    auth_srv:drop_all_users().

should_drop_all() ->
    ?assert(ok == prepare_for_testing()).

should_register() ->
    ?_assert(ok == prepare_for_testing()),
    ?_assert(ok == auth_srv:register("test_bot", "qwerty")).
    
should_try_to_register_existant() ->
    ?_assert(ok == prepare_for_testing()),
    ?_assert(ok == auth_srv:register("test_bot", "qwerty")),
    ?_assert(already_exists = auth_srv:register("test_bot", "mazafaka")).

should_try_to_auth_non_existant() ->
    ?_assert(ok == prepare_for_testing()),
    ?_assert(no_such_user == auth_srv:auth("unknown_user", "abrakadabra")).

should_auth_with_existant() ->
    ?_assert(ok == prepare_for_testing()),
    ?_assert(ok == auth_srv:register("test_bot", "qwerty")),
    ?_assert({ok, Guid} = auth_srv:auth("test_bot", "qwerty")).

should_auth_with_existant_but_invalid_password() ->
    ?_assert(ok == prepare_for_testing()),
    ?_assert(ok == auth_srv:register("test_bot", "password1")),
    ?_assert(invalid_password == auth_srv:auth("password2")).

