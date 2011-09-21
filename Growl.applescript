-- autoAccept: Since you can't specify both this script and "Auto Accept" in the script field in iChat's preferences, it's handy to be able to tell this script to do the accept for certain types of invitations.  It would also be possible to tell it to chain-call a different script; this would be more flexible (for example, if you wanted to run "iTunes Remote Control" instead), but slower.
-- Set this to a list containing some subset of "text", "audio", "video", "buddy authorization", "local screen sharing", "remote screen sharing", and "file transfer", depending on what you want to auto-accept.  (Note that "remote screen sharing" is presently broken; see the comment below.
-- Example to enable only text and remote screen sharing:
-- property autoAccept : {"text", "remote screen sharing"}
property autoAccept : {} -- The default, as distributed, is to disable auto-accept, since that's really not the point of this script.

using terms from application "iChat"
	
	on growl of theText from theBuddy for theEvent given status:showStatus
		local buddyName, buddyIcon
		local theTitle, theDescription
		
		if theBuddy is equal to null then
			set theTitle to theEvent
			set theDescription to theText
			set buddyIcon to missing value
		else
			set buddyName to theBuddy's name
			set buddyIcon to theBuddy's image
			if showStatus and theBuddy's status message is not "" then
				set theTitle to theText
				set theDescription to theBuddy's status message
			else
				set theTitle to buddyName
				set theDescription to theText
			end if
			
			-- Don't do anything if we're chatting with the buddy in question
			try
				local frontApp, windowName
				-- This is in a "try" because, if things aren't exactly as we're expecting (e.g., iChat is frontmost  but has no windows open), we want to go ahead and growl.
				tell application "System Events" to set frontApp to name of first application process whose frontmost is true
				if frontApp is "iChat" then
					tell application "iChat" to set windowName to name of front window
					if windowName starts with (buddyName & " Ñ ") then return
				end if
			end try
		end if
		
		tell application "GrowlHelperApp"
			local allNotificationsList, enabledNotificationsList
			set the allNotificationsList to {"Login Finished", "Logout Finished", "Buddy Became Available", "Buddy Became Unavailable", "Buddy Authorization Requested", "Chat Room Message Received", "Message Received", "Addressed Message Received", "Message Sent", "Received Text Invitation", "Received Audio Invitation", "Received Video Invitation", "Received Local Screen Sharing Invitation", "Received Remote Screen Sharing Invitation", "A/V Chat Started", "A/V Chat Ended", "Received File Transfer Invitation", "Completed File Transfer"}
			set the enabledNotificationsList to allNotificationsList
			-- Another reasonable enabledNotificationsList would be:
			-- {"Buddy Became Available", "Buddy Became Unavailable", "Buddy Authorization Requested", "Chat Room Message Received", "Message Received", "Addressed Message Received", "Received Text Invitation", "Received Audio Invitation", "Received Video Invitation", "Received Local Screen Sharing Invitation", "Received Remote Screen Sharing Invitation", "Received File Transfer Invitation", "Completed File Transfer"}
			-- but since the script has to be enabled individually for each event in iChat anyway, there's no point in not enabling all notifications in Growl by default.
			register as application "iChat Growl AppleScript" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "iChat"
			if buddyIcon is equal to missing value then
				notify with name theEvent title theTitle description theDescription application name "iChat Growl AppleScript" sticky no
			else
				notify with name theEvent title theTitle description theDescription application name "iChat Growl AppleScript" sticky no image buddyIcon
			end if
		end tell
		
	end growl
	
	on login finished for theService
		growl of (theService's name & " login finished") from null for "Login Finished" without status
	end login finished
	on logout finished for theService
		growl of (theService's name & " logout finished") from null for "Logout Finished" without status
	end logout finished
	on buddy became available theBuddy
		growl of (theBuddy's name & " became available") from theBuddy for "Buddy Became Available" with status
	end buddy became available
	on buddy became unavailable theBuddy
		growl of (theBuddy's name & " became unavailable") from theBuddy for "Buddy Became Unavailable" with status
	end buddy became unavailable
	on buddy authorization requested theRequest
		local theBuddy
		set theBuddy to theRequest's buddy
		growl of (theBuddy's name & " requested authorization") from theBuddy for "Buddy Authorization Requested" without status
		if "buddy authorization" is in autoAccept then accept theRequest
	end buddy authorization requested
	on chat room message received message from theBuddy for textChat
		growl of message from theBuddy for "Chat Room Message Received" without status
	end chat room message received
	on message received message from theBuddy for textChat
		growl of message from theBuddy for "Message Received" without status
	end message received
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events
	-- conflict; I think they have the same ID by mistake.
	on addressed message received from theBuddy for textChat
		growl of message from theBuddy for "Addressed Message Received"
	end addressed message received
	*)
	on message sent message for textChat
		growl of message from null for "Message Sent" without status
	end message sent
	on received text invitation message from theBuddy for textChat
		growl of message from theBuddy for "Received Text Invitation" without status
		if "text" is in autoAccept then accept textChat
	end received text invitation
	on received audio invitation from theBuddy for audioChat
		growl of (theBuddy's name & " would like to speak with you.") from theBuddy for "Received Audio Invitation" without status
		if "audio" is in autoAccept then accept audioChat
	end received audio invitation
	on received video invitation from theBuddy for videoChat
		growl of (theBuddy's name & " would like to see you.") from theBuddy for "Received Video Invitation" without status
		if "video" is in autoAccept then accept videoChat
	end received video invitation
	on received local screen sharing invitation from theBuddy for screenChat
		growl of (theBuddy's name & " would like to see your screen.") from theBuddy for "Received Local Screen Sharing Invitation" without status
		if "local screen sharing" is in autoAccept then accept screenChat
	end received local screen sharing invitation
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events
	-- conflict; I think they have the same ID by mistake.
	on received remote screen sharing invitation from theBuddy for screenChat
		growl of (theBuddy's name & " would like you to see their screen.") from theBuddy for "Received Remote Screen Sharing Invitation"
		if "remote screen sharing" is in autoAccept then accept screenChat
	end received remote screen sharing invitation
	*)
	on av chat started
		growl of "A/V Chat Started" from null for "A/V Chat Started" without status
	end av chat started
	on av chat ended
		growl of "A/V Chat Ended" from null for "A/V Chat Ended" without status
	end av chat ended
	on received file transfer invitation fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Received File Transfer Invitation" without status
		if "file transfer" is in autoAccept then accept fileTransfer
	end received file transfer invitation
	on completed file transfer fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Completed File Transfer" without status
	end completed file transfer
	
end using terms from