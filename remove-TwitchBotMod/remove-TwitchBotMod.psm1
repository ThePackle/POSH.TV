function remove-TwitchBotMod{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    $syntax = $syntax + " "
    $index  = $syntax.indexof(" ")
    $cmd    = $syntax.substring(0,$index)

    if(!($global:chatmods.$global:user -eq "Admin")){
        push-TwitchBotMessage -message "Only administrators for $global:botname can use this command."
    }
    elseif(!($global:chatmods.containskey($cmd))){
        push-TwitchBotMessage -message "$cmd is not in the moderator list."
    }
    elseif($null -eq $syntax){
        push-TwitchBotMessage -message "Syntax: !removemod [TwitchName]"
    }
    else{
        $global:chatmods.remove($cmd)

        $chatmods | convertto-json | set-content -path "Chatmods.json" -passthru | out-null
    
        push-TwitchBotMessage -message "$cmd was removed."
    }
}