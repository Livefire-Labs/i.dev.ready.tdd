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


function Show-Menu
{
     param (
           [string]$Title = 'LF DEV READY DEPLOYMENT'
     )
     cls
     Write-Host “================ $Title ================”
    
     Write-Host “1: Press '1' to create tags and storage policy.”
     Write-Host “2: Press '2' to deploy Supervisor Cluster.” # DO NOT USE FOR NOW - 
     # Write-Host “3: Press '3' To add Certificate top Supervisor.” # DO NOT USE FOR NOW - No Reason..? 
     Write-Host “4: Press '4' to Create and Configure Namespace.”
     Write-Host “5: Press '5' to Deploy Supervisor Services.”
     Write-Host “Q: Press 'Q' to quit.”
}

do
{
     Show-Menu
     $input = Read-Host “Please make a selection”
     switch ($input)
     {
           '1' {
                cls
                Write-Host "Create Datastore Tag Category and Tag Name, then apply to vSAN Datastore"
                Set-DatastoreTag -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -TagName $tagName -TagCategoryName $tagCategoryName
                
               Write-Host "Create new vSAN Storage Policy for Tanzu associated with Storage Tag"
                Add-StoragePolicy -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -PolicyName $spbmPolicyName -TagName $tagName
           } '2' {
                cls
                Write-Host "Deploy Tanzu Supervisor Control Plane"
                Enable-SupervisorCluster @wmClusterInput 
           } '3' {
                cls
                Write-Host "Create Tanzu Supervisor Control Plane Certificate"
                # New-SupervisorClusterCSR -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -cluster $wmClusterName -CommonName $CommonName -Organization $Organization -OrganizationalUnit $OrganizationalUnit -Country $Country -StateOrProvince $StateOrProvince -Locality $Locality -AdminEmailAddress $AdminEmailAddress -KeySize $Keysize -FilePath ".\SupervisorCluster.csr"
                # Request-SignedCertificate -mscaComputerName $mscaComputerName -mscaName $mscaName -domainUsername $caUser -domainPassword $caUserPass -certificateTemplate $certificateTemplate -certificateRequestFile ".\SupervisorCluster.csr" -certificateFile ".\SupervisorCluster.cer"
                # Install-SupervisorClusterCertificate -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Cluster $wmClusterName -filePath ".\SupervisorCluster.cer"

                Write-Host "Assign the Tanzu License Key"
                # Add-SupervisorClusterLicense -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -cluster $wmClusterName -LicenseKey $licenseKey
           } '4' {
                cls
                Write-Host "Create a Namespace and set the permissions"
                Add-Namespace -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -Cluster $wmClusterName -Namespace $wmNamespaceName -StoragePolicy $spbmPolicyName
                Add-NamespacePermission -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -sddcDomain $sddcDomainName -domain $domainFqdn -domainBindUser $domainBindUser -domainBindPass $domainBindPass -namespace $wmNamespaceName -principal $wmNamespaceEditUserGroup -role edit -type group
                Add-NamespacePermission -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -sddcDomain $sddcDomainName -domain $domainFqdn -domainBindUser $domainBindUser -domainBindPass $domainBindPass -namespace $wmNamespaceName -principal $wmNamespaceViewUserGroup -role view -type group
                
                Write-Host "Add TKGS Cluster Class to Namespace"
                Add-NamespaceVmClass -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Namespace $wmNamespaceName -VMClass $vmClassSmall
                Add-NamespaceVmClass -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Namespace $wmNamespaceName -VMClass $vmClassMedium

           } '5' {


                cls
                Write-Host "Add a Contour Supervisor Service to Supervisor"
                Add-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\contour.yml -configureYaml ..\contour-data-values.yml
                Write-Host "Add a External DNS Supervisor Service to Supervisor"
                Add-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\external-dns.yml -configureYaml ..\external-dns-data-values.yml
                Write-Host "Add a Harbor Supervisor Service to Supervisor"
                Add-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\harbor.yml -configureYaml ..\harbor-data-values.yml
                Write-Host "Add a CCI Supervisor Service to Supervisor"
                Add-SupervisorService -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -sddcDomain $sddcDomainName -Cluster $wmClusterName  -registerYaml ..\cci-supervisor-service.yml -configureYaml ..\cci-supervisor-service-empty.yml



              } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')