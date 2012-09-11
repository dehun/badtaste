%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created :  6 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(rate_srv).

-behaviour(gen_server).


-include("kissbang_messaging.hrl").

%% API
-export([start_link/0, setup_db/0]).
-export([rate_user/3,
         get_user_rate/1,
         are_user_rated/2,
         delete_rate_point/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(rateinfo, {guid, rates}).

%%%===================================================================
%%% API
%%%===================================================================
are_user_rated(RaterGuid, RatedGuid) ->
    gen_server:call(?SERVER, {are_user_rated, RaterGuid, RatedGuid}).

rate_user(RaterGuid, TargetUserGuid, Rate) ->
    gen_server:call(?SERVER, {rate_user, RaterGuid, TargetUserGuid, Rate}).

get_user_rate(UserGuid) ->
    gen_server:call(?SERVER, {get_user_rate, UserGuid}). %% {ok, AverageRate, LastRatePoints}

delete_rate_point(UserGuid, RaterGuid) ->
    gen_server:call(?SERVER, {delete_rate_point, UserGuid, RaterGuid}). %% ok, fail
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
    Result = mnesia:create_table(rateinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, rateinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([rateinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([rateinfo], 5000),
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
handle_call({are_user_rated, RaterGuid, RatedGuid}, From, State) ->
    utils:acall(fun() ->
                        inner_are_user_rated(RaterGuid, RatedGuid)
                end, From),
    {noreply, State};
handle_call({delete_rate_point, UserGuid, RaterGuid}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_delete_rate_point(UserGuid, RaterGuid),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({get_user_rate, UserGuid}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_get_user_rate(UserGuid),
                       gen_server:reply(From, Reply)
               end),
    {noreply, State};
handle_call({rate_user, RaterGuid, TargetUserGuid, Rate}, From, State) ->
    spawn_link(fun() ->
                       Reply = inner_rate(RaterGuid, TargetUserGuid, Rate),
                       gen_server:reply(From, Reply)
               end),
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
inner_delete_rate_point(UserGuid, RaterGuid) ->
    ok.

calculate_average_rate(Rates) ->
    lists:sum([Point#rate_point.rate || Point <- Rates]) / length(Rates).

inner_get_user_rate(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({rateinfo, UserGuid}),
                    case Existance of
                        [] ->
                            {ok, 0, []};
                        [RateInfo] ->
                            AveragePoint = calculate_average_rate(RateInfo#rateinfo.rates),
                            {ok, AveragePoint, RateInfo#rateinfo.rates}
                    end
            end,
    mnesia:activity(async_dirty, Trans).

inner_rate(RaterGuid, TargetUserGuid, Rate) ->
    Trans = fun() ->
                    NewRatePoint = #rate_point{rater_guid = RaterGuid,
                                               rate = Rate},
                    Existance = mnesia:read({rateinfo, TargetUserGuid}),
                    case Existance of
                        [] ->
                            mnesia:write(#rateinfo{guid = TargetUserGuid,
                                                   rates = [NewRatePoint]}),
                            ok;
                        [OldRateInfo] ->
                            AreAlreadyInList =  length([E || E <- OldRateInfo#rateinfo.rates, E#rate_point.rater_guid =:= RaterGuid]) > 0,
                             if
                                AreAlreadyInList ->
                                     already_rate;
                                true ->
                                     mnesia:write(OldRateInfo#rateinfo{rates = [NewRatePoint | OldRateInfo#rateinfo.rates]}),
                                     ok
                             end
                    end
            end,
    mnesia:activity(async_dirty, Trans).


inner_are_user_rated(RaterGuid, RatedGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({rateinfo, RatedGuid}),
                    case Existance of
                        [] ->
                            false;
                        [RateInfo] ->
                            length([RatePoint || RatePoint <- RateInfo#rateinfo.rates, RatePoint#rate_point.rater_guid =:= RaterGuid]) == 1
                    end
            end,
    mnesia:activity(async_dirty, Trans).
