function get-POSHTVSR{
    param([Parameter(Mandatory=$true,Position=0)][AllowNull()]$syntax,
          [Parameter(Mandatory=$true,Position=1)]$invoke)

    $global:pblistfinal = get-content "$poshtv\Speedrun\PBList.json" | convertfrom-json
    
    if(1 -eq $invoke){
        $invokedpb = $pblistfinal | where-object {$_.chatabbr -eq $syntax}

        if($syntax.startswith("list")){
            $list = ($pblistfinal | where-object {$_.chatabbr -like "*"}).chatabbr
            foreach($item in $list){
                if(!($null -eq $item)){$publish = $publish + "$item, "}
            }
            $publish = $publish.trimend(", ")

            push-POSHTVMEssage -message "All current chat abbreviations: $publish"
        }
        elseif($null -eq $invokedpb){
            push-POSHTVMessage -message "$syntax does not exist as a run abbreviation. Use !pb list to see all abbreviations."
        }
        else{
            $gamename   = $invokedpb.gamename
            $catname    = $invokedpb.gamecat
            $rta        = $invokedpb.rta
            $igt        = $invokedpb.igt
            $vars       = $invokedpb.runvalues.valname
            $runlink    = $invokedpb.runlink

            $pubvar = $null
            foreach($var in $vars){$pubvar = $pubvar + "$var, "}
            $pubvar = $pubvar.trimend(", ")
            
            if(!($null -eq $igt)){
                $igt = $invokedpb.igt
                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $rta ($igt): $runlink"
            }
            else{
                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $rta`: $runlink"
            }
        }
    }
    if(2 -eq $invoke){
        $invokedpb = $pblistfinal | where-object {$_.chatabbr -eq $syntax}

        if($syntax.startswith("list")){
            $list = ($pblistfinal | where-object {$_.chatabbr -like "*"}).chatabbr
            foreach($item in $list){
                if(!($null -eq $item)){$publish = $publish + "$item, "}
            }
            $publish = $publish.trimend(", ")

            push-POSHTVMEssage -message "All current chat abbreviations: $publish"
        }
        elseif($null -eq $invokedpb){
            push-POSHTVMessage -message "$syntax does not exist as a run abbreviation. Use !wr list to see all abbreviations."
        }
        else{
            $gameid     = $invokedpb.gameid
            $catid      = $invokedpb.gamecatid
            $vars       = $invokedpb.runvalues
            $pubvar     = $invokedpb.runvalues.valname | select-object -first 1
            
            $final = $null
            foreach($var in $vars){
                $varid  = $var.varid
                $valid  = $var.valid

                $final  = $final + "var-$varid=$valid&"
            }

            $final = $final.trimend("&")

            $invokedwr  = (invoke-restmethod -uri "https://speedrun.com/api/v1/leaderboards/$gameid/category/$catid`?$final" -method get -useragent $useragent).data.runs.run | select-object -first 1

            $gamename   = $invokedpb.gamename
            $catname    = $invokedpb.gamecat
            $runlink    = $invokedwr.weblink
            $wrrunnerid = $invokedwr.players.id | select-object -first 1
            $wrrunner   = (invoke-restmethod -uri "https://speedrun.com/api/v1/users/$wrrunnerid").data.names.international

            $wrrtbase   = $invokedwr.times.primary_t
            $convert    = [timespan]::fromseconds("$wrrtbase")
            $wrrta      = $convert.ToString("hh\:mm\:ss")

            $wrigbase   = $invokedwr.times.ingame_t
            $wrtbase    = $invokedwr.times.realtime_t
            if(!(0 -eq $wrigbase)){
                $convert    = [timespan]::fromseconds("$wrigbase")
                $wrigt      = $convert.ToString("hh\:mm\:ss")
 
                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $wrrta [RTA]/ $wrigt [IGT] by $wrrunner`: $runlink"
            }
            elseif(($wrrtbase -eq $wrigbase) -or ($wrrtbase -eq $wrtbase)){
                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $wrrta [RTA] by $wrrunner`: $runlink"
            }
            elseif(!(0 -eq ($invokedwr.times.realtime_t))){
                $convert    = [timespan]::fromseconds("$wrtbase")
                $wrt        = $convert.ToString("hh\:mm\:ss")

                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $wrrta [w/o Loads] $wrt [RTA] by $wrrunner`: $runlink"
            }
            else{
                push-POSHTVMessage -message "$gamename - $catname ($pubvar) in $wrrta [RTA] by $wrrunner`: $runlink"
            }
        }
    }
}