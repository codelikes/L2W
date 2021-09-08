
[CmdletBinding]
function Get-FromJson
{
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Path
    )

    function Get-Value {
        param( $value )

        $result = $null
        if ( $value -is [System.Management.Automation.PSCustomObject] )
        {
            Write-Verbose "Get-Value: value is PSCustomObject"
            $result = @{}
            $value.psobject.properties | ForEach-Object { 
                $result[$_.Name] = Get-Value -value $_.Value 
            }
        }
        elseif ($value -is [System.Object[]])
        {
            $list = New-Object System.Collections.ArrayList
            Write-Verbose "Get-Value: value is Array"
            $value | ForEach-Object {
                $list.Add((Get-Value -value $_)) | Out-Null
            }
            $result = $list
        }
        else
        {
            $result = $value
        }
        return $result
    }


    if (Test-Path $Path)
    {
        $json = Get-Content $Path -Raw
    }
    else
    {
        $json = '{}'
    }

    $hashtable = Get-Value -value (ConvertFrom-Json $json)

    return $hashtable
}