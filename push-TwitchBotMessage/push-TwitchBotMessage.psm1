function push-TwitchBotMessage{
    param([Parameter(Mandatory=$true,Position=0)]$message)
    
    write-host $message
    start-sleep -seconds 1
    $global:writer.WriteLine("PRIVMSG $global:channel :$message")
    $global:writer.Flush()
}