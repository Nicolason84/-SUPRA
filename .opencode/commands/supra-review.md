---
description: Lancer une relecture de code structurée.
agent: SUPRA-Reviewer
---

Perform a structured code review on the provided code.

Review target: $ARGUMENTS

1. Check code for:
   - Swift style and convention compliance
   - Performance implications
   - Edge case handling
   - Error handling completeness
   - Test coverage adequacy
   - Documentation accuracy
2. Categorize findings by severity (blocker, major, minor, nitpick).
3. Provide specific actionable feedback with code examples.

Output a structured review with: file, line, severity, issue description, suggestion with code example.
