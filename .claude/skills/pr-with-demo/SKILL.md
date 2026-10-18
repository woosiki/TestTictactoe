---
name: pr-with-demo
description: Open a pull request with a simulator demo video embedded as an inline player. Use when creating a PR that changes UI or logic (app source under TestTictactoe/), or when asked to attach/record a demo video for a PR. Not needed for configuration-only PRs.
---

# PR with demo video

Creates a PR whose description plays the demo video inline on GitHub.
The video is uploaded with `gh --attach` and is **never committed**.

## 0. Decide whether a video is needed

Check the changed files: `git diff --name-only origin/main...HEAD`.

- **Video required:** any change to app source under `TestTictactoe/` — UI (views) or logic
  (view models, models, services, reducers).
- **No video:** configuration-only changes — `AGENTS.md`/`CLAUDE.md`, docs, `.github/`, `.claude/`,
  `scripts/`, `.gitignore`, build settings.
  Create the PR normally with `gh pr create` (omit the Demo video section) and stop here.

## 1. Preconditions

- Work is on a feature branch (not `main`) and the user has approved committing/opening a PR.
- GitHub CLI is 2.99.0 or later (`--attach` was added in 2.99.0):
  ```sh
  gh --version
  ```
  If older, stop and ask the user before upgrading (`brew upgrade gh`).
- `ffmpeg` is installed for trimming (optional; without it the video is untrimmed).

## 2. Keep the demo test in sync

`TestTictactoeUITests.testDemoCompleteGame` is the script that gets recorded.
If this PR changes the UI flow or game logic, update that test in the same PR so the video shows the new behavior.
Each interaction must be followed by a delay of at least 1 second (currently 1.5 s).
The test only runs when `DEMO_MODE=1`; normal test runs skip it.

## 3. Verify tests pass

Use the build/test commands in `AGENTS.md`. Do not open the PR with failing tests.

## 4. Record

```sh
scripts/record-demo.sh            # writes artifacts/demo.mp4
```

Then check the result by extracting a few frames (start, middle, end) with ffmpeg and viewing them:
the video should start on the app (not the home screen) and show the full flow.

## 5. Create the PR with the video embedded

Write the body to a temporary file. Put the local reference where the player should appear;
`gh` replaces it with the uploaded `github.com/user-attachments/assets/...` URL:

```markdown
## Summary
...

## Test results
...

## Demo video
![demo](./artifacts/demo.mp4)

<one line describing what the video shows>
```

```sh
gh pr create --base main --title "<title>" --body-file <body.md> --attach ./artifacts/demo.mp4
```

For an existing PR use `gh pr edit <number> --body-file <body.md> --attach ./artifacts/demo.mp4`.

Do **not**:
- commit `artifacts/` or any video file (it is git-ignored);
- upload the video as a GitHub Release asset (renders only as a download link);
- write a raw `<video>` tag (GitHub strips it).

## 6. Verify the player renders

```sh
gh api repos/{owner}/{repo}/pulls/<number> -H "Accept: application/vnd.github.html+json" \
  --jq .body_html | grep -c "<video"
```

The count must be at least 1. Report the PR URL to the user.
