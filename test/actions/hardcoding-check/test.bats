setup_file() {
    export CURRENT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    ROOT_PATH="$CURRENT_PATH/../../.."
    EXECUTABLE_PATH="$ROOT_PATH/actions/hardcoding-check"
    HASH=$(md5sum $EXECUTABLE_PATH/go.sum | awk '{print $1}')
    export GOPATH="$ROOT_PATH/.bats/cache/$HASH"
    mkdir -p $GOPATH
    PATH="$GOPATH/bin:$EXECUTABLE_PATH:$PATH"
    (cd ${EXECUTABLE_PATH} && dependencies.sh)
}

setup() {
    load '../../../.bats/test_helper/bats-support/load'
    load '../../../.bats/test_helper/bats-assert/load'
}

# Config
@test "[config] should return message if config file not found" {
    run check.sh
    assert_success
    assert_output --partial "Ignoring hardcoding check as 'hardcoding.json' not found"
}

@test "[config] should return message if config not valid" {
    run check.sh ${CURRENT_PATH}/config/invalid.json
    assert_failure 1
    assert_output --regexp "Hardcoding check failed: 'invalid.json' is not valid"
}

@test "[config] should return file type not supported" {
    run check.sh ${CURRENT_PATH}/config/not_supported.json
    assert_failure 1
    assert_output --regexp "File type '.*/test.not-supported' not supported"
}

# YAML
@test "[yaml] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yaml' at path '.d.e.f'"
}

@test "[yaml] should check multiple files" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yaml' at path '.d.e.f'"
}

@test "[yaml] should return file not found output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.yaml' not found for value 'hello, world' of 'Greeting' at path '.a.b.c'"
}

@test "[yaml] should return path invalid output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_no_match_path_invalid.json
    assert_failure 1
    assert_output --regexp "Path 'a.b.c' not valid for value 'hello, world' of 'Greeting' in file '.*/test.yaml'"
}

@test "[yaml] should return path not found output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.yaml' for value 'hello, world' of 'Greeting'"
}

@test "[yaml] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.yaml' for value 'hello, world' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yaml' at path '.d.e.f'"
}

## Value not matched
@test "[yaml] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yaml' at path '.a.b.c'"
}

@test "[yaml] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yaml' at path '.a.b.c'"
}

@test "[yaml] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yaml' at path '.a.b.c'"
}

## Value matched
@test "[yaml] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[yaml] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[yaml] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/yaml/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# YML
@test "[yml] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yml' at path '.d.e.f'"
}

@test "[yml] should check multiple files" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yml' at path '.d.e.f'"
}

@test "[yml] should return file not found output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.yml' not found for value 'hello, world' of 'Greeting' at path '.a.b.c'"
}

@test "[yml] should return path invalid output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_no_match_path_invalid.json
    assert_failure 1
    assert_output --regexp "Path 'a.b.c' not valid for value 'hello, world' of 'Greeting' in file '.*/test.yml'"
}

@test "[yml] should return path not found output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.yml' for value 'hello, world' of 'Greeting'"
}

@test "[yml] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.yml' for value 'hello, world' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.yml' at path '.d.e.f'"
}

## Value not matched
@test "[yml] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yml' at path '.a.b.c'"
}

@test "[yml] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yml' at path '.a.b.c'"
}

@test "[yml] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.yml' at path '.a.b.c'"
}

## Value matched
@test "[yml] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[yml] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[yml] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/yml/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# JSON
@test "[json] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.json' at path '.d.e.f'"
}

@test "[json] should check multiple files" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.json' at path '.d.e.f'"
}

@test "[json] should return file not found output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.json' not found for value 'hello, world' of 'Greeting' at path '.a.b.c'"
}

@test "[json] should return path invalid output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_no_match_path_invalid.json
    assert_failure 1
    assert_output --regexp "Path 'a.b.c' not valid for value 'hello, world' of 'Greeting' in file '.*/test.json'"
}

@test "[json] should return path not found output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.json' for value 'hello, world' of 'Greeting'"
}

@test "[json] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path '.a.b.missing' not found in file '.*/test.json' for value 'hello, world' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.json' at path '.d.e.f'"
}

## Value not matched
@test "[json] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.json' at path '.a.b.c'"
}

@test "[json] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.json' at path '.a.b.c'"
}

@test "[json] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.json' at path '.a.b.c'"
}

## Value matched
@test "[json] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[json] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[json] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/json/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# TF
@test "[tf] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.tf' at path '.d.e\[0\].f'"
}

@test "[tf] should check multiple files" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.tf' at path '.d.e\[0\].f'"
}

@test "[tf] should return file not found output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.tf' not found for value 'hello, world' of 'Greeting' at path '.a.b\[0\].c'"
}

@test "[tf] should return path invalid output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_no_match_path_invalid.json
    assert_failure 1
    assert_output --regexp "Path 'a.b.c' not valid for value 'hello, world' of 'Greeting' in file '.*/test.tf'"
}

@test "[tf] should return path not found output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path '.a.b\[0\].missing' not found in file '.*/test.tf' for value 'hello, world' of 'Greeting'"
}

@test "[tf] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path '.a.b\[0\].missing' not found in file '.*/test.tf' for value 'hello, world' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.tf' at path '.d.e\[0\].f'"
}

## Value not matched
@test "[tf] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.tf' at path '.a.b\[0\].c'"
}

@test "[tf] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.tf' at path '.a.b\[0\].c'"
}

@test "[tf] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.tf' at path '.a.b\[0\].c'"
}

## Value matched
@test "[tf] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[tf] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[tf] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/tf/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# XML
@test "[xml] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.xml' at path '.root.d.e.f'"
}

@test "[xml] should check multiple files" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.xml' at path '.root.d.e.f'"
}

@test "[xml] should return file not found output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.xml' not found for value 'hello, world' of 'Greeting' at path '.root.a.b.c'"
}

@test "[xml] should return path invalid output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_no_match_path_invalid.json
    assert_failure 1
    assert_output --regexp "Path 'a.b.c' not valid for value 'hello, world' of 'Greeting' in file '.*/test.xml'"
}

@test "[xml] should return path not found output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path '.root.a.b.missing' not found in file '.*/test.xml' for value 'hello, world' of 'Greeting'"
}

@test "[xml] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path '.root.a.b.missing' not found in file '.*/test.xml' for value 'hello, world' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye, world' for 'Greeting' instead of 'hello, world' in file '.*/test.xml' at path '.root.d.e.f'"
}

## Value not matched
@test "[xml] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.xml' at path '.root.a.b.c'"
}

@test "[xml] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.xml' at path '.root.a.b.c'"
}

@test "[xml] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello, world' for 'Farewell' instead of 'goodbye, world' in file '.*/test.xml' at path '.root.a.b.c'"
}

## Value matched
@test "[xml] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[xml] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[xml] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/xml/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# tool-versions
@test "[tool-versions] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.tool-versions' at path 'farewell'"
}

@test "[tool-versions] should check multiple files" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.tool-versions' at path 'farewell'"
}

@test "[tool-versions] should return file not found output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.tool-versions' not found for value 'hello' of 'Greeting' at path 'greeting'"
}

@test "[tool-versions] should return path not found output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/\.tool-versions' for value 'hello' of 'Greeting'"
}

@test "[tool-versions] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/.tool-versions' for value 'hello' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.tool-versions' at path 'farewell'"
}

## Value not matched
@test "[tool-versions] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello' for 'Farewell' instead of 'goodbye' in file '.*/\.tool-versions' at path 'greeting'"
}

@test "[tool-versions] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/\.tool-versions' at path 'farewell'"
}

@test "[tool-versions] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/\.tool-versions' at path 'farewell'"
}

## Value matched
@test "[tool-versions] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[tool-versions] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[tool-versions] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/tool-versions/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# sh
@test "[sh] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.sh' at path 'farewell'"
}

@test "[sh] should check multiple files" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.sh' at path 'farewell'"
}

@test "[sh] should return file not found output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.sh' not found for value 'hello' of 'Greeting' at path 'greeting'"
}

@test "[sh] should return path not found output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/test.sh' for value 'hello' of 'Greeting'"
}

@test "[sh] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/test.sh' for value 'hello' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.sh' at path 'farewell'"
}

## Value not matched
@test "[sh] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello' for 'Farewell' instead of 'goodbye' in file '.*/test.sh' at path 'greeting'"
}

@test "[sh] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/test.sh' at path 'farewell'"
}

@test "[sh] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/test.sh' at path 'farewell'"
}

## Value matched
@test "[sh] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[sh] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[sh] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/sh/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# bat
@test "[bat] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.bat' at path 'farewell'"
}

@test "[bat] should check multiple files" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.bat' at path 'farewell'"
}

@test "[bat] should return file not found output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.bat' not found for value 'hello' of 'Greeting' at path 'greeting'"
}

@test "[bat] should return path not found output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/test.bat' for value 'hello' of 'Greeting'"
}

@test "[bat] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/test.bat' for value 'hello' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/test.bat' at path 'farewell'"
}

## Value not matched
@test "[bat] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello' for 'Farewell' instead of 'goodbye' in file '.*/test.bat' at path 'greeting'"
}

@test "[bat] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/test.bat' at path 'farewell'"
}

@test "[bat] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/test.bat' at path 'farewell'"
}

## Value matched
@test "[bat] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[bat] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[bat] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/bat/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

# sdkmanrc
@test "[sdkmanrc] should check multiple blocks" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_match_value_no_match_multiple_blocks.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.sdkmanrc' at path 'farewell'"
}

@test "[sdkmanrc] should check multiple files" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_match_value_no_match_multiple_files.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.sdkmanrc' at path 'farewell'"
}

@test "[sdkmanrc] should return file not found output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_no_match.json
    assert_failure 1
    assert_output --regexp "File '.*/missing.sdkmanrc' not found for value 'hello' of 'Greeting' at path 'greeting'"
}

@test "[sdkmanrc] should return path not found output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_match_path_no_match.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/\.sdkmanrc' for value 'hello' of 'Greeting'"
}

@test "[sdkmanrc] should return multiple failures output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_multiple_failures.json
    assert_failure 1
    assert_output --regexp "Path 'missing' not found in file '.*/.sdkmanrc' for value 'hello' of 'Greeting'"
    assert_output --regexp "Found value 'goodbye' for 'Greeting' instead of 'hello' in file '.*/\.sdkmanrc' at path 'farewell'"
}

## Value not matched
@test "[sdkmanrc] should return literal value not matched output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_match_value_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'hello' for 'Farewell' instead of 'goodbye' in file '.*/\.sdkmanrc' at path 'greeting'"
}

@test "[sdkmanrc] should return literal value with prefix not matched output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_match_value_with_prefix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/\.sdkmanrc' at path 'farewell'"
}

@test "[sdkmanrc] should return literal value with suffix not matched output" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_match_value_with_suffix_no_match.json
    assert_failure 1
    assert_output --regexp "Found value 'goodbye' for 'Farewell' instead of 'hello' in file '.*/\.sdkmanrc' at path 'farewell'"
}

## Value matched
@test "[sdkmanrc] should return success output when matching path and literal value" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_value_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[sdkmanrc] should return success output when matching path and literal value with prefix" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_value_with_prefix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}

@test "[sdkmanrc] should return success output when matching path and literal value with suffix" {
    run check.sh ${CURRENT_PATH}/sdkmanrc/hardcoding_file_path_value_with_suffix_match.json
    assert_success
    assert_output --partial "Hardcoding check: successful!"
}
