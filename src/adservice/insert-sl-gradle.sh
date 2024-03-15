#!/bin/bash

## @TODO: script all of this pre-work for the gradle plugin

# # Download/unpack java agents
# wget -nv https://agents.sealights.co/sealights-java/sealights-java-latest.zip
# unzip -o sealights-java-latest.zip && rm -rf sealights-java-latest.zip

# # Insert sl task:
# java -jar sl-build-scanner.jar -gradle -configfile sl_conf.json -workspacepath .

# # Restore the gradle.build
# java -jar sl-build-scanner.jar -restoreGradle -workspacepath .



# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: ./slsetup [insertsl|restore]"
  exit 1
fi

# Define the base directory for Sealights files (modify if needed)
SEALIGHTS_DIR="sealights"

# Function to download and unpack java agents
download_java_agents() {
  wget -nv https://agents.sealights.co/sealights-java/sealights-java-latest.zip
  unzip -o sealights-java-latest.zip && rm -rf sealights-java-latest.zip
}

# Handle insertsl argument
if [ "$1" == "insertsl" ]; then
  # Download and unpack java agents
  download_java_agents

  # Insert sl task
  java -jar "$SEALIGHTS_DIR/sl-build-scanner.jar" -gradle -configfile sl_conf.json -workspacepath .

# Handle restore argument
elif [ "$1" == "restore" ]; then
  # Restore the gradle.build
  java -jar "$SEALIGHTS_DIR/sl-build-scanner.jar" -restoreGradle -workspacepath .

else
  echo "Invalid argument: '$1'"
  echo "Usage: ./slsetup [insertsl|restore]"
  exit 1
fi

echo "Done!"
