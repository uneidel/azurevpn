﻿$rgName= "rgazure";
$location="westeurope";

$InternalVipName= "internalvip";
$vipName=$rgName +"vipname"
$networkname="testvnet1";
$compName="vm01";
$gatewayname=$rgname + "gw"
$storageaccountName = -join ((97..122) | Get-Random -Count 10 | % {[char]$_})
$vnetAddress="10.2.0.0/16";

# Create New Resource Group
New-AzureRmResourceGroup -Name $rgName -Location $location -force

# Create Public Address
$vip = New-AzureRmPublicIpAddress -ResourceGroupName $rgname `
                                  -Name $InternalVipName `
                                  -Location $location `
                                  -DomainNameLabel $vipname -force


# Create Virtual Network and  Subnets
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix '10.2.41.0/26'
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix '10.2.42.0/28'
New-AzureRmVirtualNetwork -Name $networkname `
                          -Location $location `
                          -AddressPrefix $vnetAddress `
                          -Subnet $subnet1, $subnet2 -force
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $networkname


# Create Virtual Gateway
$vnet = Get-AzureRmVirtualNetwork -Name $networkname -ResourceGroupName $rgName
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $vip.Id 

New-AzureRmVirtualNetworkGateway -Name $gatewayname `
                                 -ResourceGroupName $rgName `
                                 -Location $location `
                                 -IpConfigurations $gwipconfig `
                                 -GatewayType Vpn `
                                 -VpnType  RouteBased `
                                 -GatewaySku Standard


# Create Localgateway
New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $rgName -Location $location -GatewayIpAddress '13.91.109.89' -AddressPrefix '10.5.51.0/24'
$nw = Get-AzureRmLocalNetworkGateway -Name "LocalSite" -ResourceGroupName $rgname
$gateway1 = Get-AzureRmVirtualNetworkGateway -Name $gatewayname -ResourceGroupName $rgName
New-AzureRmVirtualNetworkGatewayConnection -Name "vnettovnet" `
                                           -ResourceGroupName $rgname `
                                           -VirtualNetworkGateway1 $gateway1 `
                                           -LocalNetworkGateway2 $nw `
                                           -Location $location `
                                           -ConnectionType IPsec `
                                           -SharedKey 'dickesockentanzentango'