#!/bin/bash

RESOURCES=
APP=
EXECUTABLE=
FORCE=0

APPNAME=
BUNDLEID=

while :
do
    case $1 in
        -e|--executable)
            EXECUTABLE="$2"
            shift
            ;;
        -r|--resource)
            RESOURCES="$RESOURCES $2"
            shift
            ;;
        -a|--app)
            APP="$2"
            shift
            ;;
        -n|--appname)
            APPNAME="$2"
            shift
            ;;
        -b|--bundleid)
            BUNDLEID="$2"
            shift
            ;;
        -f|--force)
            FORCE=1
            ;;
        *)
            break;
            ;;
    esac

    shift
done

if [ -z $EXECUTABLE ]
then
    echo "Executable must be specified"
    exit 1
fi

if [ ! -x $EXECUTABLE ]
then
    echo "Executable must be executable!"
    exit 1
fi

if [ -z $APP ]
then
    echo "App must be specified"
    exit 1
fi

if [[ $APP != *.app ]]
then
    echo "App name must end with .app"
    exit 1
fi

if [ -e $APP ]
then
    if [ $FORCE -eq 0 ]
    then
        echo "Output directory already exists"
        exit 1
    fi
    rm -rf $APP
fi

if [ -z $APPNAME ]
then
    APPNAME=`BASENAME $APP|cut -d'.' -f1`
fi

if [ -z $BUNDLEID ]
then
    BUNDLEID=appr.$APPNAME
fi

EXECUTABLE_NAME=`basename $EXECUTABLE`

echo "APP: $APP"
echo "APPNAME: $APPNAME"
echo "BUNDLEID: $BUNDLEID"
echo "RESOURCES: $RESOURCES"

echo "Creating app structure..."
mkdir -p $APP/Contents/MacOS
mkdir -p $APP/Contents/Frameworks
mkdir -p $APP/Contents/Resources

echo "Copying executable..."
EXECUTABLE_DEST=$APP/Contents/MacOS/$EXECUTABLE_NAME
cp $EXECUTABLE $EXECUTABLE_DEST

for res in $RESOURCES
do
    echo "Copying $res"
    cp -R $res $APP/Contents/Resources/
done

echo "APPL????" > $APP/Contents/PkgInfo

cat >$APP/Contents/Info.plist <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>$APPNAME</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleIdentifier</key>
        <string>$BUNDLEID</string>
        <key>CFBundleVersion</key>
        <string>1</string>
        <key>CFBundleSignature</key>
        <string>$APPNAME</string>
        <key>CFBundleExecutable</key>
        <string>$EXECUTABLE_NAME</string>

        <!-- Enable High DPI -->
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSHighResolutionMagnifyAllowed</key>
        <false/>

        <!-- Tell our code that we started from the launcher -->
        <key>LSEnvironment</key>
        <dict>
            <key>APPR</key>
            <string>1</string>
        </dict>
    </dict>
</plist>
EOL


echo "Copying Frameworks..."
LOCALLIBS=`otool -l $EXECUTABLE_DEST 2>&1|grep "\/usr\/local"|cut -d' ' -f11`

for LIB in $LOCALLIBS
do
    echo "Framework: $LIB"
    LIBNAME=`basename $LIB`
    install_name_tool -change $LIB @executable_path/../Frameworks/$LIBNAME $EXECUTABLE_DEST
    cp $LIB $APP/Contents/Frameworks
done

