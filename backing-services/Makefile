.DEFAULT_GOAL := zip
.PHONY = clean

test:
	rm setup.cfg; tox

target_dir: # test
	rm -rf .target/
	mkdir -p .target/assets
	mkdir -p .target/game_play_docs
	mkdir -p .target/templates

copy_src: target_dir
	cp src/*.py .target
	cp -R src/assets/* .target/assets/
	cp -R src/game_play_docs/* .target/game_play_docs/
	cp -R src/templates/* .target/templates/

add_deps: target_dir
	bash -c "echo -e '[install]\nprefix=\n' > setup.cfg"; pip3 install -r requirements.txt -t .target

clean:
	rm -rf __pycache__ .coverage .target *.egg-info .tox venv *.zip .pytest_cache htmlcov **/__pycache__ **/*.pyc

slim_deployment:
	find . -iname '*.so' -exec strip {} \;
	find .target -name "*-info" -type d -exec rm -rdf {} +
	find .target -name "tests" -type d -exec rm -rdf {} +
	find .target -name "*.txt" -type d -exec rm -rdf {} +
	rm -rdf .target/boto3/
	rm -rdf .target/botocore/
	rm -rdf .target/docutils/
	rm -rdf .target/dateutil/
	rm -rdf .target/jmespath/
	rm -rdf .target/s3transfer/
	rm -rdf .target/numpy/doc/
	python3 -m compileall -f .
	find .target -type f -name '*.pyc' | while read f; do n=$$(echo $$f | sed 's/__pycache__\///' | sed 's/.cpython-36//'); cp $$f  $$n; done
	find .target -type d -a -name '__pycache__' -print0 | xargs -0 rm -rf
	find .target -type f -a -name '*.py' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.h' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.exe' -print0 | xargs -0 rm -f
	find .target -type f -a -name '*.rst' -print0 | xargs -0 rm -f

zip: clean add_deps copy_src slim_deployment
	cd .target; zip -X -9 ../gde-docs.zip -r .

deploy: zip
	cd terraform/firebreak-q1-event-normalisation; terraform apply

run: clean add_deps copy_src
	cd .target; python3 game_play.py
