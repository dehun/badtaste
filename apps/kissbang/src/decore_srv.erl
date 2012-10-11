%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 20 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(decore_srv).

-behaviour(gen_server).

%% API
-export([start_link/0,
         setup_db/0]).

-export([]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([buy_decore/2,
         get_decore/1]).

-define(SERVER, ?MODULE). 

-record(state, {config}).
-record(decoreinfo, {user_guid, decores}).
-record(config, {decores}).
-record(decore, {guid, type, price}).

%%%===================================================================
%%% API
%%%===================================================================
buy_decore(TargetUserGuid, DecoreGuid) ->
    gen_server:call(?SERVER, {buy_decore, TargetUserGuid, DecoreGuid}).

get_decore(TargetUserGuid) ->
    gen_server:call(?SERVER, {get_decore, TargetUserGuid}).
    
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
    Result = mnesia:create_table(decoreinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, decoreinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([decoreinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([decoreinfo], 5000),
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
    Config = load_config(),
    {ok, #state{config = Config}}.




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
handle_call({get_decore, TargetUserGuid}, From, State) ->
    utils:acall(fun() -> inner_get_decore(TargetUserGuid) end,From),
    {noreply, State};
handle_call({buy_decore, TargetUserGuid, DecoreGuid}, From, State) ->
    Config = State#state.config,
    utils:acall(fun() -> inner_buy_decore(TargetUserGuid, DecoreGuid, Config#config.decores) end, From),
    {noreply, State}.

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
inner_get_decore(TargetUserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({decoreinfo, TargetUserGuid}),
                    case Existance of 
                        [] ->
                            [];
                        [DecoreInfo] ->
                            DecoreInfo#decoreinfo.decores
                        end
            end,
    mnesia:activity(async_dirty, Trans).

inner_buy_decore(BuyerGuid, DecoreGuid, AllDecores) ->
    Trans = fun() ->
                    %% check are there are such decore
                    case lists:keyfind(DecoreGuid, 2, AllDecores) of
                        false ->
                            no_such_decore;
                        Decore ->
                            %% buy it
                            case bank_srv:withdraw(BuyerGuid, Decore#decore.price) of
                                {ok, _} ->
                                    %% write info
                                      job_srv:try_complete_job(BuyerGuid, <<"3">>),
                                    inner_add_user_decore_trans(BuyerGuid, Decore);
                                Error ->
                                    Error
                            end

                    end
   

            end,
    mnesia:activity(async_dirty, Trans).
    
inner_add_user_decore_trans(BuyerGuid, Decore) ->
    Existance = mnesia:read({decoreinfo, BuyerGuid}),
    case Existance of
        [] ->
            mnesia:write(#decoreinfo{user_guid = BuyerGuid,
                                      decores = [Decore#decore.guid]});
        [OldDecoreInfo] ->
            NewDecores = [Decore#decore.guid | lists:keydelete(Decore#decore.type,
                                                                   3, OldDecoreInfo#decoreinfo.decores)],
            mnesia:write(OldDecoreInfo#decoreinfo{decores = NewDecores}),
            ok
        end.

load_decore({struct, DecoreJson}) ->
    #decore{guid = binary_to_list(proplists:get_value(<<"guid">>, DecoreJson)),
            type = binary_to_list(proplists:get_value(<<"group">>, DecoreJson)),
            price = list_to_integer(binary_to_list(proplists:get_value(<<"price">>, DecoreJson)))};
load_decore(Error) ->
    throw({wrong_decore, Error}).

load_config() ->
    #config{decores = load_decores()}.

load_decores() ->
    inets:start(),
    {ok, DecoresUrl} = application:get_env(kissbang, decore_cfg_url),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
        httpc:request(get, {DecoresUrl, []}, [], []),
    {struct, DecoresJson} = mochijson2:decode(Body),
    [load_decore(Decore) || Decore <- proplists:get_value(<<"decores">>, DecoresJson)].

    



