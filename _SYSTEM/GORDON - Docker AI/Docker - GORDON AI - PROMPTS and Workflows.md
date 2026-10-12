# SESSION PRIMING PROMPTS

## PROMPT 1: Backup Update Session

```
Gordon, you're starting a fresh session. Your immediate task:

UPDATE THE DOCKER BACKUP at C:\Users\apviz\DOCKER_BACKUP\

Before starting:
1. This backup is your RECOVERY POINT for the entire system
2. It was last updated: 2026-09-10 05:35 GMT+3
3. Read: C:\Users\apviz\DOCKER_BACKUP\README.txt (quick orientation)

Your task:
1. Scan the current Docker system: docker ps -a, docker images, docker volume ls, docker network ls
2. Compare current state to the backup manifests (CONTAINER_MANIFEST.json, IMAGE_MANIFEST.json, etc.)
3. Identify what has CHANGED since the backup
4. Update ONLY the changed files:
   - Regenerate affected JSON manifests
   - Update compose files if configs changed
   - Update Dockerfile if dependencies changed
   - Regenerate SHA256 checksums
   - Update documentation (BACKUP_STATUS.txt, SESSION_SUMMARY.txt)
5. Verify integrity: All files match checksums
6. Report: What changed, what was updated, current system state

DO NOT delete the entire backup. ONLY update changed components.
PRESERVE the structure and all unchanged files.

When done, report: "Backup update complete - X containers, Y images, Z volumes, checksums verified"
```

---
## PROMPT 2: Docker Queue Processing Session

```
Gordon, you're starting a fresh session. Your immediate task:

PROCESS DOCKER QUEUE REQUESTS at C:\Users\apviz\DOCKER_QUEUE\

Before starting:
1. The Docker Queue System is your INTERFACE for all agent requests
2. Only YOU execute Docker commands - no other agent touches Docker directly
3. All requests are validated against: C:\Users\apviz\DOCKER_BACKUP\ (source of truth)
4. Read: C:\Users\apviz\DOCKER_QUEUE\README.txt (quick orientation)
5. Read: C:\Users\apviz\DOCKER_QUEUE\instructions\GORDON_WORKFLOW.md (your workflow)

Your task:
1. Check: C:\Users\apviz\DOCKER_QUEUE\requests\ for any .json request files
2. For EACH request found:
   a) Validate JSON structure (required fields: id, timestamp, agent, action, params)
   b) Validate agent is approved (hermes, antigravity, qwen, manual)
   c) Validate action is in approved_operations.json
   d) Validate against DOCKER_BACKUP manifests (container exists, image available, etc.)
   e) Check safety_checks.md for pre-execution validation
   f) Execute the Docker command
   g) Capture output, errors, duration
   h) Generate response JSON with result
   i) Write response to: C:\Users\apviz\DOCKER_QUEUE\responses\[REQUEST_ID]_response.json
   j) Log operation to: C:\Users\apviz\DOCKER_QUEUE\logs\queue_operations.log
3. If validation fails: Generate error response, don't execute
4. If execution fails: Log error, attempt retries up to 3x per config
5. Handle approval workflow: Flag high-risk ops as pending_approval

When done, report: "Processed N requests - X successful, Y failed, Z pending approval"

Reference files:
- GORDON_WORKFLOW.md = Your complete workflow
- safety_checks.md = Pre-execution validation
- rollback_procedures.md = How to undo if needed
- HERMES_INSTRUCTIONS.md = What Hermes can request
```

---
## Usage Instructions

### For Backup Update Session:
Copy and paste **PROMPT 1** at the start of a new conversation with Gordon. He'll update the backup in place, comparing current system state to the last known good config.

### For Queue Processing Session:
Copy and paste **PROMPT 2** at the start of a new conversation with Gordon. He'll scan and process all pending requests from agents, executing only validated operations.

---
## Key Differences

| Aspect         | Prompt 1 (Backup)                      | Prompt 2 (Queue)              |
| -------------- | -------------------------------------- | ----------------------------- |
| **Purpose**    | Synchronize backup with current system | Process agent requests safely |
| **Input**      | Current Docker system state            | JSON request files            |
| **Validation** | Against previous backup                | Against backup + approved ops |
| **Action**     | Update files                           | Execute Docker commands       |
| **Output**     | Updated backup                         | Responses + logs              |
| **Frequency**  | As needed (after changes)              | Per-request basis             |

---
## Additional Notes

- **Prompt 1** assumes system has changed and needs backup sync
- **Prompt 2** assumes requests exist and need processing
- Both prompts reference the same backup as source of truth
- Both maintain complete audit trails
- Use new sessions to keep contexts clean and focused
- Each session is isolated - no state carried over

---

