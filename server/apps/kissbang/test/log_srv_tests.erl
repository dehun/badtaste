-module(log_srv_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).


%%==================================================
%% Testing setup
%%==================================================
log_test_() ->
    {setup, fun setup/0,
    {inorder, [
               fun should_debug/0,
               fun should_debug_format/0,
               fun should_trace/0,
               fun should_trace_format/0,
               fun should_info/0,
               fun should_info_format/0,
               fun should_warn/0,
               fun should_warn_format/0,
               fun should_error/0,
               fun should_error_format/0
              ]}}.

setup() ->
    log_srv:start_link().

%%==================================================
%% Testing functions
%%==================================================
should_debug() ->
    log_srv:debug("test debug message").
should_debug_format() ->
    log_srv:debug("test debug message with format ~w", ["[i am format]"]).

should_trace() ->
    log_srv:trace("test trace message").
should_trace_format() ->
    log_srv:trace("test trace message with format ~w", ["[i am format]"]).

should_info() ->
    log_srv:info("test info message").
should_info_format() ->
    log_srv:trace("test info message with format ~w", ["[i am format]"]).

should_warn() ->
    log_srv:warn("test warn message").
should_warn_format() ->
    log_srv:trace("test warn message with format ~w", ["[i am format]"]).

should_error() ->
    log_srv:error("test error message").
should_error_format() ->
    log_srv:trace("test error message with format ~w", ["[i am format]"]).

