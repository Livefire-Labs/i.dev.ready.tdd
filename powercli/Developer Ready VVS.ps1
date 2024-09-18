# ====================================================================================
#                      VMware Cloud Foundation Developer Ready VVS                 
#                                                                                    
#      You must have PowerVCF and PowerCLI installed in order to use this script     
#                                                                                    
#                           Alasdair Carnie and the VVS Team                     
# ====================================================================================

# Variables for the execution log file and json file directories.
Clear-Host
$scriptDir = Split-Path $MyInvocation.MyCommand.Path # Log file diretories will be created in the folder you exeute the script from
$logPathDir = New-Item -ItemType Directory -Path "$scriptDir\Logs" -Force
$jsonPathDir = New-Item -ItemType Directory -Path "$scriptDir\json" -Force
$logfile = "$logPathDir\VVS-Log-_$(get-date -format `"yyyymmdd_hhmmss`").txt"

# Custom function to create a separate logging window for script execution.
Function logger($strMessage, [switch]$logOnly,[switch]$consoleOnly)
{
	$curDateTime = get-date -format "hh:mm:ss"
	$entry = "$curDateTime :> $strMessage"
    if ($consoleOnly) {
		write-host $entry
    } elseif ($logOnly) {
		$entry | out-file -Filepath $logfile -append
	} else {
        write-host $entry
		$entry | out-file -Filepath $logfile -append
	}
}

logger "Deploying the Developer Ready Infrastructure on VCF.  Brought to you by the letters L and F, and by the number 42"

Start-Process powershell -Argumentlist "`$host.UI.RawUI.WindowTitle = 'VLC Logging window';Get-Content '$logfile' -wait"

logger "Create the variables needed to deploy the Developer Ready Infrastructure"

# SDDC Manager Credentials
$sddcManagerFqdn = "sddc-manager.vcf.sddc.lab"
$sddcManagerUser = "administrator@vsphere.local"
$sddcManagerPass = "VMware123!"

# MGMT Workload domain and NSX Edge Cluster / NSX Segment Settings
$sddcDomainName = "mgmt-domain"
$tanzuSegmentName = "vlc-m01-seg01-tanzu"
$tier1GatewayName = "VLC-Tier-1"
$tanzuSegmentGatewayCIDR = "192.168.20.1/24"
$overlayTzName = "mgmt-domain-tz-overlay01"

# NSX Prefix List and Route Map Settings
$prefixListName = "vlc-m01-ec01-t0-gw01-prefixlist"
$tanzuManagementSubnetCidr = "192.168.20.0/24"
$tanzuIngressSubnetCidr = "10.80.0.0.0/24"
$tanzuEgressSubnetCidr = "10.70.0.0.0/24"
$tier0GatewayName = "VLC-Tier-0"
$routeMapName = "vlc-m01-ec01-t0-gw01-routemap"

# vSAN Datastore Tag and Storage Policy Settings
$tagCategoryName = "vsphere-with-tanzu-category"
$tagName = "vsphere-with-tanzu-tag"
$spbmPolicyName = "vsphere-with-tanzu-storage-policy"

# vCenter Content Library Settings
#$contentLibraryName = "Kubernetes"

# vSphere with Tanzu Settings
$wmClusterName = "mgmt-cluster-01"
$spbmPolicyName = "vsphere-with-tanzu-storage-policy"
$contentLibraryName = "Kubernetes"
$kubSegmentName = "vlc-m01-seg01-tanzu"
$kubSegmentGatewayCIDR = "192.168.20.1/24"
$kubSegmentSubnetCidr = "192.168.20.0/24"
$ingressSubnetCidr = "10.80.0.0/24"
$egressSubnetCidr = "10.70.0.0/24"
$licenseKey = "1J0HK-8N39H-483R9-01124-9MALK"
$licenseKey = "454RL-EMDDK-88LR9-0NLRP-GN762"
$wmClusterSizeHint = "small"
$wmClusterManagementNetworkMode = "StaticRange"
$wmClusterManagementNetworkAddressRangeSize = 5
$wmClusterManagementNetworkSubnetMask = "255.255.255.0"
$wmClusterManagementNetworkStartIpAddress = "192.168.20.10"
$wmClusterManagementNetworkGateway = "192.168.20.1"
$distributedSwitch = "mgmt-vds01"
$nsxEdgeCluster = "EC-01"
$kubePodCIDRs = "100.100.0.0/20" 
$kubeServiceCIDR = "100.200.0.0/22"
$masterNtpServers = @("10.0.0.221")
$masterDnsServers = @("10.0.0.221")
$masterDnsName  = "kubeapi.vcf.sddc.lab"
$masterDnsSearchDomain = "vcf.sddc.lab"
$workerDnsServers = @("10.0.0.221")

# Tanzu Certificate Settings
$CommonName = "kubeapi.vcf.sddc.lab"
$Organization = "ESH"
$OrganizationalUnit = "IT"
$Country = "US"
$StateOrProvince = "Illinois"
$Locality = "Champaign"
$AdminEmailAddress = "admin@elasticskyholdings.com"
$KeySize = 2048

$mscaComputerName = "vcfad.vcf.holo.lab"
$mscaName = "vcf-VCFAD-CA"
$caUser = "svc-vcf-ca@vcf.holo.lab"
$caUserPass = "VMware123!"
$certificateTemplate = "VMware"

# Tanzu Namespace Settings
$wmNamespaceName = "vlc-m01-ns01"
$spbmPolicyName = "vsphere-with-tanzu-storage-policy"
$domainFqdn = "vcf.holo.lab"
$domainBindUser = "svc-vsphere-ad"
$domainBindPass = "VMware123!"

$wmNamespaceName = "vlc-m01-ns01"
$wmNamespaceEditUserGroup = "gg-kub-admins"
$wmNamespaceViewUserGroup = "gg-kub-readonly"

$vmClass = "guaranteed-small"

# Create the NSX Segment onto which the Tanzu Supervisor Control Plane will be deployed
logger "Create NSX Segment for Tanzu Supervisor Control Plane"
Add-NetworkSegment -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -SegmentName $tanzuSegmentName -ConnectedGateway $tier1GatewayName -Cidr $tanzuSegmentGatewayCIDR -TransportZone $overlayTzName -GatewayType Tier1 -SegmentType Overlay

# Create NSX Prefix List and Route Map
logger "Create NSX Prefix List and Route map"
Add-PrefixList -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -Tier0Gateway $tier0GatewayName -PrefixListName $prefixListName -SubnetCIDR $tanzuManagementSubnetCidr -ingressSubnetCidr $tanzuIngressSubnetCidr -egressSubnetCidr $tanzuEgressSubnetCidr -GE "28" -LE "32" -Action PERMIT
Add-RouteMap -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -Tier0Gateway $tier0GatewayName -RouteMap $routeMapName -PrefixListName $prefixListName -Action PERMIT -ApplyPolicy:$True

# Create Datastore Tag Category and Tag Name, then apply to vSAN Datastore
logger "Create the Datastore Tag"
Set-DatastoreTag -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -TagName $tagName -TagCategoryName $tagCategoryName

# Create new vSAN Storage Policy for Tanzu associated with Storage Tag
logger "Create the Tanzu Storage Policy"
Add-StoragePolicy -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -PolicyName $spbmPolicyName -TagName $tagName

# Create a vCenter Content Library for the Kubernetes Binaries
#logger "Create the Content Library for the TKGS Binaries"
#Add-ContentLibrary -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -ContentLibraryName $contentLibraryName -SubscriptionUrl "https://wp-content.vmware.com/v2/latest/lib.json"

# Deploy Tanzu Supervisor Control Plane
logger "Deploy the Tanzu Supervisor Cluster"
Enable-SupervisorCluster `
-server $sddcManagerFqdn `
-user $sddcManagerUser `
-pass $sddcManagerPass `
-domain $sddcDomainName `
-cluster $wmClusterName `
-sizeHint $wmClusterSizeHint `
-managementVirtualNetwork $kubSegmentName `
-managementNetworkMode $wmClusterManagementNetworkMode `
-managementNetworkStartIpAddress $wmClusterManagementNetworkStartIpAddress `
-managementNetworkAddressRangeSize $wmClusterManagementNetworkAddressRangeSize `
-managementNetworkGateway $wmClusterManagementNetworkGateway `
-managementNetworkSubnetMask $wmClusterManagementNetworkSubnetMask `
-contentLibrary $contentLibraryName `
-ephemeralStoragePolicy $spbmPolicyName `
-imageStoragePolicy $spbmPolicyName `
-masterStoragePolicy $spbmPolicyName `
-nsxEdgeCluster $nsxEdgeCluster `
-distributedSwitch $distributedSwitch `
-podCIDRs $kubePodCIDRs `
-serviceCIDR $kubeServiceCIDR `
-externalIngressCIDRs $ingressSubnetCidr `
-externalEgressCIDRs $egressSubnetCidr `
-masterNtpServers $masterNtpServers `
-masterDnsServers $masterDnsServers `
-masterDnsName $masterDnsName `
-masterDnsSearchDomain $masterDnsSearchDomain `
-workerDnsServers $workerDnsServers `

# Create Tanzu Supervisor Control Plane Certificate
logger "Replace the default certificate with a signed one for the Enterprise CA"
New-SupervisorClusterCSR -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -cluster $wmClusterName -CommonName $CommonName -Organization $Organization -OrganizationalUnit $OrganizationalUnit -Country $Country -StateOrProvince $StateOrProvince -Locality $Locality -AdminEmailAddress $AdminEmailAddress -KeySize $Keysize -FilePath ".\SupervisorCluster.csr"
Request-SignedCertificate -mscaComputerName $mscaComputerName -mscaName $mscaName -domainUsername $caUser -domainPassword $caUserPass -certificateTemplate $certificateTemplate -certificateRequestFile ".\SupervisorCluster.csr" -certificateFile ".\SupervisorCluster.cer"
Install-SupervisorClusterCertificate -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Cluster $wmClusterName -filePath ".\SupervisorCluster.cer"

# Assign the Tanzu License Key
logger "Assign the Tanzu License Key"
Add-SupervisorClusterLicense -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -cluster $wmClusterName -LicenseKey $licenseKey

# Create a Namespace and set the permissions
logger "Create a default namespace in the Supervisor Cluster"
Add-Namespace -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -Cluster $wmClusterName -Namespace $wmNamespaceName -StoragePolicy $spbmPolicyName
Add-NamespacePermission -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -sddcDomain $sddcDomainName -domain $domainFqdn -domainBindUser $domainBindUser -domainBindPass $domainBindPass -namespace $wmNamespaceName -principal $wmNamespaceEditUserGroup -role edit -type group
Add-NamespacePermission -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -sddcDomain $sddcDomainName -domain $domainFqdn -domainBindUser $domainBindUser -domainBindPass $domainBindPass -namespace $wmNamespaceName -principal $wmNamespaceViewUserGroup -role view -type group

# Add TKGS Cluster Class to Namespace
# logger "Assign the gaurenteed small tanzu class to the namespace"
Add-NamespaceVmClass -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Namespace $wmNamespaceName -VMClass $vmClass