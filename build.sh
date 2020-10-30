#!/bin/bash

set -e
set -o pipefail

source config.sh

usage() { echo "Usage: $0 [-b BRANCH] [-v VERSION]" 1>&2; exit 1; }

while getopts ":b:v:" arg; do
    case $arg in
        b)
            branch=${OPTARG}
            ;;
        v)
            version=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${branch}" ] || [ -z "${version}" ]; then
    usage
fi

# Setup environment
echo "Setting up environment..."
root_dir=$(pwd)
build_dir="${root_dir}/build/"
mkdir $build_dir
cd "${build_dir}"

# Setup tooling
echo "Setting up tooling..."
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
tools_dir="${build_dir}/depot_tools/"
export PATH=$PATH:$tools_dir

# Fetch repo and switch to release
echo "Fetching repo..."
fetch --nohooks webrtc_ios
gclient sync

echo "Switching branch to '$branch'..."
cd "${build_dir}/src"
git checkout -b "${branch}"

# Make the framework
echo "Start creating frameworks..."

echo "Building framework without Bitcode..."

cd "${build_dir}/src/tools_webrtc/ios"
python build_ios_libs.py --revision "${version}"

cd "${build_dir}/src"

frameworkFile="WebRTC.xcframework"

xcodebuild -create-xcframework \
    -framework out_ios_libs/arm64_libs/WebRTC.framework \
	-framework out_ios_libs/x64_libs/WebRTC.framework \
	-output out_ios_libs/$frameworkFile

echo "Archiving XCFramework..."

cd "${build_dir}/src/out_ios_libs"
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Archiving Framework..."

cd "${build_dir}/src/out_ios_libs"
frameworkFile="WebRTC.framework"
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Building framework with Bitcode..."

echo "Clean output folder"
rm -rf "${build_dir}/src/out_ios_libs"

cd "${build_dir}/src/tools_webrtc/ios"
python build_ios_libs.py --bitcode --revision "${version}"

cd "${build_dir}/src"

frameworkFile="WebRTC-Bitcode.xcframework"

xcodebuild -create-xcframework \
    -framework out_ios_libs/arm64_libs/WebRTC.framework \
	-framework out_ios_libs/x64_libs/WebRTC.framework \
	-output out_ios_libs/$frameworkFile

echo "Archiving XCFramework..."

cd "${build_dir}/src/out_ios_libs"
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Archiving Framework..."

cd "${build_dir}/src/out_ios_libs"
frameworkFile="WebRTC-Bitcode.framework"
mv WebRTC.framework $frameworkFile
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Computing checksum for XCFramework with Bitcode..."

swift package compute-checksum "${build_dir}/WebRTC-Bitcode.xcframework.zip"

echo "Finished creating frameworks."
