@tool
extends RefCounted

class_name TwitchExtension

## The name of the user or organization that owns the extension.
var author_name: String;
## A Boolean value that determines whether the extension has features that use Bits. Is **true** if the extension has features that use Bits.
var bits_enabled: bool;
## A Boolean value that determines whether a user can install the extension on their channel. Is **true** if a user can install the extension.      Typically, this is set to **false** if the extension is currently in testing mode and requires users to be allowlisted (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Access**).
var can_install: bool;
## The location of where the extension’s configuration is stored. Possible values are:      * hosted — The Extensions Configuration Service hosts the configuration. * custom — The Extension Backend Service (EBS) hosts the configuration. * none — The extension doesn't require configuration.
var configuration_location: String;
## A longer description of the extension. It appears on the details page.
var description: String;
## A URL to the extension’s Terms of Service.
var eula_tos_url: String;
## A Boolean value that determines whether the extension can communicate with the installed channel’s chat. Is **true** if the extension can communicate with the channel’s chat room.
var has_chat_support: bool;
## A URL to the default icon that’s displayed in the Extensions directory.
var icon_url: String;
## No description available
var icon_urls: TwitchExtensionIconUrls;
## The extension’s ID.
var id: String;
## The extension’s name.
var name: String;
## A URL to the extension’s privacy policy.
var privacy_policy_url: String;
## A Boolean value that determines whether the extension wants to explicitly ask viewers to link their Twitch identity.
var request_identity_link: bool;
## A list of URLs to screenshots that are shown in the Extensions marketplace.
var screenshot_urls: Array[String];
## The extension’s state. Possible values are:      * Approved * AssetsUploaded * Deleted * Deprecated * InReview * InTest * PendingAction * Rejected * Released
var state: String;
## Indicates whether the extension can view the user’s subscription level on the channel that the extension is installed on. Possible values are:      * none — The extension can't view the user’s subscription level. * optional — The extension can view the user’s subscription level.
var subscriptions_support_level: String;
## A short description of the extension that streamers see when hovering over the discovery splash screen in the Extensions manager.
var summary: String;
## The email address that users use to get support for the extension.
var support_email: String;
## The extension’s version number.
var version: String;
## A brief description displayed on the channel to explain how the extension works.
var viewer_summary: String;
## Describes all views-related information such as how the extension is displayed on mobile devices.
var views: ExtensionViews;
## Allowlisted configuration URLs for displaying the extension (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Capabilities**).
var allowlisted_config_urls: Array[String];
## Allowlisted panel URLs for displaying the extension (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Capabilities**).
var allowlisted_panel_urls: Array[String];

static func from_json(d: Dictionary) -> TwitchExtension:
	var result = TwitchExtension.new();














	for value in d["screenshot_urls"]:
		result.screenshot_urls.append(value);
{elif property.is_typed_array}
	for value in d["screenshot_urls"]:
		result.screenshot_urls.append(.from_json(value));
{elif property.is_sub_class}
	result.screenshot_urls = Array[String].from_json(d["screenshot_urls"]);
{else}
	result.screenshot_urls = d["screenshot_urls"];









	for value in d["allowlisted_config_urls"]:
		result.allowlisted_config_urls.append(value);
{elif property.is_typed_array}
	for value in d["allowlisted_config_urls"]:
		result.allowlisted_config_urls.append(.from_json(value));
{elif property.is_sub_class}
	result.allowlisted_config_urls = Array[String].from_json(d["allowlisted_config_urls"]);
{else}
	result.allowlisted_config_urls = d["allowlisted_config_urls"];


	for value in d["allowlisted_panel_urls"]:
		result.allowlisted_panel_urls.append(value);
{elif property.is_typed_array}
	for value in d["allowlisted_panel_urls"]:
		result.allowlisted_panel_urls.append(.from_json(value));
{elif property.is_sub_class}
	result.allowlisted_panel_urls = Array[String].from_json(d["allowlisted_panel_urls"]);
{else}
	result.allowlisted_panel_urls = d["allowlisted_panel_urls"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};





















	d["views"] = views.to_dict();
{else}
	d["views"] = views;



	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Describes all views-related information such as how the extension is displayed on mobile devices.
class ExtensionViews extends RefCounted:
	## Describes how the extension is displayed on mobile devices.
	var mobile: Dictionary;
	## Describes how the extension is rendered if the extension may be activated as a panel extension.
	var panel: Dictionary;
	## Describes how the extension is rendered if the extension may be activated as a video-overlay extension.
	var video_overlay: Dictionary;
	## Describes how the extension is rendered if the extension may be activated as a video-component extension.
	var component: Dictionary;
	## Describes the view that is shown to broadcasters while they are configuring your extension within the Extension Manager.
	var config: Dictionary;

	static func from_json(d: Dictionary) -> ExtensionViews:
		var result = ExtensionViews.new();
		result.mobile = d["mobile"];
		result.panel = d["panel"];
		result.video_overlay = d["video_overlay"];
		result.component = d["component"];
		result.config = d["config"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["mobile"] = mobile;
		d["panel"] = panel;
		d["video_overlay"] = video_overlay;
		d["component"] = component;
		d["config"] = config;
		return d;

