# Pippi: Computer music with python

v2.0.0 - Beta 4 (In Development)

## What is this?

This is the python library that [I use to write music](http://hecanjog.com). I think python is a wonderful language for music. 
I try to make the API for this library as nice to use as the language itself; which I consider to be a very comfortable 
environment that lets me think about the composition I'm working on more than its fiddly implementation bits.

I hope this library can be useful for your creative projects too.

## Installation and setup

Pippi requires python 3.6+ which can be found here:

    https://www.python.org/downloads/

The 3.5.x branch of python might work too, but is untested.

### Install from pip

To use the most recent release from pip (currently `2.0.0 beta 3`) just:

    pip install pippi

### Install from source

Or to install the most recent development version. Install deps:

    pip install -r requirements.txt

Build the cython extensions from source & run the test suite

    make clean build test

Please let me know if you run into problems!

## Run examples

    make examples

Which will run every example in the `examples` directory, creating audio file renders in the same directory.

## To run tests

    make test

In many cases, this will produce a soundfile in the `tests/renders` directory for the corresponding test. (Ear-driven regression testing...)

## Release Notes

### 2.0.0 - Beta 4

#### Features

- The first set of soundpipe modules are now available via the `fx` module!
    - `fx.lpf`, `fx.hpf`, `fx.bpf`, and `fx.brf` butterworth filters.
    - `fx.compressor`... a compressor.
    - `fx.mincer` a phase vocoder with independent control over pitch and speed.
    - `fx.paulstretch`... paulstretch.
    - `fx.saturator` a saturation distortion.
- Total rewrite of `grains.GrainCloud`, now `grains.Cloud` (and `SoundBuffer.cloud`) (In progress)
    - Uses `mincer` for pitch shifting
    - Grainlength and grain density are no longer tightly coupled: no more `density` param. It is replaced with a `grainlength` value/wavetable and a `grid` value/wavetable.
    - Grain masking
    - Optional per-grain butterworth filters (in progress)
    - Most (all?) params can be given as either a fixed-value float (like `1.3`), a built-in wavetable 
      flag (like `dsp.HANNOUT` or `dsp.RND`), or a wavetable-like object (a list, numpy array, sound buffer, etc). EG a cloud frozen in time `Cloud(position=0.75)`, advancing linearly through time `Cloud(position=dsp.PHASOR)`, or interpolated through four points in time `Cloud(position=[0, 1, 0.25, 0.75])`.

#### Bugfixes

- Some cython extension packaging improvements (in progress)

### 2.0.0 - Beta 3

#### Features

- Basic FIR filter with `filters.fir` or `fx.convolve`
- SoundBuffer normalization with `fx.norm`
- Get SoundBuffer magnitude with `dsp.mag`
- Single and multitap delays with `fx.delay` and `fx.mdelay`
- Some new built-in `wavetable.window` types: `dsp.SINEIN` / `dsp.SINEOUT`, `dsp.HANNIN` / `dsp.HANNOUT` for fades
- More flexible frequency table creation from arbitrary scales, tunings and scale bitmasks with `tune.tofreqs`

#### Bugfixes

- Fix phase overflow in `interpolation._linear_point`
- Fixed a nasty bug when loading mono soundfiles from disk.

### 2.0.0 - Beta 2

#### Features

- Point interpolation with `interpolation.linear_point`

#### Bugfixes

- Examples can be run from anywhere
- Interpolation fixes

#### Performance Optimizations

- Faster ADSR wavetable generation
- Faster pitch shifting
- Faster interpolation
- Faster grain cloud generation
- Some misc `SoundBuffer` performance improvements (more to come)

### 2.0.0 - Beta 1

#### Features

- Added `fx` module
- Added first pass `fx.go` granular overdrive effect. See `examples/fxgo_example.py` for usage.

#### Bugfixes

- Fixed a packaging issue preventing the `tune` module from loading.
- Better overflow handling in `SoundBuffer.adsr` and `wavetables.adsr`
- Fixed a bug with `SoundBuffer.remix` when mixing to a single channel
- Fixed a bug during `Wavetable` initialization when using wavetable flags to create a window.

### 2.0.0 - Alpha 9

Final feature releases / big api changes before going to beta.

- Breaking changes:
    - Durations for most APIs are now given in seconds (floats) rather than 
      integer frames. `len(SoundBuffer)` still returns a length in frames per
      python convention, and slicing into a `SoundBuffer` is also still done by frame
      (and channel) but there is a new `SoundBuffer.dur` property to get duration 
      in seconds as well.
    - Wavetables are no longer specified with string names, instead built-in 
      flags which are available on both the `wavetable` and `dsp` modules are 
      used. Eg to apply a sinewave envelop: `sound.env(dsp.SINE)` instead of `sound.env('sine')`. 
      The wavetypes available are `SINE`, `COS`, `TRI`, `SAW` (which is also aliased to 
      `PHASOR`), `RSAW` (reverse sawtooth), `HANN`, `HAMM`, `BLACK` or `BLACKMAN`, 
      `BART` or `BARTLETT`, `KAISER`, `SQUARE`, and the `RND` flag to select one at random.
- `Osc` changes:
    - Added 2d wavetable synthesis (similar to max/msp `2d.wave~`) to `Osc` plus example script
    - To create a 2d `Osc`, use the `stack` keyword arg on initialization: `Osc(stack=[dsp.RND, [0,1], dsp.SINE], lfo=dsp.SINE)`
    - `Osc` wavetables may be:
        - an int flag for standard wavetables (`dsp.SINE`, `dsp.TRI`, etc)
        - a python list of floats (`[0,1,0.5,0.3]`)
        - a wavetable (`wavetables.Wavetable([0,1,0,1])`)
        - a soundbuffer (`soundbuffer.SoundBuffer(filename='something.flac')`)
    - 2d wavetable stacks are a python list of any combination of the above.
    - The same types are acceptable for:
        - `wavetable` (the basic waveform)
        - `window` (an optional window to apply to the waveform wavetable - useful for eg pulsar synthesis)
        - `mod` (the frequency modulation wavetable)
        - and `lfo` (the 2d modulation wavetable)
- `SoundBuffer` changes:
    - Added `remix` for remixing a soundbuffer from N channels to N channels.
    - Panning algorithms operate on arbitrary numbers of channels (but use same algorithms applied to odd & even numbered channels instead of left & right)
    - Return a reversed copy of a soundbuffer with `sound.reversed()` or reverse in place with `sound.reverse()`
    - New ADSR envelopes with `sound.adsr(a=1, d=1, s=0.5, r=1)`
    - Generate a `GrainCloud` from a `SoundBuffer` with `sound.cloud()`
    - Clip samples to min/max with `sound.clip(minval=-1, maxval=1)`
    - Taper ends of sounds (linear fade-in, fade-out) with `sound.taper(length)`
- ADSR wavetable generator with `wavetables.adsr(a=100, d=100, s=0.5, r=100, 1024)`
- New `Wavetable` type for `SoundBuffer`-like operator-overloaded wavetable manipulation & composition
- New `GrainCloud` wavetable-driven granulator. See the `examples/swarmy_graincloud.py` example for more.
- `GrainCloud`-driven pitch shift without time change (`sound.transpose(speed)`) 
   and time stretch without pitch shift (`sound.stretch(length)`) methods for `SoundBuffer`.
- `dsp.cloud(SoundBuffer, *args, **kwargs)` shortcut for `GrainCloud` creation.
- Read wavetables from 1 channel sound files with `wavetables.fromfile`
- Added a simple helper for async rendering with `multiprocessing.Pool`
- `SoundBuffer`s can now be pickled (enables passing them between processes)
- `SoundBuffer` can be initialized (and spread across channels) from a normal python list


### 2.0.0 - Alpha 6-8

This was meant to be a feature-only release, to add the final round of features 
before going into beta / bugfix mode. Instead I switched from using numpy arrays directly 
to a first pass of a more general typed memoryview approach, and moved some more things into 
cython.

Also, hoo boy was `pip install pippi` ever *broken*.
It should be working now.

### 2.0.0 - Alpha 5

Bugfix release. Fixed an idiotic regression in `SoundBuffer`.

### 2.0.0 - Alpha 4

New in alpha 4:

- More speed improvements!
- Linear interpolation option for pitch shifting
- Pulsar synthesis with `Osc`
- Support for importing Scala `.scl` tuning files (Mapping file support coming later...)
- Waveform visualization with `graph.waveform`
- `SoundBuffer.fill` returns a copy of the sound instead of altering it in place
- `Sampler` abstraction for `Osc`-like treatment of samples and banks of samples

### 2.0.0 - Alpha 3

Optimizations and improvements in this release:

- Much better performance for wavetable and granular synthesis
- Improvements and additions to the `rhythm` modules
    - Better handling of `rhythm.curve` which now takes a length param instead of an obscure combination of multipliers
    - `rhythm.curve` can now be provided a custom wavetable
    - Added MPC swing helper for onset lists (via `rhythm.swing`)
    - Added a euclidean rhythm generator `rhythm.eu`
    - Added a pattern generation helper `rhythm.pattern`
    - Added pattern-to-onset and string-to-pattern helpers
        - Patterns are the same as pippi 1 (I may even just port some code) and can be in a few forms:
            - String literals with ascii notation eg: 'xx x- x' which is the same as 'xx.x-.x'
            - Lists of 'truthy' and 'falsey' values eg: ['1', True, 0, False] which is the same as 'xx..'
- Misc bugfixes:
    - Fix `random` param for `wavetable.window` and `wavetable.window`
    - Fix bad params for `wavetable.window` and `wavetable.window` -- falls back to sine in both cases

### 2.0.0 - Alpha 2

This release includes a few missing pieces to core functionality including:

- A crude squarewave wavetype for the wavetable osc!
- Custom wavetables for the wavetable osc and window/wavetable generators! 
  See the `simple_custom_wavetable.py` example for use with the wavetable osc.
- A simple non-interpolating `speed` method on `SoundBuffer` for pitch shifting sounds
- A set of rhythm helpers in the `rhythm` module useful for constructing onset / timing lists.
    - `rhythm.curve` which lets you map any of the window types to a list of onsets -- check out 
    the `simple_snare_bounce.py` example in the examples directory.
- Some more example scripts including:
    - `simple_snare_bounce.py` Demoing the `rhythm.curve` helper
    - `multi_snare_bounce.py` A more interesting variation on the snare bounce example
    - `simple_custom_wavetable.py` Showing a user-defined wavetable used with `Osc`
    - `synth_chords.py` Using the `tune` module with `Osc` to create a simple chord progression

### 2.0.0 - Alpha 1

This is the initial alpha release of pippi 2 -- which is very barebones at the moment, 
but already pretty functional!

Beware: the behavior of core functionality and features will probably change throughout the 
alpha releases of pippi 2. I'll try to document it here in the release notes.

This release provides:

- SoundBuffer abstraction for reading/writing soundfiles and doing basic operations on sounds.
- Osc abstraction for simple wavetable synthesis.
- Initial set of built-in wavetables for windowing (sine, triangle, saw, inverse saw) 
  and synthesis (sine, cosine, triangle, saw inverse saw)
- Set of panning algorithms and other built-in sound operations like addition, subtraction, 
  multiplication, mixing (and operater-overloaded mixing via `sound &= sound`), dubbing, 
  concatenation.
- A small set of helpers and shortcuts via the `dsp` module for loading, mixing, and concatenating (via `dsp.join`) sounds.
- Basic granular synthesis and wavetable synthesis examples.


[psf]: https://forge.ircam.fr/p/pysndfile/
[lsf]: http://www.mega-nerd.com/libsndfile/
