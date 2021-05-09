# Debian repository for Popura

To use this Debian repository:

```shell
sudo apt install -y wget apt-transport-https
sudo wget -O /usr/share/keyrings/popura-archive-keyring.gpg https://github.com/popura-network/popura-debian-repo/raw/master/popura.gpg
echo 'deb [signed-by=/usr/share/keyrings/popura-archive-keyring.gpg] https://raw.githubusercontent.com/popura-network/popura-debian-repo/master/repo stable main' |
  sudo tee /etc/apt/sources.list.d/popura.list >/dev/null
sudo apt update
sudo apt install popura
```
