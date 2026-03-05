#######################################################################
# Template: HelloID SA Powershell data source
# Name: report-ad-accounts-changed-during-the-last-30-days | AD-Get-All-Accounts-Recently-Changed
# Date: 19-02-2026
#######################################################################

# For basic information about powershell data sources see:
# https://docs.helloid.com/en/service-automation/dynamic-forms/data-sources/powershell-data-sources.html

# Service automation variables:
# https://docs.helloid.com/en/service-automation/service-automation-variables.html

#region init

$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# global variables (Automation --> Variable library):
$searchOUs = $AdReportSearchOu

# variables configured in form:
# $formValue1 = $datasource.<formElementKey>.<value>
# $formValue2 = $datasource.<formElementKey>

#endregion init

#region functions

#endregion functions

#region lookup
try {
    $actionMessage = "querying AD for users changed during the last 30 days"
    $lastDate = (Get-Date).AddDays(-30)
    $filter = {whenChanged -gt $lastDate}
    $properties = "CanonicalName", "Displayname", "UserPrincipalName", "Department", "Title", "Enabled", "whenChanged"
    
    $ous = $searchOUs -split ';'
    $result = foreach($item in $ous) {
        Get-ADUser -Filter $filter -SearchBase $item -Properties $properties
    }
    $resultCount = @($result).Count
    $result = $result | Sort-Object -Property whenChanged -Descending
    
    Write-information "Result count: $resultCount"
    
    if($resultCount -gt 0){
        foreach($r in $result){
            Write-Output @{CanonicalName=$r.CanonicalName; Displayname=$r.Displayname; UserPrincipalName=$r.UserPrincipalName; Department=$r.Department; Title=$r.Title; Enabled=$r.Enabled; whenChanged=$r.whenChanged}
        }
    } else {
        return
    }
    
} catch {
    $ex = $PSItem
    Write-Warning "Error at Line [$($ex.InvocationInfo.ScriptLineNumber)]: $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    Write-Error "Error $($actionMessage). Error: $($ex.Exception.Message)"
    # exit # use when using multiple try/catch and the script must stop
}
#endregion lookup

