FROM base/arch
MAINTAINER ppickfor

# additional files
##################

# install packer
################

# install base devel, install app using packer, set perms, cleanup
RUN	pacman -Syu --noconfirm && \
	pacman-db-upgrade && \
	(echo;echo y;echo y)|pacman -S --needed base-devel postfix
RUN	useradd -m -g wheel -s /bin/bash makepkg-user && \
	echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user && \
	echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers && \
	echo "Defaults:makepkg-user      !authenticate" >> /etc/sudoers && \
	cd /home/makepkg-user && \
	pacman -S --noconfirm core/libunistring && \
	for d in mgetty mgetty-vgetty perl-xml-mini perl-audio-dsp perl-modem-vgetty vocp;do \
		su -c " git clone https://aur.archlinux.org/${d}.git && cd /home/makepkg-user/$d && \ makepkg -s --noconfirm --needed" - makepkg-user && \
		pacman -U --noconfirm --force $d/${d}*.pkg.tar.xz && \
		pacman -Q |grep $d; \
	done && \
	#pacman -Ru base-devel --noconfirm && \
	yes|pacman -Scc && \
	userdel -r makepkg-user && \
	rm -rf /usr/share/locale/* && \
	rm -rf /usr/share/man/* && \
	rm -rf /root/* && \
	rm -rf /tmp/*

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /var/spool/voice
VOLUME /etc/vocp
VOLUME /etc/mgetty+sendfax
VOLUME /etc/postfix

# run supervisor
################

CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]
