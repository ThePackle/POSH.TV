function add-POSHTVMod{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax)

    if(!($chatmods.$global:user -eq "Admin")){
        push-POSHTVMessage -message "Only administrators for $botname can use this command."
    }
    elseif($null -eq $syntax){
        push-POSHTVMessage -message "Syntax: !addmod [TwitchName]"
    }
    elseif($global:chatmods.containskey($syntax)){
        push-POSHTVMessage -message "$syntax is already a moderator for $botname."
    }
    else{
        [hashtable]$addmod = @{
            $syntax = "Moderator"
        }
    
        $global:chatmods += $addmod
    
        $chatmods | convertto-json | set-content -path $chatmodsjson -passthru | out-null
        push-POSHTVMessage -message "$syntax has been added as a moderator."
    }
}