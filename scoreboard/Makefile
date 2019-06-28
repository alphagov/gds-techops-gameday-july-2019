.SHELL := /bin/bash
.DEFAULT_GOAL := zip
.PHONY = clean

test:
	rm setup.cfg; tox

target_dir: # test
	rm -rf .target/
	mkdir -p .target/python/lib/python3.6/site-packages

copy_src: target_dir
	cp src/*.py .target

add_deps: target_dir
	bash -c "echo -e '[install]\nprefix=\n' > setup.cfg"; pip3 install -r requirements.txt -t .target/python/lib/python3.6/site-packages

clean:
	rm -rf __pycache__ .coverage *.zip *.egg-info .tox venv .pytest_cache htmlcov **/__pycache__ **/*.pyc

slim_deployment:
	find . -iname '*.so' -exec strip {} \;
	find .target -name "*-info" -type d -exec rm -rdf {} +
	find .target -name "tests" -type d -exec rm -rdf {} +
	find .target -name "*.txt" -type d -exec rm -rdf {} +
	rm -rdf .target/python/lib/python3.6/site-packages/boto3/
	rm -rdf .target/python/lib/python3.6/site-packages/botocore/
	rm -rdf .target/python/lib/python3.6/site-packages/docutils/
	rm -rdf .target/python/lib/python3.6/site-packages/dateutil/
	rm -rdf .target/python/lib/python3.6/site-packages/jmespath/
	rm -rdf .target/python/lib/python3.6/site-packages/s3transfer/
	rm -rdf .target/python/lib/python3.6/site-packages/numpy/doc/
	python3 -m compileall -f .
	find .target -type f -name '*.pyc' | while read f; do n=$$(echo $$f | sed 's/__pycache__\///' | sed 's/.cpython-36//'); cp $$f  $$n; done
	find .target -type d -a -name '__pycache__' -print0 | xargs -0 rm -rf
	find .target -type f -a -name '*.py' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.h' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.exe' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.rst' -print0 | xargs -0 rm -f


zip: clean add_deps slim_deployment
	cd .target; zip -9 ../scoreboard_layer1.zip -r -@ < ../layer1
	cd .target; zip -9 ../scoreboard_layer2.zip -r -@ < ../layer2
	cd src; zip -9 ../scoreboard.zip -r .

deploy: zip
	cd terraform/firebreak-q1-event-normalisation; terraform apply

run: clean add_deps copy_src
	cd .target; python3 game_play.py
