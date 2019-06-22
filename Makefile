.PHONY: test test-grains test-wavesets test-fx test-noise test-shapes test-oscs test-soundbuffer test-lists build

test:
	python -m unittest discover -s tests -p 'test_*.py' -v

test-grains:
	python -m unittest tests/test_graincloud.py -v

test-wavesets:
	python -m unittest tests/test_wavesets.py -v

test-fx:
	python -m unittest tests/test_fx.py -v

test-noise:
	python -m unittest tests/test_noise.py -v

test-shapes:
	python -m unittest tests/test_shapes.py -v

test-oscs:
	python -m unittest tests/test_oscs.py -v

test-soundbuffer:
	python -m unittest tests/test_soundbuffer.py -v

test-lists:
	python -m unittest tests/test_lists.py -v

clean:
	rm -rf build/
	rm -rf pippi/*.c
	rm -rf pippi/*.so

build:
	python setup.py develop
