-module(auth_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%%==================================================
%% Testing setup
%%==================================================
auth_test_() ->
    {setup, fun setup/0,
     {inorder, [
                {"should_drop_all", fun should_drop_all/0},
                {"should_register", fun should_register/0},
                {"should_try_to_register_existant", fun should_try_to_register_existant/0},
                {"should_try_to_auth_non_existant", fun should_try_to_auth_non_existant/0},
                {"should_auth_with_existant", fun should_auth_with_existant/0},
                {"should_auth_with_existant_but_invalid_password", fun should_auth_with_existant_but_invalid_password/0},
                {"should_check_is_registered_for_existant", fun should_check_is_registered_for_existant/0},
                {"should_check_is_registered_for_non_existant", fun should_check_is_registered_for_non_existant/0}
               ]}}.

setup() ->
    mnesia:change_table_copy_type(schema, node(), disc_copies),
    guid_srv:start_link(),
    auth_srv:setup_db(),
    auth_srv:start_link().

%%==================================================
%% Testing functions
%%==================================================
prepare_for_testing() ->
    auth_srv:drop_all_users().

should_drop_all() ->
    ?assert(ok == prepare_for_testing()).

should_register() ->
    ?assert(ok == prepare_for_testing()),
    ?assert(ok == auth_srv:register("test_bot", "qwerty")).
    
should_try_to_register_existant() ->
    ?assert(ok == prepare_for_testing()),
    ?assert(ok == auth_srv:register("test_bot", "qwerty")),
    ?assert(already_exists == auth_srv:register("test_bot", "mazafaka")).

should_try_to_auth_non_existant() ->
    ?assert(ok == prepare_for_testing()),
    ?assert(no_such_user == auth_srv:auth("unknown_user", "abrakadabra")).

should_auth_with_existant() ->
    ?assert(ok == prepare_for_testing()),
    ?assert(ok == auth_srv:register("test_bot", "qwerty")),
    ?assertMatch({ok, _Guid},  auth_srv:auth("test_bot", "qwerty")).

should_auth_with_existant_but_invalid_password() ->
    ?assert(ok == prepare_for_testing()),
    ?assert(ok == auth_srv:register("test_bot", "password1")),
    ?assert(invalid_password == auth_srv:auth("test_bot", "password2")).

should_multiply_register_and_auth() ->
    ?assert(ok == prepare_for_testing()),
    Users = [{Name, Pass} || Name <- lists:seq(1, 1000), Pass <- lists:seq(1, 1000)],
    [?assert(ok == auth_srv:register(element(1, User), element(2, User))) || User <- Users],
    [?assert(ok == auth_srv:auth(element(1, User), element(2, User))) || User <- Users].

should_check_is_registered_for_existant() ->
    ?assert(ok == prepare_for_testing()),
    UserLogin = "dehun",
    ?assert(ok == auth_srv:register(UserLogin, "123")),
    ?assertMatch({true, _UserGuid}, auth_srv:is_registered(UserLogin)).

should_check_is_registered_for_non_existant() ->
    ?assert(ok == prepare_for_testing()),
    ?assertMatch({false, no_such_user}, auth_srv:is_registered("non_existant_user_login")).
