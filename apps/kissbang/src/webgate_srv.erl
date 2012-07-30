%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 13 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(webgate_srv).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([http_loop/1]).

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
    Loop = fun (Req) -> ?MODULE:http_loop(Req) end,
    {ok, _Http} = mochiweb_http:start_link([{port, element(2, application:get_env(kissbang, admin_web_port))},
                                            {loop, Loop}]),
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
    mochiweb_http:stop(),
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
http_loop(Req) ->
    case Req:get(method) of
        'POST' ->
            Body = Req:recv_body(),
            {ok, JsonResponse} = handle_json(Body),
            Req:respond({200, 
                        [{"Content-Type", "text/plain"}],
                        JsonResponse});
        _Other ->
            CrossdomainXml = "<cross-domain-policy>
    <allow-access-from domain=\"*\" />
</cross-domain-policy>",
            Req:respond({200, [{"Content-Type", "text/plain"}], CrossdomainXml})
    end.


handle_json(JsonData) ->
    %% deserialize message
    log_srv:debug("handling ~p json data", [JsonData]),
    Msg = admin_json_messaging:deserialize_message(JsonData),
    %% form callback
    Self = self(),
    Callback = fun(JsonResponse)  ->
                        Self ! {request_processed, JsonResponse}
               end,
    handlermgr_srv:handle_message_and_callback(admin, Msg, Callback),
    receive
        {request_processed, JsonMessage} ->
            {ok, admin_json_messaging:serialize_message(JsonMessage)}
    after 60000 ->
            {ok, '{"error" : "timed out"}'}
    end.
