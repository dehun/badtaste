-module(kissbang_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start() ->
    application:start(kissbang).

start(_StartType, _StartArgs) ->
    kissbang_sup:start_link().

stop(_State) ->
    ok.
