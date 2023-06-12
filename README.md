# [Nginx](https://www.nginx.com/ "Nginx's Homepage") & [Certbot](https://certbot.eff.org/ "Certbot's Homepage") Install Script
Nginx and Certbot Install Script for Ubuntu

## Installation procedure

##### 1. Download the script:
```
sudo wget sudo wget https://github.com/jjackofall/CertbotInstallScript/blob/main/certbot_install.sh

```

#### 2. Make the script executable
```
sudo chmod +x certbot_install.sh
```
##### 4. Execute the script:
```
sudo ./certbot_install.sh
```

## Where should I host Nginx?
There are plenty of great services that offer good hosting. The script has been tested with a few major players such as [Google Cloud](https://cloud.google.com/), [Hetzner](https://www.hetzner.com/), [Amazon AWS](https://aws.amazon.com/) and [DigitalOcean](https://www.digitalocean.com/products/droplets/).

## Minimal server requirements
While technically you can run an Docker instance on 500MB of RAM. A Linux instance typically uses 300MB-500MB and the rest has to be split among others.
