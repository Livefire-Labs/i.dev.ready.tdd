# ====================================================================================
#                    Livefire TDD DevReady 2024                    
#                                                                                    
#            Script is to automate the lab for testing
#              
#                   by Ben Todd, Livefire Team                    
# ====================================================================================

# SDDC Manager Credentials
$sddcManagerFqdn = "sddc-manager.vcf.sddc.lab"
$sddcManagerUser = "administrator@vsphere.local"
$sddcManagerPass = "VMware123!VMware123!"

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
$spbmPolicyName = "vsan-tanzu-storage"



# vSphere with Tanzu Settings
$wmClusterInput = @{
	server = "sddc-manager.vcf.sddc.lab"
	user = "administrator@vsphere.local"
	pass = 'VMware123!VMware123!'
	domain = "mgmt-domain"
	cluster = "mgmt-cluster-01"
	sizeHint = "small"
	managementVirtualNetwork = "sddc-vds01-vmmgmt"
	managementNetworkMode = "StaticRange"
	managementNetworkStartIpAddress = "10.0.11.180"
	managementNetworkAddressRangeSize = 5
	managementNetworkGateway = "10.0.11.253"
	managementNetworkSubnetMask = "255.255.255.0"
	masterDnsName = "lf-tdd-supervisor"
	masterDnsServers = @("10.0.0.253")
	masterNtpServers = @("10.0.0.253")
	contentLibrary = "Kubernetes"
	ephemeralStoragePolicy = "vsan-tanzu-storage"
	imageStoragePolicy = "vsan-tanzu-storage"
	masterStoragePolicy = "vsan-tanzu-storage"
	nsxEdgeCluster = "EC-01"
	distributedSwitch = "mgmt-vds01"
	podCIDRs = "10.244.0.0/20"
	serviceCIDR = "10.96.0.0/23"
	externalIngressCIDRs = "10.80.0.0/24"
	externalEgressCIDRs = "10.70.0.0/24"
	workerDnsServers = @("10.0.0.253")
	masterDnsSearchDomain = "vcf.sddc.lab"
}

# # Tanzu Certificate Settings
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
$wmNamespaceName = "lf-tdd-namespace"
$domainFqdn = "vcf.holo.lab"
$domainBindUser = "svc-vsphere-ad"
$domainBindPass = "VMware123!"


$wmNamespaceEditUserGroup = "gg-kub-admins"
$wmNamespaceViewUserGroup = "gg-kub-readonly"

$vmClassSmall = "best-effort-small"
$vmClassMedium = "best-effort-medium"
$wmClusterName = "mgmt-cluster-01"  #vCenter Cluster Name where Supervisor Runs - Not the name of the Supervisor

Write-Host "Remove Namespace:" $wmNamespaceName
Undo-Namespace  -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -Namespace $wmNamespaceName

Write-Host "Remove Contour Supervisor Service from Supervisor"
# Undo-SupervisorService [-server] <String> [-user] <String> [-pass] <String> [-sddcDomain] <String> [-cluster] <String> [[-registerYaml] <String>] [<CommonParameters>]
Undo-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName -registerYaml ..\contour.yml 

Write-Host "Remove External DNS Supervisor Service from Supervisor"
# Undo-SupervisorService [-server] <String> [-user] <String> [-pass] <String> [-sddcDomain] <String> [-cluster] <String> [[-registerYaml] <String>] [<CommonParameters>]
Undo-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\external-dns.yml 

Write-Host "Remove Harbor Supervisor Service from Supervisor"
# Undo-SupervisorService [-server] <String> [-user] <String> [-pass] <String> [-sddcDomain] <String> [-cluster] <String> [[-registerYaml] <String>] [<CommonParameters>]
Undo-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\harbor.yml 

Write-Host "Remove CCI Supervisor Service from Supervisor"
# Undo-SupervisorService [-server] <String> [-user] <String> [-pass] <String> [-sddcDomain] <String> [-cluster] <String> [[-registerYaml] <String>] [<CommonParameters>]
Undo-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\cci-supervisor-service.yml 

Write-Host "Remove CCI Supervisor Service from Supervisor"
Undo-SupervisorCluster  -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  