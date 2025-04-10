kernel.msgmnb:
  sysctl.present:
    - value: 65536

kernel.msgmax:
  sysctl.present:
    - value: 65536

kernel.shmmax:
  sysctl.present:
    - value: 68719476736

kernel.shmall:
  sysctl.present:
    - value: 4294967296

kernel.sysrq:
  sysctl.present:
    - value: 0

kernel.core_uses_pid:
  sysctl.present:
    - value: 1

vm.overcommit_memory:
  sysctl.present:
    - value: 1

vm.swappiness:
  sysctl.present:
    - value: 0

fs.file-max:
  sysctl.present:
    - value: 6815744

net.core.rmem_default:
  sysctl.present:
    - value: 262144

net.core.rmem_max:
  sysctl.present:
    - value: 16777216

net.core.wmem_default:
  sysctl.present:
    - value: 262144

net.core.wmem_max:
  sysctl.present:
    - value: 16777216

net.ipv4.tcp_keepalive_time:
  sysctl.present:
    - value: 1200

net.ipv4.ip_forward:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

net.core.somaxconn:
  sysctl.present:
    - value: 8192

net.ipv4.tcp_max_syn_backlog:
  sysctl.present:
    - value: 8192

net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

net.ipv4.tcp_synack_retries:
  sysctl.present:
    - value: 2

net.ipv4.tcp_tw_reuse:
  sysctl.present:
    - value: 1

net.ipv4.tcp_tw_recycle:
  sysctl.present:
    - value: 1

net.ipv4.tcp_fin_timeout:
  sysctl.present:
    - value: 30

net.ipv4.ip_local_port_range:
  sysctl.present:
    - value: 10000 65535
