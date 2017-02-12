#!/bin/bash

# check for correct # of parameters
if [ "$#" -ne 3 ]
  then
    echo "Illegal number of parameters"
    exit
fi

# used to sort an array
function mysort { for i in ${unsorted_array[@]}; do echo "$i"; done | sort -n; }

# get current directory so we can return
pwd > currentdir

# copy input to temp file, and then cut it up at input interval
cp $1 ~/apps/chopshop/temp/temp.mp4
cd ~/apps/chopshop/temp
ffmpeg -i temp.mp4 -map 0 -c copy -f segment -segment_time $2 -reset_timestamps 1 %02d.mp4
rm temp.mp4

# remove last file (it will not be correct time interval)
numfiles=(*)
numfiles=${#numfiles[@]}
(( numfiles-- ))
rm $numfiles.mp4

# randomly rename files
for fname in *.mp4
do
   mv "$fname" $RANDOM.mp4
done
a=1

# sequentially rename files
for i in *.mp4
do
  new=$(printf "%02d.mp4" "$a")
  mv -- "$i" "$new"
  let a=a+1
done

# store filenames in array &
# create concat text file for ffmpeg
unsorted_array=(*)
sorted_array=( $(mysort) )

for i in "${sorted_array[@]}"
do
  index=$i
  templine="file '$index'"
  echo $templine >> textfile.txt
done

# merge files
ffmpeg -f concat -i textfile.txt -c copy -fflags +genpts merged.mp4

# clean up the trash
cp ~/apps/chopshop/temp/merged.mp4 ~/Desktop/$3.mp4
cd ~/apps/chopshop/temp
rm -rf ./*.*
cd $currentdir

clear
# open finished file
echo "FINISHED!"
open ~/Desktop/$3.mp4