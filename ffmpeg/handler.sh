#!/bin/sh

# Create a temporary filename
export nano=`date +%s%N`

export OUT=/tmp/$nano.mov

# Save stdin to a temp file
cat - > ${OUT}

# Scale down to 50%
# Use format rgb24
# Reduce to 5 FPS to reduce the size
# Use "gif" as output format
# Use "pipe:1" (STDOUT) to write the binary data
ffmpeg -i ${OUT} -vf scale=iw*.5:ih*.5 -pix_fmt rgb24 -r 5 -f gif -hide_banner pipe:1

# After printing to stdout, the client has received the data via streaming
# Now we delete the temporary file
rm ${OUT}
