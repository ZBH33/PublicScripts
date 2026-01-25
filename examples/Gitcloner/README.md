curl -O https://raw.githubusercontent.com/ZBH33/PublicScripts/main/scripts/Gitcloner/gitcloner.sh

chmod +x gitcloner.sh

# Configure auditd
cat <<EOF >$HOME/gitclonder.sh
# Docker daemon configuration
-w /usr/bin/dockerd -k docker
-w /var/lib/docker -k docker
-w /etc/docker -k docker
-w /usr/lib/systemd/system/docker.service -k docker
-w /etc/default/docker -k docker
-w /etc/docker/daemon.json -k docker
-w /usr/bin/docker -k docker-bin
EOF