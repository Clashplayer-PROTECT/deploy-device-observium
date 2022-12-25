#!/bin/bash
# Script Auto Install SNMP for observium
#=====================================================================================
# Author:   Clashplayer#2134 with the help of the auto install script of observium which is not complete
#=====================================================================================
#=====================================================================================
# Root Force
# By Clashplayer#2134

  echo -e "${GREEN}Installing snmpd...${NC}"
  apt-get -qq install -y snmpd

  wget -O /usr/local/bin/distro https://www.observium.org/files/distro
  chmod +x /usr/local/bin/distro
  echo -e "${YELLOW}Reconfiguring local snmpd${NC}"
  echo "agentAddress   udp:161,udp6:[::1]:161" > /etc/snmp/snmpd.conf
  snmpcommunity="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-15};echo;)"
  echo "rocommunity $snmpcommunity" >> /etc/snmp/snmpd.conf

  # Distro sctipt
  echo "# This line allows Observium to detect the host OS if the distro script is installed" >> /etc/snmp/snmpd.conf
  echo "extend .1.3.6.1.4.1.2021.7890.1 distro /usr/local/bin/distro" >> /etc/snmp/snmpd.conf

  # Vendor/hardware extending
  if [ -f "/sys/devices/virtual/dmi/id/product_name" ]; then
    echo "# This lines allows Observium to detect hardware, vendor and serial" >> /etc/snmp/snmpd.conf
    echo "extend .1.3.6.1.4.1.2021.7890.2 hardware /bin/cat /sys/devices/virtual/dmi/id/product_name" >> /etc/snmp/snmpd.conf
    echo "extend .1.3.6.1.4.1.2021.7890.3 vendor   /bin/cat /sys/devices/virtual/dmi/id/sys_vendor" >> /etc/snmp/snmpd.conf
    echo "#extend .1.3.6.1.4.1.2021.7890.4 serial   /bin/cat /sys/devices/virtual/dmi/id/product_serial" >> /etc/snmp/snmpd.conf
  elif [ -f "/proc/device-tree/model" ]; then
    # ARM/RPi specific hardware
    echo "# This lines allows Observium to detect hardware, vendor and serial" >> /etc/snmp/snmpd.conf
    echo "extend .1.3.6.1.4.1.2021.7890.2 hardware /bin/cat /proc/device-tree/model" >> /etc/snmp/snmpd.conf
    echo "#extend .1.3.6.1.4.1.2021.7890.4 serial   /bin/cat /proc/device-tree/serial" >> /etc/snmp/snmpd.conf
  fi

  # Accurate uptime
  echo "# This line allows Observium to collect an accurate uptime" >> /etc/snmp/snmpd.conf
  echo "extend uptime /bin/cat /proc/uptime" >> /etc/snmp/snmpd.conf

  echo "# This line enables Observium's ifAlias description injection" >> /etc/snmp/snmpd.conf
  echo "#pass_persist .1.3.6.1.2.1.31.1.1.1.18 /usr/local/bin/ifAlias_persist" >> /etc/snmp/snmpd.conf
  
  service snmpd restart
  
  echo -e "${YELLOW}You can look in the file /etc/snmp/snmpd.conf to get the identifiers${NC}"



