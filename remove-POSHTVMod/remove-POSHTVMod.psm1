function remove-POSHTVMod{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    if(!($chatmods.$user -eq "Admin")){
        push-POSHTVMessage -message "Only administrators for $botname can use this command."
    }
    elseif($null -eq $syntax){
        push-POSHTVMessage -message "Syntax: !removemod [TwitchName]"
    }
    elseif(!($chatmods.containskey($syntax))){
        push-POSHTVMessage -message "$syntax is not in the moderator list."
    }
    else{
        $chatmods.remove($syntax)

        $chatmods | convertto-json | set-content -path $chatmodsjson -passthru | out-null
    
        push-POSHTVMessage -message "$syntax was removed."
    }
}