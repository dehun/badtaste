make:
	make compile

compile:
	./rebar compile

test:
	./rebar compile eunit

clean:
	./rebar clean

run:
	erl -pa apps/kissbang/ebin -boot start_sasl -s kissbang

generate:
	./rebar -v generate	

protocol:
	cd ./common/protocol && make
###	make run