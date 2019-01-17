# motion-ffmpeg-with-audio
ffmpeg write non-stop ip cam stream and motion detected action and start start_motion.sh. When action is end motion start stop_motion.sh which cut our movies and sava that fragment to another folder.

#############
Setup
#############

apt install motion 

disable motion record movie at motion.conf

add to camera1.conf

  on_event_start motion.sh 1 #(where 1 is number of cam)
  
  on_event_end stop_motion.sh 1 #(where 1 is number of cam)
  
Start ffmpeg (mkdir -p /tmp/video/cam-1/ && ffmpeg -use_wallclock_as_timestamps 1 -i rtsp://URL -strict -2 -fflags +genpts -vsync 1 -async 1 -vcodec copy -f segment -segment_time 3600 -segment_atclocktime 1 -reset_timestamps 1 -strftime 1 "/tmp/video/cam-1/%s.ts") # Filename is important!!! /opt/video/%s.ts !!!

start motion (motion)


