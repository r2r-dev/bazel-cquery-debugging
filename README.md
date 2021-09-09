# bazel-cquery-debugging

## Inspect target(s) and parse output using `jq` and `fx`
```
nix-shell
bazel cquery //main:all --output=starlark --starlark:file queries/inspect.bzl | jq -s add | fx
```
