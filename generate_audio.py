import wave
import math
import struct
import os

def generate_tone(filename, duration, freq, volume=0.5, rate=44100):
   nframes = int(rate * duration)
   with wave.open(filename, 'w') as wav_file:
       wav_file.setparams((1, 2, rate, nframes, 'NONE', 'not compressed'))
       for i in range(nframes):
           t = i / rate
           val = math.sin(2 * math.pi * freq * t)
           # Envelope
           if i < 1000: val *= (i/1000)
           if i > nframes - 1000: val *= ((nframes-i)/1000)
           
           data = struct.pack('<h', int(val * 32767 * volume))
           wav_file.writeframes(data)

def generate_win(filename):
    rate = 44100
    duration = 0.6
    freqs = [440, 554, 659, 880] # A Major
    nframes = int(rate * duration)
    with wave.open(filename, 'w') as wav_file:
       wav_file.setparams((1, 2, rate, nframes, 'NONE', 'not compressed'))
       for i in range(nframes):
           t = i / rate
           idx = int(t / (duration/4))
           freq = freqs[min(idx, 3)]
           val = math.sin(2 * math.pi * freq * t)
           data = struct.pack('<h', int(val * 32767 * 0.5))
           wav_file.writeframes(data)

def generate_music(filename):
    rate = 44100
    duration = 8.0 
    nframes = int(rate * duration)
    chord1 = [261.63, 329.63, 392.00, 493.88] 
    chord2 = [174.61, 220.00, 261.63, 329.63]
    with wave.open(filename, 'w') as wav_file:
       wav_file.setparams((1, 2, rate, nframes, 'NONE', 'not compressed'))
       for i in range(nframes):
           t = i / rate
           current_chord = chord1 if t < 4.0 else chord2
           local_t = t % 4.0
           val = 0.0
           for freq in current_chord:
               base = math.sin(2 * math.pi * freq * t)
               h2 = math.sin(2 * math.pi * freq * 2 * t) * 0.5
               h3 = math.sin(2 * math.pi * freq * 3 * t) * 0.2
               envelope = 1.0
               if local_t < 0.1: 
                   envelope = local_t / 0.1
               else:
                   envelope = math.exp(-(local_t - 0.1) * 0.8) 
               val += (base + h2 + h3) * envelope
           val = val / 10.0 
           data = struct.pack('<h', int(val * 32767 * 0.4))
           wav_file.writeframes(data)

def generate_buy(filename):
    rate = 44100
    duration = 0.4
    nframes = int(rate * duration)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setparams((1, 2, rate, nframes, 'NONE', 'not compressed'))
        for i in range(nframes):
            t = i / rate
            # Two tone coin sound
            freq = 1200 if t < 0.1 else 1600
            val = math.sin(2 * math.pi * freq * t)
            # Decay
            decay = 1.0 - (t / duration)
            data = struct.pack('<h', int(val * 32767 * 0.5 * decay))
            wav_file.writeframes(data)

def generate_equip(filename):
    rate = 44100
    duration = 0.2
    nframes = int(rate * duration)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setparams((1, 2, rate, nframes, 'NONE', 'not compressed'))
        for i in range(nframes):
            t = i / rate
            # Whoosh up
            freq = 400 + (t/duration) * 400
            val = math.sin(2 * math.pi * freq * t)
            data = struct.pack('<h', int(val * 32767 * 0.5))
            wav_file.writeframes(data)

os.makedirs('assets/audio', exist_ok=True)

print("Generating move.wav...")
generate_tone('assets/audio/move.wav', 0.1, 880)

print("Generating pop.wav...")
generate_tone('assets/audio/pop.wav', 0.05, 1200)

print("Generating win.wav...")
generate_win('assets/audio/win.wav')

print("Generating music.wav...")
generate_music('assets/audio/music.wav')

print("Generating buy.wav...")
generate_buy('assets/audio/buy.wav')

print("Generating equip.wav...")
generate_equip('assets/audio/equip.wav')

print("Done!")
