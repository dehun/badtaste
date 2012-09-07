
-module(kissbang_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one, 5, 10}, [?CHILD(auth_sup, supervisor),
                                 ?CHILD(guid_sup, supervisor),
                                 ?CHILD(gateway_sup, supervisor),
                                 ?CHILD(roommgr_sup, supervisor),
                                 ?CHILD(log_sup, supervisor),
                                 ?CHILD(sex_sup, supervisor),
                                 ?CHILD(job_sup, supervisor),
                                 ?CHILD(gift_sup, supervisor),
                                 ?CHILD(vip_sup, supervisor),
                                 ?CHILD(bank_sup, supervisor),
                                 ?CHILD(sympathy_sup, supervisor),
                                 ?CHILD(avatar_sup, supervisor),
                                 ?CHILD(rate_sup, supervisor),
                                 ?CHILD(decore_sup, supervisor),
                                 ?CHILD(mail_sup, supervisor),
                                 ?CHILD(webgate_sup, supervisor),
                                 ?CHILD(follower_sup, supervisor),
                                 ?CHILD(handlermgr_sup, supervisor),
                                 ?CHILD(roomqueue_sup, supervisor),
                                 ?CHILD(roomfullifier_sup, supervisor),
                                 ?CHILD(userinfo_sup, supervisor),
                                 ?CHILD(proxy_sup, supervisor)]}}.
