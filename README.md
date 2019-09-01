## openfaas-streaming-templates

Examples of `of-watchdog` from OpenFaaS used for streaming data with:

* Node.js 10 - to stream responses, either text or big blobs of binary data.
* Bash - to execute arbitrary commands and bash as a "HTTP" API
* ffmpeg - to produce a gif from a `mov` QuickTime file

This is a real-world example requested by Luca Morandini, Data Architect at AURIN, University of Melbourne.

The example was provided for free as a gesture of good will by [Alex Ellis of OpenFaaS Ltd](https://www.alexellis.io/).

## The examples

Whilst the data does stream, there are buffers in Golang's i/o packages set at around 32-64KB, which means that you may print out `1-10000` via STDOUT, but the first output your client may receive is 1-6770, followed by the remainder up to 10000.

### Example with Node.js

* Create new

```
$ faas-cli new --lang node-streaming stream-this
```

* Add code with timer

```javascript
"use strict"

module.exports = (context, callback) => {

    var count = 0;
    var max = 8000;

    var timer = setInterval(function() {
        process.stdout.write("Message " + count.toString()+"\n");
        count++;

        if(count > max) {
            clearInterval(timer);
            callback(undefined, undefined);
        }
    }, 1);
}
```

* Set the timeout to be more generous

```yaml
version: 1.0
provider:
  name: openfaas
  gateway: http://127.0.0.1:8080
functions:
  stream-this:
    lang: node-streaming
    handler: ./stream-this
    image: stream-this:latest
    environment:
      write_timeout: 1m
      read_timeout: 1m
      exec_timeout: 1m
```

* Deploy

```
faas-cli up -f stream-this
```

* Invoke:

```sh
curl http://127.0.0.1:8080/function/stream-this
Message 0
Message 1
Message 2
Message 3
Message 4
Message 5
Message 6
Message 7
Message 8
Message 9
Message 10
```

Generally, I saw this take 13s, with the first buffer printing at 2500, 2nd at around 5000 and finally the 8000 message.

Execute via Docker without the OpenFaaS gateway:

```sh
docker run --name stream-this -d -p 8000:8000 stream-this

curl localhost:8000
Message 0
Message 1
Message 2
Message 3
Message 4
Message 5
Message 6
Message 7
Message 8
Message 9
Message 10
```


### Example with bash:

```
faas-cli new --lang bash-streaming printr
```

* Edit `printr/handler.sh`

```
#!/bin/sh

for i in $(seq 1 10000) ; do  sleep 0.001 &&  echo $i; done
```

* Now set a bigger timeout

```yaml
version: 1.0
provider:
  name: openfaas
  gateway: http://127.0.0.1:8080
functions:
  printr:
    lang: bash-streaming
    handler: ./printr
    image: printr:latest
    environment:
      write_timeout: 1m
      read_timeout: 1m
      exec_timeout: 1m

```

Output:

```
time curl -i http://127.0.0.1:8080/function/printr
HTTP/1.1 200 OK
Content-Length: 292
Content-Type: application/octet-stream
Date: Sat, 31 Aug 2019 09:12:37 GMT
X-Call-Id: cc54c283-fc56-4c4b-9fbe-70638eb1a6dc
X-Start-Time: 1567242756314135880

1
2
3
...
98
99
100
```
### Example with ffmpeg

See the ffmpeg.yml file and `./ffmpeg/handler.sh` for how this works.

* Take a short video with the webcam on your MacBook Pro
* Deploy the ffmpeg function to your OpenFaaS installation

```
faas-cli up -f ffmpeg --build-arg ADDITIONAL_PKG=ffmpeg
```

Example of the script:

```sh
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
```

* Invoke the function
* Review your gif and share with your friends on Twitter or with [@alexellisuk](https://twitter.com/alexellisuk)

```sh
export OPENFAAS_URL=http://127.0.0.1:8080

curl -SLsf http://$OPENFAAS_URL/function/ffmpeg --data-binary @$HOME/Desktop/my-video.mov > my-gif.gif
```

You can also limit concurrency by adding `max_inflight=1` to only allow one video to be processed at once, or up the value to whatever you feel is a sane limit like `max_inflight=10`.
