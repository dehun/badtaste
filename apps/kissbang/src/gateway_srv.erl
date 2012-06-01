%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 28 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(gateway_srv).
-include("origin.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([disconnect_origin/1, 
         route_message/2,
         handle_origin_message/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).


%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% disconnects origin from a socket
%% @spec
%% disconnect_origin(Origin)
%% @end
%%--------------------------------------------------------------------
disconnect_origin(Origin) ->
    gen_server:cast(Origin#origin.node, ?SERVER, {disconnect_origin, Origin}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% routes message to origin from a services
%% @spec
%% @end
%%--------------------------------------------------------------------
route_message(Origin, Message) ->
    gen_server:cast(Origin#origin.node, ?SERVER, {route_message, Origin, Messages}),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% handles message which come from origin
%% @spec
%% handle_origin_message(Origin, Message)
%% @end
%%--------------------------------------------------------------------
handle_origin_message(Origin, Message) ->
    gen_server:cast(?SERVER, {handle_origin_message, Origin, Message}).

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
    client_acceptor:spawn_link(), 
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
handle_cast({disconnect_origin, Origin}, State) ->
    origin_controller:disconnect(Origin),
    {noreply, State};
handle_cast({route_message, Origin, Message}, State) ->
    origin_controller:route_message(Origin, Messages),
    {noreply, State};
handle_cast({handle_origin_message, Origin, Message}, State) ->
    handlemgr_srv:handle_origin_message(Origin, Message),
    {noreply, State}.

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
