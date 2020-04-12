function invoke-POSHTVCommand{
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

    write-host "[$(get-date -format 'HH:mm:ss')] {$user}: $message"
    
    if($message.startswith("!")){
        $message = $message + " "
        $index = $message.indexof(" ")
        if($index -ge 3){
            $cmd   = $message.substring(0,$index).tolower()
            $param = $message.substring($index+1).trimend(" ")
            
            if($param.startswith("!")){
                $param = $param + " "
                $index = $param.indexof(" ")
                if($index -gt 2){
                    $syntax = $param.substring(0,$index)
                    $param  = $param.substring($index+1)
                    if($param -eq " "){$param = $null}
                }
                else{
                    $syntax = $param
                    $param = $null
                }
            }
        }
        else{
            $cmd    = $message.tolower()
            $syntax = $null
        }

        if(!($chatmods.containskey($user)) -and ($commandlist -contains $cmd)){
            push-POSHTVMessage -message "$user does not have permission to use this command."
        }
        elseif($commands.containskey($cmd)){
            $sendmsg = $commands.$cmd
            push-POSHTVMessage -message "$sendmsg"
        }
        elseif($cmd.startswith("!addcmd")){add-POSHTVCommand -syntax $syntax -param $param}
        elseif($cmd.startswith("!editcmd")){update-POSHTVCommand -syntax $syntax -param $param}
        elseif($cmd.startswith("!removecmd")){remove-POSHTVCommand -syntax $syntax}
        elseif($cmd.startswith("!addmod")){add-POSHTVMod -syntax $syntax}
        elseif($cmd.startswith("!removemod")){remove-POSHTVMod -syntax $syntax}
        #elseif($cmd.startswith("!quote")){}
        #elseif($cmd.startswith("!addquote")){}
        #elseif($cmd.startswith("!removequote")){}
        elseif($cmd.startswith("!pb")){get-POSHTVSR -syntax $param -invoke 1}
        elseif($cmd.startswith("!wr")){get-POSHTVSR -syntax $param -invoke 2}
        elseif($cmd.startswith("!listcmd") -or ($cmd.startswith("!commands"))){
            $listcmd = $commands.keys | sort-object
            push-POSHTVMessage -message "All available commands: $listcmd"
        }
        elseif($cmd.startswith("!part") -and ($chatmods.$user -eq "Admin")){
            push-POSHTVMessage -message "Goodbye!"
            stop-transcript | out-null
            
            $writer.WriteLine("PART $channel")
            $writer.Flush()
            exit
        }
        else{
            push-POSHTVMessage -message "$cmd command does not exist."
        }

        $cmd    = $null
        $syntax = $null
        $param  = $null
    }
}