# Twitcher

[![Godot Asset Library](https://img.shields.io/badge/Godot%20Asset%20Library-Twitcher-blue?style=flat-square)](https://godotengine.org/asset-library/asset/2629) <!-- Replace YOUR_ASSET_ID -->
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://github.com/kanimaru/twitcher/blob/v2/LICENSE) <!-- Assuming MIT License -->
[![Twitch](https://img.shields.io/badge/Support_on_Twitch-kani_dev-purple?style=flat-square&logo=twitch)](https://www.twitch.tv/kani_dev/)
[![Documentation](https://img.shields.io/badge/Twitcher-Documentation-purple?style=flat-square&logo=readthedocs)](https://twitcher.kani.dev/)

**Seamless Twitch Integration for Godot 4.4+**

Twitcher V2 provides a comprehensive toolkit to effortlessly connect your Godot Engine games, 
overlays, or applications to the Twitch platform. Integrate real-time chat, respond to events like 
follows and subscriptions, manage rewards, handle chat commands, and utilize the full Twitch API with ease.

## Key Features

*   **Modern Twitch Integration:** Utilizes EventSub for real-time events and the Helix API for robust interactions (moving away from deprecated IRC features for core functionality).
*   **Simplified Authentication:** Supports multiple OAuth flows (Authorization Code, Client Credentials, Device Code) with helpers for secure token management.
*   **Easy Event Handling:** Dedicated `TwitchEventListener` node to react to specific EventSub events (Follows, Subs, Cheers, Rewards, etc.).
*   **API Coverage:** Auto-generated, type-safe wrapper methods for the Twitch Helix REST API.
*   **Chat Command Framework:** `TwitchCommand` nodes for defining and handling chat commands with permission checks. Includes an automated `!help` command generator.
*   **Editor Tools:** Built-in helpers for configuring OAuth Scopes, EventSub subscriptions, and testing credentials directly within the Godot editor.
*   **Media Loading:** Handles fetching and caching Twitch Emotes (including animated GIFs via optional transformers), Badges, and Cheermotes as Godot `SpriteFrames`.

## Installation

1.  **Get the Addon:**
	*   **Recommended (AssetLib):** Search for "Twitcher" in the Godot AssetLib tab and click Download.
	*   **Manual (GitHub):** Download from [GitHub](https://github.com/kanimaru/twitcher/releases). Extract the `addons/twitcher` folder into your project's directory.
	*   **Important:** The addon *must* reside in the exact path `res://addons/twitcher` for internal resources to load correctly.
2.  **Enable Plugin:** Go to `Project -> Project Settings -> Plugins` and check the `Enable` box next to "Twitcher".

## Quick Start & Documentation

1.  **Run Setup Wizard:** After enabling the plugin, the easiest way to configure authentication is via the Setup Wizard:
	*   Navigate to `Project -> Tools -> Twitcher Setup`.
	*   Follow the on-screen instructions to enter your Twitch Application credentials and select required OAuth scopes.
2.  **Explore the Documentation:** For detailed guides, tutorials, API reference, and advanced configuration (like setting up GIF support), please refer to the **[Full Twitcher Documentation](https://twitcher.kani.dev)**.

## Image Transformers (for Animated Emotes)

Godot doesn't natively support animated GIFs. Twitcher uses configurable "Image Transformers" to handle them:

*   **`TwitchImageTransformer` (Default):** Static images only. Works out-of-the-box.
*   **`MagickImageTransformer`:** Requires [ImageMagick](https://imagemagick.org) to be installed separately. Converts GIFs to `SpriteFrames`.
*   **`NativeImageTransformer`:** Experimental, uses native gdscript implementation (based on [vbousquet/godot-gif-importer](https://github.com/vbousquet/godot-gif-importer)). No external programs needed, but may struggle with malformed GIFs.

**See the [Full Documentation](https://twitcher.kani.dev/core-nodes/twitch-image-transformer.html)** for instructions on how to configure and use `MagickImageTransformer` or `NativeImageTransformer`.

## Support

Need help or have questions? Find kani_dev streaming development and answering questions on [Twitch](https://www.twitch.tv/kani_dev/). Feel free to open an Issue on GitHub for bugs or feature requests.

## License

Twitcher V2 is released under the MIT License. See the [LICENSE](https://github.com/kanimaru/twitcher/blob/master/LICENSE) file for details.
