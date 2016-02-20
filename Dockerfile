#use snapshot repo
FROM pritunl/archlinux:latest
MAINTAINER ppickfor

# install packer
################

# install base devel, install app using packer, set perms, cleanup
ENV TERM xterm

RUN	set -e ; \
	pacman -S --needed base-devel git supervisor postfix --noconfirm ; \
	useradd -m -g wheel -s /bin/bash makepkg-user ; \
	echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user ; \
	echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers ; \
	echo "Defaults:makepkg-user      !authenticate" >> /etc/sudoers ; \
	groupadd voice ; \
	cd /home/makepkg-user ; \
	for d in perl-xml-mini perl-audio-dsp perl-modem-vgetty mgetty-vgetty vocp ;do \
		su -c " git clone --depth 1 https://aur.archlinux.org/${d}.git ; cd /home/makepkg-user/$d ; makepkg -s --noconfirm --needed" - makepkg-user ; \
		pacman -U --noconfirm --force $d/${d}*.pkg.tar.xz ; \
	done ; \
	pacman -Ru $(pacman -Qqg base-devel |grep -Ev 'sed|pacman') git --noconfirm ; \
	yes|pacman -Scc ; \
	userdel -r makepkg-user ; \
	set +e ; \
	rm -rf /usr/share/locale/* ; \
	rm -rf /usr/share/man/* ; \
	rm -rf /root/* ; \
	rm -rf /tmp/* ;  \
	true

# docker settings
#################

#externalize main configuration and data
VOLUME /var/spool/voice
VOLUME /etc/vocp
VOLUME /etc/mgetty+sendfax

# additional files
##################
ADD ./app/ /app/

# run supervisor
################

RUN chmod +x /app/entrypoint

WORKDIR /app/

ENTRYPOINT ["/app/entrypoint"]
CMD ["run"]

