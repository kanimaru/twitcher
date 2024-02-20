# THIS IS A PREVIEW ITS NOT COMPLETE YET WIP

## See also:
Uses a modified version of [MagicDumps](https://github.com/erodozer/magick-dumps)
but has the same limitations. Changed the library to use SpriteFrames instead of AnimatedTextures

## Install
1. Checkout the project into your addon folder or use the AssetLib
1. Then enable the Plugin via Project -> Project Settings -> Plugins
1. Insert your credentials too: Project -> Project Settings -> Twitch -> Auth
	1. Insert client credentials, find them at [Twitch Dev Console](https://dev.twitch.tv/) use the [guide](https://dev.twitch.tv/docs/authentication/register-app/)


1. Call `TwitchService.setup();` at somepoint in your application when you want to start the Twitch integration.

## Image Transformer

TODO:
- Add info about custom image transformer
- Add info about send_message_delay (## Time to wait in msec after each sent chat message. Values below ~310 might lead to a disconnect after 100 messages.)

- Make Userstate Roomstate handling globally in the twitch_irc. To support "joining" multiple times the same room aka create new TwitchRooms without problems / Test it
- Eventsub needs to resubscribe after reconnecting
- Fix CommandManager
