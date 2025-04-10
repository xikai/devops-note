# 示例代码

```
---
  - hosts: ceshi
    remote_user: root
    gather_facts: false
    become: yes

    roles:
      - role: vevor.nodejs
        nodejs_version: v16.13.1
```