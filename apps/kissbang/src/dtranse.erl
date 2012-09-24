-module(dtranse).

-export([dtranse/1,
         async_dtranse/1,
         transefun/2,
         noop_sync/1]).

noop_sync(Res) ->
    Res.

gather_votes(FunctionsIds) ->
    gather_votes(FunctionsIds, []).

gather_votes([H | FunctionIdsRest], Accum) ->
	receive 
		{vote, From, Result, H} ->
			gather_votes(FunctionIdsRest, [{From, Result} | Accum])
	after 15000 ->
			{fail, timeout}
	end;
gather_votes([], Accum) ->
	{ok, Accum}.


generate_callback(TransId) ->
	Coordinator = self(),
	{ok, FunctionId} = guid_srv:create(),
	Callback = fun(Result) ->
					   Coordinator ! {vote, self(), Result, FunctionId},
					   receive 
						   {rollback, TransId} ->
							   mnesia:abort(vote_rollback); % abort transaction
						   {commit, TransId} ->
							   [] % continue trans
					   after 15000 ->
							   throw(timeout)			
					   end
			   end,
	{FunctionId, Callback}.


dtranse(Functions) ->
	% do calls
	{ok, TransId} = guid_srv:create(),
	FunctionIds = lists:map(fun(Function) ->
									{FunctionId, Callback} = generate_callback(TransId),
									spawn_link(fun() ->
													   Function(Callback)
											   end),
									FunctionId
                            end, Functions),
	% gather votes
	{ok, Votes} = gather_votes(FunctionIds),
	% reply to all
	case [{From, Res} || {From, Res} <- Votes, Res /= ok] of
		[] -> %result is ok. send good answers
			lists:foreach(fun({From, _Res}) ->
								  From ! {commit, TransId}												  
						  end, Votes),
            ok;
		_Other ->
			lists:foreach(fun({From, _Res}) ->
								  From ! {rollback, TransId}
                          end, Votes),
            fail
	end.


transefun(Fun, TransSync) ->
    fun() ->
            Result = Fun(),
            TransSync(element(1, Result)),
            element(2, Result)
    end.

async_dtranse(Functions) ->
	spawn_link(fun() ->
					   dtranse(Functions)
			   end).
