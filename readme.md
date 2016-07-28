logbt
-----
Simple wrapper for running a backtrace when a program segfaults. Requires `gdb`.

Before:

```sh
node index.js
```

After:

```sh
logbt node index.js
```

### Our usage

We use this from within Docker containers to get a backtrace and dump it to `stdout`.
