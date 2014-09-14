{% set psf_internal = salt["pillar.get"]("psf_internal_network") %}
{% set pypi_internal = salt["pillar.get"]("pypi_internal_network") %}

{% set interfaces = salt["ip_picker.interfaces_for_cidr"](cidr=psf_internal) %}

{% if not interfaces %}
{% set interfaces = salt["ip_picker.interfaces_for_cidr"](cidr=pypi_internal) %}
{% endif %}


{% for interface in interfaces %}
{{ interface }}:
  network.routes:
    - routes:
      - name: vpn
        ipaddr: 10.8.0.0
        netmask: 255.255.255.0
        gateway: 192.168.5.10

  cmd.wait:  # Work around https://bugs.launchpad.net/ubuntu/+source/ifupdown/+bug/1301015
    - name: ifdown {{ interface }} && ifup {{ interface }}
    - watch:
      - network: {{ interface }}
{% endfor %}