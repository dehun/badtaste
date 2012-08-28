%%%-------------------------------------------------------------------
%
%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 17 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(follower_srv).

-behaviour(gen_server).

%% API
-export([start_link/0,
        setup_db/0]).
-export([buy_following/2,
         get_followers/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(followersinfo, {user_guid, followers=[], current_price}).

%%%===================================================================
%%% API
%%%===================================================================

buy_following(BuyerGuid, TargetGuid) ->
    gen_server:call(?SERVER, {buy_following, BuyerGuid, TargetGuid}).

get_followers(UserGuid) ->
    gen_server:call(?SERVER, {get_followers, UserGuid}).
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
    Result = mnesia:create_table(followersinfo, [{disc_copies, [node() | nodes()]}, 
                                                {attributes, record_info(fields, followersinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([followersinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([followersinfo], 5000),
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
%%                                   {Reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({get_followers, UserGuid}, From, State) ->
    utils:acall(fun() -> 
                        inner_get_followers(UserGuid)
                end, From),
    {noreply, State};
handle_call({buy_following, BuyerGuid, TargetGuid}, From, State) ->
    utils:acall(fun() -> 
                        inner_buy_following(BuyerGuid, TargetGuid)
                end, From),
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
inner_buy_following(BuyerGuid, TargetGuid) ->
    Trans = fun() ->
                    %  prepare info to write
                    Existance = mnesia:read({followersinfo, TargetGuid}),
                    case Existance of
                        [] ->
                            BuyPrice = element(2, application:get_env(kissbang, following_buy_start_price)),
                            NewFollowersInfo = #followersinfo{user_guid = TargetGuid,
                                                              followers = [BuyerGuid],
                                                              current_price = calculate_next_price(BuyPrice)};
                        [OldFollowersInfo] ->
                            BuyPrice = OldFollowersInfo#followersinfo.current_price,
                            {ok, MaximumFollowersLength} = application:get_env(kissbang, maximum_followers),
                            NewFollowers = lists:sublist([BuyerGuid | OldFollowersInfo#followersinfo.followers], 1, MaximumFollowersLength),
                            NewFollowersInfo = OldFollowersInfo#followersinfo{followers = NewFollowers}
                    end,
                    % buy
                    case bank_srv:withdraw(BuyerGuid, BuyPrice) of
                        {ok, _} ->
                            mnesia:write(NewFollowersInfo),
                            ok;
                        Error ->
                            Error
                    end
            end,
    mnesia:activity(transaction, Trans).


inner_get_followers(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({followersinfo, UserGuid}),
                    case Existance of
                        [] ->
                            BuyPrice = element(2, application:get_env(kissbang, following_buy_start_price)),
                            {BuyPrice, []};
                        [FollowersInfo] ->
                            {FollowersInfo#followersinfo.current_price, 
                             FollowersInfo#followersinfo.followers}
                    end

            end,
    mnesia:activity(transaction, Trans).

calculate_next_price(OldPrice) ->
    OldPrice * 2.
