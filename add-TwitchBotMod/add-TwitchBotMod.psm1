function add-TwitchBotMod{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    $syntax = $syntax + " "
    $index  = $syntax.indexof(" ")
    $cmd    = $syntax.substring(0,$index)

    if(!($global:chatmods.$global:user -eq "Admin")){
        push-TwitchBotMessage -message "Only administrators for $global:botname can use this command."
    }
    elseif($null -eq $cmd){
        push-TwitchBotMessage -message "Syntax: !addmod [TwitchName]"
    }
    elseif($global:chatmods.containskey($cmd)){
        push-TwitchBotMessage -message "$cmd is already a moderator for $global:botname."
    }
    else{
        [hashtable]$addmod = @{
            $cmd = "Moderator"
        }
    
        $global:chatmods += $addmod
    
        $chatmods | convertto-json | set-content -path "Chatmods.json" -passthru | out-null
    }
}