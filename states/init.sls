# firefox-policy-formula
#
# This file is part of firefox-policy-formula.
# Licensed under the Apache License, Version 2.0 (Apache-2.0); see LICENSE.
# SPDX-License-Identifier: Apache-2.0
#
# Writes the primary system-wide Firefox policy file
# (default /etc/firefox/policies/policies.json) from shared pillar data.
# When the distribution fallback is enabled, also pulls in distribution.sls,
# which writes byte-identical JSON next to the Firefox binary.

{% from "firefox-policy/map.jinja" import policies, cfg with context %}

{% if cfg.manage_dir %}
firefox-policies-dir:
  file.directory:
    - name: {{ salt['file.dirname'](cfg.policy_file) }}
    - makedirs: True
    - mode: '0755'
    - user: root
    - group: root
{% endif %}

firefox-policies-json:
  file.serialize:
    - name: {{ cfg.policy_file }}
    - serializer: json
    - serializer_opts:
      - indent: 2
      - sort_keys: True
      - ensure_ascii: False
    - dataset:
        policies: {{ policies | tojson }}
    - mode: '0644'
    - user: root
    - group: root
{%- if cfg.manage_dir %}
    - require:
      - file: firefox-policies-dir
{%- endif %}

{% if cfg.manage_dist %}
include:
  - firefox-policy.distribution
{% endif %}
