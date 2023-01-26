//go:build tools
// +build tools

package main

import (
	_ "github.com/itchyny/gojq/cmd/gojq"
	_ "github.com/mikefarah/yq/v4"
	_ "github.com/santhosh-tekuri/jsonschema/cmd/jv"
	_ "github.com/tmccombs/hcl2json"
)
