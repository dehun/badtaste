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
-include("kissbang_messaging.hrl").

%% API
-export([start_link/0, 
        setup_db/0]).

-export([get_completed_jobs/1,
        try_complete_job/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {config}).
-record(config, {jobs}).
-record(job, {guid, are_on_server_side, count_to_complete, reward}).
-record(jobsinfo, {user_guid, jobs}).

%%%===================================================================
%%% API
%%%===================================================================
get_completed_jobs(UserGuid) ->
    gen_server:call(?SERVER, {get_completed_jobs, UserGuid}).

try_complete_job(UserGuid, JobGuid) ->
    gen_server:call(?SERVER, {try_complete_job, UserGuid, JobGuid}).
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
handle_call({try_complete_job, UserGuid, JobGuid}, From, State) ->
    utils:acall(fun() -> inner_try_complete_job(UserGuid, JobGuid, State#state.config) end, From),
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
         are_on_server_side = binary_to_list(proplists:get_value(<<"are_on_server_side">>, JobJson)),
         reward = list_to_integer(binary_to_list(proplists:get_value(<<"reward">>, JobJson))),
         count_to_complete = list_to_integer(binary_to_list(proplists:get_value(<<"count">>, JobJson)))}.

are_job_guid_correct(JobGuid, Config) ->
    Jobs = Config#config.jobs,
    case [Job || Job <- Jobs, Job#job.guid =:= JobGuid] of
        [] ->
            no_such_job;
        [_] ->
            ok
    end.

inner_try_complete_job(UserGuid, JobGuid, Config) ->
    case are_job_guid_correct(JobGuid, Config) of
        ok ->
            Trans = fun() ->
                            Existance = mnesia:read({jobsinfo, UserGuid}),
                            case Existance of
                                [] ->
                                    NewJobsInfo = #jobsinfo{user_guid = UserGuid,
                                                            jobs = ([#user_job{job_guid = JobGuid,
                                                                               count = 1}])},
                                    mnesia:write(NewJobsInfo),
                                    ok;
                                [OldJobsInfo] ->
                                    case [Job || Job <- OldJobsInfo#jobsinfo.jobs, Job#user_job.job_guid =:= JobGuid] of
                                        [] ->
                                            NewJob = #user_job{job_guid = JobGuid,
                                                               count=1,
                                                               are_completed="false"},
                                            CheckedNewJob = check_job_completness(UserGuid, NewJob, Config),
                                            NewJobsInfo = OldJobsInfo#jobsinfo{jobs = [CheckedNewJob | OldJobsInfo#jobsinfo.jobs]},
                                            mnesia:write(NewJobsInfo),
                                            ok;
                                        [OldJob] ->
                                            NewJob = OldJob#user_job{count = OldJob#user_job.count + 1},
                                            ExceptJobs = [Job || Job <- OldJobsInfo#jobsinfo.jobs, Job#user_job.job_guid =/= JobGuid],
                                            CheckedNewJob = check_job_completness(UserGuid, NewJob, Config),
                                            NewJobsInfo = OldJobsInfo#jobsinfo{jobs = [CheckedNewJob | ExceptJobs]},
                                            mnesia:write(NewJobsInfo),
                                            ok
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
                            JobsInfo#jobsinfo.jobs
                    end
            end,
    mnesia:activity(sync_dirty, Trans).
    

check_job_completness(CompleterGuid, Job, Config) ->
    [ConfigJob] = [J || J <- Config#config.jobs, J#job.guid =:= Job#user_job.job_guid],
    AreCompleted = ((Job#user_job.count > ConfigJob#job.count_to_complete) and (not Job#user_job.are_completed)),
    if 
        AreCompleted ->
            proxy_srv:async_route_messages(CompleterGuid, [#on_job_completed{job_guid = Job#user_job.job_guid}]),
            Job#user_job{are_completed = "true"};
        true ->
            Job
    end.
    
    
