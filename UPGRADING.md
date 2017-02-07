# Upgrading

This file contains instructions for users of `logbt` who are upgrading from
one version to another.

See also the [Changelog](CHANGELOG.md).

## Upgrading from *v1.x* to *v2.x*

Previously you ran `logbt` like:

```
sudo logbt <your program>
```

Now in >= 2.x logbt has multiple modes. First you run:

```
sudo logbt --setup
```

If running docker, this should be run on the host (not the container, unless the container is run in `--privileged` mode).

Then you run:

```
logbt -- <your program>
```

See the [README for more detailed usage info](readme.md#usage)