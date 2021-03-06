
###################################################################
#    Copyright (c) Microsoft. All rights reserved.
#    This code is licensed under the Microsoft Public License.
#    THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
#    ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
#    IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
#    PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
###################################################################

##################################################
# Test-GetCollection
##################################################

begin {
    # import modules
    Import-Module .\OrchestratorServiceModule.psm1
}

process {
    # get credentials (set to $null to UseDefaultCredentials)
    $creds = $null
    #$creds = Get-Credential "DOMAIN\USERNAME"

    # create the base url to the service
    $url = Get-OrchestratorServiceUrl -server "SERVERNAME"

    $collectionsarray = Get-OrchestratorCollection -serviceurl $url -credentials $creds
    
    Write-Host "Length = "  $collectionsarray.Length
    
    $i = 1
    foreach ($collection in $collectionsarray)
    {
        Write-Host $i
        Write-Host "Title = " $collection.Title
        Write-Host "Url = " $collection.Url
        
        $i++
    }

}

end {
    # remove modules
    Remove-Module OrchestratorServiceModule
}
