# motion-ffmpeg-with-audio
ffmpeg write non-stop ip cam stream, motion detected scene change and start start_motion.sh. When motion is end it start stop_motion.sh which cut our movies and sava that fragment to another folder

#############
Setup
#############

apt install motion 

disable motion record movie at motion.conf

add to camera1.conf

  on_event_start motion.sh
  
  on_event_end stop_motion.sh


