function remove-TwitchBotCommand{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)
    
    $syntax = $syntax + " "
    $index  = $syntax.indexof(" ")
    $cmd    = $syntax.substring(0,$index)
    
    if(!($global:commands.containskey($cmd))){
        push-TwitchBotMessage -message "$cmd does not exist. How can you remove something that doesn't exist??"
    }
    elseif($null -eq $cmd){
        push-TwitchBotMessage -message "Syntax: !removemod !command"
    }
    else{
        $global:commands.remove($cmd)

        $commands | convertto-json | set-content -path "Commands.json" -passthru | out-null
    
        push-TwitchBotMessage -message "$cmd was removed."
    }
}