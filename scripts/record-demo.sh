#!/usr/bin/env bash
#
# Records a simulator demo video by running the UI demo test
# (`testDemoCompleteGame`) and saves a trimmed MP4.
#
# Usage:
#   scripts/record-demo.sh [output.mp4]
#
# Environment overrides:
#   DEMO_DEVICE   Simulator name to use (default: "iPhone 17")
#   DEMO_SIM_ID   Exact simulator UDID (takes precedence over DEMO_DEVICE)
#   DEMO_TEST     Test identifier to record
#                 (default: TestTictactoeUITests/TestTictactoeUITests/testDemoCompleteGame)
#
# Requirements: Xcode, a simulator runtime matching the deployment target.
# Optional: ffmpeg (to trim the home-screen footage before and after the app runs).

set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$ROOT"

PROJECT="TestTictactoe.xcodeproj"
SCHEME="TestTictactoe"
OUTPUT="${1:-artifacts/demo.mp4}"
DEVICE="${DEMO_DEVICE:-iPhone 17}"
TEST_ID="${DEMO_TEST:-TestTictactoeUITests/TestTictactoeUITests/testDemoCompleteGame}"
TEST_NAME="${TEST_ID##*/}"
DERIVED="$ROOT/build/DemoDerivedData"

# Seconds trimmed after the test starts (app launch) and before it ends (app teardown).
LEAD_TRIM=2.0
TAIL_TRIM=0.8

WORK="$(mktemp -d)"
RAW="$WORK/raw.mp4"
LOG="$WORK/test.log"
RECORDER_PID=""

log() { printf '▸ %s\n' "$*" >&2; }
fail() { printf '✖ %s\n' "$*" >&2; exit 1; }
now() { perl -MTime::HiRes=time -e 'printf "%.3f\n", time'; }

cleanup() {
    if [[ -n "$RECORDER_PID" ]] && kill -0 "$RECORDER_PID" 2>/dev/null; then
        kill -INT "$RECORDER_PID" 2>/dev/null || true
        wait "$RECORDER_PID" 2>/dev/null || true
    fi
    rm -rf "$WORK"
}
trap cleanup EXIT

# 1. Pick a simulator that satisfies the deployment target.
if [[ -n "${DEMO_SIM_ID:-}" ]]; then
    SIM_ID="$DEMO_SIM_ID"
else
    # -showdestinations lists only runtimes compatible with the deployment target.
    SIM_ID="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showdestinations 2>/dev/null \
        | grep "platform:iOS Simulator" \
        | grep "name:$DEVICE }" \
        | sed -E 's/.*id:([^,]+),.*/\1/' \
        | head -n 1)"
    [[ -n "$SIM_ID" ]] || fail "No compatible simulator named '$DEVICE'. Set DEMO_DEVICE or DEMO_SIM_ID."
fi
DESTINATION="platform=iOS Simulator,id=$SIM_ID"
log "Simulator: $DEVICE ($SIM_ID)"

# 2. Boot the simulator.
xcrun simctl boot "$SIM_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_ID" -b >/dev/null

# 3. Build once, so recording only covers the test run.
log "Building for testing…"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED" build-for-testing -quiet

# 4. Record while the demo test runs.
log "Recording…"
xcrun simctl io "$SIM_ID" recordVideo --codec=h264 --force "$RAW" >/dev/null 2>&1 &
RECORDER_PID=$!
RECORD_START="$(now)"
sleep 2

# Prefix each output line with a timestamp so the app's on-screen time can be located.
set +e
TEST_RUNNER_DEMO_MODE=1 xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED" -parallel-testing-enabled NO \
    -only-testing:"$TEST_ID" test-without-building 2>&1 \
    | while IFS= read -r line; do printf '%s %s\n' "$(now)" "$line"; done > "$LOG"
TEST_STATUS=${PIPESTATUS[0]}
set -e

sleep 1
kill -INT "$RECORDER_PID"
wait "$RECORDER_PID" || true
RECORDER_PID=""

if [[ $TEST_STATUS -ne 0 ]]; then
    grep -E "error|failed" "$LOG" | cut -d' ' -f2- | tail -n 20 >&2 || true
    fail "Demo test failed (exit $TEST_STATUS)."
fi
if grep -q "$TEST_NAME.* skipped" "$LOG"; then
    fail "Demo test was skipped. Check that it honours DEMO_MODE."
fi

# 5. Trim to the part where the app is on screen.
mkdir -p "$(dirname "$OUTPUT")"
STARTED_AT="$(grep -m1 "$TEST_NAME.* started" "$LOG" | cut -d' ' -f1 || true)"
ENDED_AT="$(grep -m1 -E "$TEST_NAME.* (passed|failed)" "$LOG" | cut -d' ' -f1 || true)"

if command -v ffmpeg >/dev/null && [[ -n "$STARTED_AT" && -n "$ENDED_AT" ]]; then
    FROM="$(echo "$STARTED_AT - $RECORD_START + $LEAD_TRIM" | bc)"
    TO="$(echo "$ENDED_AT - $RECORD_START - $TAIL_TRIM" | bc)"
    log "Trimming to ${FROM}s – ${TO}s"
    ffmpeg -v error -y -ss "$FROM" -to "$TO" -i "$RAW" \
        -c:v libx264 -pix_fmt yuv420p -crf 20 -movflags +faststart "$OUTPUT"
else
    log "ffmpeg or test timestamps unavailable; saving untrimmed video."
    cp "$RAW" "$OUTPUT"
fi

if command -v ffprobe >/dev/null; then
    DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUTPUT")"
    log "Saved $OUTPUT (${DURATION%.*}s)"
else
    log "Saved $OUTPUT"
fi
echo "$OUTPUT"
