function update-POSHTVCommand{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax,
          [Parameter(Mandatory=$true,Position=1)][AllowNull()]$param)

    if($null -eq $param){
        push-POSHTVMessage -message "Syntax: !editcmd [CommandMame] <words to be changed>"
    }
    elseif(!($syntax.startswith("!"))){
        push-POSHTVMessage -message "All commands must be proceeded with an ! . Example: !editcmd !command This is text"
    }
    elseif(!($commands.containskey($syntax))){
        push-POSHTVMessage -message "$syntax does not exist. Please use !addcmd to add it."
    }
    else{
        [hashtable]$inputcommand = @{
            $syntax = $param
        }
    
        $commands.remove($cmd)
        $commands += $inputcommand
        $commands | convertto-json | set-content -path $commandsjson -passthru | out-null
    
        push-POSHTVMessage -message "$syntax was overwritten."
    }
}