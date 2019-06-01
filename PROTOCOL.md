# Nerve protocol documentation

NOTE: This documents the internal protocol of the local socket fired up on port 6669.

## Payloads

### Base format
```json
{
  "op": "int",
  "e": "event name, only sent with DISPATCH payloads",
  "d": "actual data"
}
```

### Summary
This table lists all payloads send and received by Nerve. Each payload have more detailed information below.

| Payload       | OP code | Action | Description                                                           |
|---------------|---------|--------|-----------------------------------------------------------------------|
| HELLO         | 0       | recv   | Sent when you're connected                                            |
| IDENTIFY      | 1       | send   | Authenticates and identifies the current client                       |
| WELCOME       | 2       | recv   | Sent when you're authenticated and identified                         |
| HEARTBEAT     | 3       | send   | heart...                                                              |
| HEARTBEAT_ACK | 4       | recv   | ...beat?                                                              |
| GO_AWAY       | 5       | recv   | go away. Clients should try reconnect                                 |
| NO_U_TBH      | 6       | recv   | You did an oopsie that Nerve didn't liked. You got on their nerves... |
| ABOUT_ME      | 7       | send   | Used to update metadata representing the client                       |
| DISPATCH      | 8       | both   | Used to dispatch events                                               |

### Hello
```json
{
  "op": 0,
  "d": {
    "heartbeat_interval": "int",
    "worker": "nerve-xxxxxx"
  }
}
```

### Identify
```json
{
  "op": 1,
  "d": {
    "app_name": "Application name, used as main key for querying a client",
    "client_id": "Unique ID used for a *single* connection, used to handle reconnecting",
    "password": "Authentication token configured"
  }
}
```

### Welcome
```json
{
  "op": 1,
  "d": "hi i'm dad"
}
```

### Go away
```json
{
  "op": 7,
  "d": "go away."
}
```

## Connecting
Nerve listens to the port 6669 by default. You can customize it in `config/config.exs`. The websocket listens to `/`

Once you're connected to Nerve, you'll get a HELLO payload that'll include heartbeat interval and debug information
such as internal worker id. This should be logged on application logs to make searching through logs easy when there is
a lot of load on Nerve, as worker id is logged.
