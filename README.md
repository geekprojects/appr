# appr

**appr** is a very simple script for packaging an executable as a MacOS application.

If the executable is a Mach-O binary, it will scan for libraries loaded from /usr/local/ and include them in the Frameworks directory of the output app.

## Usage

appr.sh [options]

Option              | Argument            | Required? | Description 
--------------------|---------------------|-----------|-------------
-e --executable     | /path/to/executable | Yes       | Specifies the executable that should be run
-a --app            | name.app            | Yes       | Specifies the name of the .app directory to create
-r --resource       | /path/to/resource   | No        | Specifies a file or directory to copy to Resources. Can be specified multiple times
-n --appname        | name                | No        | Specifies the name of the application. If not specified, it will be derived from the app directory
-b --bundleid       | bundle              | No        | Bundleid to insert in to Info.plist
-v --version        | version             | No        | The version id to insert in to Info.plist. Shown in About window. Defaults to 1.0.
-d --highdpi        | true \| false       | No        | Sets the flag indicating whether the app supports high DPI screens. Defaults to true
-f --force          | *none*              | No        | If specified, the output .app directory will be deleted if it already exists |

### Example

appr.sh --executable src/vide --app Vide.app --highdpi true --version 0.1


## License

[MIT License](LICENSE)
