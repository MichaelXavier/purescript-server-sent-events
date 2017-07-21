# Run this Example

This requires `npm`, `bower` and a working installation of
Purescript. It will compile the Purescript code in `Main.purs`
and start a server with a SSE endpoint.

```
$ npm install
$ bower install
$ npm run example
$ npm run server
```

Open `http://localhost:8000` in your browser and open the Javascript
console. Use `curl` or similar to post to the server and the events
should be shown on the console.

```
$ curl -X POST localhost:8000/ping
$ curl -X POST localhost:8000/event/boop
$ curl -X POST localhost:8000/event/message
```
