#!/bin/bash
export VPN_IPSEC_PSK="dickesockenwalzenwalzer"      		# Preshared Key
export VPN_USER="" 		 									# Not used currently
export VPN_PASSWORD=""										# Not Used
export LNG_PRIVATECIDR="10.0.1.0/24"    					# Local Gateway Network Addressspace		
export PUBLIC_OPPONENTIP=""									# Azure Network gateway Addressspace
export INTERNAL_OPPONENTCIDR="{10.0.2.0/24,}"				#azure Network Gateway Virtual Network CIDR  please add multiple networks comma separated and with a trailing comma
export LNGPUBLIC_IP =""										# Local Network Gateway IPAddress

# Debian on Azure has no lsb_release installed.
if ! [[ -x "/usr/bin/lsb_release" ]]
then
    apt-get update
    apt-get install -y lsb-release
fi

sh SetupLibreSwanInLinux.sh
