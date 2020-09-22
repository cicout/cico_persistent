cd `dirname $0`
carthage checkout
./carthage_build_xcode12.sh --platform iOS --cache-builds

