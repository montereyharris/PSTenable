function Get-PSTenableQueryAnalysis {
    <#
    .SYNOPSIS
        Retrieves all devices that are affected by PluginID.
    .DESCRIPTION
        This function provides a way to retrieve all devices affected by a specific PluginID that is passed to the function.
    .EXAMPLE
        PS C:\> Get-PSTenablePlugin -ID "20007"
        This passes PluginID 20007 CVE's to the fucntion and returns and all devices affected by the PluginID 20007.

        PS C:\> @("20007","31705")  Get-PSTenablePlugin
        This passes PluginID 20007 CVE's to the fucntion and returns and all devices affected by the PluginID 20007.
    .PARAMETER ID
        PluginID from Tenable
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        You can pass one or multiple PluginID's in an array.
    #>
    [CmdletBinding()]
    param (
        [parameter(Position = 0,
            mandatory = $true,
            ValueFromPipeline = $true)]
        [string]
        $ID
    )

    begin {
        $TokenExpiry = Invoke-PSTenableTokenStatus
        if ($TokenExpiry -eq $True) {Invoke-PSTenableTokenRenewal}
    }

    process {

        $output = foreach ($queryID in $ID) {
            $query = @{
                "type"       = "vuln"
                "sourceType" = "cumulative"
                "query"      = @{
                    "tool"       = "listvuln"
                    "type"       = "vuln"
                    "id"         = "$queryID"
                }
            }

            $Splat = @{
                Method   = "Post"
                Body     = $(ConvertTo-Json $query -depth 5)
                Endpoint = "/analysis"
            }

            Invoke-PSTenableRest @Splat | Select-Object -ExpandProperty Response | Select-Object -ExpandProperty Results

        }

    }

    end {
        $Output
    }
}
