# Install YANG Paper Reader on Windows

**Windows preview: 0.1.2-public.1.** The following instructions apply to the matching [official release](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/tag/0.1.2-public.1). Confirm that its program asset is available before running the installer. These instructions are not a completed installation or hardware-compatibility result.

## 1. Obtain the repository files

Start at the [official YANG Paper Reader repository](https://github.com/HHYang95/YANG_Paper_Reader_Public). Use a repository revision whose `release.json` identifies version `0.1.2-public.1`.

Git is not required. Choose **Code > Download ZIP**, extract the repository folder, and open PowerShell in the folder containing `release.json` and `install/`. Keep their relative locations intact. This ZIP contains repository documentation and installation files; the installer acquires and unpacks the program itself.

If you already use Git, you may clone the repository instead:

```powershell
git clone https://github.com/HHYang95/YANG_Paper_Reader_Public.git
Set-Location -LiteralPath .\YANG_Paper_Reader_Public
```

Read the application [LICENSE](LICENSE), the installer's [AGPL text](install/COPYING) and [license scope](install/LICENSE-SCOPE.md). The small independent installer is readable under AGPL-3.0-or-later. Main application logic is compiled/obfuscated and its source remains private; the six readable Python startup wrappers and Windows command file retain the application's terms. Third-party terms retain precedence for their components.

## 2. Check the machine and install external tools

Use native 64-bit Windows 10 or 11 and Windows PowerShell 5.1 or PowerShell 7. Compatibility on every Windows build and machine has not been verified.

| Component | What you do | Purpose |
| --- | --- | --- |
| Python 3.12, 64-bit | Install from Python's official sources if needed; keep it installed | Runs the Reader's backend and isolated Python environment |
| NVIDIA GPU and driver | Check the GPU and install its driver from [NVIDIA](https://www.nvidia.com/en-us/drivers/) if needed | Local parsing with CUDA and bf16 |
| Claude Code or Codex CLI | Install one native Windows command-line tool using the vendor instructions; sign in yourself | AI requests through your own account |
| Reader, Electron, PDF.js and native canvas | Acquired by the Reader installer | Application, PDF display and page images |
| Pinned Python packages and two model assets | Acquired by the Reader's runtime setup | Local parsing environment |

The Reader installer does not require Git, Node, a compiler or external PowerShell modules. Nuitka and GCC/MinGW are maintainer build tools. Do not install a compiler to mask an unexplained backend-load failure. Follow any separate prerequisites of your chosen AI tool.

### Python

The backend requires Python 3.12 x64. Python 3.12.10 is the historically tested installer, not the latest security release. Its [official release page](https://www.python.org/downloads/release/python-31210/) identifies newer releases and provides the Windows installer (64-bit). Read the current release information before choosing an installer. Another 3.12 patch is admitted by setup but is not thereby verified; do not replace or downgrade an existing installation automatically.

After installation, open a new PowerShell window:

```powershell
py -3.12 --version
py -3.12 -c "import struct; print(struct.calcsize('P') * 8)"
```

Check for Python 3.12.x and `64`. If the launcher is missing, follow Python's installer guidance for the launcher. A different Python major/minor version or a 32-bit installation cannot satisfy this backend.

### GPU and disk space

```powershell
nvidia-smi
(Get-PSDrive C).Free / 1GB
```

The parser uses GPU 0, the first NVIDIA GPU visible to its runtime. It requires CUDA and bfloat16 (bf16, the model's numerical format), with no CPU fallback. The driver and CUDA runtime packages are different: runtime setup supplies its selected CUDA/cuDNN packages; this guide does not require a separate CUDA Toolkit.

On Hyeon-Ho Yang's PC, an RTX 4090 with 24,564 MiB held up to 9.3 GB of parsing GPU memory for one 15-page paper. Minimum GPU, driver and memory requirements are unknown. Rendering GPU use was not measured; these parser figures do not describe rendering or your external AI service.

Use 12 GB free on the chosen runtime drive, plus the program and temporary download/extraction space, as an initial planning estimate with additional headroom. Historical environment/model sizes were 6.7 GB and 2.1 GB, with at least 2.8 GB of package downloads during setup. Replace `C` in the disk command if you choose another drive.

### Your AI tool and account

Follow [Claude Code's native Windows setup](https://code.claude.com/docs/en/setup#install-on-native-windows) or [OpenAI's Codex CLI instructions](https://developers.openai.com/codex/cli/). Use the vendor's current installation procedure; inspect a downloaded installation script before choosing to execute it. A browser login or desktop application alone does not establish that the command-line tool is discoverable by the Reader.

The Reader admits Claude Code 2.1.302 or newer, or Codex 0.163.0 or newer. These are admission thresholds, not recommendations to install an old version or guarantees for every newer version. Check the tool you installed with `claude --version` or `codex --version`, then sign in yourself through its vendor flow. Version discovery is not authentication or an AI-request test. Never give an installation assistant passwords, tokens, authentication files or browser-session data.

## 3. Inspect the installer and choose paths

From the repository folder:

```powershell
Get-Content -LiteralPath .\release.json
Get-Content -LiteralPath .\install\Install-Reader.ps1
```

Check that the metadata names this repository and version `0.1.2-public.1`. The installer accepts the version-pinned GitHub Releases URL, verifies the full archive size and SHA-256 before extraction, and refuses unsafe archive paths. There is no fallback to a moving latest release. Metadata and script must come from the trusted official repository; a checksum does not independently establish that trust.

Use short absolute paths on a local fixed drive. The program destination must not already exist and is limited to 80 characters; the runtime path is limited to 60 characters with no spaces. Paths containing traversal, reserved names or shell metacharacters are rejected. For example:

- Program: `C:\Reader\0.1.2-public.1`, a new destination.
- Runtime: `C:\Reader_Runtime`, separate from the program and with no spaces.

Do not overlap these paths or place either inside the other. Avoid linked, synchronized or network folders. The installer refuses an occupied program destination and redirected ancestors. Existing runtime files are handled by the backend's ownership checks; neither the installer nor this guide deletes them automatically.

### If Windows blocks the unsigned script

The installer does not silently change execution policy. Inspect the exact official script first. If its downloaded-file mark blocks it, you may unblock only that inspected file:

```powershell
Unblock-File -LiteralPath .\install\Install-Reader.ps1
Get-ExecutionPolicy -List
```

Unblocking does not override `Restricted`, `AllSigned` or organizational policy. If no managed policy forbids it and you choose to allow the inspected local script for this invocation, the section 4 command may use `powershell -NoProfile -ExecutionPolicy RemoteSigned -File` in place of `powershell -NoProfile -File`. This affects that PowerShell process, not the machine/user setting. Group Policy still takes precedence. Stop and consult your administrator if policy requires a signed script; do not use a global policy change or `Bypass` as an installation step. See [Microsoft's execution-policy guidance](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1).

## 4. Install the program and runtime

Close any running Reader and save your work. From the repository folder:

```powershell
powershell -NoProfile -File .\install\Install-Reader.ps1 -InstallPath C:\Reader\0.1.2-public.1 -RuntimePath C:\Reader_Runtime
```

The installer downloads the pinned program archive, checks its size and SHA-256, extracts it into an owned staging folder, checks the required executable/setup files, and places it without overwriting an installation. It then invokes `resources\backend\setup_runtime.cmd` with your runtime path. It does not open the Reader, sign in or change system Python/drivers.

Runtime setup installs 111 pinned Python packages, downloads and verifies two model assets, runs a fresh synthetic GPU preflight, and writes the program's runtime profile. Valid acquisitions can be reused. Its `Runtime ready.` result means the setup's artifact and synthetic-operator checks passed; it does not verify a paper or an AI request. Historical package/model/check work took 26.5 minutes on one PC, not a promised duration.

A setup error is returned as a nonzero installer exit. Keep the failed stage, error and logs. The placed program remains available for diagnosis and setup retry. Do not rerun the installer into that occupied program folder; use section 5.

## 5. DownloadOnly, setup retry and failures

To acquire, verify and place the program without executing runtime setup:

```powershell
powershell -NoProfile -File .\install\Install-Reader.ps1 -InstallPath C:\Reader\0.1.2-public.1 -DownloadOnly
```

`RuntimePath` may be omitted in this mode. No packages/models are installed, no GPU check runs and the application is not launched.

After completing prerequisites, finish setup from the placed program, or retry it after correcting a runtime-setup failure:

```powershell
& 'C:\Reader\0.1.2-public.1\resources\backend\setup_runtime.cmd' 'C:\Reader_Runtime'
```

Every full setup runs a fresh synthetic check, including after a driver, GPU or Reader change. The 180-second preflight process limit is a safety limit, not a minimum-GPU benchmark. The advanced `--profile-only` mode does not recheck current compatibility.

| Failed stage or observation | Next action |
| --- | --- |
| Release not published, download missing or interrupted | Check the official release status and exact error. Do not invent another URL or use an unofficial mirror. |
| Archive size/hash mismatch or unsafe entry | Stop. Keep the metadata and error for diagnosis; do not disable verification or extract the rejected archive manually. |
| Program destination occupied or paths rejected | Choose a new ordinary local destination and separate runtime path. Preserve existing files. |
| Runtime folder contains unowned files | Choose a new empty runtime folder. Do not clear an unrelated folder to pass the check. |
| Package or model failure | Read `C:\Reader_Runtime\logs\packages.log` or `models.log` for the actual network, hash, permission or space error. Keep package pins/model revisions. |
| GPU, import/DLL, numerical or timeout failure | Read `logs\preflight.log` and, if present, `preflight.pending.json` under the runtime folder. A pending report is diagnostic, not accepted readiness. Distinguish hardware, driver, package and load errors before retrying. |

A failed fresh check does not reuse an earlier successful preflight. Do not infer unsupported hardware from an unexplained failure, change precision, add CPU fallback or install arbitrary replacements. To change the runtime location, keep the old folder and run full setup with a new empty one.

## 6. Start the Reader yourself

Only after successful runtime setup:

```powershell
& 'C:\Reader\0.1.2-public.1\YANG Paper Reader.exe'
```

Read the installed `LICENSE.txt`, `NOTICE.txt` and `THIRD_PARTY_NOTICES.txt`. The application is unsigned; Windows may warn or block it. Keep the exact message and respect organizational protections.

Do not open a paper during this startup check. If the Reader restores a recent paper or starts work, close it through any confirmation and report what happened. Check Ready to Read and AI Settings. If your runtime is unavailable, use **Where the Reader Looked** and the vendor's setup guidance. The installer itself never performs this launch.

## 7. Choose a paper trial separately

Opening a new PDF can automatically send every page's text for a Summary, then parsed text and selected source images for an update, through your own AI account. Bibliographic details also go to public lookup services. Choose a paper you may transmit and accept the account usage before opening it; read [MANUAL.md](MANUAL.md), section 1.

Do not use Make Study Guide as an installation test. A synthetic check or successful startup does not establish paper accuracy, account access, an AI result or broad hardware compatibility.

## 8. Upgrade or remove

For an upgrade, obtain the official repository files/metadata for the new published version and choose a new version-specific program directory. Close the old Reader. A compatible previously owned runtime folder may reuse valid downloads, but full setup checks it again. Use a new runtime directory if you need to preserve the old runtime unchanged. Keep old program/data folders until you decide they are no longer needed.

The installer does not delete old versions or user data. The program directory, runtime directory, and `%APPDATA%\YANG Paper Reader` user records are separate. The latter includes notes, answers, parsing data and study guides. Back up records before choosing any removal; exported HTML Overviews remain where you saved them. Verify each exact folder and whether another release uses it before removing anything. Python and your AI tool are separate installations.

Report what was actually installed, exact versions, the failed stage/exit result and log locations. Review logs for paper content and personal paths before sharing them through the official repository. No clean-machine installation, compiler-free backend load on another PC, or live AI trial is established by these instructions.

### Updating an existing installation

Keep the previous program folder and obtain the repository files for 0.1.2-public.1. Use a new program destination such as `C:\Reader\0.1.2-public.1`; the installer refuses an occupied program destination. Close the Reader before setup. The existing Reader-owned runtime folder may be reused only through the normal full setup path, which runs the offline Audit and synthetic preflight again. Keep the previous runtime evidence if diagnosis is in progress. For an isolated installation, choose a new empty runtime folder. Do not remove an unrelated folder or reset paper data to make setup pass.

### Local Audit and its evidence limits

The setup Audit compares the local pip installation report against the pinned lock and `resources/backend/release-audit-catalog.json`. It rejects missing, extra or differing package identities, URLs and SHA-256 values. It makes no external request. Program, package and model acquisition are separate network stages; offline Audit does not mean the whole installation is offline.

The catalog records its verification date in `verified_utc`; it captures release-preparation status, not current withdrawal status or a vulnerability scan. PaddlePaddle uses official index-entry evidence and the locked acquired-wheel hash because its index does not provide the PyPI withdrawal field or a full wheel hash. Preserve `artifact-audit.pending.json` and `logs/audit.log` when Audit fails, and report the exact error. Do not disable antivirus, bypass Audit, replace package pins or invent an alternative download source.
