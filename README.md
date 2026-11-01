# Daybook

iPhone journal. v1 is on-device only: a feed, a composer, Apple's system moments picker, and a Face ID / passcode lock. It does not join Apple's Journal database.

Bundle id placeholder: `app.daybook.journal`. Change it in Signing before you run.

## On your Mac

1. Unzip and open `Daybook.xcodeproj` in Xcode 16 or newer. The deployment target is iOS 18.
2. Select the Daybook target, Signing & Capabilities, and set Team to your Apple ID.
3. Press + Capability and add Journaling Suggestions. The entitlements file already contains `com.apple.developer.journal.allow`. If signing says the profile lacks that entitlement, the capability button is what registers it on the App ID.
4. Plug in your iPhone, select it as the run destination, and press Run. Trust the computer if asked.

The Simulator can open the app only if the device has no passcode check available; Daybook then lets you through and says so. Moments, Face ID, and your photo library do not exist in the Simulator. Use the phone for a day (photos, a walk, music) before expecting suggestions.

## What v1 does not include

CloudKit encryption and Apple Pencil are the next pass. Do not turn on iCloud from this project yet.
