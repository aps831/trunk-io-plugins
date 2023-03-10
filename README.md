# Trunk IO Plugins

This repository defines plugins for use with [trunk](https://trunk.io/).

## Add plugin repository

To add the plugin repository run:

```bash
trunk plugins add --id aps831 https://github.com/aps831/trunk-io-plugins 2.0.0
```

## Enabling a supported linter

There are no linters defined.

## Enabling a supported action

| Action                         | Description                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| commit-branch                  | Warn when committing to the 'master' branch                       |
| commitizen                     | **DEPRECATED** Ensure commit messages are correctly formatted     |
| commitizen-prompt-conventional | Prompt for commit message using conventional-changelog style      |
| commitizen-tools-check         | Ensure commit messages are correctly formatted                    |
| hardcoding-check               | Check correctnes of hardcoded values defined in `hardcoding.json` |

To add an action, run:

```bash
trunk actions enable ${action}
```
