#!/bin/bash

# Run ioreg command and store the output
ioreg_string=$(ioreg -ar -c AppleSmartBattery)

CycleCount=$(/usr/libexec/PlistBuddy -c "print 0:BatteryData:CycleCount" /dev/stdin <<< "$ioreg_string"   )
DesignCapacity=$(/usr/libexec/PlistBuddy -c "print 0:BatteryData:DesignCapacity" /dev/stdin <<< "$ioreg_string"   )
MaxCapacity=$(/usr/libexec/PlistBuddy -c "print 0:AppleRawMaxCapacity" /dev/stdin <<< "$ioreg_string"   )

percentage_remaining=$(echo "scale=2; ($MaxCapacity / $DesignCapacity) * 100" | bc)



# Print the values
#echo "CycleCount: $CycleCount"
#echo "DesignCapacity: $DesignCapacity"
#echo "Current Max Capacity: $MaxCapacity"

echo "$CycleCount,$DesignCapacity,$MaxCapacity,$percentage_remaining"
