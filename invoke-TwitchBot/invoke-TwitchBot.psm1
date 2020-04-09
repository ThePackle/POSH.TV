function invoke-TwitchBot{
    if(!(test-path "Twitch.json") -or !(test-path "Chatmods.json")){
        enable-TwitchBot
    }
    clear-host
    try{
        $global:json        = get-content "Twitch.json" -erroraction stop | convertfrom-json
        $global:commands    = get-content "Commands.json" -erroraction stop | convertfrom-json -ashashtable
        $global:chatmods    = get-content "ChatMods.json" -erroraction stop | convertfrom-json -ashashtable
    }
    catch{
        write-error "An error occurred loading Twitch.json, Commands.json, ChatMods.json, or Points.json. Please ensure these files are in the correct directory ($pwd), then try again."
        exit
    }

    $global:botname    = $json.botname
    $global:oauth      = $json.ouath
    $global:channel    = $json.channel
    $global:srcom      = $json.srcom

    $global:commandslist =@(
        "!addcmd",
        "!editcmd",
        "!removecmd",
        "!addmod",
        "!removemod",
        "!part"
    )

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
    
    $writer.newline = "`r`n"
    
    $writer.writeline("PASS $oauth")
    $writer.writeline("NICK $botname")
    $writer.writeline("JOIN $channel")

    $writer.flush()

    $global:line = $reader.readline()

    while($line){
        if($line -like "PING*"){
            $writer.writeline("PONG :tmi.twitch.tv")
            $writer.flush()
        }
        else{
            invoke-TwitchBotCommand -regex $line
        }
        $line = $reader.ReadLine()
    }
}