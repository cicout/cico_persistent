cd "`dirname \"$0\"`"
cd ../
carthage update --platform iOS --no-use-binaries --use-xcframeworks
