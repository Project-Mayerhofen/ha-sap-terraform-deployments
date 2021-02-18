{% if grains['os_family'] == 'Suse' %}
{% set arch = grains['osarch'] %}

{% if grains['reg_code'] and (not grains.get('qa_mode') or '_node' not in grains.get('role')) %}
{% set reg_code = grains['reg_code'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% if grains['osmajorrelease'] == 12 %}
# hardcode the 12 version number for the 2 following modules, since they don't offer a sp version only 1.
default_sle_module_adv_systems_management_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-adv-systems-management/12/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/12/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% elif grains['osmajorrelease'] == 15 and grains['provider'] in ['gcp', 'aws', 'azure'] %}
default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/{{ grains['osrelease'] }}/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% endif %}

{% if grains['reg_additional_modules'] %}
{% for module, mod_reg_code in grains['reg_additional_modules'].items() %}
{{ module }}_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p {{ module }} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15
{% endfor %}
{% endif %}

{% endif %}

{% if grains['role'] in ['hana_node', 'monitoring_srv'] %}
# Workaround to get the monitoring packages from PackageHub
# - prometheus/grafana family for the monitoring server
# - prometheus-saptune_exporter for the hana nodes
# If the packages are already preinstalled in the image, those will have preference
# Works for BYOS and PAYG images
# These packages are only available for SLE15SP1 and SLE15SP2
packagehub_registration_monitoring:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p PackageHub/{{ grains['osrelease'] }}/{{ arch }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}

# Workaround for the 'Script died unexpectedly' error bsc#1158664
# If it is a PAYG image, it will force a new registration before refreshing.
# Also the pure refresh will not be executed as salt will still report failure.
# See: https://github.com/saltstack/salt/issues/16291
workaround_payg_cleanup:
  cmd.run:
    - name: |
        rm -f /etc/SUSEConnect &&
        rm -f /etc/zypp/{repos,services,credentials}.d/* &&
        rm -f /usr/lib/zypp/plugins/services/* &&
        sed -i '/^# Added by SMT reg/,+1d' /etc/hosts
    - onlyif: 'test -e /usr/sbin/registercloudguest'

workaround_payg_new_register:
  cmd.run:
    - name: /usr/sbin/registercloudguest --force-new
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'test -e /usr/sbin/registercloudguest'

{% endif %}
