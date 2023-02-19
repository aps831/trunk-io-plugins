# Trunk IO Plugins

This repository defines plugins for use with [trunk](https://trunk.io/).

## Add plugin repository

To add the plugin repository run:

```bash
trunk plugins add --id aps831 https://github.com/aps831/trunk-io-plugins 1.1.0
```

## Enabling a supported linter

There are no linters defined.

## Enabling a supported action

| Action        | Description                                    |
| ------------- | ---------------------------------------------- |
| commit-branch | Warn when committing to the 'master' branch    |
| commitizen    | Ensure commit messages are correctly formatted |

```bash
trunk actions enable {action}
```
