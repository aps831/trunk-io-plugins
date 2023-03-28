# Trunk IO Plugins

This repository defines plugins for use with [trunk](https://trunk.io/).

## Add plugin repository

To add the plugin repository run:

```bash
trunk plugins add --id aps831 https://github.com/aps831/trunk-io-plugins ${TAG}
```

## Enabling a supported linter

There are no linters defined.

## Enabling a supported action

| Action                         | Description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| commit-branch                  | Warn when committing to the 'master' branch                        |
| commitizen                     | **DEPRECATED** Ensure commit messages are correctly formatted      |
| commitizen-prompt-conventional | Prompt for commit message using conventional-changelog style       |
| commitizen-tools-check         | Ensure commit messages are correctly formatted                     |
| hardcoding-check               | Check correctness of hardcoded values defined in `hardcoding.json` |
| templated-output-check         | Check for changes to files created from templates                  |

To add an action, run:

```bash
trunk actions enable ${action}
```

For the **commitizen-prompt-conventional** action, a `.czrc` configuration file with contents

```text
{ "path": "cz-conventional-changelog" }
```

is required.

## Tests

To run bats tests: `bats -r test`
