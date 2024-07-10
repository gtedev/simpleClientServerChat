# Simple Client Server Chat


A Simple one to one chat between a client and a server, meant to be run locally with bidirectional communication with sockets.

The application can be start on either client or server mode.

## How to start

As the project is build with `dune`, the project needs to be built with

```bash
dune build
```

Optionally, if the code has been edited, there is also the possibility to run the script `build.sh`, which runs the build and the code formatting:
```bash
./build.sh
```

Then, the application can be executed either in:

- Server mode with parameter `s`:
```bash
dune exec simpleClientServerChat s
```

- Client mode with parameter `c`:
```bash
dune exec simpleClientServerChat c
```

It is possible optionally to pass a client name,by default it will be `"Unknown"`
```
dune exec simpleClientServerChat c "Bob"
```

## Some technical aspects
- It bas been chosen to use the library `Lwt` in order to take benefit of `asynchronous non blocking operations aspect`.
- The UI is simply the `console` application, but the application uses the library `spectrum` to enhance a bit the logs and messages with colors while being written in the console.

## Room for improvements
The code that handles messages is directly printing into the `console`, but it would have been better to pass callbacks (`onDisconnected`, `onSent` etc), to improve the decoupling between
the UI and the event processings.
