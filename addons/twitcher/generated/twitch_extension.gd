@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/Extension
class_name TwitchExtension
	
## The name of the user or organization that owns the extension.
var author_name: String:
	set(val): 
		author_name = val
		track_data(&"author_name", val)

## A Boolean value that determines whether the extension has features that use Bits. Is **true** if the extension has features that use Bits.
var bits_enabled: bool:
	set(val): 
		bits_enabled = val
		track_data(&"bits_enabled", val)

## A Boolean value that determines whether a user can install the extension on their channel. Is **true** if a user can install the extension.  
##   
## Typically, this is set to **false** if the extension is currently in testing mode and requires users to be allowlisted (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Access**).
var can_install: bool:
	set(val): 
		can_install = val
		track_data(&"can_install", val)

## The location of where the extension’s configuration is stored. Possible values are:  
##   
## * hosted — The Extensions Configuration Service hosts the configuration.
## * custom — The Extension Backend Service (EBS) hosts the configuration.
## * none — The extension doesn't require configuration.
var configuration_location: String:
	set(val): 
		configuration_location = val
		track_data(&"configuration_location", val)

## A longer description of the extension. It appears on the details page.
var description: String:
	set(val): 
		description = val
		track_data(&"description", val)

## A URL to the extension’s Terms of Service.
var eula_tos_url: String:
	set(val): 
		eula_tos_url = val
		track_data(&"eula_tos_url", val)

## A Boolean value that determines whether the extension can communicate with the installed channel’s chat. Is **true** if the extension can communicate with the channel’s chat room.
var has_chat_support: bool:
	set(val): 
		has_chat_support = val
		track_data(&"has_chat_support", val)

## A URL to the default icon that’s displayed in the Extensions directory.
var icon_url: String:
	set(val): 
		icon_url = val
		track_data(&"icon_url", val)

## 
var icon_urls: TwitchExtensionIconUrls:
	set(val): 
		icon_urls = val
		track_data(&"icon_urls", val)

## The extension’s ID.
var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## The extension’s name.
var name: String:
	set(val): 
		name = val
		track_data(&"name", val)

## A URL to the extension’s privacy policy.
var privacy_policy_url: String:
	set(val): 
		privacy_policy_url = val
		track_data(&"privacy_policy_url", val)

## A Boolean value that determines whether the extension wants to explicitly ask viewers to link their Twitch identity.
var request_identity_link: bool:
	set(val): 
		request_identity_link = val
		track_data(&"request_identity_link", val)

## A list of URLs to screenshots that are shown in the Extensions marketplace.
var screenshot_urls: Array[String]:
	set(val): 
		screenshot_urls = val
		track_data(&"screenshot_urls", val)

## The extension’s state. Possible values are:  
##   
## * Approved
## * AssetsUploaded
## * Deleted
## * Deprecated
## * InReview
## * InTest
## * PendingAction
## * Rejected
## * Released
var state: String:
	set(val): 
		state = val
		track_data(&"state", val)

## Indicates whether the extension can view the user’s subscription level on the channel that the extension is installed on. Possible values are:  
##   
## * none — The extension can't view the user’s subscription level.
## * optional — The extension can view the user’s subscription level.
var subscriptions_support_level: String:
	set(val): 
		subscriptions_support_level = val
		track_data(&"subscriptions_support_level", val)

## A short description of the extension that streamers see when hovering over the discovery splash screen in the Extensions manager.
var summary: String:
	set(val): 
		summary = val
		track_data(&"summary", val)

## The email address that users use to get support for the extension.
var support_email: String:
	set(val): 
		support_email = val
		track_data(&"support_email", val)

## The extension’s version number.
var version: String:
	set(val): 
		version = val
		track_data(&"version", val)

## A brief description displayed on the channel to explain how the extension works.
var viewer_summary: String:
	set(val): 
		viewer_summary = val
		track_data(&"viewer_summary", val)

## Describes all views-related information such as how the extension is displayed on mobile devices.
var views: Views:
	set(val): 
		views = val
		track_data(&"views", val)

## Allowlisted configuration URLs for displaying the extension (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Capabilities**).
var allowlisted_config_urls: Array[String]:
	set(val): 
		allowlisted_config_urls = val
		track_data(&"allowlisted_config_urls", val)

## Allowlisted panel URLs for displaying the extension (the allowlist is configured on Twitch’s [developer site](https://dev.twitch.tv/console/extensions) under the **Extensions** \-> **Extension** \-> **Version** \-> **Capabilities**).
var allowlisted_panel_urls: Array[String]:
	set(val): 
		allowlisted_panel_urls = val
		track_data(&"allowlisted_panel_urls", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_author_name: String, _bits_enabled: bool, _can_install: bool, _configuration_location: String, _description: String, _eula_tos_url: String, _has_chat_support: bool, _icon_url: String, _icon_urls: TwitchExtensionIconUrls, _id: String, _name: String, _privacy_policy_url: String, _request_identity_link: bool, _screenshot_urls: Array[String], _state: String, _subscriptions_support_level: String, _summary: String, _support_email: String, _version: String, _viewer_summary: String, _views: Views, _allowlisted_config_urls: Array[String], _allowlisted_panel_urls: Array[String]) -> TwitchExtension:
	var twitch_extension: TwitchExtension = TwitchExtension.new()
	twitch_extension.author_name = _author_name
	twitch_extension.bits_enabled = _bits_enabled
	twitch_extension.can_install = _can_install
	twitch_extension.configuration_location = _configuration_location
	twitch_extension.description = _description
	twitch_extension.eula_tos_url = _eula_tos_url
	twitch_extension.has_chat_support = _has_chat_support
	twitch_extension.icon_url = _icon_url
	twitch_extension.icon_urls = _icon_urls
	twitch_extension.id = _id
	twitch_extension.name = _name
	twitch_extension.privacy_policy_url = _privacy_policy_url
	twitch_extension.request_identity_link = _request_identity_link
	twitch_extension.screenshot_urls = _screenshot_urls
	twitch_extension.state = _state
	twitch_extension.subscriptions_support_level = _subscriptions_support_level
	twitch_extension.summary = _summary
	twitch_extension.support_email = _support_email
	twitch_extension.version = _version
	twitch_extension.viewer_summary = _viewer_summary
	twitch_extension.views = _views
	twitch_extension.allowlisted_config_urls = _allowlisted_config_urls
	twitch_extension.allowlisted_panel_urls = _allowlisted_panel_urls
	return twitch_extension


static func from_json(d: Dictionary) -> TwitchExtension:
	var result: TwitchExtension = TwitchExtension.new()
	if d.get("author_name", null) != null:
		result.author_name = d["author_name"]
	if d.get("bits_enabled", null) != null:
		result.bits_enabled = d["bits_enabled"]
	if d.get("can_install", null) != null:
		result.can_install = d["can_install"]
	if d.get("configuration_location", null) != null:
		result.configuration_location = d["configuration_location"]
	if d.get("description", null) != null:
		result.description = d["description"]
	if d.get("eula_tos_url", null) != null:
		result.eula_tos_url = d["eula_tos_url"]
	if d.get("has_chat_support", null) != null:
		result.has_chat_support = d["has_chat_support"]
	if d.get("icon_url", null) != null:
		result.icon_url = d["icon_url"]
	if d.get("icon_urls", null) != null:
		result.icon_urls = TwitchExtensionIconUrls.from_json(d["icon_urls"])
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("name", null) != null:
		result.name = d["name"]
	if d.get("privacy_policy_url", null) != null:
		result.privacy_policy_url = d["privacy_policy_url"]
	if d.get("request_identity_link", null) != null:
		result.request_identity_link = d["request_identity_link"]
	if d.get("screenshot_urls", null) != null:
		for value in d["screenshot_urls"]:
			result.screenshot_urls.append(value)
	if d.get("state", null) != null:
		result.state = d["state"]
	if d.get("subscriptions_support_level", null) != null:
		result.subscriptions_support_level = d["subscriptions_support_level"]
	if d.get("summary", null) != null:
		result.summary = d["summary"]
	if d.get("support_email", null) != null:
		result.support_email = d["support_email"]
	if d.get("version", null) != null:
		result.version = d["version"]
	if d.get("viewer_summary", null) != null:
		result.viewer_summary = d["viewer_summary"]
	if d.get("views", null) != null:
		result.views = Views.from_json(d["views"])
	if d.get("allowlisted_config_urls", null) != null:
		for value in d["allowlisted_config_urls"]:
			result.allowlisted_config_urls.append(value)
	if d.get("allowlisted_panel_urls", null) != null:
		for value in d["allowlisted_panel_urls"]:
			result.allowlisted_panel_urls.append(value)
	return result



## Describes all views-related information such as how the extension is displayed on mobile devices.
## #/components/schemas/Extension/Views
class Views extends TwitchData:

	## Describes how the extension is displayed on mobile devices.
	var mobile: Mobile:
		set(val): 
			mobile = val
			track_data(&"mobile", val)
	
	## Describes how the extension is rendered if the extension may be activated as a panel extension.
	var panel: TwitchPanel:
		set(val): 
			panel = val
			track_data(&"panel", val)
	
	## Describes how the extension is rendered if the extension may be activated as a video-overlay extension.
	var video_overlay: VideoOverlay:
		set(val): 
			video_overlay = val
			track_data(&"video_overlay", val)
	
	## Describes how the extension is rendered if the extension may be activated as a video-component extension.
	var component: Component:
		set(val): 
			component = val
			track_data(&"component", val)
	
	## Describes the view that is shown to broadcasters while they are configuring your extension within the Extension Manager.
	var config: Config:
		set(val): 
			config = val
			track_data(&"config", val)
	
	
	
	## Constructor with all required fields.
	static func create(_mobile: Mobile, _panel: TwitchPanel, _video_overlay: VideoOverlay, _component: Component, _config: Config) -> Views:
		var views: Views = Views.new()
		views.mobile = _mobile
		views.panel = _panel
		views.video_overlay = _video_overlay
		views.component = _component
		views.config = _config
		return views
	
	
	static func from_json(d: Dictionary) -> Views:
		var result: Views = Views.new()
		if d.get("mobile", null) != null:
			result.mobile = Mobile.from_json(d["mobile"])
		if d.get("panel", null) != null:
			result.panel = TwitchPanel.from_json(d["panel"])
		if d.get("video_overlay", null) != null:
			result.video_overlay = VideoOverlay.from_json(d["video_overlay"])
		if d.get("component", null) != null:
			result.component = Component.from_json(d["component"])
		if d.get("config", null) != null:
			result.config = Config.from_json(d["config"])
		return result
	


## Describes how the extension is displayed on mobile devices.
## #/components/schemas/Extension/Views/Mobile
class Mobile extends TwitchData:

	## The HTML file that is shown to viewers on mobile devices. This page is presented to viewers as a panel behind the chat area of the mobile app.
	var viewer_url: String:
		set(val): 
			viewer_url = val
			track_data(&"viewer_url", val)
	
	
	
	## Constructor with all required fields.
	static func create(_viewer_url: String) -> Mobile:
		var mobile: Mobile = Mobile.new()
		mobile.viewer_url = _viewer_url
		return mobile
	
	
	static func from_json(d: Dictionary) -> Mobile:
		var result: Mobile = Mobile.new()
		if d.get("viewer_url", null) != null:
			result.viewer_url = d["viewer_url"]
		return result
	


## Describes how the extension is rendered if the extension may be activated as a panel extension.
## #/components/schemas/Extension/Views/Panel
class TwitchPanel extends TwitchData:

	## The HTML file that is shown to viewers on the channel page when the extension is activated in a Panel slot.
	var viewer_url: String:
		set(val): 
			viewer_url = val
			track_data(&"viewer_url", val)
	
	## The height, in pixels, of the panel component that the extension is rendered in.
	var height: int:
		set(val): 
			height = val
			track_data(&"height", val)
	
	## A Boolean value that determines whether the extension can link to non-Twitch domains.
	var can_link_external_content: bool:
		set(val): 
			can_link_external_content = val
			track_data(&"can_link_external_content", val)
	
	
	
	## Constructor with all required fields.
	static func create(_viewer_url: String, _height: int, _can_link_external_content: bool) -> TwitchPanel:
		var twitch_panel: TwitchPanel = TwitchPanel.new()
		twitch_panel.viewer_url = _viewer_url
		twitch_panel.height = _height
		twitch_panel.can_link_external_content = _can_link_external_content
		return twitch_panel
	
	
	static func from_json(d: Dictionary) -> TwitchPanel:
		var result: TwitchPanel = TwitchPanel.new()
		if d.get("viewer_url", null) != null:
			result.viewer_url = d["viewer_url"]
		if d.get("height", null) != null:
			result.height = d["height"]
		if d.get("can_link_external_content", null) != null:
			result.can_link_external_content = d["can_link_external_content"]
		return result
	


## Describes how the extension is rendered if the extension may be activated as a video-overlay extension.
## #/components/schemas/Extension/Views/VideoOverlay
class VideoOverlay extends TwitchData:

	## The HTML file that is shown to viewers on the channel page when the extension is activated on the Video - Overlay slot.
	var viewer_url: String:
		set(val): 
			viewer_url = val
			track_data(&"viewer_url", val)
	
	## A Boolean value that determines whether the extension can link to non-Twitch domains.
	var can_link_external_content: bool:
		set(val): 
			can_link_external_content = val
			track_data(&"can_link_external_content", val)
	
	
	
	## Constructor with all required fields.
	static func create(_viewer_url: String, _can_link_external_content: bool) -> VideoOverlay:
		var video_overlay: VideoOverlay = VideoOverlay.new()
		video_overlay.viewer_url = _viewer_url
		video_overlay.can_link_external_content = _can_link_external_content
		return video_overlay
	
	
	static func from_json(d: Dictionary) -> VideoOverlay:
		var result: VideoOverlay = VideoOverlay.new()
		if d.get("viewer_url", null) != null:
			result.viewer_url = d["viewer_url"]
		if d.get("can_link_external_content", null) != null:
			result.can_link_external_content = d["can_link_external_content"]
		return result
	


## Describes how the extension is rendered if the extension may be activated as a video-component extension.
## #/components/schemas/Extension/Views/Component
class Component extends TwitchData:

	## The HTML file that is shown to viewers on the channel page when the extension is activated in a Video - Component slot.
	var viewer_url: String:
		set(val): 
			viewer_url = val
			track_data(&"viewer_url", val)
	
	## The width value of the ratio (width : height) which determines the extension’s width, and how the extension’s iframe will resize in different video player environments.
	var aspect_ratio_x: int:
		set(val): 
			aspect_ratio_x = val
			track_data(&"aspect_ratio_x", val)
	
	## The height value of the ratio (width : height) which determines the extension’s height, and how the extension’s iframe will resize in different video player environments.
	var aspect_ratio_y: int:
		set(val): 
			aspect_ratio_y = val
			track_data(&"aspect_ratio_y", val)
	
	## A Boolean value that determines whether to apply CSS zoom. If **true**, a CSS zoom is applied such that the size of the extension is variable but the inner dimensions are fixed based on Scale Pixels. This allows your extension to render as if it is of fixed width and height. If **false**, the inner dimensions of the extension iframe are variable, meaning your extension must implement responsiveness.
	var autoscale: bool:
		set(val): 
			autoscale = val
			track_data(&"autoscale", val)
	
	## The base width, in pixels, of the extension to use when scaling (see `autoscale`). This value is ignored if `autoscale` is **false**.
	var scale_pixels: int:
		set(val): 
			scale_pixels = val
			track_data(&"scale_pixels", val)
	
	## The height as a percent of the maximum height of a video component extension. Values are between 1% - 100%.
	var target_height: int:
		set(val): 
			target_height = val
			track_data(&"target_height", val)
	
	## A Boolean value that determines whether the extension can link to non-Twitch domains.
	var can_link_external_content: bool:
		set(val): 
			can_link_external_content = val
			track_data(&"can_link_external_content", val)
	
	
	
	## Constructor with all required fields.
	static func create(_viewer_url: String, _aspect_ratio_x: int, _aspect_ratio_y: int, _autoscale: bool, _scale_pixels: int, _target_height: int, _can_link_external_content: bool) -> Component:
		var component: Component = Component.new()
		component.viewer_url = _viewer_url
		component.aspect_ratio_x = _aspect_ratio_x
		component.aspect_ratio_y = _aspect_ratio_y
		component.autoscale = _autoscale
		component.scale_pixels = _scale_pixels
		component.target_height = _target_height
		component.can_link_external_content = _can_link_external_content
		return component
	
	
	static func from_json(d: Dictionary) -> Component:
		var result: Component = Component.new()
		if d.get("viewer_url", null) != null:
			result.viewer_url = d["viewer_url"]
		if d.get("aspect_ratio_x", null) != null:
			result.aspect_ratio_x = d["aspect_ratio_x"]
		if d.get("aspect_ratio_y", null) != null:
			result.aspect_ratio_y = d["aspect_ratio_y"]
		if d.get("autoscale", null) != null:
			result.autoscale = d["autoscale"]
		if d.get("scale_pixels", null) != null:
			result.scale_pixels = d["scale_pixels"]
		if d.get("target_height", null) != null:
			result.target_height = d["target_height"]
		if d.get("can_link_external_content", null) != null:
			result.can_link_external_content = d["can_link_external_content"]
		return result
	


## Describes the view that is shown to broadcasters while they are configuring your extension within the Extension Manager.
## #/components/schemas/Extension/Views/Config
class Config extends TwitchData:

	## The HTML file shown to broadcasters while they are configuring your extension within the Extension Manager.
	var viewer_url: String:
		set(val): 
			viewer_url = val
			track_data(&"viewer_url", val)
	
	## A Boolean value that determines whether the extension can link to non-Twitch domains.
	var can_link_external_content: bool:
		set(val): 
			can_link_external_content = val
			track_data(&"can_link_external_content", val)
	
	
	
	## Constructor with all required fields.
	static func create(_viewer_url: String, _can_link_external_content: bool) -> Config:
		var config: Config = Config.new()
		config.viewer_url = _viewer_url
		config.can_link_external_content = _can_link_external_content
		return config
	
	
	static func from_json(d: Dictionary) -> Config:
		var result: Config = Config.new()
		if d.get("viewer_url", null) != null:
			result.viewer_url = d["viewer_url"]
		if d.get("can_link_external_content", null) != null:
			result.can_link_external_content = d["can_link_external_content"]
		return result
	