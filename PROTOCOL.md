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

| Payload | OP code | Action | Description                |
|---------|---------|--------|----------------------------|
| HELLO   | 1       | recv   | Send when you're connected |

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

## Connecting
Nerve listens to the port 8880 by default. You can customize it in `config/config.exs`. The websocket listens to `/`

Once you're connected to Nerve, you'll get a HELLO payload that'll include heartbeat interval and debug information
such as internal worker id. This should be logged on application logs to make searching through logs easy when there is
a lot of load on Nerve, as worker id is logged.
