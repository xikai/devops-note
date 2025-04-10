lb_vhost:
{% if grains['env'] == 'prod' %}
  - newbos.tomtop-cdn.com
  - bos.tomtop-cdn.com
  - static-src.tomtopvip.com
  - static-src.tomtop-cdn.com
  - www.tomtopvip.com
  - www.tomtop.com
  - m.tomtop.com
{% elif grains['env'] == 'uat' %}
  - newbosuat.tomtop-cdn.com
  - bosuat.tomtop-cdn.com
  - staticuat.tomtopvip.com
  - staticuat.tomtop-cdn.com
  - uat.tomtopvip.com
  - uat.tomtop.com
  - muat.tomtop.com
{% endif %}
  - payment.api.tomtop.com
  - img.api.tomtop.com


ssl_pem:
  - server_tomtop.pem

ssl_key:
  - server_tomtop.key
