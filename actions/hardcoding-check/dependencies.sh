#! /bin/bash
tools=$(go list -f '{{range .Imports}}{{.}} {{end}}' tools.go)
# shellcheck disable=SC2086
go install ${tools}
