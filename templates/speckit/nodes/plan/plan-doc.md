---
id: plan-doc
name: Write the plan
kind: author
command: plan
writes: plan.md
reads: [gather-context]
---
2. Create `<feature_directory>/plan.md` with these sections, in order. This is the full `normal`/`oversized` shape and the **size budget above governs**: at `simple` size it keeps only the Summary and skips the rest unless genuinely needed. Lead each section with prose. Reserve `inline code` for real identifiers (paths, types, packages), not ordinary nouns: a sentence that is mostly code spans is a rewrite.
   - **Summary**: 2–4 plain-language sentences giving the primary requirement plus the technical approach. If a stack choice genuinely isn't obvious from the codebase (a new language, a newly-added dependency, a non-default storage or test setup), name it in a sentence here. Otherwise don't restate the project's known stack.
   - **Project Structure**: the concrete source layout this feature touches, as a short tree of real directories/files, plus a one-line **Structure Decision**. The repository layout is already decided in the project's `CLAUDE.md` under `## Yerleşim`, not per feature: every path goes under `components/<name>/`, one language per component, and nothing new is added at the repository root. Do not pick among the template's `src/` / `backend/` / `frontend/` option trees. If the feature needs a component that does not exist yet, name it, its language and its manifest, and say why no existing component can hold the change. Use the actual paths; do not leave placeholder option-trees in the output. *(Skipped at `simple` size per the budget, unless the feature adds a new component: then write the Structure Decision line alone.)*
