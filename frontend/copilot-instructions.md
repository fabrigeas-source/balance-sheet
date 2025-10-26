<!-- .github/copilot-instructions.md
   Purpose: concise, actionable guidance for AI coding agents editing this repo.
 -->

# Balance Sheet App — AI assistant instructions

Keep changes small and verifiable. This repo is a Flutter project that appears to be partially scaffolded: the README documents a fuller layout than what is present. Before editing, open the README (`README.md`) and `pubspec.yaml` to confirm intended structure.

Key facts
- Flutter app (mobile/web/desktop). See `pubspec.yaml` (depends on `provider`).
- Tests exist under `test/widget_test.dart` and reference `package:balance_sheet_app/screens/home_screen.dart` — that file (and many UI files documented in README) are currently missing.
- `lib/main.dart` and `lib/models/entry.dart` are present but empty. The README lists many expected files under `lib/` (screens/, widgets/, providers/) which are not present in the tree.

What to do first (fast checks)
- Run: `flutter pub get` to populate deps (use the workspace's Flutter SDK).
- Run tests: `flutter test test/widget_test.dart` - tests currently assume UI files exist and will fail if those files are missing.
- If running locally, try `flutter run -d linux` (desktop), `-d chrome` (web), or default connected device.

Architecture / big picture
- Single-package Flutter app. The README describes a classic MVU-like split:
  - `lib/screens/home_screen.dart` — app entry UI showing a header and items list
  - `lib/widgets/*` — small reusable widgets (item tile, total header, new-item modal)
  - `lib/providers/item_provider.dart` — state managed by `provider` package
  - `lib/models/*` — data classes for items/entries
- Data flow: UI reads/writes through Provider; actions (add/edit/delete) mutate provider which updates UI.

Project-specific patterns and gotchas
- State management: the project uses the `provider` package (see `pubspec.yaml`). Look for an `ChangeNotifier` style provider when adding state.
- File-name mismatch: README refers to `item.dart` but the repo has `entry.dart` (empty). Be careful when adding new files — prefer existing names used by imports in tests (e.g. `screens/home_screen.dart`).
- Tests are white-box widget tests that import app screens directly. Keep public widget constructors stable (avoid changing names/signatures without updating tests).

Build / test / debug commands (examples)
- Install deps: flutter pub get
- Run unit/widget tests: flutter test (or `flutter test test/widget_test.dart` for a single file)
- Run app (desktop): flutter run -d linux
- Run app (web): flutter run -d chrome

When changing code
- Small incremental edits: make a change, run `flutter test` and `flutter analyze` (or `dart analyze`) before committing.
- If you add files the tests import (for example `lib/screens/home_screen.dart`), update `test/widget_test.dart` expectations only if the UI contract changed intentionally.
- Prefer adding a minimal, passing implementation for missing components rather than large refactors. Example: if `HomeScreen` is missing, a minimal `Scaffold` with a `ListView` and `Text('Total: 0')` will make tests runnable.

Examples from this repo (look here)
- `pubspec.yaml` — project metadata and dependency on `provider`.
- `test/widget_test.dart` — shows expected public API of `HomeScreen` and UI behavior (total header text, ListView, FloatingActionButton).
- `linux/runner/` — desktop runner C++ code; useful if debugging native desktop behavior.

Important constraints for AI edits
- Do not invent large subsystems. If files are missing, implement minimal, well-tested stubs that satisfy imports and tests.
- Preserve API shapes used by tests: public widget names, text keys (e.g. 'Total: 0') and basic widget types (ListView, FloatingActionButton) are relied upon by the tests.
- Document any assumptions you make in your PR description (e.g., "added minimal HomeScreen to satisfy tests").

If something is unclear
- Open `README.md` and `pubspec.yaml` to cross-check intended structure.
- If a requested feature requires adding many UI files, propose a small incremental PR that implements the minimal surface area and tests.

After your change
- Run `flutter test` to verify. Attach test output to the PR if non-obvious failures remain.

Contact / context
- There is no existing `.github/copilot-instructions.md` to merge. Use the README as the single source of truth for intended structure and prefer small, test-driven edits.
