-- Originally based on http://amccloud.com/lion-ichat-growl-notifications-50108
-- Modified by Joel Holveck to support other events
-- and to fix the window title check

using terms from application "iChat"
	
	on growl of theText from theBuddy for theEvent
		local buddyName
		local buddyIcon
		local isOnScreen
		local theTitle
		
		if theBuddy is equal to null then
			set theTitle to theEvent
			set buddyIcon to missing value
		else
			set buddyName to theBuddy's name
			set theTitle to buddyName
			set buddyIcon to theBuddy's image
			
			-- Don't do anything if we're chatting with the buddy in question
			try
				tell application "System Events"
					set frontApp to name of first application process whose frontmost is true
				end tell
				if frontApp is "iChat" then
					tell application frontApp
						set windowName to name of front window
					end tell
					if windowName starts with (buddyName & " Ñ ") then
						return
					end if
				end if
			end try
		end if
		
		tell application "GrowlHelperApp"
			set the allNotificationsList to {"Login Finished", "Logout Finished", "Buddy Became Available", "Buddy Became Unavailable", "Buddy Authorization Requested", "Chat Room Message Received", "Message Received", "Addressed Message Received", "Message Sent", "Received Text Invitation", "Received Audio Invitation", "Received Video Invitation", "Received Local Screen Sharing Invitation", "Received Remote Screen Sharing Invitation", "A/V Chat Started", "A/V Chat Ended", "Received File Transfer Invitation", "Completed File Transfer"}
			set the enabledNotificationsList to allNotificationsList
			-- Another reasonable enabledNotificationsList would be:
			-- {"Buddy Became Available", "Buddy Became Unavailable", "Buddy Authorization Requested", "Chat Room Message Received", "Message Received", "Addressed Message Received", "Received Text Invitation", "Received Audio Invitation", "Received Video Invitation", "Received Local Screen Sharing Invitation", "Received Remote Screen Sharing Invitation", "Received File Transfer Invitation", "Completed File Transfer"}
			-- but since the script has to be enabled individually for each event in iChat anyway, there's no point in not enabling all notifications in Growl by default.
			register as application "iChat Growl AppleScript" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "iChat"
			if buddyIcon is equal to missing value then
				notify with name theEvent title theTitle description theText application name "iChat Growl AppleScript" sticky no
			else
				notify with name theEvent title theTitle description theText application name "iChat Growl AppleScript" sticky no image buddyIcon
			end if
		end tell
		
	end growl
	
	on login finished for theService
		growl of (theService's name & " login finished") from null for "Login Finished"
	end login finished
	on logout finished for theService
		growl of (theService's name & " logout finished") from null for "Logout Finished"
	end logout finished
	on buddy became available theBuddy
		growl of (theBuddy's name & " became available") from theBuddy for "Buddy Became Available"
	end buddy became available
	on buddy became unavailable theBuddy
		growl of (theBuddy's name & " became unavailable") from theBuddy for "Buddy Became Unavailable"
	end buddy became unavailable
	on buddy authorization requested theRequest
		set theBuddy to theRequest's buddy
		growl of (theBuddy's name & " requested authorization") from theBuddy for "Buddy Authorization Requested"
	end buddy authorization requested
	on chat room message received message from theBuddy for textChat
		growl of message from theBuddy for "Chat Room Message Received"
	end chat room message received
	on message received message from theBuddy for textChat
		growl of message from theBuddy for "Message Received"
	end message received
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events
	-- conflict; I think they have the same ID by mistake.
	on addressed message received from theBuddy for textChat
		growl of message from theBuddy for "Addressed Message Received"
	end addressed message received
	*)
	on message sent message for textChat
		growl of message from null for "Message Sent"
	end message sent
	on received text invitation message from theBuddy for textChat
		growl of message from theBuddy for "Received Text Invitation"
	end received text invitation
	on received audio invitation from theBuddy for audioChat
		growl of (theBuddy's name & " would like to speak with you.") from theBuddy for "Received Audio Invitation"
	end received audio invitation
	on received video invitation from theBuddy for videoChat
		growl of (theBuddy's name & " would like to see you.") from theBuddy for "Received Video Invitation"
	end received video invitation
	on received local screen sharing invitation from theBuddy for audioChat
		growl of (theBuddy's name & " would like to see your screen.") from theBuddy for "Received Local Screen Sharing Invitation"
	end received local screen sharing invitation
	(*
	-- The "addressed message received" and "received remote screen sharing invitation" events
	-- conflict; I think they have the same ID by mistake.
	on received remote screen sharing invitation from theBuddy for audioChat
	growl of (theBuddy's name & " would like you to see their screen.") from theBuddy for "Received Remote Screen Sharing Invitation"
	end
	*)
	on av chat started
		growl of "A/V Chat Started" from null for "A/V Chat Started"
	end av chat started
	on av chat ended
		growl of "A/V Chat Ended" from null for "A/V Chat Ended"
	end av chat ended
	on received file transfer invitation fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Received File Transfer Invitation"
	end received file transfer invitation
	on completed file transfer fileTransfer
		growl of (fileTransfer's name) from fileTransfer's buddy for "Completed File Transfer"
	end completed file transfer
	
end using terms from