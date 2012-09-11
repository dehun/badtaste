%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 31 Jul 2012 by  <>
%%%-------------------------------------------------------------------
-module(gift_srv).

-behaviour(gen_server).
-include_lib("xmerl/include/xmerl.hrl").
-include("received_gift.hrl").
%% API
-export([start_link/0, setup_db/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {gifts = []}).
-record(gift, {guid, price}).
-record(user_gifts, {user_guid, gifts=[]}).

%%%===================================================================
%%% API
%%%===================================================================
-export([send_gift/3,
         send_gift/4,
         get_gifts_for/1]).
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

send_gift(ReceiverGuid, SenderGuid, GiftGuid) ->
    NoopSync = fun(_Result) -> ok end,
    send_gift(ReceiverGuid, SenderGuid, GiftGuid, NoopSync).
send_gift(ReceiverGuid, SenderGuid, GiftGuid, TransSync) ->
    gen_server:call(?SERVER, {send_gift, ReceiverGuid, SenderGuid, GiftGuid, TransSync}).

get_gifts_for(UserGuid) ->
    gen_server:call(?SERVER, {get_gifts_for, UserGuid}).
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
    Result = mnesia:create_table(user_gifts, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, user_gifts)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([user_gifts], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([user_gifts], 5000),
            ok;
        {aborted, Reason} ->
            erlang:error(Reason)
        end.

init([]) ->
    State = load_config(),
    {ok, State}.

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
handle_call({send_gift, ReceiverGuid, SenderGuid, GiftGuid, TransSync}, _From, State) ->
    Reply = inner_send_gift(ReceiverGuid, SenderGuid, GiftGuid, TransSync, State),
    {reply, Reply, State};
handle_call({get_gifts_for, UserGuid}, _From, State) ->
    Reply = inner_get_gifts_for(UserGuid),
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

load_gift({struct, GiftJson}) ->
    log_srv:debug("loading gift"),
    #gift{guid = binary_to_list(proplists:get_value(<<"guid">>, GiftJson)),
          price = list_to_integer(binary_to_list(proplists:get_value(<<"price">>, GiftJson)))};
load_gift(Error) ->
    throw(Error).

load_gifts() ->
    inets:start(),
    {ok, GiftsUrl} = application:get_env(kissbang, gifts_cfg_url),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
        httpc:request(get, {GiftsUrl, []}, [], []),
    GiftsBinaryData = Body,
    {struct, GiftsJson} = mochijson2:decode(GiftsBinaryData),
    [load_gift(Gift) || Gift <- proplists:get_value(<<"gifts">>, GiftsJson)].



load_config() ->
    #state{gifts = load_gifts()}.


inner_get_gifts_for(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({user_gifts, UserGuid}),
                    case Existance of
                        [UserGifts] ->
                            UserGifts#user_gifts.gifts;
                        [] ->
                            []
                    end
            end,
    mnesia:activity(transaction, Trans).

inner_send_gift(ReceiverGuid, SenderGuid, GiftGuid, TransSync, State) ->
    Trans = dtranse:transefun(fun() ->
                                      case ReceiverGuid of
                                          SenderGuid ->
                                              {rollback, cant_send_gift_to_yourself};
                                          _Other ->
                                              %% buy gift
                                              [Gift] = [Gift || Gift <- State#state.gifts, Gift#gift.guid == GiftGuid],
                                              {ok, _} = bank_srv:withdraw(SenderGuid, Gift#gift.price),
                                              %% send it
                                              Existance = mnesia:read({user_gifts, ReceiverGuid}),
                                              case Existance of
                                                  [OldUserGifts] ->
                                                      NewUserGifts = OldUserGifts#user_gifts{gifts = [#received_gift{gift_guid = GiftGuid,
                                                                                                                     sender_guid = SenderGuid} | OldUserGifts#user_gifts.gifts]},
                                                      mnesia:write(NewUserGifts),
                                                      {commit, ok};
                                                  [] ->
                                                      NewUserGifts = #user_gifts{user_guid = ReceiverGuid,
                                                                                 gifts = [#received_gift{gift_guid = GiftGuid,
                                                                                                         sender_guid = SenderGuid}]},
                                                      mnesia:write(NewUserGifts),
                                                      {commit, ok}
                                              end
                                      end
                              end, TransSync),
    mnesia:activity(transaction, Trans).
