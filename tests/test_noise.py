from unittest import TestCase
from pippi import dsp, noise

class TestFx(TestCase):
    def test_bln_low(self):
        out = noise.bln('sine', 2, 40, 200).env('hann') * 0.1
        out.write('tests/renders/noise_bln_low.wav')

    def test_bln_high(self):
        out = noise.bln('sine', 2, 8000, 15000).env('hann') * 0.1
        out.write('tests/renders/noise_bln_high.wav')

    def test_bln_wide(self):
        out = noise.bln('sine', 2, 40, 15000).env('hann') * 0.1
        out.write('tests/renders/noise_bln_wide.wav')

