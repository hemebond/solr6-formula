# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr6/map.jinja" import solr6 with context %}

include:
  - solr6.install
  - solr6.config
  - solr6.service

{%- if solr6.get('cores', false) %}
extend:
{%-   for core, settings in solr6.get('cores', {}).items() %}
  solr6-core-{{ core }}:
    cmd.run:
      - require:
        - service: solr6
{%-   endfor %}
{%- endif %}
