function Get-PSTenableQuery {
    <#
    .SYNOPSIS
        Retrieves all Queries in Tenable.SC server.
    .DESCRIPTION
        This function provides a way to retrieve all queries.
    .EXAMPLE
        PS C:\> Get-PSTenableQuery -Type vuln
        This requests all vuln queries currently saved.

    .PARAMETER QueryID
        Get Specfic Query by ID
    .PARAMETER Type
        Get All Queryies of a Specfic type
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
        [ValidateSet("alert","all", "lce","mobile","ticket","user","vuln")]
        $Type
    )

    begin {
        $TokenExpiry = Invoke-PSTenableTokenStatus
        if ($TokenExpiry -eq $True) {Invoke-PSTenableTokenRenewal}
    }

    process {

        $output =

            $Endpoint = "/query"

            if($Type){

                $Endpoint = $Endpoint + "?=$Type"
            }

            $EndPoint = $Endpoint.ToLower()

            $Splat = @{
                Method   = "Get"
                Endpoint = $Endpoint
            }

            $response = Invoke-PSTenableRest @Splat | Select-Object -ExpandProperty Response

            $managedOnly = $response.manageable|where{$_.canUse -eq $false}

            if(($managedOnly|measure).Sum -gt 0){

                return $managedOnly
            }

            return $response.usable
    }

    end {
        $Output
    }
}
