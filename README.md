# Daybook

iPhone journal. Entries stay on the phone: feed, composer, photos, and a Face ID or passcode lock.

Bundle id: `app.daybook.journal`. Change it in Signing if you want.

## Run it on a free Apple ID

A personal team cannot sign Journaling Suggestions. This project does not request that capability.

1. Open `Daybook.xcodeproj` in Xcode 16 or newer.
2. Select the Daybook target, Signing & Capabilities, and set Team to your Apple ID.
3. If Journaling Suggestions is listed, click its remove button. It must not be there.
4. Plug in the iPhone and press Run.

## Moments later

Moments needs the paid Apple Developer Program ($99/year). After you enroll, add the Journaling Suggestions capability and set the build setting `SWIFT_ACTIVE_COMPILATION_CONDITIONS` to include `DAYBOOK_MOMENTS`.

CloudKit and Apple Pencil are not in this build.
