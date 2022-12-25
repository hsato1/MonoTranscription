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
![template_example](https://user-images.githubusercontent.com/71889206/209474062-fdceaf13-6db6-4bf7-a796-21b80d921308.png)
|:--:| 
| *Spectra Diagram of pitch template* |
* Fourier Transform is a function which decompose complex waveform into a summation of simpler sine/cosine waves. Each wave component can be described with Modulous and Phase. 
* For our transcription purpose, we focused on the Modulus information of pitched sound and we model the spectra of each - we create the pitch template as reference to match the actual real-audio spectra.
* In order to implement this transcription task, we use log probability matching of given frame FFT spectra and templates of pitched sound.

### Hidden Markov Model Structure
#### **Even we can match and attempt to find the best fitting template frame by frame. We should not be calling just one grain of audio, a note. Why??**
#### A. Because one grain of audio is too short to be considered a note, if we do frame by frame recognition without any restriction. Result may be much noisier. For example, for ss0.wav, with N = 1024, hop size of N/2, each grain of audio is 0.064 seconds. This is too short to be recognized as a note.
![HMM](https://user-images.githubusercontent.com/71889206/209474110-aa2e6fae-6606-44a1-b3b0-d409841c91bc.png)
|:--:| 
| *Example of Abstracted Hidden Markov Model Structure* |
![HMM_unabstracted](https://user-images.githubusercontent.com/71889206/209474099-4fa18240-e709-40af-90e8-f74c65622262.png)
|:--:| 
| *Example of Unabstracted Hidden Markov Model Structure* |
* In order to address this issue, we uses Hidden Markov Model Structure with State with certain note length *L* so that we consider sequence of audio for some amount of time as musical note. 

### Dynamic Programming 
* For this recognition task, we utilize particular graph structure called **trellis** and we traverse this graph structure characterized with log probability of matching template using technique called **dynamic programming**.


## Result

![recogv2](https://user-images.githubusercontent.com/71889206/209474419-57b642d2-55cc-474f-b6af-a6a74eb87831.png)
<p align="center">
Plot of recognized pitch with the given recognition algorithm was:
</p>

![recogv1](https://user-images.githubusercontent.com/71889206/209474463-d1ee3bd2-cb60-48ba-aa52-2bb71de3b1c1.png)
<p align="center">
 Plot of recognized pitch in comparison to the correct pitch Midi values (ploted in green)
</p>


