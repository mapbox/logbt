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

### Install

```sh
curl -sL https://github.com/mapbox/logbt/archive/v1.0.0.tar.gz | tar --gunzip --extract --strip-components=1 --exclude=readme.md --directory=/usr/local
```

### Our usage

We use this from within Docker containers to get a backtrace and dump it to `stdout`.
