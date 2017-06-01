# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from "solr6/map.jinja" import solr6 with context %}


{%- if "file" in solr6.archive %}
# User has provided a local archive for the installation
{%-   set archive_file = solr6.archive.file %}
{%- else %}
{%-   set archive_file = solr6.install_dir ~ '/solr-' ~ solr6.version ~ '.tgz' %}

{%-   if "source" in solr6.archive %}
# User has provided a custom source for the archive
{%-     set archive_src = solr6.archive.source %}
{%-     if "source_hash" in solr6.archive %}
{%-       set source_hash = solr6.archive.source_hash %}
{%-     endif %}
{%-   else %}
{%-     set archive_src = solr6.archive.host ~ solr6.archive.path ~ '/' ~ solr6.version ~ '/solr-' ~ solr6.version ~ '.tgz' %}
{%-     set source_hash = archive_src ~ '.md5' %}
{%-   endif %}

#
# The archive must be saved locally for extraction and installation
#
solr6-download:
  file.managed:
    - name: {{ archive_file }}
    - source: {{ archive_src }}
{%-   if "source_hash" is defined %}
    - source_hash: {{ source_hash }}
{%-   else %}
    - skip_verify: True
{%- endif %}
    - require_in:
      - cmd: solr6-extract-installer
{%- endif %}


#
# Extract the installation script from the archive
#
solr6-extract-installer:
  cmd.run:
    - cwd: {{ solr6.install_dir }}
    - name: tar xzf {{ archive_file }} solr-{{ solr6.version }}/bin/install_solr_service.sh --strip-components=2
    - onchanges:
      - file: solr6-download


#
# Install the service using the extracted files and the saved archive
#
solr6-install:
  cmd.run:
    - cwd: {{ solr6.install_dir }}
    - name: {{ solr6.install_dir }}/install_solr_service.sh {{ archive_file }} -f -u {{ solr6.user }} -d {{ solr6.data_dir }}
    - onchanges:
      - cmd: solr6-extract-installer

#
# Make sure the version symlink has been updated
#
solr6-symlink:
  file.symlink:
    - name: {{ solr6.install_dir }}/solr
    - target: {{ solr6.install_dir }}/solr-{{ solr6.version }}
    - watch_in:
      - service: solr6
