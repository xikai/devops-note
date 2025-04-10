# ansible-java-oracle-jdk

Ansible role which downloads and installs the Oracle Java SDK.

# Dependencies

None.

# Role Variables

Available variables are listed below, along with default values (see
`defaults/main.yml`).  

All variables have set sensible defaults and usually should not need any
configuration.

## General settings

    java_oracle_jdk_version: 8

Major Java version to install.

    java_oracle_jdk_subversion: 131

Minor Java version to install.

    java_oracle_jdk_target_directory: /usr/java

Base directory where the SDK files should be installed.

    java_oracle_jdk_global_install: false

Install environment variables for the Java JDK in `/etc/profile.d`.

    java_oracle_jdk_use_urandom: false

Use `/dev/urandom` instead of `/dev/random` in the default PRNG.

# Example Playbook

    - hosts: java-hosts
      vars:
        - java_oracle_jdk_version: 8
        - java_oracle_jdk_subversion: 131
        - java_oracle_jdk_target_directory: /usr/local
        - java_oracle_jdk_global_install: true
        - java_oracle_jdk_use_urandom: false
      roles:
        - wecash.jdk
      
# License

MPLv2
--
