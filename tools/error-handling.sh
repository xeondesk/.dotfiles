#!/usr/bin/env bash

# Shared error handling utilities for dotfiles shell scripts
# This file should be sourced by other scripts to provide consistent error handling
#
# Usage:
#   source "$(dirname "$0")/../tools/error-handling.sh"
#   
#   # Now you can use:
#   # - check_dependency <command>
#   # - die <message>
#   # - try <command>
#   # - ensure_dir <path>
#   # - cleanup functions via trap

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

# Default cleanup function (can be overridden)
_cleanup_functions=()

# Register a cleanup function to be called on exit
register_cleanup() {
    local func=$1
    _cleanup_functions+=("$func")
}

# Call all registered cleanup functions
_run_cleanup() {
    local exit_code=$?
    for func in "${_cleanup_functions[@]}"; do
        if declare -f "$func" >/dev/null 2>&1; then
            "$func" || true
        fi
    done
    exit $exit_code
}

# Set up the trap for cleanup
trap _run_cleanup EXIT

# Display error message and exit
# Usage: die "Error message"
die() {
    local message=$1
    local code=${2:-1}
    echo -e "${RED}❌ Error: $message${NC}" >&2
    exit "$code"
}

# Display warning message
# Usage: warn "Warning message"
warn() {
    local message=$1
    echo -e "${YELLOW}⚠️  Warning: $message${NC}" >&2
}

# Display success message
# Usage: success "Success message"
success() {
    local message=$1
    echo -e "${GREEN}✅ $message${NC}"
}

# Check if a command exists
# Usage: check_dependency "git" || die "git is required"
check_dependency() {
    local cmd=$1
    local error_msg=${2:-"Required command '$cmd' not found"}
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        die "$error_msg"
    fi
}

# Check if multiple commands exist
# Usage: check_dependencies git gh parallel
check_dependencies() {
    for cmd in "$@"; do
        check_dependency "$cmd"
    done
}

# Execute a command and check for errors
# Usage: try git pull || die "Failed to pull"
try() {
    if ! "$@"; then
        die "Command failed: $*"
    fi
}

# Ensure a directory exists
# Usage: ensure_dir "/path/to/dir"
ensure_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

# Validate that a file is readable
# Usage: ensure_readable "/path/to/file"
ensure_readable() {
    local file=$1
    if [ ! -r "$file" ]; then
        die "File is not readable: $file"
    fi
}

# Validate that a file is not a symlink
# Usage: ensure_not_symlink "/path/to/file" || die "File is a symlink"
ensure_not_symlink() {
    local file=$1
    if [ -L "$file" ]; then
        die "File should not be a symlink: $file"
    fi
}

# Safe temporary file creation
# Usage: temp_file=$(safe_mktemp)
safe_mktemp() {
    mktemp || die "Failed to create temporary file"
}

# Safe temporary directory creation
# Usage: temp_dir=$(safe_mktemp_dir)
safe_mktemp_dir() {
    mktemp -d || die "Failed to create temporary directory"
}

# Validate variable is not empty
# Usage: require_var "MY_VAR" "${MY_VAR}"
require_var() {
    local var_name=$1
    local var_value=$2
    
    if [ -z "$var_value" ]; then
        die "Required variable is not set: $var_name"
    fi
}

# Execute command with timeout
# Usage: timeout_exec 30 "long running command"
timeout_exec() {
    local timeout=$1
    shift
    local cmd="$@"
    
    if ! command -v timeout >/dev/null 2>&1; then
        die "timeout command not found"
    fi
    
    timeout "$timeout" "$@" || {
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            die "Command timed out after ${timeout}s: $cmd"
        else
            die "Command failed with exit code $exit_code: $cmd"
        fi
    }
}

# Execute command in background with error handling
# Usage: run_background "command" || die "Failed to start command"
run_background() {
    local cmd="$@"
    local pid
    
    if ! pid=$($cmd &); then
        die "Failed to execute command in background: $cmd"
    fi
    
    echo "$pid"
}

# Validate command line arguments
# Usage: require_args 2 "$@" || die "Expected 2 arguments"
require_args() {
    local expected=$1
    shift
    local actual=$#
    
    if [ $actual -ne $expected ]; then
        die "Expected $expected argument(s), got $actual"
    fi
}

# Validate argument count is at least N
# Usage: require_min_args 1 "$@"
require_min_args() {
    local min=$1
    shift
    local actual=$#
    
    if [ $actual -lt $min ]; then
        die "Expected at least $min argument(s), got $actual"
    fi
}

# Return the calling script's directory
# Usage: SCRIPT_DIR=$(get_script_dir)
get_script_dir() {
    local source="${BASH_SOURCE[1]}"
    while [ -h "$source" ]; do
        local dir=$(cd -P "$(dirname "$source")" && pwd)
        source=$(readlink "$source")
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

# Log message with timestamp
# Usage: log "Important message"
log() {
    local message=$1
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $message"
}

export -f die warn success check_dependency check_dependencies try ensure_dir
export -f ensure_readable ensure_not_symlink safe_mktemp safe_mktemp_dir
export -f require_var timeout_exec run_background require_args require_min_args
export -f get_script_dir log register_cleanup
