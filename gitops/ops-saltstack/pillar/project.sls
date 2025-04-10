{% if 'api01' in grains['roles'] %}
api01_project:
  - base
  - member
  - product-search
  - product-esdb
  - advert
  - advertising
  - rabbitmq-producer
{% endif %}

{% if 'manage' in grains['roles'] %}
manage_project:
  - management
  - search-job
  - bos
{% endif %}

{% if 'lb' in grains['roles'] %}
static_project:
  - tomtopstatic
  - chicuustatic
  - rcmomentstatic
  - koogeekstatic
  - camferestatic
  - tooartsstatic
  - dodocoolstatic
  - interougehomestatic
  - interougestatic
  - cafagostatic
  - lovdockstatic
{% endif %}

{% if 'tomtopvip' in grains['roles'] %}
tomtopvip_project:
  - tomtopvip
{% endif %}

{% if 'tomtopweb' in grains['roles'] %}
tomtop_project:
  - tomtopwww
  - tomtopm
{% endif %}