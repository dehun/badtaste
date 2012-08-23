%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 30 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(bank_srv).

-behaviour(gen_server).
-include("kissbang_messaging.hrl").

%% API
-export([start_link/0,
         setup_db/0]).


%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(bank_balance, {user_guid, gold}).

%%%===================================================================
%%% API
%%%===================================================================
-export([withdraw/2, withdraw/3,
         deposit/2, deposit/3,
         check/1, check/2]).
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
setup_db() ->
    Result = mnesia:create_table(bank_balance, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, bank_balance)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([bank_balance], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([bank_balance], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
        end.



start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


withdraw(UserGuid, Gold) ->
    NoopSync = fun(_Result) -> ok end,
    withdraw(UserGuid, Gold, NoopSync).

withdraw(UserGuid, Gold, TransSync) ->
    gen_server:call(?SERVER, {withdraw, UserGuid, Gold, TransSync}).

deposit(UserGuid, Gold)  ->
    NoopSync = fun(_Result) -> ok end,
    deposit(UserGuid, Gold, NoopSync).

deposit(UserGuid, Gold, TransSync) ->
    gen_server:call(?SERVER, {deposit, UserGuid, Gold, TransSync}).

check(UserGuid) ->
    NoopSync = fun(_Result) -> ok end,
    check(UserGuid, NoopSync).

check(UserGuid, TranSync) ->
    gen_server:call(?SERVER, {check, UserGuid, TranSync}).
    
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
handle_call({withdraw, UserGuid, Gold, TransSync}, _From, State) ->
    Reply = inner_withdraw(UserGuid, Gold, TransSync),
    {reply, Reply, State};
handle_call({deposit, UserGuid, Gold, TransSync}, _From, State) ->
    Reply = inner_deposit(UserGuid, Gold, TransSync),
    {reply, Reply, State};
handle_call({check, UserGuid, TransSync}, _From, State) ->
    Reply = inner_check(UserGuid, TransSync),
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
inner_deposit(UserGuid, Gold, TransSync) ->
    Trans = dtranse:transefun(fun() -> 
                                      inner_touch_user(UserGuid),
                                      [OldBalance] = mnesia:read({bank_balance, UserGuid}),
                                      NewGold = OldBalance#bank_balance.gold + Gold,
                                      NewBalance = OldBalance#bank_balance{gold = NewGold},
                                      mnesia:write(NewBalance),
                                      {commit, {ok, NewGold}}
                              end, TransSync),
    Result = mnesia:activity(transaction, Trans),
    proxy_srv:route_messages(UserGuid, [#on_bank_balance_changed{new_gold = element(2, Result)}]),
    Result.

inner_withdraw(UserGuid, Gold, TransSync) ->
    Trans = dtranse:transefun(fun() -> 
                                      inner_touch_user(UserGuid),
                                      [OldBalance] = mnesia:read({bank_balance, UserGuid}),
                                      AreEnoughtMoney = OldBalance#bank_balance.gold >= Gold,
                                      if
                                          AreEnoughtMoney ->
                                              NewGold = OldBalance#bank_balance.gold - Gold,
                                              NewBalance = OldBalance#bank_balance{gold =  NewGold},
                                              mnesia:write(NewBalance),
                                              {commit, {ok, NewGold}};
                                          true ->
                                              {rollback, not_enought_money}
                                      end
                              end, TransSync),
    Result = mnesia:activity(transaction, Trans),
    %% notify user
    case Result of 
        {ok, NewGold} ->
            proxy_srv:route_messages(UserGuid, [#on_bank_balance_changed{new_gold = NewGold}]),
            Result;
        Error ->
            Error
        end.

inner_check(UserGuid, TransSync) ->
    Trans = dtranse:transefun(fun() ->
                                      inner_touch_user(UserGuid),
                                      [Balance] = mnesia:read({bank_balance, UserGuid}),
                                      {commit, Balance#bank_balance.gold}
                              end, TransSync),
    Result = mnesia:activity(transaction, Trans),
    proxy_srv:route_messages(UserGuid, [#on_bank_balance_checked{gold = Result}]),
    Result.


inner_touch_user(UserGuid) ->
    Existance = mnesia:read({bank_balance, UserGuid}),
    case Existance of
        [] ->
            NewBalance = #bank_balance{user_guid = UserGuid,
                                       gold = 0},
            mnesia:write(NewBalance),
            ok;
        _Exist ->
            ok
    end.


