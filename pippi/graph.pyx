#cython: language_level=3

import random
from PIL import Image, ImageDraw, ImageFont
from pippi cimport interpolation
from pippi cimport dsp
from pippi.defaults cimport MIN_FLOAT
from pippi.soundbuffer cimport SoundBuffer
from pippi.wavetables cimport Wavetable
import sys
import numpy as np


cdef int ycoord(double point, int canvas_height, double minval, double maxval):
    y = (point - minval) * (1.0/(maxval - minval))
    return <int>(((y - 1) * -1) * canvas_height)

def write(object data, 
        object filename=None, 
        int width=400, 
        int height=300, 
        double offset=1, 
        double mult=0.5, 
        int stroke=2, 
        int upsample_mult=5, 
        bint show_axis=True,
        list insets=None, 
        list notes=None, 
        object y=None, 
        str label=None, 
        int fontsize=40, 
        str label_top=None,
        str label_bottom=None,
        ):

    cdef int i = 0
    cdef int channels
    cdef int channel = 0
    cdef double pos = 0
    cdef double point = 0
    cdef tuple color
    cdef double[:,:] _data
    cdef double[:] points
    cdef list mapped_points
    cdef list x_axis
    cdef int x
    cdef int gutter

    cdef double ymin=-1, ymax=1

    if isinstance(data, SoundBuffer):
        channels = data.channels
        _data = data.frames

    elif isinstance(data, Wavetable):
        channels = 1
        _data = np.transpose(np.array(data.data, dtype='d', ndmin=2))

    elif isinstance(data, list):
        channels = 1
        _data = np.transpose(np.array(data, dtype='d', ndmin=2))

    else:
        channels = data.shape[1]
        _data = data

    if y is not None:
        ymin, ymax = y
    else:
        ymin = np.min(_data)
        ymax = np.max(_data)

    if ymax - ymin <= MIN_FLOAT:
        raise ValueError('ymax and ymin are too close together')

    width *= upsample_mult
    height *= upsample_mult
    stroke *= upsample_mult

    if filename is None:
        filename = 'waveform.png'

    x_axis = list(range(width))

    with Image.new('RGBA', (width, height), (255, 255, 255, 255)) as img:
        draw = ImageDraw.Draw(img)

        for channel in range(channels):
            color = tuple([random.randint(0, 200) for _ in range(3)] + [200])

            points = np.array(_data[:,channel], dtype='d')

            mapped_points = []
            for x in x_axis:
                pos = x / width
                y = interpolation._linear_pos(points, pos)
                y = ycoord(y, height, ymin, ymax)
                mapped_points += [ (x, y) ]

            draw.line(mapped_points, fill=color, width=stroke, joint='curve')

        if show_axis:
            y = ycoord(0, height, ymin, ymax)
            draw.line((0, y, width, y), fill=(0,0,0,255), width=stroke//4)

        if label is not None:
            label_bottom = label

        if label_top is not None:
            fontsize = fontsize * upsample_mult
            font = ImageFont.truetype('modules/pixeldroid-console/pixeldroidConsoleRegular.ttf', fontsize)
            fontwidth, fontheight = font.getsize(label_top)
            fontx = width//2 - (fontwidth//2)
            fonty = 10
            draw.text((fontx, fonty), label_top, font=font, fill=(0, 0, 0, 200))

        if label_bottom is not None:
            fontsize = fontsize * upsample_mult
            font = ImageFont.truetype('modules/pixeldroid-console/pixeldroidConsoleRegular.ttf', fontsize)
            fontwidth, fontheight = font.getsize(label_bottom)
            fontx = width//2 - (fontwidth//2)
            fonty = height - int(fontheight*2)
            draw.text((fontx, fonty), label_bottom, font=font, fill=(0, 0, 0, 200))

        gutter = stroke
        if insets is not None:
            inset_width = width//len(insets) - gutter//2
            inset_height = height//3 - gutter//2
            new = Image.new('RGBA', (img.width, img.height + inset_height), (255,255,255,255))
            new.paste(img, (0, inset_height))
            for i, inset in enumerate(insets):
                inset = inset.resize((inset_width, inset_height))
                new.paste(inset, (inset_width*i + gutter//2, 0))

            img = new

        img.thumbnail((width//upsample_mult, height//upsample_mult))

        if filename is not None:
            img.save(filename)

    return img


# FIXME use `write` interface everywhere
cpdef void waveform(object sound, 
        object filename=None, 
        int width=400, 
        int height=300, 
        double lowvalue=-1,
        double highvalue=1,
        int stroke=3, 
        int upsample_mult=5, 
        bint show_axis=True):
    write(sound, filename, width, height, lowvalue, highvalue, stroke, upsample_mult, show_axis)
 
if __name__ == '__main__':
    snd_filename = sys.argv[1]
    out_filename = sys.argv[2]
    snd = dsp.read(snd_filename).remix(1)
    waveform(snd, out_filename, width=2050, height=1024)
