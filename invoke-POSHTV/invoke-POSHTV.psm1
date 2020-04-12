function invoke-POSHTV{
    #Requires -Version 6.0
    $global:poshtv          = "$env:appdata\POSHTV"
    $global:twitchjson      = "$poshtv\Settings\Twitch.json"
    $global:commandsjson    = "$poshtv\Settings\Commands.json"
    $global:chatmodsjson    = "$poshtv\Settings\ChatMods.json"
    $global:srpblistjson    = "$poshtv\Speedrun\PBList.json"
    $global:useragent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Firefox
    
    if(!(test-path "$poshtv\Settings\Twitch.json") -or !(test-path "$poshtv\Settings\Chatmods.json") -or !(test-path "$poshtv\Settings\Commands.json")){
        enable-POSHTV
    }

    clear-host

    try{$global:json = get-content $twitchjson -erroraction stop | convertfrom-json}
    catch{write-error "An error occurred loading Twitch.json from $twitchjson."; exit}

    #SET GLOBAL VARIABLES FROM JSONS
    $global:botname         = $json.botname
    $global:oauth           = $json.ouath
    $global:channel         = $json.channel
    $global:srcom           = $json.srcom
    $global:quotes          = $json.quotes

    try{$global:commands = get-content $commandsjson -erroraction stop | convertfrom-json -ashashtable}
    catch{write-error "An error occurred loading Commands.json from $commandsjson."; exit}

    try{$global:chatmods = get-content $chatmodsjson -erroraction stop | convertfrom-json -ashashtable}
    catch{write-error "An error occurred loading ChatMods.json from $chatmodsjson."; exit}

    try{$global:srpblist = get-content $srpblistjson -erroraction stop | convertfrom-json}
    catch{write-error "An error occurred loading Twitch.json from $srpblistjson."; exit}

    ##########################################
    #START IRC CLIENT
    ##########################################
    $global:client              = new-object System.Net.Sockets.TcpClient
    $client.nodelay             = $true
    $client.sendbuffersize      = 81920
    $client.receivebuffersize   = 81290
    $client.connect("irc.chat.twitch.tv", 6697)

    $global:stream = $client.getstream()

    $global:sslstream = new-object System.Net.Security.SSLStream $stream, true
    $sslstream.authenticateasclient("irc.chat.twitch.tv")

    $global:writer = new-object System.IO.StreamWriter $sslstream
    $global:reader = new-object System.IO.StreamReader $sslstream
    
    $writer.writeline("PASS $oauth")
    $writer.writeline("NICK $botname")
    $writer.writeline("JOIN $channel")

    $writer.flush()

    if(($json.logs) -eq $true){
        write-host "Current chat log session will be saved to $poshtv\Logs\" -foregroundcolor green
        start-transcript -path "$poshtv\Logs\$(get-date -format 'dd-MM-yy HH-mm-ss')`.log" -useminimalheader | out-null
    }

    write-host "POSH.TV v0.6 -- $(get-date -format 'dd-MMM-yyyy AT HH:mm:ss')" -foregroundcolor green
    write-host "------------------------------------------------" -foregroundcolor green
    
    $global:line = $reader.readline()
    
    while($line){
        if($line -like "PING*"){
            $writer.writeline("PONG :tmi.twitch.tv")
            $writer.flush()
        }
        else{
            invoke-POSHTVCommand -regex $line
        }
        $line = $reader.ReadLine()
    }
}