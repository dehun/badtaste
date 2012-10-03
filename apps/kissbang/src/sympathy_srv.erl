%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created : 16 Aug 2012 by  <>
%%%-------------------------------------------------------------------
-module(sympathy_srv).

-behaviour(gen_server).
-include("kissbang_messaging.hrl").

%% API
-export([start_link/0,
         setup_db/0]).
-export([get_sympathies/1,
         add_sympathy/2]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).
-record(sympathyinfo, {user_guid, sympathies = []}).

%%%===================================================================
%%% API
%%%===================================================================
get_sympathies(UserGuid) ->
    gen_server:call(?SERVER, {get_sympathies, UserGuid}).

add_sympathy(LeftUser, RightUser) ->
    gen_server:cast(?SERVER, {add_sympathy, LeftUser, RightUser}).
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
    Result = mnesia:create_table(sympathyinfo, [{disc_copies, [node() | nodes()]}, 
                                                {attributes, record_info(fields, sympathyinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([sympathyinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([sympathyinfo], 5000),
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
handle_call({get_sympathies, UserGuid}, From, State) ->
    utils:acall(fun() -> inner_get_sympathies(UserGuid) end, From),
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
handle_cast({add_sympathy, LeftUser, RightUser}, State) ->
    utils:acast(fun() -> inner_add_sympathy(LeftUser, RightUser) end),
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
inner_get_sympathies(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({sympathyinfo, UserGuid}),
                    case Existance of 
                        [] ->
                            [];
                        [SympathyInfo] ->
                            SympathyInfo#sympathyinfo.sympathies
                        end
            end,
    mnesia:activity(async_dirty, Trans).

inner_add_sympathy(LeftGuid, RightGuid) ->
    job_srv:try_complete_job(LeftGuid, <<"7">>),
    job_srv:try_complete_job(RightGuid, <<"7">>),
    %lists:foreach(fun (Guid) -> scoreboard_srv:add_score(Guid, "sympathy") end, [LeftGuid, RightGuid]),
    
    Trans = fun() ->
                    increment_sympathies(LeftGuid, RightGuid),
                    increment_sympathies(RightGuid, LeftGuid)
            end,
    mnesia:activity(sync_dirty, Trans).

increment_sympathies(LeftGuid, RightGuid) ->
    Existance = mnesia:read({sympathyinfo, LeftGuid}),
    case Existance of
        [] ->
            NewSympathyInfo = #sympathyinfo{user_guid = LeftGuid, 
                                            sympathies = [#sympathy{kisser_guid = RightGuid,
                                                                    kisses = 1}]},
            mnesia:write(NewSympathyInfo);
        [OldSympathyInfo] ->
            %% increment counter or add new sympathy to list
            case lists:keysearch(RightGuid, 2, OldSympathyInfo#sympathyinfo.sympathies) of
                {value, OldSympathy} ->
                    SympathiesToTrim = [OldSympathy#sympathy{kisses = OldSympathy#sympathy.kisses + 1} | lists:keydelete(RightGuid, 2, OldSympathy#sympathyinfo.sympathies)];
                false ->
                    SympathiesToTrim = [#sympathy{kisser_guid = RightGuid,
                                                  kisses = 1} | OldSympathyInfo#sympathyinfo.sympathies]
            end,
            %% trim list of sympathies to maximum size 
            MaximumSympathies = element(2, application:get_env(kissbang, maximum_sympathies)),
            NewSympathies = lists:sublist(SympathiesToTrim, 1, MaximumSympathies),
            mnesia:write(OldSympathyInfo#sympathyinfo{sympathies = NewSympathies})
        end.

