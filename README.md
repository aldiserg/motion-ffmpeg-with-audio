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
  
Start ffmpeg (-use_wallclock_as_timestamps 1 -i rtsp://ip_to_cam -strict -2 -fflags +genpts -vsync 1 -async 1 -vcodec copy -f segment -segment_time 3600 -segment_atclocktime 1 -reset_timestamps 1 -strftime 1 "/opt/video/%s.ts"") # Filename is important!!! /opt/video/%s.ts !!!

start motion (motion)


