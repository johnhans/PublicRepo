#!/bin/bash

#This script grabs the plist file that seems to contain the value used in the About this Mac pane, which is populated with warranty status information. THe output is formatted to be used as an Intune Custom Attribute, so a single line for each reporting computer.
#The directory seems to contain multiple files if the Mac knows about multiple devices, so it only parses the ones described as starting with "Mac".

loggedInUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
loggedInUID=$(id -u "${loggedInUser}")
warrantyPlistFileDir="/Users/${loggedInUser}/Library/Application Support/com.apple.NewDeviceOutreach"
warrantyStatusString=""

# Use find with null-terminated output to handle spaces in file paths
find "$warrantyPlistFileDir" -type f -name "*_Warranty.plist" -print0 > /tmp/warranty_files

# Use a while loop to read the null-terminated file paths
while IFS= read -r -d '' warrantyPlistFile; do
    deviceDesc=$(/usr/libexec/PlistBuddy -c 'Print ":deviceInfo:deviceDesc"' "$warrantyPlistFile")
    warrantyStatus=$(/usr/libexec/PlistBuddy -c 'Print ":covered"' "$warrantyPlistFile")

    if [[ "$deviceDesc" == "Mac"* ]]; then

        if [ "$warrantyStatus" == "true" ]; then
            warrantyExpiryDate=$(/usr/libexec/PlistBuddy -c 'Print ":coverageEndDate"' "$warrantyPlistFile")
            # Add the expiry date to the warrantyStatusString
            warrantyStatusString+=",$warrantyExpiryDate"
        else
            # Add the warranty status boolean value to the warrantyStatusString
            warrantyStatusString+=",$warrantyStatus"
        fi
    fi
done < /tmp/warranty_files

# Remove the leading comma
warrantyStatusString=${warrantyStatusString#","}

echo "$warrantyStatusString"

# Remove the temporary file
rm /tmp/warranty_files
