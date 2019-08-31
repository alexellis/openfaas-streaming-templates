#!/bin/sh

export nano=`date +%s%N`

export OUT=/tmp/$nano.mov
cat - > ${OUT}

# ffmpeg  -loglevel panic -i ${OUT} -r 10 -ss 15 -t 20 -vf scale=160:90 - -hide_banner
# ffmpeg -i ${OUT} -r 10 -ss 15 -t 20 -vf scale=iw*.5:ih*.5 -pix_fmt rgb24 -r 20 -f gif -
ffmpeg -i ${OUT} -vf scale=iw*.5:ih*.5 -pix_fmt rgb24 -r 5 -f gif -hide_banner pipe:1

rm ${OUT}
