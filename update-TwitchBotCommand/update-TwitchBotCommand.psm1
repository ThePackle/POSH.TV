function update-TwitchBotCommand{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    $index  = $syntax.indexof(" ")
    if($index -gt 1){
        $cmd    = $syntax.substring(0,$index)
        $syntax = $syntax.substring($index+1)
    }
    else{
        $syntax = $null
    }

    if($null -eq $syntax){
        push-TwitchBotMessage -message "Syntax: !editcmd [CommandMame] <words to be changed>"
    }
    elseif(!($cmd.startswith("!"))){
        push-TwitchBotMessage -message "All commands must be proceeded with an ! . Example: !editcmd !command This is text"
    }
    elseif(!($commands.containskey($cmd))){
        push-TwitchBotMessage -message "$cmd does not exist. Please use !addcmd to add it."
    }
    elseif($null -eq $syntax){
        push-TwitchBotMessage -message "No text was specified following the command name."
    }
    else{
        [hashtable]$inputcommand = @{
            $cmd = $syntax
        }
    
        $global:commands.remove($cmd)
        $global:commands += $inputcommand
        $commands | convertto-json | set-content -path "Commands.json" -passthru | out-null
    
        push-TwitchBotMessage -message "$cmd was overwritten."
    }
}