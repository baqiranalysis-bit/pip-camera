# PIP Camera

Minimal native iOS proof-of-concept for testing camera Picture in Picture.

## Important

This prototype uses Apple's video-call Picture in Picture API:
`AVPictureInPictureVideoCallViewController`.

Apple documents camera access during PiP on iOS 16+ through
`AVCaptureSession.isMultitaskingCameraAccessEnabled`.

The first goal is only to verify:

1. Open PIP Camera.
2. Allow camera permission.
3. Tap Start PiP.
4. Leave the app.
5. Open another app such as a game.
6. Check whether the camera remains in the PiP window.

This is a proof of concept, not a finished App Store product.

## Build

The repository uses XcodeGen so an `.xcodeproj` does not have to be stored manually.
Codemagic can install XcodeGen and generate the project before building.
