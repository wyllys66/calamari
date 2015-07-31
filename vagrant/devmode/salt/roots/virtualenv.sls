
virtualenv:
  virtualenv.managed:
    - user: {{ pillar[username] }}
    - name: /home/{{ pillar[username] }}/calamari/env
    - system_site_packages: true
    - require:
      - git: git_clone
      - pkg: build_deps

# Explicit installation for pyzmq so we can pass --zmq=bundled
pyzmq:
  pip.installed:
    - name: pyzmq == 14.1.1
    - user: {{ pillar[username] }}
    - bin_env: /home/{{ pillar[username] }}/calamari/env
    - activate: true
    - download_cache: /home/{{ pillar[username] }}/pip_cache
    - install_options:
      - "--zmq=bundled"
    - require:
      - virtualenv: virtualenv

pip_pkgs:
  pip:
    - installed
    - user: {{ pillar[username] }}
    - bin_env: /home/{{ pillar[username] }}/calamari/env
    - activate: true
    - requirements: /home/{{ pillar[username] }}/calamari/requirements/2.7/requirements.txt
    - download_cache: /home/{{ pillar[username] }}/pip_cache
    - env_vars: SWIG_FEATURES=-cpperraswarn
    - require:
      - virtualenv: virtualenv
      - pip: pyzmq

pip_force_pkgs:
  pip:
    - installed
    - user: {{ pillar[username] }}
    - bin_env: /home/{{ pillar[username] }}/calamari/env
    - activate: true
    - requirements: /home/{{ pillar[username] }}/calamari/requirements/2.7/requirements.force.txt
    - ignore_installed: true
    - download_cache: /home/{{ pillar[username] }}/pip_cache
    - require:
      - virtualenv: virtualenv
      - pip: pyzmq

carbon:
  pip:
    - installed
    - user: {{ pillar[username] }}
    - bin_env: /home/{{ pillar[username] }}/calamari/env
    - activate: true
    - download_cache: /home/{{ pillar[username] }}/pip_cache
    - install_options:
      - "--prefix=/home/{{ pillar[username] }}/calamari/env"
      - "--install-lib=/home/{{ pillar[username] }}/calamari/env/lib/python2.7/site-packages"
    - require:
      # Carbon inserts its packages into twisted's folders so it only works
      # if installed after twisted (graphite packaging is wonky generally)
      - pip: pip_pkgs
      - pip: pip_force_pkgs

graphite-web:
  pip:
    - name: git+https://github.com/ceph/graphite-web.git@calamari
    - installed
    - user: {{ pillar[username] }}
    - bin_env: /home/{{ pillar[username] }}/calamari/env
    - activate: true
    - install_options:
      - "--prefix=/home/{{ pillar[username] }}/calamari/env"
      - "--install-lib=/home/{{ pillar[username] }}/calamari/env/lib/python2.7/site-packages"
