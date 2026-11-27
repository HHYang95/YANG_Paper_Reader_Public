# YANG Paper Reader

YANG Paper Reader is a standalone Windows application for reading research PDFs, local parsing, notes, and assistance through your own Claude Code or Codex account.

Watch the 2:30 introduction on YouTube: [YANG Paper Reader](https://www.youtube.com/watch?v=LzsCjgvVZKQ).

**Stable Windows release: 0.2.1.** Use the matching [official release](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/tag/0.2.1) and the installation instructions below. Confirm that the release contains its assets before you install. These instructions do not establish successful installation or hardware compatibility on your PC.

## Start here

Use this [official repository](https://github.com/HHYang95/YANG_Paper_Reader_Public) as the starting point. The main application logic is compiled and obfuscated, and its source remains private. Six small Python startup wrappers and one Windows command file are readable and remain under the application's terms. The Setup's script, the independent installation source, is publicly readable under AGPL-3.0-or-later.

Read the [installation guide](INSTALL_GUIDE.md) and the requirements below. You install the Reader with its Setup.

Download `YANG_Paper_Reader_Setup_0.2.1.exe` from the [0.2.1 release](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/tag/0.2.1). Its SHA-256 is 02677ad7e676b5c1ae89fbc9cd974bffca06b6b31f6b1eb050f1ffcbf0bafe3e; check it before you run the file, as the two PowerShell lines of the installation guide do. The Setup installs the program for your Windows account without administrator rights. It checks Python, the NVIDIA GPU and its driver, Claude Code or Codex and the free disk space, with a link for a missing tool, and runs the parsing runtime setup at its end. Then start the Reader from the Start menu. The Setup and the program are not code-signed: Windows may ask you to choose More info, then Run anyway, and while Smart App Control is on they cannot run.

Install Python 3.12 (64-bit), the NVIDIA driver and your AI command-line tool separately, from their official instructions; the Setup does not install them, sign in or start the Reader. The installed program also holds the manual and the installation guide as pages that open in your web browser without an internet connection: User Manual and Install Guide in the Start menu open them, and User Manual in the Reader's Information dialog opens the manual.

## Requirements and data use

Requirements:

- Windows 10 version 1809 or later, or Windows 11, 64-bit (x64)
- Python 3.12, 64-bit
- An NVIDIA GPU of compute capability 8.0 or higher, which supports bfloat16 (bf16), such as the GeForce RTX 30, 40 or 50 series, with NVIDIA driver 576.02 or newer
- Claude Code 2.1.330 or newer, or Codex 0.171.0 or newer, signed in with your own account
- 4 GB of RAM, about 12 GB of free disk space for the program and the parsing runtime, and an internet connection during setup and for AI requests

Recommended: 12 GB of GPU memory or more, the figure that the maintainers of PaddleOCR-VL, the parsing tool, give in their pinned FAQ as the smallest configuration they have run.

Local parsing uses the first visible NVIDIA GPU (GPU 0), CUDA and bfloat16 (bf16); there is no CPU fallback. The minimums come from the published requirements of the tools the Reader uses, which the installation guide names, and the disk space is the size of a completed installation of the program and the parsing runtime.

Opening a paper is a separate choice after installation: while Start the Paper Summary by itself is on, as it is at first, it can automatically send paper text and selected images to your own AI provider for the Paper Summary and its Summary Update, and it sends bibliographic details to public lookup services. Setup does not open papers. After full Background Parsing, you can export the HTML Overview locally. Read the [manual](MANUAL.md) before you open your first paper.

If your own Claude/Codex helps with installation, give it [AI_ASSISTED_SETUP.md](AI_ASSISTED_SETUP.md). Keep account sign-in and credentials under your control.

## Limits and what to check

YANG Paper Reader parses your PDF on your PC, and your own AI writes every answer; both can be wrong. Parsing can misread equations, tables and symbols, and it does not read text inside figures. The headings and captions it detects are not verified. Parsed Text and Equation transcriptions mark what they could not confirm against the PDF's own text. A scanned page has no text to find or select; its text comes only from full parsing. For each answer, the Reader checks that every quotation appears in the text the request sent. After full parsing that is mostly the parsed text, which can differ from the printed page. Sources marks a source whose quotation could not be matched to the text of its page as Check in the paper, with its page: the Reader could not match the AI's quotation to that page, so open the page and check the passage. An answer with such a source is still shown, unless none of its sources could be matched; an image of the paper it cites, such as a Figure or Table, counts as matched. The Reader does not check the AI's own sentences, numbers, formulas, translations or extracted table values, or what it says about a figure or table. A PDF of more than 200 pages does not open, and the Paper Summary and Auto Highlight, which send the text of every page, are refused for a paper of more than 48 pages. Before you rely on an answer, open its sources and compare them with the page.

## Terms and support

- The application and its documentation use the [research and education terms](LICENSE): noncommercial research, teaching and learning are free; commercial use needs separate permission.
- The Setup's script, `install/YANG_Paper_Reader.iss`, the independent installation source, uses [AGPL-3.0-or-later](install/COPYING). Its [license scope](install/LICENSE-SCOPE.md) does not relicense the private application.
- Third-party components keep their original rights. The installed program includes `LICENSE.txt`, `NOTICE.txt`, `THIRD_PARTY_NOTICES.txt` and the referenced license/source information. Keep them with the program.

Share the official repository link. When reporting a problem there, include the version, failed stage and exact error, after removing paper content and personal details from logs. Installation checks do not certify every Windows/GPU combination or a successful AI request.

## Changes in 0.2.1

- Figures can now include both side callouts and their text when their pointers identify the same illustration.
- A heading inside a matched callout stays with the figure when you reopen a saved parse. Nearby article headings keep their section actions.
