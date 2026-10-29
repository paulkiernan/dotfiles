---
name: grafana-silence-alerts
description: "Silence firing Grafana unified-alerting alerts (e.g. for a down Kubernetes node) via the built-in Alertmanager API, scoped tightly so unrelated failures still page"
---

# Silencing Grafana alerts

Silences live in Grafana's built-in Alertmanager as runtime state. They are **not** in git, they expire on their own, and they are the right instrument for "quiet this for N days" — editing alert rules in git is not.

## 1. Reach the API

```bash
kubectl port-forward -n monitoring svc/grafana 18080:80
```

Credentials come from the admin secret. **Do not use `-o jsonpath={.data.admin-user}`**: jsonpath parses the hyphen as subtraction and returns an empty string, which surfaces only as a confusing 401. Use `-o json` and decode:

```python
raw = json.loads(subprocess.run(["kubectl","get","secret","-n","monitoring",
    "<grafana-admin-secret>","-o","json"],capture_output=True,text=True).stdout)
USER = base64.b64decode(raw["data"]["admin-user"]).decode().strip()
PW   = base64.b64decode(raw["data"]["admin-password"]).decode().strip()
```

If running from a Python kernel rather than the shell, export `KUBECONFIG` explicitly — the kernel does not inherit the shell's environment.

## 2. Enumerate what is actually firing

```
GET /api/alertmanager/grafana/api/v2/alerts
```

Print each alert's full label set. Sort the alerts into:

- **Directly attributable** — carries a label naming the thing (`node`, `instance`, `pod`).
- **Derived** — caused by the same root problem but carrying no such label (`TargetDown{job=...}`, `KubeDaemonSetRolloutStuck{daemonset=...}`).

## 3. Prove attribution before silencing derived alerts

Never silence a label-less rule on assumption. Query Prometheus through the Grafana datasource proxy and confirm the root cause explains 100% of it:

```
GET /api/datasources/proxy/uid/<uid>/api/v1/query?query=<promql>
```

- `up == 0` → are the only down targets the ones you expect?
- `kube_daemonset_status_desired_number_scheduled` vs `..._number_ready` vs `..._number_misscheduled` → is the gap exactly the dead node?

## 4. Create silences, scoped as narrowly as the labels allow

```
POST /api/alertmanager/grafana/api/v2/silences
{"matchers":[{"name":"node","value":"k8s-worker-04","isRegex":false,"isEqual":true}],
 "startsAt":"<RFC3339 Z>","endsAt":"<RFC3339 Z>","createdBy":"...","comment":"why + what is still covered"}
```

Rules that matter:

- A silence matches an alert only when **every** matcher matches. You cannot OR across different label *names* — a value that appears as `node` on some alerts and `instance` on others needs two silences.
- Regex matchers are **fully anchored**, so `"cilium|spegel"` matches those names exactly.
- Prefer `alertname` + an enumerated regex of exact `pod`/`job`/`daemonset` values over a bare `alertname` matcher. A bare alertname silence blinds you to every future instance of that rule.
- Put the coverage tradeoff in the `comment` — what is hidden, and what still pages.
- Updating a silence = POST with its `id`; Grafana expires the old one and returns a **new** id. Re-list and confirm you have no active duplicate.

## 5. Verify

Wait ~20-30s for the next evaluation, then re-`GET` the alerts and assert `status.state == "suppressed"`. Creating a silence returning 202 is not proof it matched anything — a typo'd matcher silences nothing and looks identical at creation time.
