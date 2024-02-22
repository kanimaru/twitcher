# [Alpha] for experienced user
Most of the features are implemented. Bugs are very likly, cause of the amount of generated code.

## See also:
Uses a modified version of [MagicDumps](https://github.com/erodozer/magick-dumps)
but has the same limitations. Changed the library to use SpriteFrames instead of AnimatedTextures

## Install
1. Checkout the project into your addon folder or use the AssetLib
1. Then enable the Plugin via Project -> Project Settings -> Plugins
1. Insert your credentials too: Project -> Project Settings -> Twitch -> Auth
	1. Insert client credentials, find them at [Twitch Dev Console](https://dev.twitch.tv/) use the [guide](https://dev.twitch.tv/docs/authentication/register-app/)


1. Call `TwitchService.setup();` at somepoint in your application when you want to start the Twitch integration.


TODO:
**Documentation**
- Add info about custom image transformer
- Add info how to setup imagemagic for animated emojis
- Add info about send_message_delay (## Time to wait in msec after each sent chat message. Values below ~310 might lead to a disconnect after 100 messages.)
- Step by step installation
- Add the note that the path has to be res:/addons/Twitcher
- More doc to the examples
- Add do not change to the header of generated folder
- Make it obviously what kind of redirect url is needed
- Windows Step Recorder to capture the Creating Credential Process

**Known Bugs**

**Nice to Have**
- Add continious deployment to Godot AssetLib
- Implement a native gif parser for godot
- Implement all eventsub datastructures?
