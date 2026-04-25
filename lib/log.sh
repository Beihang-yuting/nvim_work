#!/usr/bin/env bash
[ -t 2 ] && _CLR_R=$'\033[31m' _CLR_G=$'\033[32m' _CLR_Y=$'\033[33m' _CLR_B=$'\033[34m' _CLR_X=$'\033[0m'

log_info() { printf '%s[INFO]%s %s\n' "${_CLR_B-}" "${_CLR_X-}" "$*" >&2; }
log_warn() { printf '%s[WARN]%s %s\n' "${_CLR_Y-}" "${_CLR_X-}" "$*" >&2; }
log_err()  { printf '%s[ERR ]%s %s\n' "${_CLR_R-}" "${_CLR_X-}" "$*" >&2; }
log_ok()   { printf '%s[OK  ]%s %s\n' "${_CLR_G-}" "${_CLR_X-}" "$*" >&2; }
log_step() { printf '\n%s== %s ==%s\n' "${_CLR_B-}" "$*" "${_CLR_X-}" >&2; }
