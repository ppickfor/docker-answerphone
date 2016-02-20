#use snapshot repo
FROM pritunl/archlinux:latest
MAINTAINER ppickfor

# additional files
##################

# install packer
################

# install base devel, install app using packer, set perms, cleanup
ENV TERM xterm

RUN	pacman -S --needed base-devel git supervisor postfix --noconfirm && \
	useradd -m -g wheel -s /bin/bash makepkg-user && \
	echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user && \
	echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers && \
	echo "Defaults:makepkg-user      !authenticate" >> /etc/sudoers
RUN	cd /home/makepkg-user && \
	for d in perl-xml-mini perl-audio-dsp perl-modem-vgetty ;do \
		su -c " git clone https://aur.archlinux.org/${d}.git && cd /home/makepkg-user/$d && makepkg -s --noconfirm --needed" - makepkg-user && \
		pacman -U --noconfirm --force $d/${d}*.pkg.tar.xz || exit 1; \
	done
RUN	cd /home/makepkg-user && \
	for d in mgetty-vgetty;do \
		su -c " git clone https://aur.archlinux.org/${d}.git && cd /home/makepkg-user/$d && makepkg -s --noconfirm --needed" - makepkg-user && \
		pacman -U --noconfirm --force $d/${d}*.pkg.tar.xz || exit 1; \
	done
RUN	cd /home/makepkg-user && \
	for d in  vocp;do \
		su -c " git clone https://aur.archlinux.org/${d}.git && cd /home/makepkg-user/$d && makepkg -s --noconfirm --needed" - makepkg-user && \
		pacman -U --noconfirm --force $d/${d}*.pkg.tar.xz || exit 1; \
	done
RUN	pacman -Ru $(pacman -Qqg base-devel |grep -v pacman) git --noconfirm ; \
	yes|pacman -Scc ; \
	userdel -r makepkg-user ; \
	rm -rf /usr/share/locale/* ; \
	rm -rf /usr/share/man/* ; \
	rm -rf /root/* ; \
	rm -rf /tmp/* ;  \
	true

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /var/spool/voice
VOLUME /etc/vocp
VOLUME /etc/mgetty+sendfax

# run supervisor
################

ADD ./app/ /app/
RUN chmod +x /app/entrypoint

WORKDIR /app/

ENTRYPOINT ["/app/entrypoint"]
CMD ["run"]

