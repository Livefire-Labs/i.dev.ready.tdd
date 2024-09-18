
# ====================================================================================
#                    Livefire TDD DevReady 2024                    
#                                                                                    
#            Script is to automate the lab for testing
#              
#                   by Ben Todd, Livefire Team                    
# ====================================================================================

# ==========  Tanzu Namespace Settings ===============================================
$wmNamespaceName = "lf-tdd-namespace-3"
$spbmPolicyName = "vsan-tanzu-storage"
$domainFqdn = "vcf.holo.lab"
$domainBindUser = "svc-vsphere-ad"
$domainBindPass = "VMware123!"

$wmNamespaceEditUserGroup = "gg-kub-admins"
$wmNamespaceViewUserGroup = "gg-kub-readonly"

$vmClass = "guaranteed-small"
# ==========  SDDC Manager Info ======================================================
$sddcManagerFqdn = "sddc-manager.vcf.sddc.lab"
$sddcManagerUser = "administrator@vsphere.local"
$sddcManagerPass = "VMware123!"
# ==========  vCenter Info   =========================================================
$vcFQDNName = "vcenter-mgmt.vcf.sddc.lab"
$vcUserName ='administrator@vsphere.local'
$vcPassword = 'VMware123!VMware123!'
$vcFQDNName = "vcenter-mgmt.vcf.sddc.lab"
$superVisorName = "lf-tdd-supervisor"
$iassCplaneCluster = "mgmt-cluster-01"
$sddcManagerFQDN = ""
# ====================================================================================
Connect-VIServer -Server $vcFQDNName -Protocol https -User $vcUserName -Password $vcPassword

# ====================================================================================
#  Crate Tag Category and Tag
# ====================================================================================
New-TagCategory -Name vsphere-with-tanzu-category-2 -Description lf-dev.ready.tdd.lab -Cardinality single -EntityType Datastore

New-Tag -Name “vsphere-with-tanzu-tag-2” -Category “vsphere-with-tanzu-category-2”

New-TagAssignment -Tag "vsphere-with-tanzu-tag-2" -Entity "vcf-vsan"


# ====================================================================================
#  Create and Configure Namespace
# ====================================================================================
$newNameSpace = "lf-test-tdd" # NOTE: Change this to match new Namespace 
$userDomain1 = "vsphere.local"
$userDomain2 = "vcf.holo.lab"
$userDomain3 = ""

# ====================================================================================
#  Create Namespace
New-WMNamespace -Name $newNameSpace -Cluster $iassCplaneCluster
Set-WMNamespace $newNameSpace -Description "LF TDD NameSpace For Lab"

# ====================================================================================
#  Create Namespace permisions
#  Create Owner
# New-WMNamespacePermission -Domain $userDomain1 -Namespace $newNameSpace -PrincipalName "kk-kub-admins" -PrincipalType Group -Role (Get-VIRole -Name 'Owner')
New-WMNamespacePermission -Domain $userDomain1 -Namespace $newNameSpace -PrincipalName "gg-kub-admins" -PrincipalType Group -Role 'Admin'
#  Create Edit
New-WMNamespacePermission -Domain $userDomain2 -Namespace $newNameSpace -PrincipalName "gg-kub-devs" -PrincipalType Group -Role 'Edit'
#  Create View
New-WMNamespacePermission -Domain $userDomain2 -Namespace $newNameSpace -PrincipalName "gg-kub-readonly" -PrincipalType Group -Role'View'

# ====================================================================================
#  Create Namespace
#  Add Storage Policy
New-WMNamespaceStoragePolicy -Namespace $newNameSpace -StoragePolicy vsan-tanzu-storage




Add-NamespaceVmClass -server $ -user administrator@vsphere.local -pass VMw@re1! -domain sfo-w01 -namespace sfo-w01-tkc01 -vmClass guaranteed-small




Get-WMNamespace -Name "lf-tdd-namespace"