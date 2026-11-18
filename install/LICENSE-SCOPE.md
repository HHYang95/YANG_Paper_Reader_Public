# Installation code license

Copyright (c) 2026 Hyeon-Ho Yang.

`Install-Reader.ps1` is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See [COPYING](COPYING) for the full license.

The script's complete source is this repository's `install/Install-Reader.ps1`. It uses Windows/.NET facilities, retrieves the separately distributed application, checks and places its files, and may start that application's documented setup command as a separate process. It contains none of the Reader's main implementation.

This license applies to the independent installation script only. The downloaded Reader and its small startup wrappers are separately licensed under the [application license](../LICENSE); third-party components retain their own licenses. Installing them with this script does not change their terms. The public repository supplies the installer source with every matching release tag.
