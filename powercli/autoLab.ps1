
# ====================================================================================
#                    Livefire TDD DevReady 2024                    
#                                                                                    
#            Script is to automate the lab for testing
#              
#                   by Ben Todd, Livefire Team                    
# ====================================================================================

# ==========  Tanzu Namespace Settings ===============================================
# $wmNamespaceName = "lf-test-tdd"
$wmNamespaceName = "lf-tdd-namespace"
$domainFqdn = "vcf.holo.lab"
$domainBindUser = "svc-vsphere-ad"
$domainBindPass = "VMware123!"
$wmNamespaceEditUserGroup = "gg-kub-admins"
$wmNamespaceViewUserGroup = "gg-kub-readonly"
# vSAN Datastore Tag and Storage Policy Settings
$tagCategoryName = "vsphere-with-tanzu-category"
$tagName = "vsphere-with-tanzu-tag"
$spbmPolicyName = "vsan-tanzu-storage"
$vmClassSmall = "best-effort-small"
$vmClassMedium = "best-effort-medium"
# ==========  SDDC Manager Info ======================================================
$sddcManagerFqdn = "sddc-manager.vcf.sddc.lab"
$sddcManagerUser = "administrator@vsphere.local"
$sddcManagerPass = "VMware123!VMware123!"
$sddcDomainName = "mgmt-domain"
# ==========  vCenter Info   =========================================================
$vcFQDNName = "vcenter-mgmt.vcf.sddc.lab"
$vcUserName ='administrator@vsphere.local'
$vcPassword = 'VMware123!VMware123!'
$vcFQDNName = "vcenter-mgmt.vcf.sddc.lab"
$superVisorName = "lf-tdd-supervisor"
$iassCplaneCluster = "mgmt-cluster-01"
# ====================================================================================
Connect-VIServer -Server $vcFQDNName -Protocol https -User $vcUserName -Password $vcPassword

# ====================================================================================
#  Crate Tag Category and Tag
New-TagCategory -Name $tagCategoryName -Description "lf-dev.ready.tdd.lab" -Cardinality single -EntityType Datastore
New-Tag -Name $tagName -Category $tagCategoryName
# ====================================================================================
#  Assign Tag to Datstore
New-TagAssignment -Tag $tagName -Entity "vcf-vsan"
# ====================================================================================
#  Crate Tag Category and Tag
# Set-DatastoreTag -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -TagName $tagName -TagCategoryName $tagCategoryName

# ====================================================================================
# Create new vSAN Storage Policy for Tanzu associated with Storage Tag
Add-StoragePolicy -Server $sddcManagerFqdn -User $sddcManagerUser -Pass $sddcManagerPass -Domain $sddcDomainName -PolicyName $spbmPolicyName -TagName $tagName



# ====================================================================================
#  Create and Configure Namespace
# ====================================================================================
$userDomain1 = "vsphere.local"
$userDomain2 = "vcf.holo.lab"
# ====================================================================================
#  Create Namespace
New-WMNamespace -Name $wmNamespaceName -Cluster $iassCplaneCluster
Set-WMNamespace $wmNamespaceName -Description "LF TDD NameSpace For Lab"

# ====================================================================================
#  Create Namespace permisions
#  Create Owner
# New-WMNamespacePermission -Domain $userDomain1 -Namespace $wmNamespaceName -PrincipalName "kk-kub-admins" -PrincipalType Group -Role (Get-VIRole -Name 'Owner')
New-WMNamespacePermission -Domain $userDomain1 -Namespace $wmNamespaceName -PrincipalName "gg-kub-admins" -PrincipalType Group -Role 'Admin'
#  Create Edit
New-WMNamespacePermission -Domain $userDomain2 -Namespace $wmNamespaceName -PrincipalName "gg-kub-devs" -PrincipalType Group -Role 'Edit'
#  Create View
New-WMNamespacePermission -Domain $userDomain2 -Namespace $wmNamespaceName -PrincipalName "gg-kub-readonly" -PrincipalType Group -Role'View'

# ====================================================================================
#  Add Storage Policy
New-WMNamespaceStoragePolicy -Namespace $wmNamespaceName -StoragePolicy "vsan-tanzu-storage"


# ====================================================================================
#  Add VMClass
Add-NamespaceVmClass -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Namespace $wmNamespaceName -VMClass $vmClassSmall
Add-NamespaceVmClass -server $sddcManagerFqdn -user $sddcManagerUser -pass $sddcManagerPass -domain $sddcDomainName -Namespace $wmNamespaceName -VMClass $vmClassMedium