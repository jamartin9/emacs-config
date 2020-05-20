;;
;; Manifest for development env
;;
;; https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh -> guix
(specifications->manifest
 '(
   ;; basic
   "emacs"
   ;;"git"
   ;;"busybox" ;; coreutils ;; binutils
   ;;"gnupg"
   ;;"glibc-utf8-locales" ; should be in default profile
   ;;"guix"
   ;;"guile"

   ;;"perf"
   ;;"openssh" ; "dropbear"
   ;; C dev
   ;;"make"
   ;;"glibc"
   ;;"gcc"
   ;;"gdb"
   ;;"clang" ; lldb

   ;; java
   ;;"openjdk"

   ;; shell
   ;;"htop"
   ;;"zsh"
   ;;"xclip"
   ;;"bc"
   ;;"jq"
   ;;"gawk"
   ;;"coreutils"
   ;;"less"
   ;;"wget"
   ;;"gzip"
   ;;"tar"
   ;;"which"
   ;;"sed"
   ;;"grep"
   ;;"diffutils"
   ;;"patch"
   ;;"findutils"
   ;;"fdisk"

   ;; apps
   ;;"winetricks"
   ;;"clamav"
   ;;"filezilla"
   ;;"lynx"
   ;;"transmission"
   ;;"qemu"
   ;;"libvirt"
   ;;"virt-manager"
   ;;"postgresql"
   ;;"sqlite"
   ;;"tigervnc-client"
   ;;"tigervnc-server"

   ;; docs
   ;;"libreoffice"
   ;;"calibre"
   ;;"biber"
   ;;"texlive"
   ;;"aspell-dict-en"

   ;; media
   ;;"blender"
   ;;"gimp"
   ;;"inkscape"
   ;;"vlc"
   ;;"mkvtoolnix"
   ;;"mediainfo"
   ;;"ffmpeg"
   ;;"gnuplot"
   ;; makemkv
   ;; flamegraph

   ;; net
   ;;"curl"
   ;;"whois"
   ;;"bind:utils"
   ;;"nmap"
   ;;"tor"
   ;;"iptables"
   ;;"ebtables"
   ;;"wireshark"
   ;;"netcat"
   ;;"net-tools"
   ))
