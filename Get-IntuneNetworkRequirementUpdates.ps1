<#
This script is not done!
.SYNOPSIS
This script will retrieve the RSS for M365 endpoints (via https://endpoints.office.com/version/worldwide) and publish it to GitHub
.DESCRIPTION
This script will retrieve the RSS feed for M365 endpoints and publish it to a GitHub repository.
#>
$GUID = (New-Guid).Guid
$EndpointURL = "endpoints.office.com"
$RequestParameters = "clientRequestId=$GUID&allVersions=true&format=RSS&ServiceAreas=MEM"
#$FullList = Invoke-RestMethod -Uri ("$EndpointURL/endpoints/WorldWide?ServiceAreas=MEM`&`clientrequestid=$GUID")
$total = foreach ($item in Invoke-RestMethod -Uri "https://$EndpointURL/version/worldwide?$RequestParameters" ) {
    [PSCustomObject]@{
        guid  = $item.guid.'#text'
        date  = $item.pubDate
        title = $item.Title
        link  = $item.Link
    }
}

$total | Sort-Object { $_.date -as [datetime] } -Descending -Top 10 #limit this to the last 10 upodates for now. ToDo: Remove this limit
foreach ($Link in $total.link) {
    $JSON = (Invoke-WebRequest -Uri $Link).Content | ConvertFrom-Json
    foreach ($Entry in $JSON) {
        $Impacts = $Entry.impact -join ","
        if($Impacts.count -ge 1){
            # These are all possible values for impact that I have found thus far
            "RemovedIpOrUrl,RemovedDuplicateIpOrUrl,MovedIpOrUrl,AddedUrLs,AddedSubstituteUrl," -split "," | ForEach-Object {
                if ($Impacts -notmatch $_) {
                    Write-Output "$_ is not a known impact value"
                }
            }
        }
        <#        if ($Entry.disposition -eq "Change") {

        } elseif ($Entry.disposition -eq "Remove") {

        } elseif ($Entry.disposition -eq "Add") {

        }#>

    }
}