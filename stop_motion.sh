#!/bin/bash
################################
# Variables
################################
captured_movie_dir="/opt/captured"
stream_movie_dir="/opt/video"
tmp_movie_dir="/opt/part"
# deflection - count of sec before and after motion has been detected/ended
deflection=4
movie_format=".ts"

################################
# Script start
################################
#end_motion=`/bin/date +%Y%m%d%H:%M:%S`
end_motion=`/bin/date +%s`
start_motion=`cat /opt/start_motion`

movie_timestamp=`ls -lrth $stream_movie_dir/ | awk {'print $9'} | sed 's/\./ /g' | sed 's/_/ /g' | awk {'print $1'} | tail -n 1`
movie_delay=`echo $end_motion - $start_motion + $deflection | bc`
movie_start_motion=`echo $start_motion - $movie_timestamp - $deflection | bc`
newfile=`/bin/date +%Y%m%d_%H_%M_%S`

array=(`ls $stream_movie_dir`)
len=${#array[*]}
if [[ $len -eq 1 ]]
then
    ffmpeg -i "$stream_movie_dir/$movie_timestamp$movie_format" -ss $movie_start_motion -t $movie_delay -qscale 0 "$captured_movie_dir/$newfile$movie_format"
2> /dev/null
    echo "New captured movie $newfile$movie_format from $movie_timestamp$movie_format (since $movie_start_motion sec with duration $movie_delay)"
else
    for (( i=1; i<$len; i++)) do
    {
        movie=`echo ${array[$i-1]} | sed 's/\./ /g' | awk {'print $1'}`
        movie1=`echo ${array[$i]} | sed 's/\./ /g' | awk {'print $1'} `
        if [[ $movie -lt $start_motion ]] && [[ $movie1 -le $end_motion ]]
        then
            movie_start_motion=`echo $start_motion - $movie - $deflection | bc`
            period_to_sec_movie=`echo $end_motion - $movie1 + $deflection | bc`
            echo "New captureed movie $newfile$movie_format from $movie$movie_format and $movie1$movie_format (since $movie_start_motion sec to the end for fi
rst movie and since start to $period_to_sec_movie sec for second movie)"
            ffmpeg -i "$stream_movie_dir/$movie$movie_format" -ss $movie_start_motion -qscale 0  "$tmp_movie_dir/part1$movie_format" 2> /dev/null
            ffmpeg -i "$stream_movie_dir/$movie1$movie_format" -ss 0 -t $period_to_sec_movie -qscale 0  "$tmp_movie_dir/part2$movie_format" 2> /dev/null
            ffmpeg -f concat -safe 0 -i <(for f in $tmp_movie_dir/*$movie_format; do echo "file '$f'"; done)  -c copy "$captured_movie_dir/$newfile$movie_form
at" 2> /dev/null
            echo "Deleting temp files"
            rm -rf $tmp_movie_dir/part1$movie_format $tmp_movie_dir/part2$movie_format $stream_movie_dir/$movie$movie_format

        elif [[ $movie1 -lt $start_motion ]] && [[ $movie1 -lt $end_motion ]]
        then
            echo "Older movie is used ($movie)"
            ffmpeg -i "$stream_movie_dir/$movie1$movie_format" -ss $movie_start_motion -t $movie_delay -qscale 0 "$captured_movie_dir/$newfile$movie_format" 2
> /dev/null
            echo "delete old movie ($movie)"
            rm -rf "$stream_movie_dir/$movie$movie_format"
        fi
    }
done
fi
