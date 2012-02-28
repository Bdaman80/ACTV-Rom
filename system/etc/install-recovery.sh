#!/system/bin/sh
if ! applypatch -c MTD:recovery:2048:92c06415221dcde31ce5c092312a7a1e5f9c7828; then
  log -t recovery "Installing new recovery image"
  applypatch MTD:boot:2955264:a534c0e0e8cc8c28aa796c013a5ce045a10c2db1 MTD:recovery 12297023ef539127697d380589ea55b3cdb4f0ac 3289088 a534c0e0e8cc8c28aa796c013a5ce045a10c2db1:/system/recovery-from-boot.p
else
  log -t recovery "Recovery image already installed"
fi
