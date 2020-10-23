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
# mkdir $build_dir
cd "${build_dir}"

# Setup tooling
echo "Setting up tooling..."
# git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
tools_dir="${build_dir}/depot_tools/"
export PATH=$PATH:$tools_dir

# Fetch repo and switch to release
echo "Fetching repo..."
# fetch --nohooks webrtc_ios
# gclient sync

echo "Switching branch to '$branch'..."
# cd "${build_dir}/src"
# git checkout -b "${branch}"

# make the framework file
echo "Start creating frameworks..."

echo "Building XCFramework..."

cd "${build_dir}/src"
rm -rf out
gn gen out/mac_x64 --args='target_os="mac" target_cpu="x64" is_component_build=false is_debug=false rtc_libvpx_build_vp9=false enable_stripping=true rtc_enable_protobuf=false'
gn gen out/ios_arm64 --args='target_os="ios" target_cpu="arm64" is_component_build=false use_xcode_clang=true is_debug=false ios_deployment_target="10.0" rtc_libvpx_build_vp9=true use_goma=false ios_enable_code_signing=false enable_stripping=true rtc_enable_protobuf=false enable_ios_bitcode=false treat_warnings_as_errors=false'
gn gen out/ios_x64 --args='target_os="ios" target_cpu="x64" is_component_build=false use_xcode_clang=true is_debug=true ios_deployment_target="10.0" rtc_libvpx_build_vp9=true use_goma=false ios_enable_code_signing=false enable_stripping=true rtc_enable_protobuf=false enable_ios_bitcode=false treat_warnings_as_errors=false'

ninja -C out/mac_x64 sdk:mac_framework_objc
ninja -C out/ios_arm64 sdk:framework_objc
ninja -C out/ios_x64 sdk:framework_objc

frameworkFile="WebRTC.xcframework"

xcodebuild -create-xcframework \
	-framework out/ios_arm64/WebRTC.framework \
	-framework out/ios_x64/WebRTC.framework \
	-framework out/mac_x64/WebRTC.framework \
	-output out/$frameworkFile

echo "Archiving XCFramework..."

cd "${build_dir}/src/out"
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Building Framework..."

cd "${build_dir}/src/tools_webrtc/ios"
python build_ios_libs.py --bitcode --revision "${version}"

echo "Archiving Framework..."

cd "${build_dir}/src/out_ios_libs"
frameworkFile="WebRTC.framework"
zipFile="${frameworkFile}.zip"
zip -r $zipFile $frameworkFile
mv $zipFile "${build_dir}"

echo "Finished creating frameworks."
