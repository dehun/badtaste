%%%-------------------------------------------------------------------
%%% @author  <dehun@localhost>
%%% @copyright (C) 2012, 
%%% @doc
%%% 
%%% @end
%%% Created : 31 May 2012 by  <dehun@localhost>
%%%-------------------------------------------------------------------
-module(handlermgr_srv).

-behaviour(gen_server).

%% API
-export([start_link/0, setup_db/0]).
-export([handle_message/2, register_handler/2]).


%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(handler_reaction, {message_name, handler_fun}).

%%%===================================================================
%%% API
%%%===================================================================
handle_message(Guid, Message) ->
    gen_server:cast(?SERVER, {handle_message, Guid, Message}).

register_handler(MessageName, HandlerFun) ->
    gen_server:cast(?SERVER, {register_handler, MessageName, HandlerFun}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

setup_db() ->
    mnesia:start(),
    Result = mnesia:create_table(handler_reaction, [{ram_copies, [node() | nodes()]},
                                                    {attributes, record_info(fields, handler_reaction)}]),
    case Result of 
        {atomic, ok} ->
            mnesia:wait_for_tables([handler_reaction], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([handler_reaction], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
    end.
    

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
handle_cast({handle_message, Guid, Message}, State) ->
    inner_handle_message(Guid, Message),
    {noreply, State};
handle_cast({register_handler, MessageName, HandlerFun}, State) ->
    inner_register_handler(MessageName, HandlerFun),
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
inner_handle_message(Guid, Message) ->
    Trans = fun() ->
                    mnesia:read(handler_reaction, element(1, Message))
            end,
    Existance = mnesia:activity(async_dirty, Trans),
    case Existance of
        [] ->
            unknown_message;
        [HandlerReaction] ->
            spawn(fun () -> 
                          apply(HandlerReaction#handler_reaction.handler_fun, [Guid, Message])
                  end),
            ok
    end.

inner_register_handler(MessageName, HandlerFun) ->
    Trans = fun() ->
                    mnesia:write(#handler_reaction{message_name = MessageName,
                                              handler_fun = HandlerFun})
            end,
    mnesia:activity(async_dirty, Trans).
                    
