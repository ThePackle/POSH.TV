function remove-POSHTVCommand{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    if($null -eq $syntax){
        push-POSHTVMessage -message "Syntax: !removemod !command"
    }
    elseif(!(commands.containskey($syntax))){
        push-POSHTVMessage -message "$syntax does not exist. How can you remove something that doesn't exist??"
    }
    else{
        $commands.remove($syntax)

        $commands | convertto-json | set-content -path $commandsjson -passthru | out-null
    
        push-POSHTVMessage -message "$syntax was removed."
    }
}