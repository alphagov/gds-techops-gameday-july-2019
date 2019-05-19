.DEFAULT_GOAL := zip
.PHONY = clean

test:
	rm setup.cfg; tox

target_dir: # test
	mkdir -p .target/assets
	mkdir -p .target/templates

copy_src: target_dir
	cp src/*.py .target
	cp -R src/assets/* .target/assets/
	cp -R src/templates/* .target/templates/

add_deps: target_dir
	bash -c "echo -e '[install]\nprefix=\n' > setup.cfg"; pip3 install -r requirements.txt -t .target

clean:
	rm -rf __pycache__ .coverage .target *.egg-info .tox venv *.zip .pytest_cache htmlcov **/__pycache__ **/*.pyc

zip: add_deps copy_src
	cd .target; zip -9 ../gge.zip -r .

deploy: zip
	cd terraform/firebreak-q1-event-normalisation; terraform apply

run: add_deps copy_src
	python3 .target/game_play.py
