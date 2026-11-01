---
name: update-tumbleweed
description: Update or maintain this user's openSUSE Tumbleweed setup and maintain one brief Obsidian Tumbleweed note with command blocks. Use for system upgrades, package and repository changes, and setup fixes on this machine.
---

# Tumbleweed maintenance

Keep all documentation in `/home/haaksk/Obsidian/Data/Linux/Tumbleweed.md`. Read it before changing the setup. Use short topic headings and concise, self-contained instructions with fenced command blocks. Include enough explanation and code for the user to repeat the steps later without an agent or this conversation. Update the relevant section in place; do not create separate topic files unless the user asks.

Write reusable setup instructions, not session reports. For example, use “Remove unwanted apps like this:” followed by the command. Omit execution history, dates, dependency-test results, authentication blockers, duplicate-name explanations, and agent activity from the note. Include only caveats that change how the command should be used. Keep execution status and pending work in the conversation; never imply an unexecuted action succeeded. Preserve unrelated useful instructions and avoid secrets or duplicate content.

For each procedure, include the purpose, any necessary prerequisites, commands in execution order, and how to tell it worked. When editing a file, give its exact path, the required changes or complete relevant contents, and any apply/reload/restart command. Explain placeholders and where to obtain required downloads or values. Mention consequential prompts, reboot requirements, or recovery steps only when relevant. Keep this proportional to the task: a simple operation can be one sentence and one command block. Brevity must not omit steps needed to reproduce the result. Before saving, check that the procedure can be followed from the note alone.

Creating this skill did not authorize an upgrade. Carry out the user's requested maintenance scope without expanding to unrelated changes.

## Local context (observed 2026-11-01; recheck)

- Regular Tumbleweed with Btrfs root, Snapper root configuration, and `snapper-zypp-plugin`. Verify snapshot operation before relying on recovery.
- Official, OpenH264, Packman (priority 70), Brave, and VS Code repositories. Preserve priorities and vendors unless a specific change is needed and authorized.
- Flatpak includes Obsidian and RapidRAW; inspect user and system installations.
- Boot uses `sdbootutil`. Preserve `plymouth.enable=0` in `/etc/kernel/cmdline` for a visible LUKS text prompt. Do not apply GRUB instructions or assume GRUB snapshot recovery works.
- Notes document a manual ChatGPT RPM with a bundled DNF repository. Do not assume zypper updates it or reinstall from an old URL; investigate only when in scope.

## Update workflow

1. Inspect OS version, repositories, package locks, free space on `/` and `/boot/efi`, Btrfs usage, Snapper state, and existing failed services. Read the Tumbleweed note. Consult current official guidance for release-specific issues.
2. Refresh and preview:

   ```bash
   sudo zypper refresh
   sudo zypper dup --dry-run --details
   ```

   Use `dup` for Tumbleweed system updates. Review removals, downgrades, vendor changes, and conflicts. Do not bypass signatures, import unverified keys, force solver resolution, or enable global vendor switching to make an update pass. If Packman is out of sync, explain and defer rather than blindly removing codecs or switching vendors. Do not kill a package manager holding a lock.
3. For an authorized upgrade, inspect the transaction summary before accepting and keep the session alive:

   ```bash
   sudo zypper dup --download-in-advance
   ```

   Use a TTY or persistent terminal for a major desktop upgrade when appropriate. If sudo authentication is unavailable, give the exact command to the user; never request a password or claim execution. Stop on unresolved errors rather than repeatedly retrying mutations.
4. When app updates are in scope, inspect Flatpak installations and update the relevant user/system installation. Do not automatically include firmware or language package managers.
5. Check the resulting OS version, snapshots, `sudo zypper ps -s`, and `systemctl --failed`. Compare failures with the baseline. Report restart needs; reboot only if requested or already authorized. For failures, inspect `/var/log/zypp/history` and logs before proposing recovery; do not blindly roll back this sdboot setup.
6. Update the relevant section of `Tumbleweed.md` with brief reusable instructions and command blocks. Report actual results and pending work in the conversation, without adding a session log to the note.

Official reference: https://doc.opensuse.org/documentation/tumbleweed/updating_upgrading_reverting/
