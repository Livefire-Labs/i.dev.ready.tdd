
$vcUserName ='administrator@vsphere.local'
$vcPassword = 'VMware123!VMware123!'
$vcFQDNName = "vcenter-mgmt.vcf.sddc.lab"

Connect-VIServer -Server $vcFQDNName -Protocol https -User $vcUserName -Password $vcPassword

$supervisorConfig = Get-Content -Path .\wcp-config.json | ConvertFrom-Json


$supervisor = New-Object -TypeName VMware.VimAutomation.Vsphere.Impl.WorkloadManagement.Supervisor
$supervisor.ExtensionData = $supervisorConfig
$supervisorManager = Get-View -ViewType VMware.VimAutomation.Vsphere.Impl.WorkloadManagement.SupervisorManager
$supervisorManager.ActivateSupervisor($supervisor)