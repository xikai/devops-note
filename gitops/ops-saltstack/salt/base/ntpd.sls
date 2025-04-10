ntpd_service:
  pkg.installed:
    - name: ntp
  service.running:
    - name: ntpd
    - enable: True
    - require:
      - pkg: ntp
