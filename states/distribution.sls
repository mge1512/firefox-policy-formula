# firefox-policy-formula
#
# This file is part of firefox-policy-formula.
# Licensed under the Apache License, Version 2.0 (Apache-2.0); see LICENSE.
# SPDX-License-Identifier: Apache-2.0
#
# Fallback location: writes the same policies.json into the Firefox binary's
# distribution directory (default /usr/lib64/firefox/distribution/policies.json,
# the SLES/openSUSE ESR install path). Content is identical to the primary file,
# so it is safe regardless of which location a given Firefox build honors first.

{% from "firefox-policy/map.jinja" import policies, cfg with context %}

firefox-policies-distribution-dir:
  file.directory:
    - name: {{ salt['file.dirname'](cfg.dist_file) }}
    - makedirs: True
    - mode: '0755'
    - user: root
    - group: root

firefox-policies-distribution-json:
  file.serialize:
    - name: {{ cfg.dist_file }}
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
    - require:
      - file: firefox-policies-distribution-dir
