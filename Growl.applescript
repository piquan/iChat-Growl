(*
What follows are configuration variables that advanced users can edit to customize the script's behavior.
If you don't want to change this script to edit these config variables, you can put them in another script named "Growl Config.scpt" in your Library:Scripts:iChat folder (usually the same folder as this script).  You can copy just the properties you want.  For example, if you want to change autoAccept, then the "Growl Config.scpt" file should only contain the line:
property autoAccept : {"text", "remote screen sharing"}
*)
-- Note to developers: If you add a property or handler to the config script, you'll need to add it to the end of initConfig() too.
script config
	-- autoAccept: Since you can't specify both this script and "Auto Accept" in the script field in iChat's preferences, it's handy to be able to tell this script to do the accept for certain types of invitations.  It would also be possible to tell it to chain-call a different script; this would be more flexible (for example, if you wanted to run "iTunes Remote Control" instead), but slower.
	-- Set this to a list containing some subset of "text", "audio", "video", "buddy authorization", "local screen sharing", "remote screen sharing", and "file transfer", depending on what you want to auto-accept.  (Note that "remote screen sharing" is presently broken; see the comment below.
	-- The default, as distributed, is to not auto-accept anything, since that's really not the point of this script.
	-- Example to enable only text and remote screen sharing:
	-- property autoAccept : {"text", "remote screen sharing"}
	property autoAccept : {}
	
	(*
I have too many contacts on the social networks, and I don't chat with the vast majority of them.  This script supports filtering out the distracting login / logout messages.  I don't care about login / logout messages from:
- Facebook friends
- Contacts from Google Talk via Google+
- Bonjour contacts
- Myself

However, if I'm chatting with any of these people, I do care what they have to say.  Only login and logout messages get filtered.

The filtering rules may seem strange, but they work for me in practice.
First: Filtering is only applied to events in filterEvents.  No other events ever get filtered.
Second: A event will be ignored if it matches either filterAccounts or filterBuddies.
In other words, it must match (filterEvents and (filterAccounts or filterBuddies)) to be filtered.
*)
	
	-- filterEvents : Don't show these events if either the account name is in filterAccounts, or the buddy is in filterBuddies.  If neither of those matches, then the event is handled normally. If you want to ignore a particular event altogether, regardless of account, then disable the script for that event in iChat's Preferences.
	-- Note that only events that are associated with a buddy can be filterd here.
	-- Example:
	-- property filterEvents : {"Buddy Became Available", "Buddy Became Unavailable"}
	property filterEvents : {}
	
	-- filterAccounts : Don't show certain events (listed in filterEvents) for these accounts.  The account name should match the "Description" field of the service in your iChat settings; note that Bonjour is always named "Bonjour".
	-- Example:
	-- property filterAccounts : {"Bonjour", "Facebook"}
	property filterAccounts : {}
	-- filterBuddies : Don't show events from filterEvents if the handle or name includes one of these strings.  You may want to include yourself here, so that you don't get messages when you log in.  The @public.talk.google.com will filter out Google+ contacts (if you've enabled Google Talk for Google+ friends), but not Google Talk contacts that you've added otherwise.  You can also include any buddies who log on and off frequently.
	-- Example:
	-- property filterBuddies : {"@public.talk.google.com"}
	property filterBuddies : {}
	
	-- If you're filtering certain events, you might want to turn off their sounds in iChat, and let this script play the sound if the event passes the filters.
	-- The sound can be a filename, or any of the sounds built into iChat: "Buddy Logging In", "Buddy Logging Out", "File Transfer Complete", "Invitation Accepted", "Invitation", "Logged In", "Received Message", "Ringer", "Sent Message".
	-- Example:
	-- property soundList : {{event:"Buddy Became Available", sound:"Buddy Logging In"}, {event:"Buddy Became Unavailable", sound:"Buddy Logging Out"}}
	property soundlist : {}
	
	(********************************************************
This is the end of the the straightforward configuration variables.
If you know some basic AppleScript, there's a few handlers you can put in your Growl Config.scpt to add custom actions, as follows.
(By the way: if you need to, you can use a script bundle named Growl Config.scptd instead of a normal .scpt script.)
********************************************************)
	
	-- We avoid using terms from iChat or Growl in the parameter names here, so that the user's config file doesn't need a "using terms from" section.  (Terms from AppleScript are fine, even if they're also in iChat or Growl.  That's why we can use "title".)
	
	-- readyToNotify is called before notifications for an event, regardless of whether an event is filtered out or not.
	on readyToNotify for theGrowlText from theBuddy out of growlEventName given showingStatus:showingStatus
	end readyToNotify
	
	-- willNotify and didNotify are called before and after playing sounds or showing growls.  They are not called if an event is filtered out, or if the chat window for the buddy is frontmost.
	on willNotify for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end willNotify
	on didNotify for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end didNotify
	
	-- willGrowl and didGrowl are called right before and after showing a Growl notification.  If a Growl won't be sent (because it's been filtered out, or because Growl isn't running), then they are not called.  (If you turn off Growls for iChat in the Growl preferences, these are still called anyway.)
	on willGrowl for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end willGrowl
	on didGrowl for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end didGrowl
	
	-- willPlaySound and didPlaySound are called right before and after playing a sound.
	on willPlaySound for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end willPlaySound
	on didPlaySound for theGrowlText from theBuddy out of growlEventName given title:theTitle, icon:theIcon, showingStatus:showingStatus
	end didPlaySound
	
	-- shouldNotify is called to filter events, and only notify for some events.  It must return a true or false value.  It is called after readyToNotify, but before willNotify.
	on shouldNotify for theText from theBuddy out of growlEventName given showingStatus:showingStatus
		-- This is where filterEvents, filterAccounts, and filteredBuddies happen.  If you override this handler in your config file, then your code will need to do this if you want it to happen.
		using terms from application "iChat"
			if growlEventName is in config's filterEvents then
				local thefilteredBuddy, buddyName, buddyHandle
				if the name of the service of theBuddy is in config's filterAccounts then return false
				set buddyName to theBuddy's name
				set buddyHandle to theBuddy's handle
				repeat with thefilteredBuddy in config's filterBuddies
					if thefilteredBuddy is in buddyHandle then return false
					if thefilteredBuddy is in buddyName then return false
				end repeat
			end if
			return true
		end using terms from
	end shouldNotify
	
	(********************************************************
This is the end of the configuration section.
********************************************************)
end script

property userConfig : missing value
property userConfigLastModified : missing value

-- When we're loading the user's config, we save the default config (the one in "script config" above) here, so that if a variable is removed from the user's config, we can recover the default, despite "config" being persistent.
property defaultConfig : missing value

on getConfig(cfg, default)
	try
		return cfg's contents
	on error number -1700
		return default's contents
	end try
end getConfig
on initConfig()
	set userLib to (the path to the library folder from the user domain as text without folder creation)
	-- We can't use "load script" on .applescript (uncompiled) files, only .scpt and .scptd files.  We actually can also use .app files, but I don't think that would be a great idea here.
	repeat with extension in {"scpt", "scptd"}
		set configPath to userLib & "Scripts:iChat:Growl Config." & extension
		try
			set newConfigAlias to the alias configPath
			exit repeat
		on error number -43
			-- Try the next extension
		end try
	end repeat
	if configPath is missing value then
		log "No config file"
		set configScript to {}
		return
	end if
	
	set newConfigScriptLastModified to the modification date of (info for newConfigAlias)
	if newConfigScriptLastModified = userConfigLastModified then
		-- The script we've loaded is the latest version.
		log "Config is current"
		return
	end if
	log "Loading config file"
	if defaultConfig is missing value then
		set defaultConfig to config
	end if
	load script newConfigAlias
	set userConfig to the result
	set userConfigLastModified to newConfigScriptLastModified
	-- All these go through references, because it prevents us from getting an error immediately if they're not in the user's config file.  Instead, the error is raised when we dereference it in getConfig, where we have a handler.
	-- Sadly, the AppleScript compiler will eliminate any Â continuations inside the record literal, so this is all run together.
	set config's autoAccept to getConfig(a reference to userConfig's autoAccept, defaultConfig's autoAccept)
	set config's filterEvents to getConfig(a reference to userConfig's filterEvents, defaultConfig's filterEvents)
	set config's filterAccounts to getConfig(a reference to userConfig's filterAccounts, defaultConfig's filterAccounts)
	set config's filterBuddies to getConfig(a reference to userConfig's filterBuddies, defaultConfig's filterBuddies)
	set config's soundlist to getConfig(a reference to userConfig's soundlist, defaultConfig's soundlist)
	set config's readyToNotify to getConfig(a reference to userConfig's readyToNotify, defaultConfig's readyToNotify)
	set config's willNotify to getConfig(a reference to userConfig's willNotify, defaultConfig's willNotify)
	set config's didNotify to getConfig(a reference to userConfig's didNotify, defaultConfig's didNotify)
	set config's willGrowl to getConfig(a reference to userConfig's willGrowl, defaultConfig's willGrowl)
	set config's didGrowl to getConfig(a reference to userConfig's didGrowl, defaultConfig's didGrowl)
	set config's willPlaySound to getConfig(a reference to userConfig's willPlaySound, defaultConfig's willGrowl)
	set config's didPlaySound to getConfig(a reference to userConfig's didPlaySound, defaultConfig's didPlaySound)
	set config's shouldNotify to getConfig(a reference to userConfig's shouldNotify, defaultConfig's shouldNotify)
	return config
end initConfig

-- Play a sound file, specified by its POSIX path.  The file can be any format that Core Audio or QuickTime supports.
on playSoundFile from soundPath
	-- Yes, this is ridiculous.  AppleScript doesn't provide a way to play a sound file.  AppKit gives us NSSound, but of course it isn't accessible to AppleScript.  It's possible with AppleScriptObjC, but that's only available in AppleScript applications, not in scripts.  This has to be a script (not an application) for iChat to be able to run it.
	do shell script "python -c 'import sys, time, AppKit; s=AppKit.NSSound .alloc() .initWithContentsOfFile_byReference_(sys.argv[1], True); s.play() and time.sleep(s.duration())' " & the quoted form of soundPath & " &>/dev/null&"
end playSoundFile
-- Play a sound.  The soundName can be an alias, a POSIX path, or text that is the name of a sound built into iChat (e.g., "Buddy Logging In").
on playSound from soundName
	if the class of soundName is alias then
		playSoundFile from the POSIX path of soundName
	else if soundName starts with "/" then
		playSoundFile from soundName
	else
		local soundFilename, soundAlias
		set soundFilename to soundName & ".aiff"
		set soundAlias to the path to resource soundFilename in bundle (application "iChat")
		playSoundFile from soundAlias's POSIX path
	end if
end playSound

using terms from application "iChat"
	on growl of theText from theBuddy for theEvent given showingStatus:showingStatus
		local buddyName, buddyIcon
		local theTitle, theDescription
		
		initConfig()
		
		-- You could actually combine readyToNotify with shouldNotify.  They're separate because the default shouldNotify has useful code that the user might want to keep when overriding readyToNotify.
		readyToNotify of config for theText from theBuddy out of theEvent given showingStatus:showingStatus
		
		shouldNotify of config for theText from theBuddy out of theEvent given showingStatus:showingStatus
		if not result then
			log "User config has filtered out this event"
			return
		end if
		
		if theBuddy is equal to null then
			set theTitle to theEvent
			set theDescription to theText
			set buddyIcon to missing value
		else
			set buddyName to theBuddy's name
			set buddyIcon to theBuddy's image
			
			if showingStatus and theBuddy's status message is not "" then
				set theTitle to theText
				set theDescription to theBuddy's status message
			else
				set theTitle to buddyName
				set theDescription to theText
			end if
			
			-- Don't do anything if we're chatting with the buddy in question.
			try
				local frontApp, windowName
				-- This is in a "try" because, if things aren't exactly as we're expecting (e.g., iChat is frontmost but has no windows open), we want to go ahead and growl.
				if application "iChat" is frontmost then
					tell application "iChat" to set windowName to name of front window
					-- Character id 8212 is an em dash.  We don't use a literal, because AppleScript uses Mac-Roman or UTF-16 (with a BOM), but github will show it as ISO-8859-1.  To allow both clones and web browsing to work, we use ASCII only.
					if windowName starts with (buddyName & space & character id 8212 & space) then return
					if windowName ends with (space & character id 8212 & space & buddyName) then return
				end if
			end try
		end if
		
		willNotify of config for theText from theBuddy out of theEvent given title:theTitle, description:theDescription, icon:buddyIcon, showingStatus:showingStatus
		
		repeat with soundRec in config's soundlist
			if soundRec's event is theEvent then
				willPlaySound of config for theText from theBuddy out of theEvent given title:theTitle, description:theDescription, icon:buddyIcon, showingStatus:showingStatus
				playSound from soundRec's sound
				didPlaySound of config for theText from theBuddy out of theEvent given title:theTitle, description:theDescription, icon:buddyIcon, showingStatus:showingStatus
			end if
		end repeat
		
		-- The Growl development team highly recommends not sending notifications from AppleScript if the app isn't running.  I'm not sure I agree with that assessment (particularly for a script whose purpose is to growl), but I'll defer to the collected wisdom of the community.  http://growl.info/documentation/applescript-support.php#growlisrunning
		-- We avoid talking to System Events like the sample code does, since that may take several seconds of loading.  We know the current application is running, and it's a fair bet that the current application has a fair bit of its scripting support paged in, so we mostly try to use it instead.
		if application id "com.Growl.GrowlHelperApp" is running then
			
			willGrowl of config for theDescription from theBuddy out of theEvent given title:theTitle, eventName:theEvent, icon:buddyIcon, showingStatus:showingStatus
			
			-- We use the application id here instead of the name because the application name changed in Growl 1.3, so this works with both.	
			tell application id "com.Growl.GrowlHelperApp"
				local allNotificationsList, enabledNotificationsList
				set the allNotificationsList to {"Login Finished", "Logout Finished", "Buddy Became Available", "Buddy Became Unavailable", "Buddy Authorization Requested", "Chat Room Message Received", "Message Received", "Addressed Message Received", "Message Sent", "Received Text Invitation", "Received Audio Invitation", "Received Video Invitation", "Received Local Screen Sharing Invitation", "Received Remote Screen Sharing Invitation", "A/V Chat Started", "A/V Chat Ended", "Received File Transfer Invitation", "Completed File Transfer"}
				-- Since the script has to be manually enabled for each event in iChat, we tell Growl to enable us on all notifications.  There's no point in filtering both in iChat and in Growl.
				set the enabledNotificationsList to allNotificationsList
				register as application "iChat Growl AppleScript" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "iChat"
				if buddyIcon is equal to missing value then
					notify with name theEvent title theTitle description theDescription application name "iChat Growl AppleScript"
				else
					notify with name theEvent title theTitle description theDescription application name "iChat Growl AppleScript" image buddyIcon
				end if
			end tell
			
			didGrowl of config for theDescription from theBuddy out of theEvent given title:theTitle, eventName:theEvent, icon:buddyIcon, showingStatus:showingStatus
		end if
		
		didNotify of config for theText from theBuddy out of theEvent given title:theTitle, description:theDescription, icon:buddyIcon, showingStatus:showingStatus
		
	end growl
	
	on login finished for theService
		growl of (theService's name & " login finished") from null for "Login Finished" without showingStatus
	end login finished
	on logout finished for theService
		growl of (theService's name & " logout finished") from null for "Logout Finished" without showingStatus
	end logout finished
	on buddy became available theBuddy
		growl of (theBuddy's name & " became available") from theBuddy for "Buddy Became Available" with showingStatus
	end buddy became available
	on buddy became unavailable theBuddy
		growl of (theBuddy's name & " became unavailable") from theBuddy for "Buddy Became Unavailable" with showingStatus
	end buddy became unavailable
	on buddy authorization requested theRequest
		local theBuddy
		set theBuddy to theRequest's buddy
		growl of (theBuddy's name & " requested authorization") from theBuddy for "Buddy Authorization Requested" without showingStatus
		if "buddy authorization" is in config's autoAccept then accept theRequest
	end buddy authorization requested
	on chat room message received message from theBuddy for textChat
		growl of message from theBuddy for "Chat Room Message Received" without showingStatus
	end chat room message received
	on message received message from theBuddy for textChat
		growl of message from theBuddy for "Message Received" without showingStatus
	end message received
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events conflict; I think they have the same ID by mistake.
	on addressed message received from theBuddy for textChat
		growl of message from theBuddy for "Addressed Message Received"
	end addressed message received
	*)
	on message sent message for textChat
		growl of message from null for "Message Sent" without showingStatus
	end message sent
	on received text invitation message from theBuddy for textChat
		growl of message from theBuddy for "Received Text Invitation" without showingStatus
		if "text" is in config's autoAccept then accept textChat
	end received text invitation
	on received audio invitation from theBuddy for audioChat
		growl of (theBuddy's name & " would like to speak with you.") from theBuddy for "Received Audio Invitation" without showingStatus
		if "audio" is in config's autoAccept then accept audioChat
	end received audio invitation
	on received video invitation from theBuddy for videoChat
		growl of (theBuddy's name & " would like to see you.") from theBuddy for "Received Video Invitation" without showingStatus
		if "video" is in config's autoAccept then accept videoChat
	end received video invitation
	on received local screen sharing invitation from theBuddy for screenChat
		growl of (theBuddy's name & " would like to see your screen.") from theBuddy for "Received Local Screen Sharing Invitation" without showingStatus
		if "local screen sharing" is in config's autoAccept then accept screenChat
	end received local screen sharing invitation
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events conflict; I think they have the same ID by mistake.
	on received remote screen sharing invitation from theBuddy for screenChat
		growl of (theBuddy's name & " would like you to see their screen.") from theBuddy for "Received Remote Screen Sharing Invitation"
		if "remote screen sharing" is in config's autoAccept then accept screenChat
	end received remote screen sharing invitation
	*)
	on av chat started
		growl of "A/V Chat Started" from null for "A/V Chat Started" without showingStatus
	end av chat started
	on av chat ended
		growl of "A/V Chat Ended" from null for "A/V Chat Ended" without showingStatus
	end av chat ended
	on received file transfer invitation fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Received File Transfer Invitation" without showingStatus
		if "file transfer" is in config's autoAccept then accept fileTransfer
	end received file transfer invitation
	on completed file transfer fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Completed File Transfer" without showingStatus
	end completed file transfer
	
end using terms from

(*
-- It's convenient to have an "on run" handler during development to run test code from AppleScript Editor.  However, it appears that this handler will be called if there is an error, when iChat displays the error dialog.  (It is not called for normal events.)  So don't leave it in here after you're done with debugging.
on run
	using terms from application "iChat"
		growl of "test message" from {handle:"buddy", name:"buddy", image:missing value, service:{name:"Gmail"}} for "Buddy Became Available" without showingStatus
	end using terms from
end run
*)