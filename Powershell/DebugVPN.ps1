# This script downloads gateway diagnostic data for a VPN Gateway inside an Azure Virtual Network
# Original Script provided by Keith Mayer of Microsoft
# http://blogs.technet.com/b/keithmayer/archive/2015/12/07/step-by-step-capturing-azure-resource-manager-arm-vnet-gateway-diagnostic-logs.aspx
# Modified by Mitesh Chauhan (miteshc.wordpress.com) slightly to add some variables and only get provisioned state gateway.
 
# STEP 1 – SIGN IN TO BOTH Azure SM and RM
$SubscriptionID = (Get-AzureSubscription)[0].SubscriptionId
#$cred = Get-Credential
# Sign-in to Azure via Azure Resource Manager and also Sign into Azure Service Manager
# Set up Azure Resource Manager Connection
#Login-AzureRmAccount -Credential $cred
Select-AzureRmSubscription -SubscriptionId $subscriptionId
 
 
# Set up Service Manager Connection – Required as gateway diagnostics are still running on Service Manager and not ARM as yet.
Add-AzureAccount -Credential $cred
Select-AzureSubscription -SubscriptionId $subscriptionId
 
# VNET Resource Group and Name
#$rgName = ‘RG NAME’
$vnetGwName = "vnet2vnet"
$timestamp = get-date -uFormat "%d%m%y@%H%M%S"
 
# Details of existing Storage Account that will be used to collect the logs
$storageAccountName = "uneidelstorage"
$storageAccountKey = "<storage>"
$captureDuration = 60
$storageContainer = "vpnlogs"
$logDownloadPath = "C:\Temp"
$Logfilename = "VPNDiagLog_" + $vnetGwName + "_" + $timestamp + ".txt"
 
# Set Storage Context and VNET Gateway ID
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
 
# NOTE: This is an Azure Service Manager cmdlet and so no AzureRM on this one.  AzureRM will not work as we don’t get the gatewayID with it.
$vnetGws = Get-AzureVirtualNetworkGateway
 $foo = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $rgName
# Show Details of Gateway
$vnetGws
 
# Added check for only provisioned gateways as older deleted gateways of same name can also appear in results and capture will fail
$vnetGwId = ($vnetGws | ? GatewayName -eq $vnetGwName | ? state -EQ"provisioned").GatewayID
 
# Start Azure VNET Gateway logging
Start-AzureVirtualNetworkGatewayDiagnostics  `
    -GatewayId $foo.Id `
    -CaptureDurationInSeconds $captureDuration `
    -StorageContext $storageContext `
    -ContainerName $storageContainer
 
# Optional – Test VNET gateway connection to another server across the tunnel
# Only use this if you are connected to the local network you are connecting to FROM Azure. Otherwise create some traffic across the link from on prem.
# Test-NetConnection -ComputerName 10.0.0.4 -CommonTCPPort RDP
 
# Wait for diagnostics capturing to complete
Sleep -Seconds $captureDuration
 
 
# Step 6 – Download VNET gateway diagnostics log
$logUrl = ( Get-AzureVirtualNetworkGatewayDiagnostics -GatewayId $vnetGwId).DiagnosticsUrl
$logContent = (Invoke-WebRequest -Uri $logUrl).RawContent
$logContent | Out-File -FilePath $logDownloadPath\$Logfilename
