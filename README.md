# webrtc-ios

## Generating a Framework

The offical documenation could be found [here](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/ios/index.md). 

### Get Depot Tools

You will need to install Chromium `depot_tools` if you don't already have it on your machine.

First, clone the depot_tools repository:

```bash
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

Add `depot_tools` to the end of your PATH (you will probably want to put this in your `~/.bashrc` or `~/.zshrc`). Assuming you cloned depot_tools to /path/to/depot_tools:

```bash
$ export PATH=$PATH:/path/to/depot_tools
```

### Getting the Code

Create a working directory, enter it, and run:

```bash
fetch --nohooks webrtc_ios
gclient sync
```

This will fetch a regular WebRTC checkout with the iOS-specific parts added. Notice the size is quite large: about 6GB. The same checkout can be used for both Mac and iOS development, since GN allows you to generate your Ninja project files in different directories for each build config.

Note that the git repository root is in `src`.

### Checkout Release

Checkout the desired release. Releases can be found in the the [Google group](https://groups.google.com/forum/#!forum/discuss-webrtc).


### Build With Bitcode

To build the framework with bitcode support, pass the `--bitcode` flag to the `build_ios_libs` script found in `/tools_webrtc/ios`.

```bash
python build_ios_libs.py -—bitcode --revision [RELEASE_NUMBER]
```

The resulting framework can be found in `/out_ios_libs/`.
