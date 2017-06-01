# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr6/map.jinja" import solr6 with context %}


{%- for core, settings in solr6.get('cores', {}).items() %}
solr6-core-{{ core }}:
  cmd.run:
    - name: {{ solr6.install_dir }}/solr-{{ solr6.version }}/bin/solr create -c {{ core }}
    - runas: solr
    - creates: {{ solr6.data_dir }}/data/{{ core }}/
    - require:
      - cmd: solr6-install

solr6-core-{{ core }}-schema:
  file.managed:
    - name: {{ solr6.data_dir }}/data/{{ core }}/conf/managed-schema
    - source: {{ settings.schema|default("salt://files/solr6/schema/" ~ core) }}
    - user: {{ solr6.user }}
    - group: {{ solr6.group }}
    - require:
      - cmd: solr6-core-{{ core }}
{%- endfor %}
