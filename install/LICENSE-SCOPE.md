# Installation code license

Copyright (c) 2026 Hyeon-Ho Yang.

`YANG_Paper_Reader.iss`, the Setup's script, is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See [COPYING](COPYING) for the full license.

The script's complete source is this repository's `install/YANG_Paper_Reader.iss`, from which Inno Setup builds the Setup, `YANG_Paper_Reader_Setup_<version>.exe`. It defines the Setup's pages and its checks of the requirements, installs the separately licensed application that the Setup carries, and may start that application's documented runtime setup command as a separate process. It contains none of the Reader's main implementation.

This license applies only to the Setup's script, the independent installation source. The installed Reader and its small startup wrappers are separately licensed under the [application license](../LICENSE); third-party components retain their own licenses. Installing them with the Setup does not change their terms. The public repository supplies the Setup's script with every matching release tag.
