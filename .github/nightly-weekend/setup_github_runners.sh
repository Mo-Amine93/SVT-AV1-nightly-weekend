#!/bin/bash
# Install 4 GitHub Actions self-hosted runners on this supermicro for Mo-Amine93/SVT-AV1-nightly-weekend
# (4 copies = the 4 jobs at once the GitLab runner ran with concurrent = 4). They run as gitlab-runner, like the
# GitLab runner, so the jobs keep their access to /home/CI_Script, the clips and /dev/shm/bitstreams.
#
#   sudo bash setup_github_runners.sh Ubuntu10      # supermicro1 = Ubuntu10, 2 = Ubuntu11, 3 = Ubuntu12, 4 = Ubuntu13
#
# It asks for the registration token: repo Settings -> Actions -> Runners -> New self-hosted runner
# (the token after --token on that page; it works for 1 hour and for all 4 machines).
set -euo pipefail

LABEL=${1:-}
case "$LABEL" in Ubuntu10|Ubuntu11|Ubuntu12|Ubuntu13) ;; *) echo "usage: sudo bash $0 Ubuntu10|Ubuntu11|Ubuntu12|Ubuntu13"; exit 1;; esac
[ "$(id -u)" = 0 ] || { echo "run it with sudo"; exit 1; }

REPO_URL=https://github.com/Mo-Amine93/SVT-AV1-nightly-weekend
VER=2.338.2
SHA256=baebf204307bac6193480852732f0aba2ae97b6c5597c244f4d5558390147c40   # from the v2.338.2 release notes
RUNNER_USER=gitlab-runner
BASE=/home/gitlab-runner
TGZ=$BASE/actions-runner-linux-x64-$VER.tar.gz

read -rsp "Registration token: " TOKEN; echo

[ -f "$TGZ" ] || sudo -u $RUNNER_USER curl -fsSL -o "$TGZ" \
    "https://github.com/actions/runner/releases/download/v$VER/actions-runner-linux-x64-$VER.tar.gz"
echo "$SHA256  $TGZ" | sha256sum -c -

for i in 1 2 3 4; do
    D=$BASE/actions-runner-$i
    if [ -f "$D/.runner" ]; then echo "$D is already configured, skipping"; continue; fi
    sudo -u $RUNNER_USER mkdir -p "$D"
    sudo -u $RUNNER_USER tar xzf "$TGZ" -C "$D"
    cd "$D"
    [ "$i" = 1 ] && ./bin/installdependencies.sh
    sudo -u $RUNNER_USER ./config.sh --unattended --url "$REPO_URL" --token "$TOKEN" \
        --name "$(hostname)-$i" --labels "$LABEL" --work _work
    ./svc.sh install $RUNNER_USER
    ./svc.sh start
done

echo "Done. Check: repo Settings -> Actions -> Runners should list $(hostname)-1..4 as Idle with label $LABEL."
