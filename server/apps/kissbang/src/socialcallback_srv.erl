%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 22 Oct 2012 by  <>
%%%-------------------------------------------------------------------
-module(socialcallback_srv).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([handle_callback_data/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {social_handler, port}).

%%%===================================================================
%%% API
%%%===================================================================
handle_callback_data(Self, Req) ->
    Body = Req:recv_body(),
    Get = Req:parse_qs(),
    Post = Req:parse_post(),
    log_srv:debug("handling social callback with params get : ~p, post : ~p, body : ~p", [Get, Post, Body]),
    Response = gen_server:call(Self, {handle_callback_data, Body, Get, Post}),
    log_srv:debug("replying to social network with ~p", [Response]),
    Req:respond(Response).



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
    State = #state{social_handler = chose_social_handler(),
                   port = chose_social_port()},
    start_web_server(State#state.port),
    {ok, State}.

chose_social_port() ->
    {ok, SocialPort} = application:get_env(kissbang, social_api_port),
    log_srv:info("starting socialcallback server on port ~p" , [SocialPort]),
    SocialPort.

chose_social_handler() ->
    {ok, SocialApiName} = application:get_env(kissbang, social_api_name),
    social_handler_sup:start_link(),
    {ok, Pid} = social_handler_sup:start_handler(SocialApiName),
    log_srv:info("starting social handler for api ~p", [SocialApiName]),
    Pid.

start_web_server(Port) ->
    Self = self(), 
    Loop = fun (Req) -> ?MODULE:handle_callback_data(Self, Req) end,
    {ok, _Http} = mochiweb_http:start_link([{name, socialcallback},
                                            {port, Port},
                                            {loop, Loop}]),
    ok.


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
handle_call({handle_callback_data, Body, Get, Post}, _From, State) ->
    Response = social_handler:handle_social_data(State#state.social_handler, Body, Get, Post),
    {reply, Response, State}.

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

handle_cast(_Msg, State) ->
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
