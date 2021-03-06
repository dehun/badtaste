%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 10 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(roomfullifier_srv).

-behaviour(gen_server).

%% API
-export([start_link/0, setup_db/0]).
-export([join_main_queue/1, join_tagged_queue/2, get_main_queue/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {main_queue}).
-record(tagged_queue, {tag, queue}).

%%%===================================================================
%%% API
%%%===================================================================
join_main_queue(UserGuid) ->
    gen_server:cast(?SERVER, {join_main_queue, UserGuid}).

join_tagged_queue(UserGuid, Tag) ->
    gen_server:cast(?SERVER, {join_tagged_queue, UserGuid, Tag}).

get_main_queue() ->
    gen_server:call(?SERVER, {get_main_queue}).
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
setup_db() ->
    Result = mnesia:create_table(tagged_queue, [{ram_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, tagged_queue)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([tagged_queue], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([tagged_queue], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
        end.


init([]) ->
    {ok, MainQueuePid} = roomqueue_sup:start_queue(),
    {ok, #state{main_queue = MainQueuePid}}.

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
handle_call({get_main_queue}, _From, State) ->
    Reply = {ok, State#state.main_queue},
    {reply, Reply, State};
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

handle_cast({join_tagged_queue, UserGuid, Tag}, State) ->
    inner_join_tagged_queue(UserGuid, Tag),
    {noreply, State};
handle_cast({join_main_queue, UserGuid}, State) ->
    roomqueue_srv:join(State#state.main_queue, UserGuid),
    {noreply, State}.
    
%% handle_cast(_Msg, State) ->
%%     {noreply, State}.

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
inner_join_tagged_queue(UserGuid, Tag) ->
    Trans = fun() ->
                    ok = inner_touch_tagged_queue(Tag),
                    [TaggedQueue] = mnesia:read({tagged_queue, Tag}),
                    TaggedQueue#tagged_queue.queue
            end,
    Queue = mnesia:activity(sync_dirty, Trans),
    roomqueue_srv:join(Queue, UserGuid).

inner_touch_tagged_queue(Tag) ->
    Existance = mnesia:read({tagged_queue, Tag}),
    case Existance of 
        [] ->
            {ok, Queue} = roomqueue_sup:start_queue(),
            NewTaggedQueue = #tagged_queue{tag = Tag, 
                                           queue = Queue},
            mnesia:write(NewTaggedQueue),
            ok;
        [_] ->
            ok
    end.
    
