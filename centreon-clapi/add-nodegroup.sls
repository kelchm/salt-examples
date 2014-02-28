############################
# Add and Update DVS Nodes #
############################

{%- set dvspattern = salt['pillar.get']('master:nodegroups:solus.ovzhn.dvs',{}) -%}
{%- set vpspattern = salt['pillar.get']('master:nodegroups:solus.ovzhn.vps',{}) -%}
{% set username = "salt" %}
{% set password = "##########" %}

{% set ip_data = salt['publish.publish'](dvspattern,'network.ip_addrs','cidr="10.0.0.0/8"','compound') %}
{% set manufacturer_data = salt['publish.publish'](dvspattern,'grains.get','manufacturer','compound') %}
{% for hostname in ip_data %}
{% for ip in ip_data[hostname] %}
{% if ip.startswith('10.') %}

{% set manufacturer = manufacturer_data[hostname] %}

# Add new VPS/DVS node
{{ hostname }}-nagios-add:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a ADD -v "{{ hostname  }};{{ hostname  }};{{ ip  }};generic-host;central;Linux-Servers|OpenVZ-Servers|OpenVZ-DVS-Node"
    - unless: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a enable -v "{{ hostname  }}"

# Add hostgroups based on manufacturer

{% if manufacturer.startswith('Dell') %}
{{ hostname }}-nagios-add-dell-omsa:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a addhostgroup -v "{{ hostname }};Dell_OMSA_Servers"

{% endif %}
{% endif %}
{% endfor %}
{% endfor %}

############################
# Add and Update VPS Nodes #
############################

{% set ip_data = salt['publish.publish'](vpspattern,'network.ip_addrs','cidr="10.0.0.0/8"','compound') %}
{% set manufacturer_data = salt['publish.publish'](vpspattern,'grains.get','manufacturer','compound') %}
{% for hostname in ip_data %}
{% for ip in ip_data[hostname] %}
{% if ip.startswith('10.') %}

{% set manufacturer = manufacturer_data[hostname] %}

# Add new VPS/DVS node
{{ hostname }}-nagios-add:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a ADD -v "{{ hostname  }};{{ hostname  }};{{ ip  }};generic-host;central;Linux-Servers|OpenVZ-Servers|OpenVZ-VPS-Node"
    - unless: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a enable -v "{{ hostname  }}"

# Add hostgroups based on manufacturer

{% if manufacturer.startswith('Dell') %}
{{ hostname }}-nagios-add-dell-omsa:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -o HOST -a addhostgroup -v "{{ hostname }};Dell_OMSA_Servers"

{% endif %}
{% endif %}
{% endfor %}
{% endfor %}

# Export configuration and restart
apply-nagios-config:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u {{ username  }} -p {{ password  }} -a APPLYCFG -v 1
    - order: last
