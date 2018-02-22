# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr6/map.jinja" import solr6 with context %}

{%- if 'cores' in solr6 %}
{%-   for core, settings in solr6.get('cores', {}).items() %}
solr6-core-{{ core }}:
  cmd.run:
    - name: {{ solr6.install_dir }}/solr-{{ solr6.version }}/bin/solr create -c {{ core }} -d {{ solr6.install_dir }}/solr-{{ solr6.version }}/example/files/conf
    - runas: solr
    - creates: {{ solr6.data_dir }}/data/{{ core }}/
    - require:
      - cmd: solr6-install

solr6-core-{{ core }}-schema:
  file.managed:
    - name: {{ solr6.data_dir }}/data/{{ core }}/conf/schema.xml
    - source: {{ settings.schema|default("salt://solr6/example/managed-schema") }}
    - user: {{ solr6.user }}
    - group: {{ solr6.group }}
    - makedirs: True
    - require:
      - cmd: solr6-core-{{ core }}

solr6-core-{{ core }}-solrconfig:
  file.managed:
    - name: {{ solr6.data_dir }}/data/{{ core }}/conf/solrconfig.xml
    - source: {{ settings.solrconfig|default("salt://solr6/example/solrconfig.xml") }}
    - user: {{ solr6.user }}
    - group: {{ solr6.group }}
    - makedirs: True
    - require:
      - cmd: solr6-core-{{ core }}

solr6-reload-core-{{ core }}:
  http.query:
    - name: http://127.0.0.1:{{ solr6.port }}/solr/admin/cores?action=RELOAD&core={{ core }}
    - status: 200
    - onchanges:
      - file: solr6-core-{{ core }}-schema
      - file: solr6-core-{{ core }}-solrconfig
{%-   endfor %}
{%- endif %}

