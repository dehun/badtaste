%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2012 by  <>
%%%-------------------------------------------------------------------
-module(social_handler_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([start_handler/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================
start_handler(vk) ->
    start_concrete_child(vk_social_handler_srv);
start_handler(ok) ->
    start_concrete_child(ok_social_handler_srv);
start_handler(mm) ->
    start_concrete_child(mm_social_handler_srv).

start_concrete_child(ChildServerName) ->
    Restart = permanent,
    Shutdown = 2000,
    Type = worker,

    ChildSpec = {ChildServerName, {ChildServerName, start_link, []},
                 Restart, Shutdown, Type, [ChildServerName]},
    
    supervisor:start_child(?SERVER, ChildSpec).

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    {ok, {SupFlags, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
