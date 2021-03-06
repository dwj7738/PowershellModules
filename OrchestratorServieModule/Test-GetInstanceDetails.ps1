
###################################################################
#    Copyright (c) Microsoft. All rights reserved.
#    This code is licensed under the Microsoft Public License.
#    THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
#    ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
#    IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
#    PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
###################################################################

##################################################
# Test-GetInstanceDetails
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

    # Defing the Job Id
    $jobid = [guid]"GUID"

    $job = Get-OrchestratorJob -serviceurl $url -credentials $creds -jobid $jobid
    Write-Host "job.Id = " $job.Id

    $instances = Get-OrchestratorRunbookInstance -credentials $creds -job $job
    
    $i = 1
    foreach ($instance in $instances)
    {
        Write-Host ""
        Write-Host "INSTANCE " $i
        Write-Host "Url = " $instance.Url
        Write-Host "Url_Service = " $instance.Url_Service
        Write-Host "Url_Runbook = " $instance.Url_Runbook
        Write-Host "Url_Job = " $instance.Url_Job
        Write-Host "Url_Parameters = " $instance.Url_Parameters
        Write-Host "Url_ActivityInstances = " $instance.Url_ActivityInstances
        Write-Host "Url_RunbookServer = " $instance.Url_RunbookServer
        Write-Host "Published = " $instance.Published
        Write-Host "Updated = " $instance.Updated
        Write-Host "Category = " $instance.Category
        Write-Host "Id =  " $instance.Id
        Write-Host "RunbookId = " $instance.RunbookId
        Write-Host "JobId = " $instance.JobId
        Write-Host "RunbookServerId = " $instance.RunbookServerId
        Write-Host "Status = " $instance.Status
        Write-Host "CreationTime = " $instance.CreationTime
        Write-Host "CompletionTime = " $instance.CompletionTime
        Write-Host ""
        Write-Host "PARAMS"
        
        $params = Get-OrchestratorRunbookInstanceParameter -RunbookInstance $instance -Credentials $creds
        foreach ($param in $params)
        {
            Write-Host ""
            Write-Host 'Url_Service = ' $param.Url_Service
            Write-Host 'Url_RunbookInstance = ' $param.Url_RunbookInstance
            Write-Host 'Url_RunbookParameter = ' $param.Url_RunbookParameter
            Write-Host 'Url = ' $param.Url
            Write-Host 'Updated = ' $param.Updated
            Write-Host 'Category = ' $param.Category
            Write-Host 'Id = ' $param.Id
            Write-Host 'RunbookInstanceId = ' $param.RunbookInstanceId
            Write-Host 'RunbookParameterId = ' $param.RunbookParameterId
            Write-Host 'Name = ' $param.Name
            Write-Host 'Value = ' $param.Value
            Write-Host 'Direction = ' $param.Direction
            Write-Host 'GroupId = ' $param.GroupId
        }
        $i++
    }    
}

end {
    # remove modules
    Remove-Module OrchestratorServiceModule
}
