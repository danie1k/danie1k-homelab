logger 'Configuring Docker Icons'

if [ -f "{{ unraid.homelab_dir }}/docker_icons/docker.png" ]
then
  cp -vf "{{ unraid.homelab_dir }}/docker_icons/docker.png" /usr/local/emhttp/plugins/dynamix.docker.manager/images/question.png
fi

if [ -f "{{ unraid.homelab_dir }}/docker_icons/docker-image.png" ]
then
  cp -vf "{{ unraid.homelab_dir }}/docker_icons/docker-image.png" /usr/local/emhttp/plugins/dynamix.docker.manager/images/image.png
fi

if [ -f "{{ unraid.homelab_dir }}/docker_icons/docker-image-icon.patch" ]
then
  fromdos < "{{ unraid.homelab_dir }}/docker_icons/docker-image-icon.patch" > /var/tmp/docker-image-icon.patch
  patch /usr/local/emhttp/plugins/dynamix.docker.manager/include/DockerContainers.php /var/tmp/docker-image-icon.patch
  rm -f /var/tmp/docker-image-icon.patch
fi
