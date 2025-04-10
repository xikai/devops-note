base:
  '*':
    - user
    
  'roles:lb':
    - match: grain
    - lb_vhost
    - project

  'roles:ilb':
    - match: grain
    - ilb_vhost
    - project

  'roles:*web':
    - match: grain
    - web_vhost
    - project

  'G@roles:api* or G@roles:manage':
    - match: compound
    - project 

