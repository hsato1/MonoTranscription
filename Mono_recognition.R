# library needed for audio 
library(tuneR)			
tuneR::setWavPlayer('/usr/bin/afplay')

w = readWave("/Users/satouhiroshiki/Desktop/IndianaUniversity/MIRP/Project/ss0.wav")
bits = w@bit
sr = w@samp.rate
y = w@left                         
#y = y[60673:length(y)]  
u = Wave(y, samp.rate = sr, bit=16)


d_maj = c(50,52,54,55,57,59,61)
d_maj_two_oct = d_maj + 12
diatonic = c(0,d_maj,d_maj_two_oct)

# FFT length
N = 512*2
# N = 512
# number of sample points to advance per frame.
skiplen = N/2

# parameters needed for creating pitch template.
templates = matrix(0,d_maj_two_oct[-1],N/2)
frames = floor(length(y)/skiplen)
wid =0.5   # how permissive the pitch is 
decay = 4 

tplt = matrix(.01,length(pitches)+ 1,N/2)

# windowing function to get cleaner spectrum energy.
t = seq(from=0,by=2*pi/N,length=N)     
win = (1 + cos(t-pi))/2      

rest_ = 1*skiplen + 1
grain_rest = y[rest_:(rest_+N-1)]
rest_ = win*grain_rest
R = fft(rest_)
# this is rest model.
rest_mod = Mod(R[1:(N/2)])/sum(Mod(R))

# creating pitch template.
for (j in 1:length(pitches)) {
  print(j)
  f = 440*2^((pitches[j]-69)/12)
  #f = 440*2^((pitches[j]-69)/)
  print(pitches[j])
  b = f*N/sr
  for (h in 1:15) {
    if (pitches[j] == 0) {
      tplt[j,] = rest_mod
    } else {
      tplt[j,] = tplt[j,] + 2^(-h/decay)*dnorm(1:(N/2),mean=(b*h),sd = wid)
    }            # lop is the rest = flat template
    #tplt[j,] = tplt[j,] + 2^(-h/decay)*dnorm(1:(N/2),mean=(b*h),sd = wid)
  }
  tplt[j,] = tplt[j,]/sum(tplt[j,])
  plot(tplt[j,],type='l')
  #scan()                            # wait for human to type key
}


bpm = 90


# sample rate 8,000 khz
# 90 bpm -> 1.5 bps
# 1.5 b/sec => 2/3 sec for 1 beat 
# N = 512 for FFT, skip is 256 / N = 512, 
# entire_duration_sample_num
# N_frames = (entire_duration_sample_num) / skip_length 
N_frames = length(y) / skiplen
duration_t = length(y) / sr
len_frame = duration_t/N_frames

# duration (in seconds) = length(y) / sample_rate
# each frame represents (in seconds) = duration / frames
# number of frames per second = 1/each frame represents (in seconds)
# 1.5 b/sec => 2/3 sec for 1 beat  
# number of frames per second *(2/3) for number of frames per beat.
# energy_threshold. scoring function, sum up the square of fft. 
L = 9

states = L*length(pitches)

lat = matrix(0,states,frames)  # the array that holds the dynamic programming scores
best = matrix(0,states,frames) # the array of best predecessors.  


# precomputed values. creating the other contribution in terms of whether the frame we are observing is a rest or singing.
rest_ = 2*skiplen + 1
singing = 74*skiplen + 1
silent = y[rest_:(rest_+N-1)]
#silent_feat = (silent^2)
silent_feat = abs(silent)
#silent_feat = Mod(fft(win*silent))/N
grain_singing = y[singing:(singing+N-1)]
#singing_feat = (grain_singing^2)
singing_feat = abs(grain_singing)
#singing_feat = Mod(fft(win*grain_singing))/N
silent_mean = mean(silent_feat)
singing_mean = mean(singing_feat)
silent_std = sd(silent_feat)
singing_sd = sd(singing_feat)
arr = rep(0,frames)

log_score_silent = c(0)
log_score_sing = c(0)


rests = rep(0,frames)

for (j in 2:frames){                # main loop of program (for all frames)
  s = (j-1)*skiplen +1               # start of frame
  grain = win*y[s:(s+N-1)]           # the frame
  #audio_feat = win*sum(y[s:(s+N-1)]^2) /N
  #print(s)
  # maybe standardlize the modulus.to not to account the louder frame more than the softer frames.
  Y = fft(grain)                     # take the fft
  w = Mod(Y) / max(Mod(Y))
  #w = w[10:length(w)]
  log_score = 0
  
  if (j != frames){
    rest_score = sum(log(rest_mod)*w[1:(N/2)])
    rests[j] = rest_score
  }
  # if (j != frames){
  #  # audio_feat = sum(y[s:(s+N-1)]^2)/N
  #   audio_feat = sum(abs(y[s:(s+N-1)]))/N
  #   #audio_feat = sum(Mod(fft(y[s:(s+N-1)]))/N)
  #   log_score_sing = c(log_score_sing,log(dnorm(audio_feat,mean=singing_mean,sd=singing_sd)))
  #   log_score_silent = c(log_score_silent,log(dnorm(audio_feat,mean=silent_mean,sd=silent_std)))
  #   #print(dnorm(audio_feat,mean = silent_mean,sd=silent_std))
  #   #print(dnorm(audio_feat,mean=singing_mean,sd=singing_sd))
  #   if (dnorm(audio_feat,mean = silent_mean,sd=silent_std) > dnorm(audio_feat,mean=singing_mean,sd=singing_sd)){
  #     # which means it's silent
  # 
  #     #print(0)
  #     log_score = log(dnorm(audio_feat,mean = silent_mean,sd=silent_std))
  #   } else{
  #     #print(1)
  #    # arr[j] = 1
  #    log_score = log(dnorm(audio_feat,mean=singing_mean,sd=singing_sd))
  #   }
  # 
  # }
  
  for (i in 1:states) {        # for all states (L for each note)
    r = (i-1) %% L
    cur = floor((i-1) / L)
    if (r == (L-1)) pred = c(i,i-1)
    if (r > 0 & r < (L-1)) pred = i-1
    if (r == 0) {
      cur = floor(i / L)
      pred = 0:(length(pitches)-1)
      pred = pred[pred != cur]
      pred = pred*L + (L-1) + 1
      # print(pred)
    }
    lat[i,j] = -Inf                  
    for (ii in pred) if (lat[ii,j-1] > lat[i,j]) { # if predecessor better than best so far ..
      lat[i,j] = lat[ii,j-1]                       # dynamic programming score
      best[i,j] = ii                               # remember optimal predecessor
    }
    #if (j == 180){
    # print(sum(log(tplt[cur+1,])*w[1:(N/2)]))
    #}
    #print( sum(log(tplt[cur+1,])*w[1:(N/2)]))
    lat[i,j] = lat[i,j] + sum(log(tplt[cur+1,])*w[1:(N/2)]) + rest_score  #+ log_score
    #lat[i,j] = lat[i,j] + sum(log(tplt[cur+1,])*Mod(Y[1:(N/2)]))   # score all notes by data model
    # prior if the previous state is same as current state, -> Reward that, if it is different, then we want to 
    # penalize it. Prior * likelihood. 
  }
}

# bouncing the log_silent and log_singing score

#png("/Users/satouhiroshiki/Desktop/IndianaUniversity/MIRP/Project/log_score.png")
#plot(log_score_sing,type='l',
#     main="Log likelihood/Model matching with silence and singing by frames",
#     xlab="Frames",ylab="Log-likelihood")
#lines(log_score_silent,col=2)
#dev.off()

hat = rep(0,frames)                  # the optimal parse
hat[frames] = length(list)           # know the optimal last note
for (j in frames:2)  hat[j-1] = best[hat[j],j] # trace back optimal parse



recog = pitches[1+floor((hat-1)/L)]

correct_one = recog

for (i in (length(recog) - 9):(length(recog))){
  correct_one[i] = 0
}


### bouncing the result plot.
png("/Users/satouhiroshiki/Desktop/IndianaUniversity/MIRP/Project/recogv2.png")
plot(recog,main="Transcribed Midi Pitches",
     xlab="Frames",ylab="Midi Values")
dev.off()
png("/Users/satouhiroshiki/Desktop/IndianaUniversity/MIRP/Project/recogv1.png")
plot(recog,main="Transcribed Midi Pitches",
     xlab="Frames",ylab="Midi Values")
points(correct_one,col=3)
dev.off()


t = 0

for (i in 1:frames) { 
  v = 2*pi*440.*2^((recog[i]-69)/12)/sr
  t = c(t,rep(v,skiplen))
}
ph = cumsum(t);
z = sin(ph) + sin(2*ph) + sin(3*ph);
u = Wave(round((2^9)*z), samp.rate = sr, bit=16)   # make wave struct for the recognized audio.
writeWave(u,filename = "/Users/satouhiroshiki/Desktop/IndianaUniversity/MIRP/Project/transcribed_audio_n_512.wav")
play(u)   







