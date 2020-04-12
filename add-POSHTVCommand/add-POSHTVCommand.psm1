function add-POSHTVCommand{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax,
          [Parameter(Mandatory=$true,Position=1)][AllowNull()]$param)

    if($null -eq $syntax){
        push-POSHTVMessage -message "Syntax: !addcmd !command This is text"
    }
    elseif($null -eq $param){
        push-POSHTVMEssage -message "There was no text after $syntax."
    }
    elseif(!($syntax.startswith("!"))){
        push-POSHTVMessage -message "All commands must be proceeded with an ! . Example: !addcmd !command This is text"
    }
    elseif($global:commands.containskey($syntax)){
        push-POSHTVMessage -message "$syntax already exists. Please use !editcmd to change it."
    }
    else{        
        [hashtable]$inputcommand = @{
            $syntax = $param
        }

        $global:commands += $inputcommand
        $global:commands | convertto-json | set-content -path $commandsjson -passthru | out-null

        push-POSHTVMessage -message "$syntax was added."
    }
}