# Repository Instructions

## Project Context Docs

This repository has Markdown documentation in `Docs/` with package architecture, public UI surface summaries, platform support notes, decisions and pending work.

When making code changes in this repository:

1. Check whether `Docs/` exists.
2. If the change affects public APIs, UI behavior, SwiftUI/UIKit behavior, Android Skip behavior, view-model lifetime, async loading/error handling, navigation, media/social integrations, styling, snapshot expectations or pending work, update the relevant Markdown notes before finishing.
3. Do not update docs for purely internal refactors, variable renames, formatting, test-only changes or cleanup that does not change project context.
4. Prefer focused notes under `Docs/features/`, `Docs/decisions/`, `Docs/context/` or `Docs/todo/` instead of only appending to the index.
5. If documentation should change but the right update is ambiguous, mention the documentation gap in the final response.

Package ownership:

- `Docs/` is the source of truth for `BSWInterfaceKit` package context, public UI surface summaries, platform support notes and known pending work.
- DocC comments and Swift Package Index documentation remain the API reference for symbol-level documentation.

## Graphify

Graphify output in `graphify-out/` is a generated navigation index for architecture, dependency and documentation questions. Commit the generated output so agents can read the graph even when the Graphify CLI is not installed locally.

- Use `graphify-out/GRAPH_REPORT.md`, `graphify-out/graph.html` or `graphify query ... --graph graphify-out/graph.json` when they help orient codebase exploration.
- If Graphify is unavailable, read the committed `graphify-out/GRAPH_REPORT.md` and `graphify-out/graph.json` directly, then continue with normal repository exploration using `rg`, source files and `Docs/`.
- Treat Graphify as derived context only. `Docs/` remains the source of truth for package context, public UI surface summaries, platform support notes and pending work.
- Do not replace required `Docs/` updates with Graphify output.
- Do not edit generated files under `graphify-out/` by hand.
- Regenerate Graphify after large merges, broad refactors, API/doc changes or when graph freshness matters for the task.
- Prefer `graphify update .` for code-only changes. Use a full `graphify extract . --mode deep` only when docs, PDFs, images or semantic relationships need to be refreshed.

## GitHub PR Conventions

- Do not prefix pull request titles with `[codex]`.
- Use plain English PR titles that describe the change directly.
