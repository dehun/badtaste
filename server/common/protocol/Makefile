make:
	make erlang_srv
	make erlang_admin
	make python_tests

erlang_srv:
	python ./tools/protogen/pgen.py --lang erlang --format json --output=../../apps/kissbang/src/ --proto ./kissbang_proto.py

erlang_admin:
	python ./tools/protogen/pgen.py --lang erlang --format json --output=../../apps/kissbang/src/ --proto ./admin_proto.py

python_tests:
	python ./tools/protogen/pgen.py --lang python --format json --output=../../apps/kissbang/test/pytests/ --proto ./kissbang_proto.py
	python ./tools/protogen/pgen.py --lang python --format json --output=../../apps/kissbang/test/pytests/ --proto ./admin_proto.py