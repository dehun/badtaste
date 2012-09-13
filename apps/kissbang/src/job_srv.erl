%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2012, 
%%% @doc
%%%
%%% @end
%%% Created :  4 Sep 2012 by  <>
%%%-------------------------------------------------------------------
-module(job_srv).

-behaviour(gen_server).

%% API
-export([start_link/0, 
        setup_db/0]).

-export([get_completed_jobs/1,
        complete_job/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {config}).
-record(config, {jobs}).
-record(job, {guid, are_on_server_side}).
-record(userjob, {guid, count}).
-record(jobsinfo, {user_guid, completed_jobs}).

%%%===================================================================
%%% API
%%%===================================================================
get_completed_jobs(UserGuid) ->
    gen_server:call(?SERVER, {get_completed_jobs, UserGuid}).

complete_job(UserGuid, JobGuid) ->
    gen_server:call(?SERVER, {complete_job, UserGuid, JobGuid}).
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
    Result = mnesia:create_table(jobsinfo, [{disc_copies, [node() | nodes()]}, 
                                            {attributes, record_info(fields, jobsinfo)}]),
    case Result of
        {atomic, ok} ->
            mnesia:wait_for_tables([jobsinfo], 5000),
            ok;
        {aborted, {already_exists, _}} ->
            mnesia:wait_for_tables([jobsinfo], 5000),
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
handle_call({get_completed_jobs, UserGuid}, From, State) ->
    utils:acall(fun() -> inner_get_completed_jobs(UserGuid) end, From),
    {noreply, State};
handle_call({complete_job, UserGuid, JobGuid}, From, State) ->
    utils:acall(fun() -> inner_complete_job(UserGuid, JobGuid, State#state.config) end, From),
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
load_config() ->
    #config{jobs = load_jobs()}.

load_jobs() ->
    inets:start(),
    {ok, JobsUrl} = application:get_env(kissbang, jobs_cfg_url),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
        httpc:request(get, {JobsUrl, []}, [], []),
    JobsBinaryData = Body,
    {struct, JobsJson} = mochijson2:decode(JobsBinaryData),
    [load_job(Job) || Job <- proplists:get_value(<<"jobs">>, JobsJson)].

load_job({struct, JobJson}) ->
    #job{guid = binary_to_list(proplists:get_value(<<"guid">>, JobJson)),
         are_on_server_side = binary_to_list(proplists:get_value(<<"are_on_server_side">>, JobJson))}.

are_job_guid_correct(JobGuid, Config) ->
    Jobs = Config#config.jobs,
    case [Job || Job <- Jobs, Job#job.guid =:= JobGuid] of
        [] ->
            no_such_job;
        [_] ->
            ok
    end.

inner_complete_job(UserGuid, JobGuid, Config) ->
    case are_job_guid_correct(JobGuid, Config) of
        ok ->
            Trans = fun() ->
                            Existance = mnesia:read({jobsinfo, UserGuid}),
                            case Existance of
                                [] ->
                                    NewJobsInfo = #jobsinfo{user_guid = UserGuid,
                                                            completed_jobs = sets:from_list([JobGuid])},
                                    mnesia:write(NewJobsInfo),
                                    ok;
                                [OldJobsInfo] ->
                                    case sets:is_element(JobGuid, OldJobsInfo#jobsinfo.completed_jobs) of
                                        true ->
                                            mnesia:write(OldJobsInfo#jobsinfo{completed_jobs = sets:add_element(JobGuid, OldJobsInfo#jobsinfo.completed_jobs)}),
                                            ok;
                                        false ->
                                            job_already_completed
                                        end
                                end
                    end,
            mnesia:activity(sync_dirty, Trans);
        Error ->
            Error
    end.

inner_get_completed_jobs(UserGuid) ->
    Trans = fun() ->
                    Existance = mnesia:read({jobsinfo, UserGuid}),
                    case Existance of 
                        [] ->
                            [];
                        [JobsInfo] ->
                            sets:to_list(JobsInfo#jobsinfo.completed_jobs)
                    end
            end,
    mnesia:activity(sync_dirty, Trans).
                    

inner_update_job(Guid, Count) ->
    ok.
                    
    
