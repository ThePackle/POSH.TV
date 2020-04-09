function invoke-TwitchBotCommand{
    param([Parameter(Mandatory=$true,Position=0)]$regex)
    
    #$regexchk   = [regex]::new("^>[a-zA-Z0-9\ ]+$")
    $ircregex   = [regex]::new("^(?:@([^ ]+) )?(?:[:]((?:(\w+)!)?\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$")
    $match      = $ircregex.match($regex)
    
    #$tags       = $match.groups[1].value #Metatags associated with all messages.
    #$prefix     = $match.groups[2].value #Usually PRIVMSG, the Twitch IRC API call for sending a message.
    $global:user = $match.groups[3].value #User who sent the message.
    #$command    = $match.groups[4].value #Channel of which the message is with.
    #$params     = $match.groups[5].value #Forgot
    $message     = $match.groups[6].value #The actual message of the chat line.

    write-host "$user : [$message]"
    
    if($message.startswith("!")){
        $index  = $message.indexof(" ")
        if($index -gt 1){
            $cmd = $message.substring(0, $index)
            $syntax = $message.substring($index+1)
        }
        else{
            $cmd = $message
            $syntax = $null
        }
        
        if(!($chatmods.containskey($user)) -and ($commandlist -contains $cmd)){
            push-TwitchBotMessage -message "$user does not have permission to use this command."
        }
        elseif($commands.containskey($cmd)){
            $sendmsg = $commands.$cmd
            push-TwitchBotMessage -message "$sendmsg"
        }
        elseif($message.startswith("!addcmd")){add-TwitchBotCommand -syntax $syntax}
        elseif($message.startswith("!editcmd")){update-TwitchBotCommand -syntax $syntax}
        elseif($message.startswith("!removecmd")){remove-TwitchBotCommand -syntax $syntax}
        elseif($message.startswith("!addmod")){add-TwitchBotMod -syntax $syntax}
        elseif($message.startswith("!removemod")){remove-TwitchBotMod -syntax $syntax}
        elseif($message.startswith("!listcmd") -or ($message.startswith("!commands"))){
            $listcmd = $commands.keys | sort-object
            push-TwitchBotMessage -message "All available commands: $listcmd"
        }
        elseif($message.startswith("!part") -and ($global:chatmods.$user -eq "Admin")){
            push-TwitchBotMessage -message "Goodbye!"
            $global:writer.WriteLine("PART $global:channel")
            $global:writer.Flush()
            exit
        }
        else{
            push-TwitchBotMessage -message "$cmd command does not exist."
        }
    }
}