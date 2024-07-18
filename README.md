# Simple Client Server Chat


A Simple one to one chat between a client and a server, meant to be run locally with bidirectional communication sockets.

Some rules:
- The server is waiting for incoming client connections
- When a client terminates a connection, the server continues to wait for another client
- From both side, each message automatically sends back an aknowledgment message with a roundtrip information
- Message are transmitted over the network with each parameter separated by `|`. The first parameter represents the type of message (i.e `SEND`, `ACK`).
```bash
   type|sender|body|timestamp

   # Examples:
   # SEND|bob|how are you|1720619776
   # ACK|alice|good|1720619776

   #`timestamp` allowing to calculate the `roundtrip time`
```

The application can be start on either `client` or `server` mode.

## How to start

As the project is build with `dune`, it needs to be built with

```bash
dune build
```

Optionally, there is the possibility to run the build followed by the code formatting with the script `build.sh`:
```bash
./build.sh
```

Once the build is done, the application can be executed either in:

- Server mode with parameter `s`:
```bash
dune exec simpleClientServerChat s
```

- Client mode with parameter `c`:
```bash
dune exec simpleClientServerChat c
```

There is the option to pass a client name, by default it will be `"Unknown"`
```
dune exec simpleClientServerChat c "Bob"
```

## Some technical aspects
- It bas been chosen to use the library `Lwt` in order to take benefit of `asynchronous non blocking operations aspect`.
- The UI is simply the `console` application, but the application uses the library [Spectrum](https://github.com/anentropic/ocaml-spectrum) to enhance a bit the logs and messages with colors.

## Room for improvements
The code that handles messages is directly printing into the `console`, but it would have been better to pass callbacks (`onDisconnected`, `onSent` etc), to improve the decoupling between
the UI and the event processings.
