#!/bin/bash
### ./stop_motion.sh 1
################################
# Variables
################################
cam_number="$1" #(example: 1)
today=`/bin/date +%Y-%m-%d`
captured_file_name=`/bin/date +%H-%M-%S`
captured_movie_dir="/opt/captured/$today/cam-$cam_number"
stream_movie_dir="/tmp/video/cam-$cam_number"
tmp_movie_dir="/tmp/tmpvideo/cam-$cam_number"
# video quality after cut (0 - 32 highest to lowest)
video_quality="10"
# deflection - count of sec before and after motion has been detected/ended
deflection=4
movie_format=".ts"

################################
# Script start
################################
mkdir -p $captured_movie_dir $tmp_movie_dir
end_motion=`/bin/date +%s`
start_motion=`cat /tmp/start_motion_cam-$cam_number`

movie_timestamp=`ls -lrth $stream_movie_dir/ | awk {'print $9'} | sed 's/\./ /g' | sed 's/_/ /g' | awk {'print $1'} | tail -n 1`
movie_delay=`echo $end_motion - $start_motion + $deflection | bc`
movie_start_motion=`echo $start_motion - $movie_timestamp - $deflection | bc`

array=(`ls $stream_movie_dir`)
len=${#array[*]}
if [[ $len -eq 1 ]]
then
    echo "Start cutting from movie"
    ffmpeg -i "$stream_movie_dir/$movie_timestamp$movie_format" -ss $movie_start_motion -t $movie_delay -qscale $video_quality "$captured_movie_dir/$captured_
file_name$movie_format" 2> /dev/null
    echo "New captured movie $captured_file_name$movie_format from $movie_timestamp$movie_format (since $movie_start_motion sec with duration $movie_delay)"
else
    for (( i=1; i<$len; i++)) do
    {
        movie=`echo ${array[$i-1]} | sed 's/\./ /g' | awk {'print $1'}`
        movie1=`echo ${array[$i]} | sed 's/\./ /g' | awk {'print $1'} `
        if [[ $start_motion -lt $movie1 ]] && [[ $movie1 -le $end_motion ]]
        then
            movie_start_motion=`echo $start_motion - $movie - $deflection | bc`
            period_to_sec_movie=`echo $end_motion - $movie1 + $deflection | bc`
            echo "Start cutting from movie"
            ffmpeg -i "$stream_movie_dir/$movie$movie_format" -ss $movie_start_motion -qscale 0 "$tmp_movie_dir/part1$movie_format" 2> /dev/null
            ffmpeg -i "$stream_movie_dir/$movie1$movie_format" -ss 0 -t $period_to_sec_movie  -qscale 0 "$tmp_movie_dir/part2$movie_format" 2> /dev/null
            ffmpeg -i "concat:$tmp_movie_dir/part1$movie_format|$tmp_movie_dir/part2$movie_format" -qscale 0 "$captured_movie_dir/$captured_file_name$movie_fo
rmat" 2> /dev/null
            echo "New captureed movie $captured_file_name$movie_format from $movie$movie_format and $movie1$movie_format (since $movie_start_motion sec to the
 end for first movie and since start to $period_to_sec_movie sec for second movie)"
            echo "Deleting temp files"
            rm -rf $tmp_movie_dir/part1$movie_format $tmp_movie_dir/part2$movie_format $stream_movie_dir/$movie$movie_format
            echo "Deleted"
        elif [[ $start_motion -ge $movie1 ]] && [[ $movie1 -le $end_motion ]]
        then
            echo "Newer movie is used ($movie1)"
            ffmpeg -i "$stream_movie_dir/$movie1$movie_format" -ss $movie_start_motion -t $movie_delay -qscale $video_quality "$captured_movie_dir/$captured_f
ile_name$movie_format" 2> /dev/null
            echo "Cutting is over"
            echo "Delete old movie ($movie)"
            rm -rf "$stream_movie_dir/$movie$movie_format"
            echo "Deleted"
        fi
    }
done
fi
echo "Done"

