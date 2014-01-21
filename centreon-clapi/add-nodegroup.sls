{%- set pattern = salt['pillar.get']('master:nodegroups:mynodegroup',{}) -%}
{% set data = salt['publish.publish'](pattern,'network.ip_addrs','cidr="10.0.0.0/8"','compound') %}
{% for hostname in data %}

{% for ip in data[hostname] %}

{% if ip.startswith('10.') %}

{{ hostname }}-nagios-add:
  cmd.run:
    - name: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u clapi_user -p password -o HOST -a ADD -v "{{ hostname  }};{{ hostname  }};{{ ip  }};generic-host;central;Linux-Servers"

{% endif %}
{% endfor %}
{% endfor %}
