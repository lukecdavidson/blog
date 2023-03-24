---
layout: post
title:  "GeoIP on pfSense with pfBlockerNG"
date:   2022-08-23 12:00:00 -0800
categories: pfsense
---
If you’ve recently setup pfBlockerNG, you may have noticed new messages on some of the configuration pages. In example:

![GeoIP: Don't block the world](/assets/images/pfsense-no-world-block.png)

I would wager that many who setup pfBlocker do exactly this, hence the notice. Again the two important principles here are:

* Do not block the world. Instead build rules to permit traffic to/from select countries
* pfSense by default blocks all unsolicited traffic to the WAN. Adding pfBlocker WAN rules is often not needed.

I’ve taken this advice and compiled a short guide to manifest these principals. In my configuration, I move to only permit LAN to WAN traffic for select countries. All other outbound traffic is rejected. In regards to the WAN, I only have one open port to handle OpenVPN traffic. In conjunction with this, my configuration again uses GeoIP to limit traffic bound for this port.

## Prerequisites
Requirements to implement this solution:
* pfSense machine with pfBlockerNG-devel.
  * This should work with the non-development package but I have not tested it. Should you need information on this, here is the documentation direct from Netgate for the non-devel package
* A Free MaxMind GeoIP License Key applied in the IP settings section for pfBlockerNG
  * Conveniently, a link to register for MaxMind is included on that configuration page

## Configuration

### GeoIP

Remember that we will be selectively permitting traffic and defaulting to blocking. To support this, we want select the countries to allow.

On the GeoIP configuration page, set the action for each permitted region to Alias Match and disable logging. Then, disable all remaining regions and save.

![pfSense GeoIP Configuration Page](/assets/images/pfsense-geoip-config-page.png)

I elected to disable these logs as it would generate a large amount and ultimately be useless. Consider that simply going to google.com will trigger this rule to log.

To drill down specific countries to permit, use the edit icon for the region. In the edit pane, select the countries to permit. Repeat for all non-disabled regions.

![pfSense GeoIP Country List](/assets/images/pfsense-geoip-country-permit.png)


### Alias Configuration

To easy management, I suggest creating an alias containing your allowed GeoIP regions.

Complete this by navigating to Firewall > Aliases > Add. 

![Add pfSense GeoIP Alias](/assets/images/pfsense-geoip-firewall-alias.png)

The type is networks. For each network, enter the aliases for the pfBlocker regions and save. I am blocking all IPv6 anyway so I am only using the v4 rules. Like other alias fields in pfSense, aliases will pop up as suggestions as you begin typing. These build in aliases should all begin with “pfB_”.

In a future step, we will configure manual allowed networks/hosts. To manages these, I suggest creating another alias. If you do not already have an alias representing your LAN networks, now is a good time to set this up as well. We will definitely need this to allow traffic from the LAN destined for the pfSense machine. Such as the case you use pfSense for DHCP, DNS, NTP, squid forward proxy, etc.

### Firewall Rules

Now, to implement this firewall alias as a LAN rule. Navigate to Firewall > Rules > Lan (tab). Here I suggest first adding a rule for local traffic. Again, If your pfSense handles DNS or routing for your network, you will need some sort of rule here.

![pfSense GeoIP Firewall Rules](/assets/images/pfsense-geoip-firewall-rules.png)

In my case, I allow all from LAN_NET to LAN_NET. LAN_NET is an alias containing a subset of RFC1918 addresses I use. I have a broad rule here as my switch handles nearly all inter-VLAN routing and houses ACLs for segmentation. I recognize that further tightening here could provide a more secure environment. However, given my situation, I’ve chosen to tackle this another day.

Below the allow rule for your LAN traffic, add a new rule for your LAN traffic out to your new GeoIP Allow alias. This forms the main rule that allows outbound traffic. It is important to note the concept that is being implemented here. Only traffic with a destination IP that is recognized as being geographically in one of the countries you selected is allowed out. All other traffic is rejected.

There will definitely be traffic that you will need to allow manually. This could be for one offs, in various countries, or for IPs that are not mapped to a country in the GeoIP list. Following my picture above, our next rule allows out from the LAN to the alias for manually allowed traffic.

Lastly, a rule to catch all other traffic and reject.

### GeoIP for OpenVPN

Moving to the WAN side, we can lock down the open port for OpenVPN.

Edit the existing rule for OpenVPN and set the source to an alias. As I only ever plan to connect from the US, I used the pfBlocker North America alias.

![pfSense OpenVPN Firewall Rule](/assets/images/pfsense-geoip-openvpn-rule.png)

### Allowing Traffic

This implementation will result in desired traffic that is blocked. The first instance of this I encountered was Discord. Pulling up the Web Developer Tools in Firefox, I was able to easily identify the blocked traffic.

I first had to allow discord.com to even load the site. With the site loaded, you can see the domains that are failing in the network tab of the web developer tools. This resulted in the following domains to the MANUAL_ALLOW alias:

![pfSense GeoIP Permit Rule](/assets/images/pfsense-geoip-permit-rule.png)

pfSense will automatically, periodically resolve these and domains and utilize the IP for the allow list.
