{% if 'present_group_name' in pillar %}
{% for group in pillar['present_group_name'] %}  
{{ group.groupname }}:
  group.present:
    - system: True
{% endfor %}
{% endif %}

sudoers_file:
  file.managed:
    - name: /etc/sudoers
    - source: salt://base/files/sudoers
    - user: root
    - mode: 440

{% if 'present_user_name' in pillar %}
{% for user in pillar['present_user_name'] %}  
user_{{ user.username }}:
  user.present:
    - name: {{ user.username }}
    - shell: {{ user.shell }}
    - home: {{ user.home }}
    - groups: 
      - {{ user.group }}
    - createhome: True
  ssh_auth.present:
    - user: {{ user.username }}
    - enc: {{ user.enc }}
    - comment: {{ user.comment }}
    - names:
      - {{ user.pub_key }}
{% endfor %}
{% endif %}
