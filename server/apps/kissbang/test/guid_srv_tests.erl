-module(guid_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

%%==================================================
%% Testing setup
%%==================================================
guid_srv_test_() ->
    {setup, fun setup/0,
     [
      {"should_create_guid", fun should_create_guid/0},
      {"should_create_multiply_guids", fun should_create_multiply_guids/0},
      {"should_test_guid_uniquness", fun should_test_guid_uniquness/0}
     ]}.

setup() ->
    guid_srv:start_link().

%%==================================================
%% Testing functions
%%==================================================
should_create_guid() ->
    ?assertMatch({ok, _Guid}, guid_srv:create()).

should_create_multiply_guids() ->
    lists:foreach(fun (X) -> 
                          ?assertMatch({ok, _Guid}, guid_srv:create()) 
                  end, lists:seq(0, 10000)).

should_test_guid_uniquness() ->
    Guids = lists:map(fun (_) -> 
                              {ok, Guid} = guid_srv:create(),
                              Guid 
                      end, lists:seq(0, 10000)),
    ?assert(length(Guids) == sets:size(sets:from_list(Guids))).
