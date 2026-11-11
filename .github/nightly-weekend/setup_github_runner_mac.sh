#!/bin/bash
# Install the GitHub Actions self-hosted runner on jimmy (Mac mini M2) for Mo-Amine93/SVT-AV1-nightly-weekend.
# One runner (8 GB RAM), label R2R-Macos1, run as gitlab-runner like the GitLab Mac runner. It is installed as a
# LaunchDaemon so it runs with nobody logged in (GitHub's own svc.sh on macOS makes a LaunchAgent, which only runs
# while that user is logged in).
#
#   sudo bash setup_github_runner_mac.sh
#
# It asks for the registration token: repo Settings -> Actions -> Runners -> New self-hosted runner.
set -euo pipefail

[ "$(id -u)" = 0 ] || { echo "run it with sudo"; exit 1; }

REPO_URL=https://github.com/Mo-Amine93/SVT-AV1-nightly-weekend
VER=2.338.2
SHA256=25a065af409ffa317ab4d5a3b614dd15fc9c40f2172bc1b35a1b1258e919a388   # from the v2.338.2 release notes
RUNNER_USER=gitlab-runner
BASE=/Users/gitlab-runner
D=$BASE/actions-runner-1
TGZ=$BASE/actions-runner-osx-arm64-$VER.tar.gz
NAME=actions.runner.svt-av1-nightly-weekend
PLIST=/Library/LaunchDaemons/$NAME.plist
# the PATH the GitLab Mac runner gets from gitlab-runner's .bash_profile: pyenv python2, Homebrew cmake/nasm/gtime
RUN_PATH=$BASE/.pyenv/shims:$BASE/.pyenv/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

read -rsp "Registration token: " TOKEN; echo

[ -f "$TGZ" ] || sudo -u $RUNNER_USER curl -fsSL -o "$TGZ" \
    "https://github.com/actions/runner/releases/download/v$VER/actions-runner-osx-arm64-$VER.tar.gz"
echo "$SHA256  $TGZ" | shasum -a 256 -c -

if [ -f "$D/.runner" ]; then
    echo "$D is already configured"
else
    sudo -u $RUNNER_USER mkdir -p "$D"
    sudo -u $RUNNER_USER tar xzf "$TGZ" -C "$D"
    cd "$D"
    sudo -u $RUNNER_USER env HOME=$BASE PATH="$RUN_PATH" PYENV_ROOT=$BASE/.pyenv ./config.sh --unattended \
        --url "$REPO_URL" --token "$TOKEN" --name jimmy-1 --labels R2R-Macos1 --work _work
fi

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$NAME</string>
  <key>UserName</key><string>$RUNNER_USER</string>
  <key>ProgramArguments</key><array><string>$D/run.sh</string></array>
  <key>WorkingDirectory</key><string>$D</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key><string>$BASE</string>
    <key>PATH</key><string>$RUN_PATH</string>
    <key>PYENV_ROOT</key><string>$BASE/.pyenv</string>
  </dict>
  <key>StandardOutPath</key><string>$D/_diag/launchd.out.log</string>
  <key>StandardErrorPath</key><string>$D/_diag/launchd.err.log</string>
</dict>
</plist>
EOF
chown root:wheel "$PLIST"
chmod 644 "$PLIST"
launchctl bootstrap system "$PLIST" 2>/dev/null || launchctl kickstart -k system/$NAME

echo "Done. Check: repo Settings -> Actions -> Runners should list jimmy-1 as Idle with label R2R-Macos1."
