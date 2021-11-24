cd "`dirname \"$0\"`"
cd ../
carthage bootstrap --platform iOS --cache-builds --no-use-binaries --use-xcframeworks
