%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 31 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(sock_sattelite_srv).

-behaviour(gen_server).

-include("origin.hrl").
%% API
-export([start_link/0]).
-export([on_new_connection/1,
         disconnect_origin/1,
         route_messages/2,
         lost_origin/1).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
on_new_connection(ClientSock) ->
    gen_tcp:controlling_process(),
    gen_server:cast(?SERVER, {on_new_connection, ClientSock}).

disconnect_origin(Origin) ->
    gen_server:cast(?SERVER, {disconnect_origin, Origin}).

route_messages(Origin, Messages) ->
    gen_server:cast(?SERVER, {route_messages, Origin, Messages}).

lost_origin(Origin) ->
    gen_server:cast(?SERVER, {lost_origin, Origin}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    tcp_listener:start_link(),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({on_new_connection, ClientSock}, State) ->
    spawn_client_process(ClientSock),
    {noreply, State};
handle_cast({disconnect_origin, Origin}, State) ->
    client_sock_process:stop(Origin),
    {noreply, State};
handle_cast({lost_origin, Origin}, State) ->
    proxy_srv:drop_origin(Origin),
    {noreply, State};
handle_cast({route_messages, Origin, Messages}, State) ->
    client_sock_process:send_messages(Origin, Messages).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
spawn_client_process(ClientSock) ->
    {ok, Origin} = client_sock_process:start(ClientSock).
 
