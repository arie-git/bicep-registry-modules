# DRCP Bicep Registry Modules

## Before You Do Anything (MANDATORY)

Every session, before writing any code or making any commit:

1. **Read `tasks/lessons.md`** -- contains hard-won rules from past mistakes. Violating these wastes time.
2. **Read the relevant `todo.md`** for your work area (see Repository Structure below). Find the task, confirm it's not done.
3. **Read the relevant `CLAUDE.md`** for your work area -- each has area-specific rules.

Do NOT skip these steps. Do NOT start work without checking what's already been done.

---

## Repository Structure

```
bicep-registry-modules/
├── amavm/                    # AMAVM module fork (private ACR)
│   ├── CLAUDE.md             # Module dev rules, build process, compliance
│   └── verified-modules/     # Bicep modules published to ACR
│       └── todo.md           # AMAVM task tracker
├── drcptestcases/            # Integration test scenarios (S1-S17)
│   ├── CLAUDE.md             # Scenario rules, policy compliance, validation
│   └── todo.md               # Scenario task tracker
├── microsoft-avm/            # Upstream AVM reference (READ-ONLY, do not edit)
├── policy/                   # DRCP policy definitions (READ-ONLY, do not edit)
│   ├── Generic/              # 315 Azure Policy JSONs
│   └── knowledge_base/       # Platform docs (RST)
├── tasks/                    # Cross-cutting project management
│   ├── instructions.md       # Master scope, whitelisted modules, agent workflows
│   ├── lessons.md            # Accumulated rules from mistakes -- READ EVERY SESSION
│   ├── todo.md               # Top-level task tracker
│   └── todo-archive.md       # Completed work history
└── claude.md                 # This file
```

### Read-only directories

- `microsoft-avm/` -- upstream AVM reference. Never edit.
- `policy/` -- DRCP policy definitions. Never edit. Read to understand compliance requirements.

---

## Workflow Orchestration

### Plan Mode Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately -- don't keep pushing
- Use plan mode for verification steps, not just building

### Subagent Strategy

- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Review lessons at session start

### Verification Before Done

- Never mark a task complete without proving it works
- Run `bicep build`, check logs, demonstrate correctness
- Ask yourself: "Would a staff engineer approve this?"

### Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests -> then resolve them
- Zero context switching required from the user

---

## Task Management

1. **Check todo.md first**: Find the relevant task, confirm it's not already done
2. **Plan first**: For non-trivial work, write plan with checkable items
3. **Track progress**: Mark items `[x]` as you go
4. **Capture lessons**: Update `tasks/lessons.md` after any correction

---

## Hard Rules

- **No em dashes**: Never use the em dash character anywhere -- files, commits, comments. Use double hyphens (--). Em dashes break the README build tooling.
- **No scope creep**: Only touch files relevant to the current task. If something else needs fixing, add it to todo.md first.
- **Minimal impact**: Changes should only touch what's necessary. Don't "improve" adjacent code.
- **Simplicity first**: Make every change as simple as possible.
- **No laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Consult policy before writing Bicep**: Read the relevant policy JSONs in `policy/Generic/` before configuring any resource.
- **Call Azure MCP tools before generating Bicep**: Run `mcp__plugin_azure_azure__get_azure_bestpractices` before writing or modifying Bicep code.
