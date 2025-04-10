base:
  '*':
    - base

  'roles:lb': 
    - match: grain
    - lb

  'roles:ilb': 
    - match: grain
    - ilb

  'roles:api01':
    - match: grain
    - api01

  'roles:api02':
    - match: grain
    - api02

  'roles:cart':
    - match: grain
    - cart

  'roles:manage':
    - match: grain
    - manage

  'roles:tomtopweb':
    - match: grain
    - web.tomtop

  'roles:chicuuweb':
    - match: grain
    - web.chicuu

  'roles:rcmomentweb':
    - match: grain
    - web.rcmoment

  'roles:koogeekweb':
    - match: grain
    - web.koogeek

  'roles:camfereweb':
    - match: grain
    - web.camfere

  'roles:tooartsweb':
    - match: grain
    - web.tooarts

  'roles:dodocoolweb':
    - match: grain
    - web.dodocool

  'roles:memberweb':
    - match: grain
    - web.member

  'roles:marketingweb':
    - match: grain
    - web.marketing

