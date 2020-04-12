function update-POSHTVSR{
    param([Parameter(Mandatory=$false,Position=0)]$invoke)

    if(1,2 -contains $invoke){
        $caption    = "Update POSH.TV Speedrun.com Information"
        $message    = "What would you like to do?"
        $1          = new-object System.Management.Automation.Host.ChoiceDescription "&Abbreviations","Abbreviations"
        $2          = new-object System.Management.Automation.Host.ChoiceDescription "&Update from Speedrun.com","Update from Speedrun.com"
        $choices    = [System.Management.Automation.Host.ChoiceDescription[]]($1,$2)
        $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
        switch ($answer){
            0 {$invoke = 1}
            1 {$invoke = 2}
        }
    }

    $poshtv          = "$env:appdata\POSHTV"
    $srpblistjson    = "$poshtv\Speedrun\PBList.json"

    try{$srpblist = get-content $srpblistjson -erroraction stop | convertfrom-json}
    catch{write-error "An error occurred loading Twitch.json from $srpblistjson."; exit}

    if(1 -eq $invoke){
        write-host "After pressing Enter, select any PBs you would like to create (or change) an abbreviation for"
        pause

        $selectpbs = $srpblist | select-object -property GameName,GameCat,@{Name="RunValues"; Expression={$_.runvalues | select-object -expandproperty ValName}},RunID,ChatAbbr | out-gridview -title "Select PBs" -passthru
        foreach($pb in $selectpbs){
            $pbname         = $pb.gamename
            $pbcatname      = $pb.gamecat
            $id             = $pb.runid
            $valname        = $pb.runvalues

            $confirmabb     = "redo"
            while("redo" -contains $confirmabb){
                $chatabbr   = read-host "What is your chat abbreviation for $pbname - $pbcatname ($valname)?"
                $caption    = "The following command would be used in your chat. Is this fine?"
                $message    = "!pb $chatabbr"
                $yes        = new-object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes"
                $no         = new-object System.Management.Automation.Host.ChoiceDescription "&No","No"
                $redo       = new-object System.Management.Automation.Host.ChoiceDescription "&Redo","Redo"
                $choices    = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no,$redo)
                $answer     = $host.ui.PromptForChoice($caption,$message,$choices,0)
                switch ($answer){
                    0 {$confirmabb = 0; $pblistfinal | where-object {$_.runid -eq $id} | add-member -type noteproperty -name ChatAbbr -value $chatabbr -force}
                    1 {}
                    2 {$confirmabb = "redo"}
                }
            }
        }
    }
    elseif(2 -eq $invoke){
        invoke-POSHTVSRAPI
    }
    $pblistfinal | convertto-json | set-content -path $srpblistjson -passthru | out-null
}