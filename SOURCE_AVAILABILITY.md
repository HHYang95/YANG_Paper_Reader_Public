# Third-party source availability

These source companions accompany release `0.1.2-public.1` in the [official repository's Releases](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases). Use the matching release page and the exact files below. The application installer does not need to download these sources to run the Reader. Recipients receive them under their upstream terms.

| Component | Source asset | SHA-256 |
| --- | --- | --- |
| Electron 44.4.5 FFmpeg/Opus source companion | [YANG_Paper_Reader-FFmpeg-source-electron-44.4.5-s02.zip](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/download/0.1.2-public.1/YANG_Paper_Reader-FFmpeg-source-electron-44.4.5-s02.zip) | `9d979a39fcd374322bb1f0932b283e02e9b74335e538255f6a765a510e594b86` |
| Canvas 1.0.11 MPL source companion | [YANG_Paper_Reader-MPL-sources-canvas-1.0.11-s02.zip](https://github.com/HHYang95/YANG_Paper_Reader_Public/releases/download/0.1.2-public.1/YANG_Paper_Reader-MPL-sources-canvas-1.0.11-s02.zip) | `bed2eaf863b500c41e8c66f2339b9dad8610f08340ee04e974bc8c5b47b4b3d5` |

## FFmpeg and Opus

The companion contains the full Chromium FFmpeg snapshot at `2b68d2babae73714846961fb0ee47e3b3d2e39a9`, Chromium 152.0.7977.130's Opus copy, Electron v44.4.5's FFmpeg patch, selected build inputs, original notices and a source manifest. Its size is 23,101,190 bytes. The packaged separate `ffmpeg.dll` is 3,113,472 bytes with SHA-256 `22e07be5d900ecad1fa47cbd9f783143af0058e18793b4804b887253988273ac`.

Official version/configuration metadata supports source selection. This is not a reproduced-DLL claim or verification of every recursive build input. The full Chromium/Electron development environment is not bundled or build-verified. The included `licenses/FFMPEG_SOURCE_README.md` preserves detailed source/build references and the qualification of that preparation.

The distribution uses equivalent source access from the binary download location under LGPL-2.1 section 4 and a separate shared library under section 6(b). Replacement of `ffmpeg.dll` with an interface-compatible modified build, and debugging modifications to that library, remain permitted by the applicable license and application LICENSE section 5. Close the Reader before replacing the DLL and preserve your original copy. Compatible replacement has not been tested here; this notice does not certify behavior of a modified build. No application-object offer is substituted for the stated shared-library route.

## MPL-2.0 components in canvas

The 226,274-byte companion includes complete original registry archives, expanded sources and original MPL notices for cssparser 0.38.0, cssparser-color 0.6.0, cssparser-macros 0.7.0 and dtoa-short 0.3.5. Their archive hashes match canvas commit `adce718ec8ff82f9e896875752fd621c46b1c04e` Cargo.lock and the native package's exact SBOM entries. Inspected metadata supplies no concrete evidence of modified crate sources. This correspondence is not reproduction of the native binary. The included `licenses/MPL_SOURCE_README.md` supplies the individual upstream URLs and hashes.

Covered sources remain under MPL-2.0 sections 3.1-3.3; the larger application's first-party terms do not restrict those source rights. Retain source access for recipients of each distributed version. If future builds modify covered sources, those modifications must also be supplied under the applicable terms.

## Independent installation source

The complete source for the independent AGPL-3.0-or-later installation script is [install/Install-Reader.ps1 in the public repository](https://github.com/HHYang95/YANG_Paper_Reader_Public/blob/0.1.2-public.1/install/Install-Reader.ps1), with its [license](https://github.com/HHYang95/YANG_Paper_Reader_Public/blob/0.1.2-public.1/install/COPYING) and [scope](https://github.com/HHYang95/YANG_Paper_Reader_Public/blob/0.1.2-public.1/install/LICENSE-SCOPE.md). The protected application's main source is not included. Its small existing startup wrappers retain their separately stated application terms.

Original copyright, license and patent notices remain unchanged. The companions were prepared before publication; historical preparation wording inside them does not change the source contents or upstream rights. Actual public download access must accompany any distributed binary version.
