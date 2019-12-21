#use snapshot repo
FROM archlinux/base:latest
MAINTAINER ppickfor

# install packer
################

# install base devel, install app using packer, set perms, cleanup
ENV TERM xterm

RUN	set -e ; \
	pacman -Sy --needed base-devel git supervisor postfix --noconfirm ; \
	useradd -m -g wheel -s /bin/bash makepkg-user ; \
	echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user ; \
	echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers ; \
	echo "Defaults:makepkg-user      !authenticate" >> /etc/sudoers ; \
	groupadd voice ;
RUN	set -e ; \
	cd /home/makepkg-user ; \
	for p in perl-xml-mini perl-audio-dsp perl-modem-vgetty ;do \
		su -c " git clone --depth 1 https://aur.archlinux.org/${p}.git ; cd /home/makepkg-user/${p} ; makepkg -s --noconfirm --needed" - makepkg-user ; \
		pacman -U --noconfirm --overwrite='*' ${p}/${p}*.pkg.tar.xz ; \
	done ;
ARG	MGETTY_VGETTY_GIT_VERSION="*"
RUN	set -e ; \
	cd /home/makepkg-user ; \
	p=mgetty-vgetty-git ; \
	su -c " git clone --depth 1 https://github.com/ppickfor/arch-${p}.git /home/makepkg-user/${p}  ; cd /home/makepkg-user/${p} ; makepkg -s --noconfirm --needed" - makepkg-user ; \
	pacman -U --noconfirm --overwrite='*' ${p}/${p}-${MGETTY_VGETTY_GIT_VERSION}-*.pkg.tar.xz ;
ARG	VOCP_GIT_VERSION="*"
RUN	set -e ; \
	cd /home/makepkg-user ; \
	p=vocp-git ; \
	su -c " git clone --depth 1 https://aur.archlinux.org/${p}.git ; cd /home/makepkg-user/${p} ; makepkg -s --noconfirm --needed" - makepkg-user ; \
	pacman -U --noconfirm --overwrite='*' ${p}/${p}-${VOCP_GIT_VERSION}-*.pkg.tar.xz ;
RUN	pacman -Ru $(pacman -Qqg base-devel |grep -Ev 'sed|grep|pacman') git --noconfirm ; \
	yes|pacman -Scc ; \
	userdel -r makepkg-user ; \
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

