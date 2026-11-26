# Install YANG Paper Reader on Windows

**Stable Windows release: 0.2.1.** These instructions apply to the matching [official release](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/tag/0.2.1) and its Setup, `YANG_Paper_Reader_Setup_0.2.1.exe`.

## 1. Requirements

| Item | Minimum |
| --- | --- |
| Windows | Windows 10 version 1809 or later, or Windows 11; 64-bit, on an Intel or AMD (x64) processor |
| Python | Python 3.12, 64-bit, from python.org |
| GPU | An NVIDIA GPU of compute capability 8.0 or higher, which supports bfloat16 (bf16), such as the GeForce RTX 30, 40 or 50 series |
| GPU driver | NVIDIA driver 576.02 or newer, the driver NVIDIA lists for CUDA 12.9 |
| AI tool | Claude Code 2.1.330 or newer, or Codex 0.171.0 or newer, signed in with your own account |
| Memory | 4 GB of RAM |
| Disk | About 12 GB of free disk space for the program and the parsing runtime |
| Network | An internet connection during setup and for AI requests |

- Parsing runs only on the first NVIDIA GPU (GPU 0); there is no CPU fallback.
- You need no CUDA Toolkit: the runtime setup installs its own CUDA and cuDNN packages.
- On the GeForce RTX 50 series, this release's parsing packages have not been confirmed.
- The disk figure is the size of a completed installation; downloads and extraction need temporary space beyond it.
- The other figures are minimums from the published requirements of Python, CUDA, cuDNN, PaddlePaddle, PaddleOCR-VL, Electron, Claude Code and Codex.
- Recommended: 12 GB of GPU memory or more, the smallest that PaddleOCR-VL's maintainers report running in their [pinned FAQ](https://github.com/PaddlePaddle/PaddleOCR/issues/16823), and the newest driver.

## 2. Get what is missing

The Setup does not install Python, the NVIDIA driver or your AI tool; get what is missing from the official sources below.

### Python

The runtime setup accepts any 64-bit Python 3.12 release.

1. Get the Windows installer (64-bit) from Python's [official release page](https://www.python.org/downloads/release/python-31210/).
2. Install it without replacing or downgrading an existing Python automatically.
3. Open a new PowerShell window and run:

```powershell
py -3.12 --version
py -3.12 -c "import struct; print(struct.calcsize('P') * 8)"
```

4. Check for Python 3.12.x and `64`.

- **Limit:** another major or minor Python version, or a 32-bit installation, cannot run the parsing.

### GPU and disk space

Check the GPU and the free disk space.

1. Install the GPU's driver from [NVIDIA](https://www.nvidia.com/en-us/drivers/) if needed.
2. If your runtime folder will be on another drive, replace `C` in the second line below.
3. Run these two lines in PowerShell:

```powershell
nvidia-smi
(Get-PSDrive C).Free / 1GB
```

### Your AI tool and account

Install Claude Code or Codex, and sign in.

1. Follow the vendor's current procedure: [Claude Code's native Windows setup](https://code.claude.com/docs/en/setup#install-on-native-windows) or [OpenAI's Codex CLI instructions](https://developers.openai.com/codex/cli/).
2. Check it with `claude --version` or `codex --version`.
3. Sign in yourself through the vendor's flow.

- A browser login or desktop application alone does not establish that the Reader finds the command-line tool.
- **Limit:** with Claude Code older than 2.1.330 or Codex older than 0.171.0, AI Settings asks for an update; no AI request goes through it.

## 3. Install with the Setup

The Setup installs the program for your Windows account and asks for no administrator rights. Take it and this guide only from the official repository and its release page.

1. The Setup's SHA-256 is 02677ad7e676b5c1ae89fbc9cd974bffca06b6b31f6b1eb050f1ffcbf0bafe3e. In PowerShell, run the two lines below; they download the Setup and start it only when its SHA-256 matches.

```powershell
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/download/0.2.1/YANG_Paper_Reader_Setup_0.2.1.exe -OutFile .\YANG_Paper_Reader_Setup_0.2.1.exe
if ((Get-FileHash .\YANG_Paper_Reader_Setup_0.2.1.exe -Algorithm SHA256).Hash -eq '02677ad7e676b5c1ae89fbc9cd974bffca06b6b31f6b1eb050f1ffcbf0bafe3e') { Start-Process .\YANG_Paper_Reader_Setup_0.2.1.exe } else { Write-Error 'The SHA-256 does not match. Do not run this file.' }
```

2. If Windows shows "Windows protected your PC" for a Setup whose SHA-256 matched, choose **More info**, then **Run anyway**.
3. On **License Agreement**, read the license.
4. Go on from **Select Destination Location**, which shows the program folder; an update skips this page.
5. On **Parsing Runtime Folder**, choose a new or empty folder, or an earlier installation's runtime folder, whose runtime is not downloaded again.
6. On **Requirements**, read its checks; none stops the installation, and a missing tool shows its official link.
7. Keep or change the box **Set up the parsing runtime at the end of Setup**, checked at first when Python and the GPU pass.
8. On **Ready to Install**, check the runtime folder and whether the runtime setup runs.
9. With the box checked, wait while the runtime setup downloads packages and models; this can take a long time.
10. On the last page, read whether the parsing runtime is ready.
11. Start the Reader as section 4 says.

- The first time, **Parsing Runtime Folder** proposes `C:\YANG_Paper_Reader_Runtime`, or `C:\Reader_Runtime` when it finds an earlier version's runtime there.
- With the box unchecked, **Set Up Parsing Runtime** in the Start menu sets the runtime up later.
- **Limit:** the runtime folder lies on a local fixed drive, apart from the program folder, with at most 60 characters and no spaces.
- **Limit:** it may not be a linked, synchronized or network folder, or hold files the runtime setup did not make.
- **Limit:** the Setup and the program are not code-signed; while Smart App Control is on, Windows blocks them and allows no exception.
- **If it stops:** when the parsing runtime is not ready, follow section 5.

A matching SHA-256 shows that the file is the one this guide names, not that its source can be trusted. The Setup is built with Inno Setup, whose site is [jrsoftware.org](https://jrsoftware.org/).

The Setup's script, `install/YANG_Paper_Reader.iss`, is readable under AGPL-3.0-or-later, with its [AGPL text](install/COPYING) and [license scope](install/LICENSE-SCOPE.md); the application has its own [LICENSE](LICENSE).

## 4. Start the Reader for the first time

Check the Reader once before the first paper.

1. Start **YANG Paper Reader** from the Start menu.
2. Read the installed `LICENSE.txt`, `NOTICE.txt` and `THIRD_PARTY_NOTICES.txt` in the program folder.
3. Do not open a paper at this first start.
4. Check **Ready to Read** and **AI Settings**.
5. If AI Settings shows your AI tool as **Unavailable**, open **Where the Reader Looked** there and follow the vendor's guidance.

- From the Start menu, **User Manual** and **Install Guide** open the installed manual and this guide in your web browser, offline.
- In the Reader's Information dialog, **User Manual** opens the manual too.
- **If it stops:** if Windows warns about or blocks the Reader, keep the exact message and respect organizational protections.

### Before you open a paper

Decide what opening a paper may send.

1. Choose a paper you may transmit, and accept the account usage before you open it.
2. To send neither summary by itself, turn off **Start the Paper Summary by itself** in **General Settings** before you open a paper.
3. Read section 1 of the [manual](MANUAL.md).

- **Sent:** opening a new PDF, with the switch on as at first, can send every page's text for a Paper Summary.
- **Sent:** then parsed text and selected source images for a Summary Update, both through your own AI account.
- **Sent:** bibliographic details go to public lookup services.

## 5. If the runtime setup fails

The runtime setup installs 111 pinned Python packages, downloads and verifies two models, and checks the GPU.

1. Keep the failed step, the error and the logs, and fix the cause as the table below says.
2. Run **Set Up Parsing Runtime** from the Start menu, or run the Setup again, which also lets you choose another runtime folder.

| What failed | What to do |
| --- | --- |
| Python 3.12 was not found | Install Python 3.12, 64-bit (section 2). |
| The runtime folder holds files that the runtime setup did not make | Run the Setup again with a new or empty runtime folder; do not clear an unrelated folder. |
| Package or model failure | Read `logs\packages.log` or `logs\models.log`; keep package pins and model revisions. |
| GPU, import/DLL, numerical or timeout failure | Read `logs\preflight.log` and any `preflight.pending.json`, which does not mean the check passed. |
| Audit failure | Read The audit step below. |

- The logs are in the runtime folder.
- The runtime setup ends with `Runtime ready.` when its checks passed; that verifies no paper or AI request.
- A retry reuses verified downloads and downloads incomplete or damaged packages again.
- **Limit:** the GPU check stops the runtime setup when the GPU cannot run the parser; an earlier pass does not count.
- **Limit:** the GPU check stops after 180 seconds.

### The audit step

The audit step checks the installed packages against the pinned lock and the package list shipped with the Reader.

1. When the audit fails, keep `artifact-audit.pending.json` and `logs\audit.log` from the runtime folder.
2. Report the exact error.

- **Sent:** the audit makes no external request; the package and model downloads are separate network stages.

## 6. Update with a new Setup

A new version's Setup installs over the earlier one.

1. Close the Reader.
2. Run the Setup of the new version.

- It installs into the same program folder and proposes the runtime folder you chose before.
- With its box checked, the runtime setup runs again, reusing what is still valid.
- Your notes, answers, settings and parsing data stay in `%APPDATA%\YANG Paper Reader`.

If you installed an earlier version with the PowerShell installer:

1. Close that Reader.
2. Install 0.2.1 with the Setup, and give **Parsing Runtime Folder** the runtime folder you already downloaded.
3. Delete the old program folder yourself.

## 7. Uninstall

Uninstalling removes the program, not your data.

1. Uninstall **YANG Paper Reader** from the list of installed apps in Windows Settings.
2. To remove your data and the runtime too, keep copies of the records you want, then delete both folders yourself.

- It removes the program folder, its Start-menu entries and its entry in that list.
- It leaves `%APPDATA%\YANG Paper Reader`, which holds your data, and the runtime folder.
- It leaves Python, the NVIDIA driver, your AI tool and the HTML Overviews you saved.
- It leaves in `%TEMP%` each Setup run's log and a folder of about 7 MB ending in `-uninstall.tmp`, which you can delete.

## 8. Report a problem

1. Review the logs for paper content and personal paths before you share them.
2. Report through the official repository what was installed, the exact versions, the failed step and the log locations.

- These instructions do not establish that the Reader installs and runs on every PC or that an AI request succeeds.
