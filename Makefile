make:
	make compile

compile:
	./rebar compile eunit

test:
	make eunit

run:
	erl -pa apps/kissbang/ebin -boot start_sasl -s kissbang	
###	make run