{% if 'tomtopvip' in grains['roles'] and grains['env'] == 'prod' %}
tomtopvip_vhost:
  - www.tomtopvip.com
{% elif 'tomtopvip' in grains['roles'] and grains['env'] == 'uat' %}
tomtopvip_vhost:
  - uat.tomtopvip.com
{% endif %}

{% if 'tomtopweb' in grains['roles'] and grains['env'] == 'prod' %}
tomtop_vhost:
  - www.tomtop.com
  - m.tomtop.com
{% elif 'tomtopweb' in grains['roles'] and grains['env'] == 'uat' %}
tomtop_vhost:
  - uat.tomtop.com
  - muat.tomtop.com
{% endif %}