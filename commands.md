# commands.md — every demo command, section by section

Every demo for the course, as a command you can run, in teaching order and grouped into five
sections. **Every command starts with its section number (01–05).**

| Section | Commands | Demos covered |
|---|---|---|
| **01** · Customer Discovery & Scoping | 7 + 7 guest | live triage agent, Ops Console tour, guest-lecture agent evolution |
| **02** · SoW, Pricing & Solution Architecture | 5 | pricing calculator, stack-choice matrix, integration topology |
| **03** · Building Production Agents | 9 | demos 1–4, CI gate, deploy ladder |
| **04** · Integration, MCP & RBAC | 9 | MCP door + two-analyst test, AgentCore Gateway, Slack |
| **05** · Evals, Observability & Handover | 7 | golden gate, Promptfoo graders, trace spans, incident drill |

**The guest lecture demo**, "Evolution of AI Agent Architecture", runs from an external
GitHub repo, not this one, and needs an LLM. Its commands are at the end of section 01.

**Run each command in its own new VS Code terminal.** Every block starts from the repo
root, so it works when pasted into a fresh terminal.

## How to run them in VS Code

**All at once, each in its own terminal:** press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> →
**Tasks: Run Task** → **Run all commands (01-05)**. [.vscode/tasks.json](.vscode/tasks.json)
opens a **new VS Code terminal for every command** and runs them in order, stopping at the
first failure.

- **The two servers:** *01 - Serve Ops Console Locally* and *03 - Serve AgentCore App Locally*
  start in the background via `.vscode/start-bg.sh`. Their terminal shows the server output
  and exits once the server answers, so the run moves straight on. If the console is already
  running, it is left up. The helper task *03 - Stop Local AgentCore App* stops the AgentCore
  app once *03 - Invoke Local AgentCore App* has used it.
- **No browser tabs:** *01 - Show Ops Console Pages* checks every console page in one terminal,
  and the 🌐 pricing-calculator step does the same for its page. Each prints the link with its HTTP
  status instead of opening it. <kbd>Ctrl</kbd>+click a link in the terminal to open it.
- **The console stays up at the end:** the run finishes after *05 - Rehearse The Incident Drill*.
  Teardown (*05 - Stop Database After Class*, and the helper *05 - Stop Ops Console Server*)
  is not part of the run. Run those two tasks yourself when you're done.
- **Left out of Run all:** the commands marked ☁️ (AWS, billed), 💬 (Slack tokens) and 🤖
  (needs an LLM). They're in the task list to run one at a time once you have what they need.
- **Keys:** the helper task *01 - Save Analyst Keys To Env* writes the keys that
  *01 - Start Bank Database And Seed* minted into `codebase/.env` for you.
- **Windows:** the tasks use Git Bash and need only the `~/bin/python3` line of the
  one-time setup below.

**One at a time:** **Tasks: Run Task** → pick e.g. `01 - Run Live Triage Agent Demo`. Or by hand:

1. **Open a new terminal for every command:** <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>`</kbd>
   (or **Terminal → New Terminal**). A new terminal opens in the repo root (`ik-fde/`).
2. **Use the Git Bash profile.** Every command is bash, and the `Makefile` needs bash.
   Pick it from the dropdown next to **+** in the terminal panel, or set it once with
   **Terminal: Select Default Profile → Git Bash**.
3. **Leave long-running terminals open.** Commands marked ⏳ keep running. Run the next
   command in a *new* terminal; don't stop these.
4. **Load the keys when a command says so.** `set -a && source .env && set +a` loads the
   analyst keys from `codebase/.env` (*01 - Start Bank Database And Seed* tells you how to fill it in).

### One-time setup on Windows (do this once, then restart VS Code)

On Windows, `python3` is the Microsoft Store stub and the console's code page garbles
em dashes. This adds a `python3` that runs your real Python, and fixes the encoding:

```bash
mkdir -p ~/bin && printf '#!/bin/sh\nexec python "$@"\n' > ~/bin/python3 && chmod +x ~/bin/python3
cat >> ~/.bashrc <<'EOF'
export PATH="$HOME/bin:$PATH"
export PYTHONUTF8=1
export PROMPTFOO_PYTHON=python
EOF
```

**Prerequisites:** Docker Desktop (running), Node 20+, Python 3.11+, `uv`. Optional: AWS CLI v2
for ☁️, a Slack workspace for 💬, and an OpenAI/Anthropic key or an Ollama model for 🤖.

| Marker | Meaning |
|---|---|
| ⏳ | Keeps running. Leave this terminal open and use a new one for the next command |
| 🔑 | Needs the analyst keys from `codebase/.env` (minted by *01 - Start Bank Database And Seed*) |
| 🌐 | Opens a page in your browser |
| ☁️ | Needs an AWS account / STARTED lab. Creates billed resources, so tear down after |
| 💬 | Needs a Slack workspace and bot token (`labs/integrate/SLACK_LIVE_SETUP.md`) |
| 🤖 | Needs an LLM: an OpenAI or Anthropic API key, or a local Ollama model |

---

## 01 · Customer Discovery & Scoping

The bank on your laptop, the **whole-game demo** of the finished triage agent, and the tour
of the Ops Console that hands the class its requirements.

### 01 - Check Prerequisites With Doctor
```bash
cd codebase && make doctor
```
Expect: a version for `docker`, `node`, `python` and `uv`. `db: not running — make up` is fine before the next command.

### 01 - Start Bank Database And Seed
```bash
cd codebase && make up
```
Expect: the sanity table `100000 | 365 | 1` (txns, Reg E breaches, poisoned chunk), then two
`KEY : mrdn_…` lines. **Copy them into `codebase/.env`.** Run `cp .env.example .env` first if it
doesn't exist. Put the type_a key in `MERIDIAN_API_KEY` and `MERIDIAN_KEY_A`, and the type_b key
in `MERIDIAN_KEY_B`. Re-running this resets the DB and mints new keys.
Shortcut: `bash .vscode/save-keys.sh` (task *01 - Save Analyst Keys To Env*) mints a fresh pair and writes it into `.env`.

### 01 - Serve Ops Console Locally ⏳
```bash
cd codebase && make web
```
Expect: `▲ Next.js … Local: http://localhost:3100`, then `✓ Ready`. **Leave this terminal open.**

### 01 - Run Live Triage Agent Demo
*The whole-game demo: the finished system, end to end.*
```bash
cd codebase/agent && uv run --extra db meridian-agent run --dispute 29 --mock
```
The finished Meridian dispute agent, run end to end on the live console's dispute 29 (the
story calls it "case 4417"). Narrate the stages as they print: **triage** (Type A, Reg E
urgency) → handoff → **evidence** from 3+ systems → **policy check** (Reg E RAG, poisoned
chunk quarantined) → **human handoff**. Expect `data backend: postgres`, `Karen Peterson`,
`$35.36`, 8 `[PASS]` checks and `outcome: HUMAN APPROVAL (type_a_approval)   confidence: 0.90`.
`--extra db` installs the Postgres driver so the agent reads the live database. On a fresh
clone without it, `make agent` silently falls back to the bundled sample data (a different
dispute 29). Once installed, `make agent` and the eval gates read the live database too.
Drop `--mock` for the live Bedrock brain.

### 01 - Run Smoke Eval Gate
*Stage 5 of the whole-game demo: the "eval dashboard".*
```bash
cd codebase && make eval
```
Expect: `pass rate: 100% (25/25)  ·  GATE PASSED`, 25 disputes from the live database
(`3/3` on the bundled sample data, before the live triage demo has installed the driver).
This is the gate CI runs on every PR.

### 01 - Show Ops Console Pages
*The Ops Console tour: login → dashboard → five screens. All pages in one terminal; nothing opens in the browser.*
```bash
ok=1
for u in http://localhost:3100/login http://localhost:3100/ http://localhost:3100/disputes \
         http://localhost:3100/disputes/29 http://localhost:3100/transactions \
         http://localhost:3100/customers http://localhost:3100/policies \
         https://ik-fde-casestudy-bank.vercel.app; do
  c=$(curl -s -o /dev/null -L --max-time 20 -w '%{http_code}' "$u"); echo "HTTP $c  $u"
  [ "$c" = 200 ] || ok=0
done
[ $ok = 1 ]
```
Expect: eight `HTTP 200` lines, one per page. <kbd>Ctrl</kbd>+click a link in the terminal to open
that page. Sign in first at `/login` with `jason.soto@meridianbank.com` (Type A) or
`robert.joyce@meridianbank.com` (Type B), email only, no password. Until you sign in, the other
console pages redirect to the login page.

| Page | What it shows |
|---|---|
| `/login` | Analyst sign-in |
| `/` dashboard | KPI cards (open, SLA-breached, provisional credit out), needs-attention panel, by-type donut, risk-exposure panel |
| `/disputes` | The queue the analysts work, sorted by hours-to-deadline |
| `/disputes/29` | "The screen you'll live in": Reg E countdown, evidence across systems, linked tickets. From section 03 on, the agent's tickets land under **Linked tickets** here |
| `/transactions` | The raw charge and its 90-day history |
| `/customers` | Who's disputing, and their prior disputes |
| `/policies` | The Reg E / GLBA rule knowledge base the agent's policy check retrieves from |
| hosted class console | The always-on class instance: same seed and logins, nothing to run |

### 01 - Run Agent Unit Tests
```bash
cd codebase && make test
```
Expect: `15 passed`.

### Guest lecture demo · Evolution of AI Agent Architecture 🤖

An e-commerce support bot built with LangGraph + FastAPI, evolving through four
architectures. The code is the guest speaker's public repo
<https://github.com/eliharoun/evolution-of-ai-agents-architecture>, cloned next to this repo
(not inside it). Every stage needs an LLM. In `.env`, set `OPENAI_API_KEY`, or use a free
local model: `DEFAULT_MODEL`, `PLANNER_MODEL` and `SOLVER_MODEL` = `ollama:llama3.1`, after
`ollama pull llama3.1` (~4.7 GB).

### 01 - Set Up Agent Evolution Demo 🤖
```bash
cd .. && git clone https://github.com/eliharoun/evolution-of-ai-agents-architecture.git
cd evolution-of-ai-agents-architecture && uv venv && uv pip install -r requirements.txt && cp .env.example .env
```
One-time. The install pulls `sentence-transformers` + `chromadb` (PyTorch, several GB). Then edit `.env` as above.

### 01 - Run Stage 1 ReAct Demo 🤖
*A simple ReAct agent with 2 tools.*
```bash
cd ../evolution-of-ai-agents-architecture && uv run python stage_1/demo.py
```

### 01 - Run Stage 2 Tool Overload Demo 🤖
*The same agent with 7 tools, and where it starts to struggle.*
```bash
cd ../evolution-of-ai-agents-architecture && uv run python stage_2/demo.py
```

### 01 - Run Stage 3 ReWOO Demo 🤖
*Plan first, then execute (ReWOO).*
```bash
cd ../evolution-of-ai-agents-architecture && uv run python stage_3/rewoo_demo.py
```

### 01 - Run Stage 4 Supervisor Demo 🤖
*A supervisor coordinating specialist agents (custom, v2).*
```bash
cd ../evolution-of-ai-agents-architecture && uv run python stage_4/supervisor_2/demo.py
```
The quick-setup version with LangGraph's built-ins is `stage_4/supervisor_1/demo.py`.

### 01 - Serve Agent Evolution Backend 🤖 ⏳
*The web chat for typing test prompts ("What's the status of my order #12345?").*
```bash
cd ../evolution-of-ai-agents-architecture && STAGE=1 uv run uvicorn backend.api:app --reload
```
`STAGE` picks the agent: `1`, `2`, `3.1` (ReWOO), `4.1` (supervisor). API on `http://localhost:8000`.

### 01 - Serve Agent Evolution Frontend ⏳
```bash
cd ../evolution-of-ai-agents-architecture/frontend && python3 -m http.server 8080
```
Then open `http://localhost:8080`. It uses port 8080, the same as *03 - Serve AgentCore App Locally*, so don't run both at once.

---

## 02 · SoW, Pricing & Solution Architecture

The estimation and pricing calculator, the stack-choice matrix and the integration-topology
selector. Then the API contract and the RBAC behaviour the SoW promises.

### 02 - Score Stack Choice Matrix
*Stack-choice matrix — and when the answer flips.*
```bash
cd codebase/labs/design/demo && python3 stack_matrix.py
```
Expect: `Winner for Meridian: OpenAI Agents SDK + AWS Bedrock  (4.70)`, then Azure and Google winning for the other two clients.

### 02 - Run Integration Topology Selector
*Integration topology — P2P / iPaaS / event mesh.*
```bash
cd codebase/labs/design/demo && python3 topology.py
```
Expect: `Recommended: P2P (point-to-point)` for the pilot, and `-> iPaaS (managed hub)` for the future state.

### 02 - Open Pricing Calculator Browser 🌐
*The estimation & pricing calculator.*
```bash
start https://ik-fde-calculator.vercel.app
```
The estimation and pricing half of this section's demo. Size the Meridian milestones and read off the four pricing options.

### 02 - Check Platform API Health
```bash
curl -s http://localhost:3100/api/v1/health
```
Expect: `{"status":"ok","service":"meridian-api","db":"up",…}` (needs *01 - Serve Ops Console Locally* running).

### 02 - Prove API RBAC Two Keys 🔑
```bash
cd codebase && set -a && source .env && set +a
curl -s -o /dev/null -w "no key     -> %{http_code}\n" http://localhost:3100/api/v1/disputes/29
curl -s -o /dev/null -w "Type-A key -> %{http_code}\n" -H "Authorization: Bearer $MERIDIAN_KEY_A" http://localhost:3100/api/v1/disputes/29
curl -s -o /dev/null -w "Type-B key -> %{http_code}\n" -H "Authorization: Bearer $MERIDIAN_KEY_B" http://localhost:3100/api/v1/disputes/29
```
Expect: `401`, `200`, `403`. The server enforces scope, so the model can never widen it.

---

## 03 · Building Production Agents

Demos 1–4: the agent primitives, the end-to-end pipeline with guardrails, a second harness,
and the deploy ladder. Every demo takes `--mock` ($0, no AWS). Drop `--mock` to run live on
Bedrock; live, demo 2 writes its ticket into the Ops Console (refresh `http://localhost:3100/disputes/29`).

### 03 - Run Agent Primitives Demo
*Demo 1 — the primitives, one at a time.*
```bash
cd codebase/labs/build/demo && python3 demo1_primitives.py --mock
```
Expect: Triage → Evidence handoff, ending `✓ final agent: Evidence`.

### 03 - Run End To End Pipeline
*Demo 2 — the end-to-end pipeline + the complete circle (also rung 1 of the deploy ladder).*
```bash
cd codebase/labs/build/demo && python3 demo2_pipeline.py --dispute 29 --mock
```
Expect: `money-moving claims are cited — PASS`, then `✓ THE CIRCLE IS CLOSED — the agent's recommendation is now a ticket`.

### 03 - Trip The Output Guardrail
*The demo 2 `--tripwire` rerun.*
```bash
cd codebase/labs/build/demo && python3 demo2_pipeline.py --dispute 29 --mock --tripwire
```
Expect: `⛔ BLOCKED: uncited provisional-credit/refund claim → routing to a human instead of auto-resolving`.

### 03 - Run Verify CI Gate
*The CI eval gate.*
```bash
cd codebase && make verify
```
Expect: the doctor report, `pass rate: 100% (25/25)  ·  GATE PASSED`, `15 passed`, then `verify: OK`. Green before every push.

### 03 - Run Strands Portability Demo
*Demo 3 — the same agent on a second harness.*
```bash
cd codebase/labs/build/demo && python3 demo3_strands.py --mock
```
Expect: `✓ same problem, same tool, same instructions — different harness`.

### 03 - Serve AgentCore App Locally ⏳
*The AgentCore ladder's $0 rung.*
```bash
cd codebase/labs/build/demo/deploy/agentcore && MERIDIAN_MOCK=1 python3 app.py
```
The runtime contract served on `:8080`. **Leave it open, run the next command in a new
terminal, then stop this one with <kbd>Ctrl</kbd>+<kbd>C</kbd>.**

### 03 - Invoke Local AgentCore App
```bash
curl -s localhost:8080/ping
curl -s -X POST localhost:8080/invocations -d '{"dispute_id": 29}'
```
Expect: `{"status": "Healthy"}`, then JSON with `guardrail_tripped`, `ticket_id`, `recommendation … HUMAN_REVIEW` and `see_it_live`.

### 03 - Deploy Lambda Agent Endpoint ☁️
*Demo 4 — deploy it (rung 2 of the deploy ladder).*
```bash
cd codebase/labs/build/demo/deploy && ./deploy.sh && ./invoke.sh 29 && ./teardown.sh
```
Deploy, then invoke on dispute 29. The ticket "Deployed-agent recommendation" lands in the
console. Then tear down, **always**: idle deployments are silent burn.

### 03 - Deploy To AgentCore Runtime ☁️
*Rung 3 — one command, and the run ends as a ticket ID plus a product URL.*
```bash
cd codebase/labs/build/demo/deploy/agentcore
pip install bedrock-agentcore-starter-toolkit
agentcore configure -e app.py -n meridian_triage -r us-east-1 -dt direct_code_deploy -rf requirements.txt --non-interactive
agentcore deploy --env MERIDIAN_BASE_URL=$MERIDIAN_BASE_URL --env MERIDIAN_API_KEY=$MERIDIAN_API_KEY
agentcore invoke '{"dispute_id": 29}'
agentcore destroy --agent meridian_triage --force
```
The managed version of the Lambda deploy above. Check that `aws sts get-caller-identity` resolves first, and finish with `destroy`.

---

## 04 · Integration, MCP & RBAC

The governed MCP door and its two-analyst test, the managed AgentCore Gateway twin, and the
Slack escalation through the same door.

### 04 - Run Governed MCP Door
*Demo I — the Meridian MCP server (bare run = the four proofs).*
```bash
cd codebase && make mcp
```
Expect: `DEMO: PASS ✓ all four proofs hold — scope, idempotent replay, retry/backoff, enumeration-safe denials`.

### 04 - Run Two Analyst RBAC Test
*The two-analyst test on the story dispute.*
```bash
cd codebase/labs/integrate && python3 mcp_demo.py 4417
```
Expect: Analyst A gets the dispute, `Analyst B (type_b): 403 DENIED`, and `RESULT: PASS ✓ scope holds — different answers + matching audit`.

### 04 - Run Door Against Live Portal 🔑
*The `--live` run, and the payoff ticket on dispute 29.*
```bash
cd codebase && set -a && source .env && set +a && make mcp-live
```
Expect: a real 200 vs 403, then `first` and `replay` of the same ticket id
(`idempotent_replay: true`), then `LIVE RESULT: PASS ✓`. Refresh `http://localhost:3100/disputes/29` to see the ticket under **Linked tickets**.

### 04 - Plan AgentCore Gateway Setup
*The managed twin of the door.*
```bash
cd codebase/labs/integrate/agentcore_gateway && python3 gateway_setup.py plan
```
The $0 floor. It prints every AWS call `apply` would make, with zero credentials used.

### 04 - Run AgentCore Gateway Rungs ☁️
*`apply` → `invoke` → `destroy`.*
```bash
cd codebase && set -a && source .env && set +a && cd labs/integrate/agentcore_gateway
python3 gateway_setup.py apply      # vault the key -> gateway -> 4 MCP tools
python3 gateway_setup.py invoke     # SigV4 tools/list + get_dispute 29
python3 gateway_setup.py destroy    # leave nothing running
```

### 04 - Run Slack Escalation Scenarios
*The agent pings on-call in Slack — through the governed door.*
```bash
cd codebase && make slack
```
Expect: the 7 `PROBLEM/RBAC/SETUP → HANDLED` lines (rate limit, expired webhook, timeout
with circuit breaker, duplicate, schema drift), then `SUMMARY — every failure mode handled deterministically, in the door`.

### 04 - Post Real Slack Card 💬
*The `--real` run: a card lands in #meridian-oncall.*
```bash
cd codebase && set -a && source .env && set +a && make slack-live
```
Needs `SLACK_BOT_TOKEN` and `SLACK_CHANNEL_ID` in `codebase/.env` (5-minute setup:
`codebase/labs/integrate/SLACK_LIVE_SETUP.md`). The card's button opens dispute 29 in the portal.

### 04 - Selftest Slack MCP Server
*The same Slack tool over real MCP (`meridian_slack_mcp.py`).*
```bash
cd codebase && make slack-mcp
```
Expect: `deduped=True` on the replay, `error=access_denied` for Type-B → Type-A, and `SELFTEST PASS`.

### 04 - Selftest Two Way Slack Bot 🔑
```bash
cd codebase && set -a && source .env && set +a && make slack-bot-test
```
Expect: 8 `[PASS]` lines, `audit rows: 8 (incl. 1 deny)`, and `SELFTEST PASS`. Without the keys loaded, the dispute, ticket and policy checks fail with "no API key configured".

---

## 05 · Evals, Observability & Handover

The release exam, the second grader, the observability check, the incident drill, and teardown.

### 05 - Run Full Golden Gate
*The release exam: `meridian-agent eval --suite golden --min-pass 0.95 --mock`.*
```bash
cd codebase && make golden
```
Expect: `adversarial 13/13 · edge 19/19 · standard 118/118`, and `pass rate: 100% (150/150)  ·  GATE PASSED`.

### 05 - Run Adversarial Cases Only
*Lab I, step 2: adversarial zero tolerance.*
```bash
cd codebase/agent && uv run meridian-agent eval --suite golden --min-pass 0.95 --mock --category adversarial
```
Expect: `pass rate: 100% (13/13)  ·  GATE PASSED`. A single adversarial failure blocks a release, whatever the average.

### 05 - Cross Check With Promptfoo
*Grader 2, command 1 (the agreement runner).*
```bash
cd codebase/labs/prove && npx --yes promptfoo@latest eval -c promptfoo-golden.yaml --no-cache
```
Expect: `✓ 150 passed (100%)`. The second grader agrees with the gate case by case. The first run downloads promptfoo.

### 05 - Run Promptfoo Rubric Grader 🤖
*Grader 2, command 2 (LLM-rubric asserts on a local model, $0).*
```bash
cd codebase/labs/prove && ollama pull llama3.1 && npx --yes promptfoo@latest eval -c promptfoo.yaml --no-cache
```
Expect: 3 scenarios pass. `npx promptfoo@latest view` then shows per-case results in the browser.
No Ollama? Swap in the commented `bedrock:` provider in `promptfoo.yaml`.

### 05 - Check AgentCore Trace Spans ☁️
*OTel spans in CloudWatch: the auditor's path.*
```bash
python3 codebase/labs/prove/check_spans.py --hours 24
aws logs tail /aws/bedrock-agentcore/runtimes/<runtime-id>-DEFAULT --since 1h
```
Needs a deployed AgentCore runtime (*03 - Deploy To AgentCore Runtime*) and AWS credentials.

### 05 - Rehearse The Incident Drill
*Lab II — live incident drill.*
```bash
cd codebase/labs/prove && python3 incident_drill.py --inject-at 30 --rollback-at 75 --requests 100 --fast
rm -f incident_traces.jsonl incident_rca_reference.txt INCIDENT_ON
```
Expect: the live dashboard breaching the 95% SLO at the injection and recovering after the
rollback, then the blanked **RCA SKELETON**. The `rm` cleans up the generated files.
(Live in class: run it without flags, and use `touch INCIDENT_ON` / `rm INCIDENT_ON` in a second terminal.)

### 05 - Stop Database After Class
```bash
cd codebase && make down
```
Stops Postgres. The data survives (`make clean` deletes the volume too). Also stop the
*01 - Serve Ops Console Locally* terminal with <kbd>Ctrl</kbd>+<kbd>C</kbd>. Tear down what you start.
