#!/bin/bash

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

# Setup tooling
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
current_dir=$(pwd)
tools_dir="${current_dir}/depot_tools/"
export PATH=$PATH:$tools_dir

# Fetch repo and switch to release
fetch --nohooks webrtc_ios
gclient sync
cd src
git checkout -b "${branch}"

# make the framework file, may need xcode installed
cd src/tools_webrtc/ios/
python build_ios_libs.py --bitcode --revision "${version}"
