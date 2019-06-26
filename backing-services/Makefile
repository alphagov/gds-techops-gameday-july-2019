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

zip: clean add_deps copy_src
	cd .target; zip -9 ../gde-docs.zip -r .

deploy: zip
	cd terraform/firebreak-q1-event-normalisation; terraform apply

run: clean add_deps copy_src
	cd .target; python3 game_play.py
