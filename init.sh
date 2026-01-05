#!/usr/bin/env bash

git init -b main
git config user.name "Sim User"
git config user.email "sim@example.com"

commit_at () {
  local d="$1"; shift
  git add -A
  GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git commit -m "$*"
}

# Seed shared hotfix-agent files first so they exist in the base history
mkdir -p .hotfix-agents src docs

cat > .hotfix-agents/AGENTS_chf.md <<'EOF'
# CHF Agent Instructions
- Inspect before acting
- Prefer tenant-scoped hotfixes
- Keep audit trail
EOF

cat > .hotfix-agents/AGENTS_diff.md <<'EOF'
# Diff Guidance
- Show only relevant tenant delta
- Keep fix minimal
EOF

cat > .hotfix-agents/AGENTS_pack.md <<'EOF'
# Pack Guidance
- Bundle only approved CHF commits
EOF

cat > .hotfix-agents/HOTFIX-ORCHESTRATOR.md <<'EOF'
# Hotfix Orchestrator
Coordinates tenant hotfix creation, validation, tagging, and merge-back.
EOF

cat > README.md <<'EOF'
# DDI Manager
EOF

cat > src/app.py <<'EOF'
BRAND = "airlet"

def startup():
    print(f"Welcome to {BRAND}")
EOF

cat > src/network.py <<'EOF'
def dhcp_scope():
    return "scope=small"
EOF

commit_at "2026-01-05T09:00:00" "Seed repo with hotfix agent files and baseline app"

git tag v1.0.0

# Branch lanes from v1.0.0
git branch release/1.0.0
git branch tenant/airtel/1.0.0
git branch tenant/tata/1.0.0
git branch tenant/reliance/1.0.0

# Month 2: normal development on main
cat >> src/app.py <<'EOF'

def login():
    return True
EOF
commit_at "2026-02-03T10:00:00" "Add login flow"

cat >> src/network.py <<'EOF'

def validate_network():
    return True
EOF
commit_at "2026-02-18T11:30:00" "Add network validation"

git tag v1.1.0
git branch release/1.1.0
git branch tenant/airtel/1.1.0
git branch tenant/tata/1.1.0
git branch tenant/reliance/1.1.0

# Month 3: more mainline work
cat >> src/app.py <<'EOF'

def telemetry():
    return {"enabled": True}
EOF
commit_at "2026-03-07T14:00:00" "Add telemetry hook"

# Month 4: another release cut
cat >> src/app.py <<'EOF'

def billing():
    return "billing-ready"
EOF
commit_at "2026-03-22T16:00:00" "Add billing stub"

git tag v1.2.0
git branch release/1.2.0
git branch tenant/airtel/1.2.0
git branch tenant/tata/1.2.0
git branch tenant/reliance/1.2.0

# Month 5: mainline continues
cat >> src/app.py <<'EOF'

def feature_flags():
    return {"multi_tenant": True}
EOF
commit_at "2026-04-10T09:45:00" "Add feature flags for tenant rollout"

# -----------------------
# Airtel CHF
# -----------------------
git switch tenant/airtel/1.0.0
git switch -c hotfix/airtel/branding-correction

perl -0pi -e 's/airlet/Airtel/g' src/app.py
commit_at "2026-05-05T10:20:00" "CHF: correct Airtel branding spelling"

git tag airtel-chf-v1.0.1

git switch tenant/airtel/1.0.0
git merge --no-ff hotfix/airtel/branding-correction -m "Merge Airtel branding CHF into tenant lane"

git switch release/1.0.0
git merge --no-ff hotfix/airtel/branding-correction -m "Backport Airtel branding CHF to release/1.0.0"

# -----------------------
# Tata CHF
# -----------------------
git switch tenant/tata/1.1.0
git switch -c hotfix/tata/dhcp-scope-exhaustion

cat > src/network.py <<'EOF'
def dhcp_scope():
    # widened scope to prevent exhaustion for Tata
    return "scope=large"

def validate_network():
    return True
EOF

commit_at "2026-05-12T15:20:00" "CHF: widen Tata DHCP scope to prevent exhaustion"

git tag tata-chf-v1.1.1

git switch tenant/tata/1.1.0
git merge --no-ff hotfix/tata/dhcp-scope-exhaustion -m "Merge Tata DHCP scope CHF into tenant lane"

git switch release/1.1.0
git merge --no-ff hotfix/tata/dhcp-scope-exhaustion -m "Backport Tata DHCP scope CHF to release/1.1.0"

# Optional: keep main moving
git switch main
cat >> src/app.py <<'EOF'

def audit_log(event):
    return {"event": event}
EOF
commit_at "2026-05-28T12:00:00" "Add audit log helper"

