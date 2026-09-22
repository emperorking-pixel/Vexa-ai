A private personal AI app with 4 chat personas, real biometric lock, voice
input, and opt-in notification summarizing. Built for one phone-only workflow:
edit files on GitHub's mobile editor, let GitHub Actions build the APK.

## Current file list

| File | What it is |
|---|---|
| `pubspec.yaml` | **Complete file** — replace yours entirely with this one |
| `build-apk.yml` | GitHub Actions workflow — goes in `.github/workflows/` |
| `lib/main.dart` | Entry point: biometric lock → API key check → chat |
| `lib/biometric_lock.dart` | Real fingerprint/face lock (Android BiometricPrompt) |
| `lib/personas.dart` | The 4 personas: Atlas, Nova, Engineer, Linda |
| `lib/chat_screen.dart` | Main chat UI, persona switcher, mic input, settings |
| `lib/secure_key_store.dart` | Encrypted API key storage + first-run setup screen |
| `lib/anthropic_service.dart` | Calls Anthropic's API directly with your key |
| `lib/notification_buffer_service.dart` | Opt-in notification reading (local only) |
| `lib/background_service.dart` | Keeps the notification listener alive in the background |
| `index.html` | Standalone mic-permission test page for GitHub Pages (separate from the app — see below) |

**Obsolete — ignore/delete these two:** `pubspec_additions.yaml` and
`AndroidManifest_additions.xml` were early drafts for manual merging. They're
no longer needed: `pubspec.yaml` above is now the complete file, and
`build-apk.yml` now generates and patches `AndroidManifest.xml`
automatically during every build. You never touch `AndroidManifest.xml` by
hand.

## Setup order (all from GitHub's mobile editor)

1. Replace `pubspec.yaml` at your repo root with the complete version above.
2. Put `build-apk.yml` in `.github/workflows/build-apk.yml`.
3. Put all 8 `lib/*.dart` files in your `lib/` folder (overwrite any older versions).
4. Open `lib/notification_buffer_service.dart` and add package names to
   `allowedPackages` for any app you actually want summarized — it starts
   **empty on purpose**.
5. Commit. That triggers a build. Or: **Actions** tab → **Build APK** → **Run workflow**.
6. Wait a few minutes → open the finished run → **Artifacts** → download `aster-debug-apk`.
7. Unzip on your phone, tap the `.apk`, install.

On first launch: unlock with fingerprint/face → paste your own Anthropic API key → chat.

## The 4 personas

One AI (your key), four system prompts, switchable with the chips at the top
of the chat:
- **Atlas** — coordinator, sees what all four have discussed
- **Nova** — code & design, technical and concrete
- **Engineer** — builds & troubleshooting, methodical
- **Linda** — messages & notes, drafts things and summarizes notifications

Each keeps its own conversation (Atlas is the only one that sees all four).
History is stored locally in the app's own storage — not a guaranteed
"never forget forever," just a normal local file that survives app restarts
until you clear the app's data or uninstall it.

## Important — still true from before

- **No hands-free "Hey Aster" yet.** Tap-to-talk (`speech_to_text`) works.
  True always-on wake-word detection needs a separate dedicated engine
  (e.g. Picovoice Porcupine) — bigger, separate piece of work.
- **Notification content only leaves the phone when you ask.** "What did I
  miss?" sends buffered notifications (from apps you opted in) to Anthropic
  to summarize — nothing is sent automatically as they arrive.
- **Never commit the API key.** It's typed in at runtime, stored in Android
  Keystore via `flutter_secure_storage`. Not in any file you'd push to GitHub.
- **Biometric lock needs biometrics actually set up on the phone.** If none
  are enrolled, the app tells you and won't proceed — that's Android's
  restriction, not a bug.
- **Cost:** every message bills your own Anthropic account.
- **minSdk:** left to Flutter's default. If a build error names a required
  minSdk, raise it in `android/app/build.gradle.kts`.

## Not built yet
- Device-settings control (DND, volume, brightness) — said "nothing yet" earlier.
- Full SMS + call auto-reply ("Linda" fully automated) — confirmed as wanted,
  but scoped as its own separate build: it requires this app to become your
  phone's *default* SMS/Phone app, which is a much bigger undertaking than
  anything above. Say when you're ready and it gets its own round, tested
  after Phase 1 (this README) is confirmed working.

## `index.html` — separate from the app
This is not part of the Flutter app. It's a tiny standalone page to host on
GitHub Pages to test whether microphone access itself works outside of any
embedded preview. Enable it via repo **Settings → Pages**, then visit the
URL GitHub gives you and tap "Run mic check."
EOF
wc -l /home/claude/aster_flutter/README.md
