function add-TwitchBotCommand{
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
        push-TwitchBotMessage -message "Syntax: !addcmd !command This is text"
    }
    elseif(!($cmd.startswith("!"))){
        push-TwitchBotMessage -message "All commands must be proceeded with an ! . Example: !addcmd !command This is text"
    }
    elseif($global:commands.containskey($cmd)){
        push-TwitchBotMessage -message "$cmd already exists. Please use !editcmd to change it."
    }
    else{        
        [hashtable]$inputcommand = @{
            $cmd = $syntax
        }

        $global:commands += $inputcommand
        $global:commands | convertto-json | set-content -path "Commands.json" -passthru | out-null

        push-TwitchBotMessage -message "$cmd was added."
    }
}