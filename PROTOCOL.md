# Nerve protocol documentation

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

| Payload       | OP code | Action | Description                                     |
|---------------|---------|--------|-------------------------------------------------|
| HELLO         | 0       | recv   | Sent when you're connected                      |
| IDENTIFY      | 1       | send   | Authenticates and identifies the current client |
| WELCOME       | 2       | recv   | Sent when you're authenticated and identified   |
| ABOUT_ME      | 3       | send   | Used to update metadata representing the client |
| DISPATCH      | 4       | both   | Used to dispatch events                         |
| HEARTBEAT     | 5       | recv   | heart...                                        |
| HEARTBEAT_ACK | 6       | recv   | ...beat?                                        |
| GO_AWAY       | 7       | recv   | go away. Clients should try reconnect           |

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

### Go away
```json
{
  "op": 7,
  "d": "go away."
}
```

## Connecting
Nerve listens to the port 8880 by default. You can customize it in `config/config.exs`. The websocket listens to `/`

Once you're connected to Nerve, you'll get a HELLO payload that'll include heartbeat interval and debug information
such as internal worker id. This should be logged on application logs to make searching through logs easy when there is
a lot of load on Nerve, as worker id is logged.
