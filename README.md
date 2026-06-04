# Ink&void - Mobile Build (v0.1-alpha)

This branch contains the Android port and mobile optimization pass for the GDG Game Dev Hub prototype. The core engine remains driven by a custom Entity-Component-System (ECS) architecture, now featuring a decoupled mobile UI pipeline and specialized touch controls.

## Mobile Controls

The control scheme has been rebuilt from the ground up for glass screens, replacing the PC mouse-and-keyboard layout with a dedicated touch interface.

* **Left Joystick:** Omni-directional player movement.
* **Right Joystick:** 360-degree twin-stick aiming.
* **Tap R-Pad (Parry / Interact):** Tapping the center of the right joystick instantly fires your parry slash. When standing near an active terminal, the joystick will glow gold—tap it to interact.
* **Dash:** The dedicated red UI button triggers your dodge mechanics.

## Installation Instructions (Android)

This is an unlisted, pre-release `.apk` compiled directly from the development branch. You will need to manually sideload it onto your Android device.

1. Download the `ink_and_void_v0.1-alpha.apk` file from the GitHub Releases tab directly to your phone.
2. Open your file manager and tap the downloaded `.apk` file.
3. If prompted by your operating system, grant your browser or file manager permission to **Install Unknown Apps** in your Android security settings.
4. Confirm the installation, bypass any generic Play Protect warnings for unlisted apps, and launch the game.

## Engineering Notes

The mobile UI operates entirely decoupled from the core ECS state machine. To maintain 60FPS on mobile processors, the virtual joysticks act as raw data pipes. They directly feed input vectors and tap events to the underlying interaction and parry systems without relying on heavy engine-side event bubbling or state machine overrides.
