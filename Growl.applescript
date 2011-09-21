using terms from application "iChat"
    on message received message from theBuddy for textChat
        set whoDidIt to full name of theBuddy
        set buddyIcon to image of theBuddy
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
        end tell
        tell application frontApp
            set window_name to name of front window
        end tell
        if whoDidIt is not in window_name then
            tell application "GrowlHelperApp" -- ** the daemon that is behind the scenes
                -- Make a list of all the notification types that this script will ever send:
                set the allNotificationsList to {"IM Received"}
                -- Make a list of the notifications that will be enabled by default.
                set the enabledNotificationsList to {"IM Received"}
                -- Register our script with growl.
                register as application "iChat Growl AppleScript" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "iChat"
                if buddyIcon is equal to missing value then
                    notify with name "IM Received" title whoDidIt description message application name "iChat Growl AppleScript" sticky no
                else
                    notify with name "IM Received" title whoDidIt description message application name "iChat Growl AppleScript" sticky no image buddyIcon
                end if
            end tell
        end if
    end message received
end using terms from
