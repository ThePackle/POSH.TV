function enable-POSHTV{

    if(6 -gt ($psversiontable.psversion.major)){
        write-host "Your PowerShell version is 5.0 or below. You will not be able to use certain aspects of this bot." -foregroundcolor red
        write-host "The latest version of PowerShell can be downloaded here:" -foregroundcolor red
        write-host "https://github.com/PowerShell/PowerShell/releases" -foregroundcolor red
        exit
    }

    $poshtv         = "$env:appdata\POSHTV"
    $poshtvlogs     = "$poshtv\Logs"
    $twitchjson     = "$poshtv\Settings\Twitch.json"
    $commandsjson   = "$poshtv\Settings\Commands.json"
    $chatmodsjson   = "$poshtv\Settings\ChatMods.json"
    $srpblistjson   = "$poshtv\Speedrun\PBList.json"

    if(test-path "$poshtv\Settings\*.json"){
        $caption    = "POSHTV Settings Found"
        $message    = "Settings were found in $poshtv\Settings. Would you like to reset or change them?"
        $yes        = new-object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes"
        $no         = new-object System.Management.Automation.Host.ChoiceDescription "&No","No"
        #$change     = new-object System.Management.Automation.Host.ChoiceDescription "&Change","Change"
        $choices    = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
        $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
        switch ($answer){
            0 {remove-item -path "$poshtv\Settings\*.json" -force | out-null}
            1 {write-host "Exiting...";exit}
        }
    }

    clear-host
    write-host "POSH.TV v0.6" -foregroundcolor green
    write-host "DEVELOPED BY THEPACKLE" -foregroundcolor green
    write-host "TWITTER: https://twitter.com/thepackle" -foregroundcolor Green
    write-host "---------------------------------------------" -foregroundcolor green
    $botname = read-host "Input the name of your bot"

    $oauth = read-host "Input your OAUTH token (i.e. oauth:<BLAH>)"
    while(!($oauth -like "oauth:*")){
        write-host "Your OAUTH token MUST be proceeded by 'oauth:' (without quotes)" -foregroundcolor red
        $oauth = read-host "Input your OAUTH token (i.e. oauth:<token>)"
    }
    
    $channel = read-host "Input your channel name"
    
    $caption    = "Quotes"
    $message    = "Would you like quotes to enable quotes?"
    $yes        = new-object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes"
    $no         = new-object System.Management.Automation.Host.ChoiceDescription "&No","No"
    $choices    = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
    $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
    switch ($answer){
        0 {$quotes = $true}
        1 {$quotes = $false}
    }

    $caption    = "Logging"
    $message    = "Would you like to enable logging to $poshtvlogs`?"
    $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
    switch ($answer){
        0 {$logs = $true}
        1 {$logs = $false}
    }

    $twitchtoken = convertto-securestring -string ($oauth.trimstart("oauth:")) -asplaintext
    $userid      = (invoke-restmethod -uri "https://api.twitch.tv/helix/users?login=$channel" -authentication oauth -token $twitchtoken).data.id

    $caption    = "Speedrun.com Integration"
    $message    = "Would you like to enable integration with Speedrun.com?"
    $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
    switch ($answer){
        0 {$srintegration = $true}
        1 {$srintegration = $false}
    }

    if($true -eq $srintegration){
        $srcom = read-host "What is your username for Speedrun.com?"
        if(!($null -eq $srcom)){
            $srapi = invoke-restmethod -uri "https://speedrun.com/api/v1/users/$srcom"
            $global:srcom = $srapi.data.id

            write-host "POSH.TV will search your username provided for your PBs as of this moment." -foregroundcolor green
            write-host "Depending on how many runs (including ILs) you have completed, this can take time." -foregroundcolor green
            write-host "If this needs to be updated, run this script again." -foregroundcolor green
            pause
            
            invoke-POSHTVSRAPI
            write-host "After pressing Enter, a pop-up will appear with all of your PBs. Select each one you want to save." -foregroundcolor green
            pause

            $selectpbs = $pblistfinal | select-object -property GameName,GameCat,@{Name="RunValues"; Expression={$_.runvalues | select-object -expandproperty ValName}},RunID | out-gridview -title "Select PBs" -passthru
            foreach($pb in $selectpbs){
                $pbname         = $pb.gamename
                $pbcatname      = $pb.gamecat
                $id             = $pb.runid
                $valname        = $pb.runvalues.valname
                $confirmabbr    = "redo"
                while("redo" -contains $confirmabbr){
                    write-host "Create a chat abbreviation for $pbname $pbcatname ($valname)." -foregroundcolor green
                    write-host "Only characters or numbers, no special characters or spaces." -foregroundcolor green
                    $chatabbr = read-host "Chat Abbreviation"
                    write-host "The follow command would be used in your chat to display this pb:" -foregroundcolor green
                    write-host "!pb $chatabbr" -foregroundcolor green
                    $confirmabbr = read-host "Is this the abbreviation you wish to use? (y/n/redo)"
                    while("y","n","redo" -notcontains $confirmabbr){
                        $confirmabbr = read-host "Is this the abbreviation you wish to use? (y/n/redo)"
                    }
                }
                if("y" -eq $confirmabbr){
                    $pblistfinal | where-object {$_.runid -eq $id} | add-member -type noteproperty -name ChatAbbr -value $chatabbr
                }
            }
        }
        else{
            $srcom = $null
        }
    }
    else{
        $srcom = $null
    }

    if(!($channel -like "#*")){$channel = "#$channel"}

    $mainjson = new-object psobject -property @{
        BotName   = $botname
        Ouath     = $oauth
        TwitchID  = $userid
        Channel   = $channel
        SRCom     = $srcom
        Quotes    = $quotes
        Logs      = $logs
    }

    $chatmods = new-object psobject -property @{
        $channel.replace("#","") = "Admin"
    }

    $commands = new-object psobject -property @{}

    $mainjson | convertto-json | add-content -path $twitchjson -passthru | out-null
    $chatmods | convertto-json | add-content -path $chatmodsjson -passthru | out-null
    $commands | convertto-json | add-content -path $commandsjson -passthru | out-null
    $pblistfinal | convertto-json | set-content -path $srpblistjson -passthru | out-null
    
    write-host "Settings saved! Use the following command to start your new bot:" -foregroundcolor green
    write-host "invoke-POSHTV" -foregroundcolor green
}