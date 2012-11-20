-module(signature_checker).

-export([check_signature/2]).

check_signature(Data, vk) ->
    {ok, Secret} = application:get_env(kissbang, vk_secret_key),
    inner_check_signature(Data, Secret);
check_signature(Data, ok) ->
    {ok, Secret} = application:get_env(kissbang, ok_secret_key),
    inner_check_signature(Data, Secret);
check_signature(Data, mm) ->
    {ok, Secret} = application:get_env(kissbang, mm_secret_key),
    inner_check_signature(Data, Secret).
    

inner_check_signature(Data, SecretKey) ->
    %% sort keys and remove sig
    SortedKeys = lists:sort(fun(Left, Right) -> element(1, Left) =< element(2, Right) end, Data),

    SortedKeysWithSigRemoved = proplists:delete('sig', SortedKeys),
    %% get string to hash
    StringToHash = lists:flatten([element(1, I) ++ "=" ++ element(2, I) || I <- SortedKeysWithSigRemoved]) ++ SecretKey,
    log_srv:debug("vk_social_handler: going to hash string %s", [StringToHash]),
    %% compare sig with hashed string
    TheirSig = proplists:get_value('sig', Data),
    OurSig = md5:md5_hex(StringToHash),
    case TheirSig of
        OurSig ->
            log_srv:debug("vk signature is ok"),
            ok;
        _Other ->
            log_srv:warn("vk signature is failed : ours  = ~s, theirs = ~s", [OurSig, TheirSig]),
            fail
        end.

