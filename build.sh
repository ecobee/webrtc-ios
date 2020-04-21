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
root_dir=$(pwd)
build_dir="${root_dir}/build/"
mkdir $build_dir
cd "${build_dir}"

# Setup tooling
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
tools_dir="${build_dir}/depot_tools/"
export PATH=$PATH:$tools_dir

# Fetch repo and switch to release
fetch --nohooks webrtc_ios
gclient sync
cd "${build_dir}/src"
git checkout -b "${branch}"

# make the framework file
cd "${build_dir}/src"
gn gen out/ios --args='target_os="ios" ios_enable_code_signing=false target_cpu="arm64"' --ide=xcode
cd "${build_dir}/src/tools_webrtc/ios"
python build_ios_libs.py --arch {arm64,arm} --bitcode --revision "${version}"
cd "${build_dir}/src/out_ios_libs"
timestamp=$(date +%s)
zip -r "WebRTC_${timestamp}.zip" .
mv WebRTC.framework.zip "${build_dir}"
