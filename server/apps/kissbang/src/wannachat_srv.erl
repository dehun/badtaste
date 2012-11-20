%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 24 Sep 2012 by  <>
%%%-------------------------------------------------------------------
-module(wannachat_srv).

-behaviour(gen_server).

%% API
-export([start_link/0,
         setup_db/0]).
 -export([buy_wanna_chat_status/2,
          buy_wanna_chat_status/3,
          get_random_chatter/0,
         purge_expired/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(wannachatinfo, {user_guid, expiration_date}).

%%%===================================================================
%%% API
%%%===================================================================
buy_wanna_chat_status(BuyerGuid, Period) ->
    NoopSync = fun(_Result) -> ok end,
    buy_wanna_chat_status(BuyerGuid, Period, NoopSync).
buy_wanna_chat_status(BuyerGuid, Period, TransSync) ->
    gen_server:call(?SERVER, {buy_wanna_chat_status, BuyerGuid, Period, TransSync}).

get_random_chatter() ->
    gen_server:call(?SERVER, {get_random_chatter}).

purge_expired() ->
    gen_server:cast(?SERVER, {purge_expired}).
    
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
    Result = mnesia:create_table(wannachatinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, wannachatinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([wannachatinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([wannachatinfo], 5000),
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
    init_purger(),
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
handle_call({buy_wanna_chat_status, BuyerGuid, Period, TransSync}, From, State) ->
    utils:acall(fun() -> inner_buy_wanna_chat_status(BuyerGuid, Period, TransSync) end, From),
    {noreply, State};
handle_call({get_random_chatter}, From, State) ->
    utils:acall(fun() -> inner_get_random_chatter() end, From),
    {noreply, State}.
    
%% handle_call(_Request, _From, State) ->
%%     Reply = ok,
%%     {reply, Reply, State}.

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
inner_get_random_chatter() ->
    Keys = mnesia:dirty_all_keys(wannachatinfo),
    _Guid = lists:nth(random:uniform(length(Keys)), Keys).

inner_buy_wanna_chat_status(BuyerGuid, Period, TransSync) ->
    Trans = dtranse:transefun(fun() ->
                                      case  mnesia:read({wannachatinfo, BuyerGuid}) of
                                          [] ->
                                              mnesia:write(#wannachatinfo{user_guid = BuyerGuid, 
                                                                          expiration_date = utils:unix_time() + Period});
                                          [OldWannaChatInfo] ->
                                              AreExpired = is_expired(OldWannaChatInfo),
                                              if
                                                  AreExpired ->
                                                      mnesia:write(OldWannaChatInfo#wannachatinfo{expiration_date = utils:unix_time() + Period});
                                                  true ->
                                                      mnesia:write(OldWannaChatInfo#wannachatinfo{expiration_date = OldWannaChatInfo#wannachatinfo.expiration_date + Period})
                                              end
                                      end,
                                      {commit, ok}
                              end, TransSync),
    mnesia:activity(transaction, Trans).

inner_purge_expired() -> %% TODO : optimize me
    Trans = fun() ->
                    Expired = qlc:e(qlc:q([E || E <- mnesia:table(wannachatinfo), is_expired(E)])),
                    lists:foreach(fun(E) -> 
                                          mnesia:delete(E) 
                                  end, Expired)
            end,
    mnesia:activity(transaction, Trans).
    
is_expired(E) ->
    E#wannachatinfo.expiration_date < utils:unix_time().

init_purger() ->
    timer:apply_interval(60 * 10 * 1000, wannachat_srv, purge_expired, []).
