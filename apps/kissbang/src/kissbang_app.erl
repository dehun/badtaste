-module(kissbang_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0, 
         setup_db/0, test_setup_db/0,
         replicate_db_from/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
test_setup_db() ->
    mnesia:start(), 
    mnesia:change_table_copy_type(schema, node(), disc_copies),
    setup_db().

setup_db() ->
    auth_srv:setup_db(),
    proxy_srv:setup_db(),
    roommgr_srv:setup_db(),
    userinfo_srv:setup_db(),
    sex_srv:setup_db(),
    ok.
    
replicate_db_from(NodeName) ->
    [{Tb, mnesia:add_table_copy(Tb, node(), Type)}
     || {Tb, [{NodeName, Type}]} <- [{T, mnesia:table_info(T, where_to_commit)}
                                     || T <- mnesia:system_info(tables)]].

connect_db_node(Node) ->
    mnesia:change_config(extra_db_nodes, [Node]).

start() ->
    application:start(kissbang).

start(_StartType, _StartArgs) ->
    kissbang_sup:start_link().

stop(_State) ->
    ok.
