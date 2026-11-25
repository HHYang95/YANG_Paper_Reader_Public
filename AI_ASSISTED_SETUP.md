# Install with help from your Claude or Codex

**Stable Windows release: 0.2.0.** Start from the [official repository](https://github.com/HHYang95/YANG_Paper_Reader_Public) and its matching release. Verify actual download availability and each installation result; do not infer them from the existence of these instructions.

Read [INSTALL_GUIDE.md](INSTALL_GUIDE.md) first. You install the Reader with its Setup, `YANG_Paper_Reader_Setup_0.2.0.exe`, which holds the compiled and obfuscated program, installs it and runs its pinned runtime setup at its end. Your AI can help you check the requirements, download the Setup and check its SHA-256 with the guide's two lines, and read the logs after a failure; you go through the Setup's pages, sign in and start the Reader yourself. The main source remains private. Small readable startup files in the application retain the application's terms; the Setup's script alone uses AGPL-3.0-or-later. Python, the NVIDIA driver and your AI command-line tool are separate installations from official vendor instructions; account sign-in remains yours.

## Checklist

1. Confirm that the official release 0.2.0 is published and that its page holds `YANG_Paper_Reader_Setup_0.2.0.exe`.
2. Check native Windows 64-bit, Python 3.12 x64, NVIDIA GPU and driver visibility, Claude Code or Codex and disk space against the guide's requirements. Use the guide's official Python, NVIDIA, Claude Code and Codex links. Do not silently replace Python, install a compiler or disable a security policy.
3. Download the Setup with the first of the guide's two PowerShell lines and check its SHA-256 with the second, which starts the Setup only when the SHA-256 matches. Run no installer silently and no remote script.
4. Go through the Setup's pages yourself: the program folder, a new or empty runtime folder or the runtime folder of an earlier installation, and the Requirements page with its box Set up the parsing runtime at the end of Setup. With that box checked, the runtime setup runs at the end of the Setup and ends with a GPU check.
5. If the runtime setup fails, the program stays installed. Read the lines the Setup's last page shows, the `logs` folder in the runtime folder and the log of the Setup that the page names, and resolve the cause; then run Set Up Parsing Runtime from the Start menu, or run the Setup again. Do not delete runtime data automatically.
6. Sign in yourself through the AI vendor. The assistant may check version and discovery, but must not collect credentials, tokens, authentication files or browser-session data.
7. You start the Reader from the Start menu after successful setup. Check Ready to Read and AI Settings without opening a paper, then stop. An unexpected restored paper or processing is a reason to close it and report it as a problem in the official repository. Open a paper or make an AI request only later, as a separate choice.
8. Record observed versions, paths, results, logs and unknowns. A plan, an old measurement, a version string or a passed setup check does not prove that the installation works on this PC or that an AI request succeeds.

## Copyable prompt

```text
Help me install YANG Paper Reader from https://github.com/HHYang95/YANG_Paper_Reader_Public using README.md, INSTALL_GUIDE.md and AI_ASSISTED_SETUP.md.

First check the public release status. The target is 0.2.0; do not claim it is available merely because the files describe it. The Reader installs with its Setup, YANG_Paper_Reader_Setup_0.2.0.exe, from the release page. Do not build the private application source or invent download URLs.

Explain each command before you run it. Keep the protected application and its minimal readable startup files under their application terms, separate from the Setup's script under AGPL-3.0-or-later. Preserve third-party rights and supplied notices.

Check my PC against the requirements in INSTALL_GUIDE.md: Windows, Python 3.12 x64, the NVIDIA GPU and its driver, Claude Code or Codex, and disk space. Record the exact Python version. Use official current vendor instructions for missing external tools, without automatically replacing an existing Python, installing unrelated build tools or signing into my AI account.

Explain that local parsing uses GPU 0 and bf16 with no CPU fallback, and that the GPU memory the guide recommends is a recommendation, not a guarantee. Rendering and my external AI service are separate from local parsing.

Download the Setup and check its SHA-256 with the guide's two PowerShell lines, which start the Setup only when the SHA-256 matches. Run no installer silently and no remote script. I go through the Setup's pages myself.

If the runtime setup fails, read with me the lines the Setup's last page shows, the logs folder in the runtime folder and the log of the Setup that the page names. Help me resolve the cause; then I run Set Up Parsing Runtime from the Start menu, or the Setup again. Do not delete runtime data automatically, alter verification, skip the GPU check, add CPU fallback or change precision to suppress a failure.

Leave sign-in and starting the Reader to me. Do not open a paper or start a Reader AI request as an installation check. Explain automatic Paper Summary requests and public metadata lookup before I open my first paper.

Finish with exactly what changed, checks actually run, results, log paths and remaining limits. Do not claim that the GPU, AI requests or other PCs work from old results or setup checks.
```

## Update checks

To update, follow the installation guide's update instructions: close the Reader and run the new version's Setup over the earlier one. Preserve the logs of the earlier setup. The audit step of the runtime setup compares the installed packages with the package list shipped with the Reader, on this PC; downloads of the Setup, packages and models remain separate network operations. Read `artifact-audit.pending.json` and `logs\audit.log` in the runtime folder for an audit failure. Do not disable antivirus or bypass hash checks. A completed setup does not establish your parsing or Paper Summary result.
