hostname: ${hostname}
manage_etc_hosts: true
users:
    - name: ${env_user}
      sudo: ALL=(ALL) NOPASSWD: ALL
      groups: users, sudo
      shell: /bin/bash
      lock_passwd: false
      # The value for ${hashed_pass} should be a SHA-512 hashed password (e.g., generated with 'mkpasswd --method=SHA-512').
      passwd: ${hashed_pass}
ssh_pwauth: true

chpasswd:
  list: |
    ${env_user}:${env_pass}  # WARNING: Using plain text passwords is insecure. Consider using hashed passwords or secure secret management.
  expire: false

package_update: true
packages:
  - openssh-server
  # netplan.io is required only for Ubuntu and some derivatives; remove or replace for other distributions.
  - netplan.io

runcmd:
  - systemctl enable ssh
  - systemctl restart ssh
  - netplan apply