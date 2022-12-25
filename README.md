# MonoTranscription
## Overview of the Project
* Sight-singing is a practice of, given a sheet music, and a scale or starting pitch, one is required to sing through a given example by reading the music. *This is an extremely important skill for singers and is a difficult skill to develop. 
* As a musician myself, practicing this skill can be very challenging.
* Therefore **I wanted to develop a software which can provide feedback of where the singer sang wrong intervals or pitch!**
* As the beginning of this software, I tackled the problem of **monophonic music audio transcription for recorded vocal audio 🎼**
------
## Implementation
### Key Concepts
  * Use of FFT (Fourier Transform)
    * **Sound wave can be expressed in terms of summation of many simpler wave functions!**
  * Hidden Markov Model Structure
  * Dynamic Programming
  

## Summary of key concepts
---------
### FFT / Fast Fourier Transform
<p align="center">
  <img src="https://github.com/hsato1/MonoTranscription/blob/main/imgs/template_example.png">
 </p>
 <p align="center">
Fig.1 Spectra Diagram of pitch template
</p>

* Fourier Transform is a function which decompose complex waveform into a summation of simpler sine/cosine waves. Each wave component can be described with Modulous and Phase. 
* For our transcription purpose, we focused on the Modulus information of pitched sound and we model the spectra of each - we create the pitch template as reference to match the actual real-audio spectra.
* In order to implement this transcription task, we use log probability matching of given frame FFT spectra and templates of pitched sound.

### Hidden Markov Model Structure
#### **Even we can match and attempt to find the best fitting template frame by frame. We should not be calling just one grain of audio, a note. Why??**
#### A. Because one grain of audio is too short to be considered a note, if we do frame by frame recognition without any restriction. Result may be much noisier. For example, for ss0.wav, with N = 1024, hop size of N/2, each grain of audio is 0.064 seconds. This is too short to be recognized as a note.

<p align="center">
  <img src="https://github.com/hsato1/MonoTranscription/blob/main/imgs/HMM.png">
 </p>
 <p align="center">
Fig.2 Example of abstracted Hidden Markov Model Structure
</p>
<p align="center">
  <img src="https://github.com/hsato1/MonoTranscription/blob/main/imgs/HMM_unabstracted.png">
</p>

<p align="center">
Fig.3 Example of Unabstracted Hidden Markov Model Structure
<\p>

* In order to address this issue, we uses Hidden Markov Model Structure with State with certain note length *L* so that we consider sequence of audio for some amount of time as musical note. 

### Dynamic Programming 
* For this recognition task, we utilize particular graph structure called **trellis** and we traverse this graph structure characterized with log probability of matching template using technique called **dynamic programming**.


## Result
<p align="center">
  <img src="https://github.com/hsato1/MonoTranscription/blob/main/imgs/recogv2.png">
</p>

<p align="center">
Fig.4 Plot of recognized MIDI values with the given recognition algorithm 
<\p>
<p align="center">
  <img src="https://github.com/hsato1/MonoTranscription/blob/main/imgs/recogv1.png">
</p>
<p align="center">
 Fig. 5 Plot of recognized pitch in comparison to the correct pitch Midi values (ploted in green)
</p>


