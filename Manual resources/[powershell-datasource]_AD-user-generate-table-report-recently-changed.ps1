try {
    $lastDate = (Get-Date).AddDays(-30)
    $filter = {whenChanged -gt $lastDate}
    $properties = "CanonicalName", "Displayname", "UserPrincipalName", "SamAccountName", "Department", "Title", "Enabled", "whenChanged"
    
    $ous = $ADusersReportOU | ConvertFrom-Json
    $result = foreach($item in $ous) {
        Get-ADUser -Filter $filter -SearchBase $item.ou -Properties $properties
    }
    $resultCount = @($result).Count
    $result = $result | Sort-Object -Property whenChanged -Descending
    
    Write-information "Result count: $resultCount"
    
    if($resultCount -gt 0){
        foreach($r in $result){
            $returnObject = @{CanonicalName=$r.CanonicalName; Displayname=$r.Displayname; UserPrincipalName=$r.UserPrincipalName; SamAccountName=$r.SamAccountName; Department=$r.Department; Title=$r.Title; Enabled=$r.Enabled; whenChanged=$r.whenChanged;}
            Write-output $returnObject
        }
    } else {
        return
    }    
} catch {
    Write-error "Error generating report. Error: $($_.Exception.Message)"
    return
}
