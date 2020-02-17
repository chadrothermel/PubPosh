Function start-adsync{
    Param ($PolicyType = 'Delta')
$session = New-PSSession -ComputerName ad2-mgt-c
Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType $PolicyType}

}
