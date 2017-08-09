# Contributing

## Documentation

## Releasing

1) Ensure the tests are passing

2) Update:

- The version in:
 - ./bin/logbt line 9
 - 2 places in the "Install" section of the readme.md
- CHANGELOG.md

3) Push changes to github

```
git commit -a -m "bump to v1.2.0"
```

4) Git tag

```bash
git tag v1.2.0 -a -m "v1.2.0"
git push --tags
```
