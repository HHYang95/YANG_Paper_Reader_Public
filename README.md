# YANG Paper Reader

YANG Paper Reader is a standalone Windows application for reading research PDFs, local parsing, notes, and assistance through your own Claude Code or Codex account.

**Windows preview: 0.1.2-public.1.** Use the matching [official release](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/tag/0.1.2-public.1) and the installation instructions below. Confirm that the release contains its program asset before running the installer. These instructions do not establish successful installation or hardware compatibility on your PC.

## Start here

Use this [official repository](https://github.com/HHYang95/YANG_Paper_Reader_Public) as the starting point. The main application logic is compiled and obfuscated, and its source remains private. Six small Python startup wrappers and one Windows command file are readable and remain under the application's terms. The independent installation script is publicly readable under AGPL-3.0-or-later.

1. Read the [installation guide](INSTALL_GUIDE.md), including the Python, NVIDIA GPU/driver and AI-tool requirements.
2. Once the release is published, obtain this repository's documentation, `release.json` and `install/` folder. Git is optional: GitHub's **Code > Download ZIP** downloads these repository files; extract that folder and open PowerShell inside it.
3. Inspect the installation script and version metadata, choose the paths, then run:

```powershell
powershell -NoProfile -File .\install\Install-Reader.ps1 -InstallPath C:\Reader\0.1.2-public.1 -RuntimePath C:\Reader_Runtime
```

The installer fetches the exact version named in `release.json` from this repository's GitHub Releases, verifies the program archive's size and SHA-256, places it in a new folder, and runs the existing pinned runtime setup. You do not build the private source or manually unpack the program archive. GitHub's repository ZIP is only one way to obtain the small setup files; the program archive is handled by the installer.

The Reader installer needs no Git, Node, compiler or external PowerShell module. Install Python 3.12 x64, an appropriate NVIDIA driver and your chosen AI command-line tool separately using their official instructions. The script does not install those tools, sign in or launch the Reader.

For acquisition and placement without runtime setup:

```powershell
powershell -NoProfile -File .\install\Install-Reader.ps1 -InstallPath C:\Reader\0.1.2-public.1 -DownloadOnly
```

This mode does not make the Reader ready to run. See the guide for completing setup later, unsigned-script guidance and recovery after a failure. After successful setup, you manually start the Reader:

```powershell
& 'C:\Reader\0.1.2-public.1\YANG Paper Reader.exe'
```

## Requirements and data use

Local parsing uses the first visible NVIDIA GPU (GPU 0), CUDA and bfloat16 (bf16); there is no CPU fallback. Minimum GPU memory and driver requirements have not been established. Historical measurements and the fresh synthetic compatibility check are explained in the installation guide.

Opening a paper is a separate choice after installation: it can automatically send paper text and selected images to your own AI provider for Summary work, and bibliographic details to public lookup services. Setup does not open papers or use Make Study Guide. Read the [manual](MANUAL.md) before a paper trial.

If your own Claude/Codex helps with installation, give it [AI_ASSISTED_SETUP.md](AI_ASSISTED_SETUP.md). Keep account sign-in and credentials under your control.

## Terms and support

- The application and its documentation use the [research and education terms](LICENSE): noncommercial research, teaching and learning are free; commercial use needs separate permission.
- The independent installation script uses [AGPL-3.0-or-later](install/COPYING). Its [license scope](install/LICENSE-SCOPE.md) does not relicense the private application.
- Third-party components keep their original rights. The installed program includes `LICENSE.txt`, `NOTICE.txt`, `THIRD_PARTY_NOTICES.txt` and the referenced license/source information. Keep them with the program.

Share the official repository link. When reporting a problem there, include the version, failed stage and exact error, after removing paper content and personal details from logs. Installation checks do not certify every Windows/GPU combination, a successful AI request, or a clean-machine deployment.

## Changes in 0.1.1-public.1

- Runtime setup Audit compares the installation report, pinned package lock and shipped release catalog locally. The Audit stage makes no package-index request; package and model acquisition still need network access.
- OCR polygon vertices at most one raster pixel outside a page edge are mapped onto that edge while the original coordinates remain recorded. Coordinates beyond the tolerance still fail validation.
- Whole-paper Summary accepts a complete JSON response wrapped in one Markdown code block, then applies the existing content and citation checks. Invalid content remains an error.

These changes do not establish successful parsing or AI behavior on every tester machine. Report the exact remaining error and stage after retesting.

## Changes in 0.1.2-public.1

- Reference attribution checks first-author and coauthor surnames in supported author-year forms instead of accepting a short prefix of another author.
- Whole-paper Summary accepts LF and CRLF line endings after headings inside JSON claim text, for raw or Markdown-wrapped JSON responses. Bare CR line endings remain invalid; schema, content and citation checks still apply.
- Find discards delayed indexing results after switching documents and refreshes a retained query when the Find panel is reopened.

Retest your original paper and preserve the exact error and stage if a failure remains. Local release verification does not establish real-paper accuracy or compatibility on every machine.
