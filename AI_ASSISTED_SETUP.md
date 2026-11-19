# Install with help from your Claude or Codex

**Stable Windows release: 0.1.3.** Start from the [official repository](https://github.com/HHYang95/YANG_Paper_Reader_Public) and its matching release. Verify actual download availability and each installation result; do not infer them from the existence of these instructions.

Read [INSTALL_GUIDE.md](INSTALL_GUIDE.md) first. The Reader's small public installer downloads and verifies the compiled/obfuscated program, places it, then runs its pinned runtime setup. The main source remains private. Small readable startup files in the application retain the application's terms; the independent public installer alone uses AGPL-3.0-or-later. Python, the NVIDIA driver and your AI command-line tool are separate choices using official vendor instructions; account sign-in remains yours.

## Checklist

1. Confirm the official release is published and that the repository's script and `release.json` describe the intended version. Git is optional: **Code > Download ZIP** supplies repository files, not a manual program handoff.
2. Inspect the script and metadata. Choose a new short local program directory and a separate runtime directory. Preserve existing installations and records; do not use linked/network paths or overlapping destinations.
3. Check native Windows 64-bit, Python 3.12 x64, NVIDIA GPU/driver visibility and disk space. Use the guide's official Python, NVIDIA, Claude Code and Codex links. Do not silently replace Python, install a compiler or disable a security policy.
4. Choose normal installation or `-DownloadOnly`. Normal mode runs pinned runtime setup and a fresh synthetic preflight. DownloadOnly only verifies and places the program; it performs no runtime setup or application launch.
5. If the program download stops, restore the connection and run the same installer command with the original program path to recover the transfer. If runtime setup fails after program placement, keep the placed program, read the stage and logs, and retry its setup command as described in the installation guide.
6. Sign in yourself through the AI vendor. The assistant may check version/discovery, but must not collect credentials, tokens, authentication files or browser-session data.
7. You manually launch the Reader after successful setup. Check Ready to Read and AI Settings without opening a paper, then stop. An unexpected restored paper or processing is a reason to close and report it. Choose any paper or AI trial separately.
8. Record observed versions, paths, results, logs and unknowns. A plan, old measurement, version string or synthetic check is not proof of a successful clean-machine installation or AI request.

## Copyable prompt

```text
Help me install YANG Paper Reader from https://github.com/HHYang95/YANG_Paper_Reader_Public using README.md, INSTALL_GUIDE.md and AI_ASSISTED_SETUP.md.

First check the public release status. The target is 0.1.3; do not claim it is available merely because the files describe it. Read the official script, release.json and license scope. Do not build the private application source or invent download URLs. Git is optional for obtaining the repository files.

Explain the exact changes before running installation commands. Keep the protected application and its minimal readable startup files under their application terms, separate from the independent AGPL-3.0-or-later installer. Preserve third-party rights and supplied notices.

Check native Windows 64-bit, Python 3.12 x64 and NVIDIA GPU/driver visibility. Record the exact Python patch; 3.12.10 is historical test evidence, not the latest security release. Use official current vendor instructions for missing external tools, without automatically replacing an existing Python, installing unrelated build tools or signing into my AI account.

Explain that local parsing uses GPU 0 and bf16 with no CPU fallback. Historical VRAM figures are not minimum-hardware guarantees. Rendering and my external AI service are separate from local parsing.

Choose a new short local InstallPath and a separate RuntimePath with me. From the repository folder, the normal command is:
powershell -NoProfile -File .\install\Install-Reader.ps1 -InstallPath C:\Reader\0.1.3 -RuntimePath C:\Reader_Runtime

If I choose acquisition/placement only, use -DownloadOnly and omit RuntimePath. This is not completed runtime setup. Follow the guide's unsigned-script instructions without globally changing execution policy or overriding organization policy.

Preserve full archive hash/size checks, safe extraction, package pins and model revisions. Do not substitute a latest release, alter verification, add CPU fallback or change precision to suppress a failure. Full runtime setup must run a fresh synthetic preflight; --profile-only is not a current compatibility check.

If runtime setup fails, preserve the placed program and read the stage, error and named logs. Retry its resources\backend\setup_runtime.cmd only after resolving the cause; do not reinstall into the occupied InstallPath or delete runtime data automatically.

Leave sign-in and the final Reader launch to me. Do not open a paper or start a Reader AI request as an installation check. Explain automatic Summary requests and public metadata lookup before any separately chosen paper trial.

Finish with exactly what changed, checks actually run, results, log paths and remaining limits. Do not claim GPU, AI, clean-machine or broad compatibility success from old evidence or synthetic tests.
```

## Patch installation checks

For 0.1.3, follow the installation guide's update instructions. Preserve the previous program and diagnostic evidence. Audit uses the shipped release catalog locally; downloads of the program, packages and models remain separate network operations. Read `artifact-audit.pending.json` and `logs/audit.log` for an Audit failure. Do not disable antivirus or bypass hash checks. A completed setup does not establish the tester's parsing or Summary result.
