## node-streaming

Example of of-watchdog using Node.js and the streaming mode

Requested by Luca Morandini, Data Architect at AURIN, University of Melbourne. Designed at no cost by Alex Ellis of OpenFaaS Ltd.

## Notes

Whilst the data does stream, there are buffers in Golang's i/o packages set at around 32-64KB, which means that you may print out `1-10000` via STDOUT, but the first output your client may receive is 1-6770, followed by the remainder up to 10000.

## Example

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


Example with bash:

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
