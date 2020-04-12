function push-POSHTVMessage{
    param([Parameter(Mandatory=$true,Position=0)]$message)
    
    write-host "[$(get-date -format 'HH:mm:ss')] {$botname}: $message"
    start-sleep -milliseconds 500
    $writer.WriteLine("PRIVMSG $channel :$message")
    $writer.Flush()
}