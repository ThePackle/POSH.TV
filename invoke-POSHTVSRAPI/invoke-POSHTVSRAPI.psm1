function invoke-POSHTVSRAPI{
    $global:srcomapi    = invoke-webrequest -uri "https://speedrun.com/api/v1/users/$srcom/personal-bests" -method get -useragent $useragent | convertfrom-json -depth 10 -ashashtable
    $global:pblist      = $srcomapi.data.run | select-object id,date,game,category,times,weblink,values

    $vallist = @()
    $pblistfinal = @()
    foreach($run in $pblist){
        $runid          = $run.id
        $rundate        = $run.date
        $rungameid      = $run.game
        $runcatid       = $run.category
        $runtimes       = $run.times
        $runlink        = $run.weblink
        $runvalues      = $run.values

        $rungameapi     = invoke-restmethod -uri "https://speedrun.com/api/v1/games/$rungameid" -method get -useragent $useragent
        $rungamename    = $rungameapi.data.names.twitch

        $runcatapi      = invoke-restmethod -uri "https://speedrun.com/api/v1/categories/$runcatid" -method get -useragent $useragent
        $runcatname     = $runcatapi.data.name

        $srpbrtbase     = $runtimes.primary_t
        $convert        = [timespan]::fromseconds("$srpbrtbase")
        $rta            = $convert.ToString("hh\:mm\:ss")

        $srpbigbase     = $runtimes.ingame_t
        if(!(0 -eq $srpbigbase)){
            $convert        = [timespan]::fromseconds("$srpbigbase")
            $igt            = $convert.ToString("hh\:mm\:ss")
        }

        foreach($var in ($runvalues.getenumerator())){
            $key        = $var.name
            $val        = $var.value
            $runvalapi  = invoke-restmethod -uri "https://speedrun.com/api/v1/variables/$key" -method get -useragent $useragent
        
            $runkeyname = $runvalapi.data.name
            $runvalname = $runvalapi.data.values.values."$val".label

            $vallist = new-object psobject -property @{
                VarID   = $key
                VarName = $runkeyname
                ValID   = $val
                ValName = $runvalname
            }
        }

        $pblistadd = new-object psobject -property @{
            RunID       = $runid
            RunDate     = $rundate
            GameID      = $rungameid
            GameName    = $rungamename
            GameCatID   = $runcatid
            GameCat     = $runcatname
            RTA         = $rta
            IGT         = $igt
            RunLink     = $runlink
            RunValues   = $vallist
        }

        $global:pblistfinal += $pblistadd
        
        $igt = $null #because it will automatically set itself to games w/o IGT
    }
}