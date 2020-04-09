function enable-TwitchBot{
    if(test-path "Twitch.json"){
        $restart = read-host "Setting files were found in $pwd. Would you like to reset it? (y/n)"
        while("y","n" -notcontains $restart){
            $restart = read-host "Setting files were found in $pwd. Would you like to reset it? (y/n)"
        }
        if($restart -eq "y"){
            remove-item -path "Twitch.json" -force | out-null
            remove-item -path "Commands.json" -force | out-null
            remove-item -path "Chatmods.json" -force | out-null
            clear-host
        }
        else{
            write-host "Exiting..."
            exit
        }
    }

    write-host "POSH.TV v0.5" -foregroundcolor green
    write-host "DEVELOPED BY THEPACKLE" -foregroundcolor green
    write-host "TWITTER: https://twitter.com/thepackle" -foregroundcolor Green
    write-host "INSTRUCTIONS: https://github.com/ThePackle/POSH.TV/blob/master/Instructions" -foregroundcolor green
    write-host "---------------------------------------------" -foregroundcolor green
    $botname = read-host "Input the name of your bot"
    $oauth = read-host "Input your OAUTH token (i.e. oauth:<BLAH>)"
    while(!($oauth -like "oauth:*")){
        write-host "Your OAUTH token MUST be proceeded by 'oauth:' (without quotes)" -foregroundcolor red
        $oauth = read-host "Input your OAUTH token (i.e. oauth:<token>)"
    }
    
    $channel = read-host "Input the channel you wish to initially join"
    $srcom = read-host "What is your username for speedrun.com?"
    
    $quotes = read-host "Would you like quotes to be available to everyone? (y/n)"
    while("y","n" -notcontains $quotes){
        $quotes = read-host "Would you like quotes to be available to everyone? (y/n)"
    }
    if($quotes -eq "y"){$quotes = $true}
    else{$quotes = $false}

    $logs = read-host "Would you like to enable chat logging to $pwd\Logs? (y/n)"
    while("y","n" -notcontains $logs){
        $logs = read-host "Would you like quotes to be available to everyone? (y/n)"
    }
    if($logs -eq "y"){$logs = $true}
    else{$logs = $false}

    if(!($channel -like "#*")){$channel = "#$channel"}

    $mainjson = new-object psobject -property @{
        BotName = $botname
        Ouath   = $oauth
        Channel = $channel
        SRCom   = $srcom
        Quotes  = $quotes
        Logs    = $logs
    }

    $chatmods = new-object psobject -property @{
        $channel.replace("#","") = "Admin"
    }

    $commands = new-object psobject -property @{
        "!ping" = "Pong"
    }

    $mainjson | convertto-json | add-content -path "Twitch.json" -passthru | out-null
    $chatmods | convertto-json | add-content -path "Chatmods.json" -passthru | out-null
    $commands | convertto-json | add-content -path "Commands.json" -passthru | out-null
    
    write-host "Settings saved! Use the following command to start your new bot:" -foregroundcolor green
    write-host "invoke-TwitchBot" -foregroundcolor green
}