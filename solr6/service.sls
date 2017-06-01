# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr6/map.jinja" import solr6 with context %}

solr6-name:
  service.running:
    - name: {{ solr6.service.name }}
    - enable: True
