## node-streaming

Example of of-watchdog using Node.js and the streaming mode

Requested by Luca Morandini, Data Architect at AURIN, University of Melbourne. Designed at no cost by Alex Ellis of OpenFaaS Ltd.

* Create new

```
$ faas-cli new --lang node-streaming stream-this
```

* Add code with timer

```javascript
"use strict"

module.exports = (context, callback) => {

    var count = 0;
    var timer = setInterval(function() {
        console.log("Message " + count.toString());
        count++;

        if(count > 10) {
            clearInterval(timer);
            callback(undefined, undefined);
        }
    }, 500);
}
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
