#!/bin/bash

# This Bash script allows you to easily and safely install Enlightenment, along with
# other EFL-based applications, on your Ubuntu desktop system.

# ELLUMINATE takes care of downloading, configuring and building everything
# you need to enjoy the very latest version of Enlightenment.

# Tip: Set your terminal to unlimited scrolling so that you can scroll up
# to look at earlier output at any time.
# See README.md for instructions on how to use this script.
# See also the repository's wiki for post-installation hints.

# Heads up!
# Enlightenment programs installed from .deb packages or tarballs will inevitably
# conflict with programs compiled from git repositories——do not mix source code
# with prebuilt binaries! So, please remove thoroughly any previous binary
# installation of EFL/Enlightenment/E-apps (track down and delete any
# leftover files), before running ELLUMINATE.

# Also note that ELLUMINATE is not compatible with ESTEEM (previous install script).

# Once installed, you can update your shiny new Enlightenment desktop whenever you want to.
# However, because software gains entropy over time (performance regression, unexpected
# behavior... and this is especially true when dealing directly with source code), we
# highly recommend doing a complete uninstall and reinstall of your Enlightenment
# desktop every three weeks or so for an optimal user experience.

# ELLUMINATE is written and maintained by batden@sfr.fr and carlasensa@sfr.fr,
# feel free to use this script as you see fit.

# ---------------
# LOCAL VARIABLES
# ---------------

BLD="\e[1m"    # Bold text.
ITA="\e[3m"    # Italic text.
BDR="\e[1;31m" # Bold red text.
BDG="\e[1;32m" # Bold green text.
BDY="\e[1;33m" # Bold yellow text.
BDP="\e[1;35m" # Bold purple text.
LWG="\e[2;32m" # Low intensity green text.
LWP="\e[2;35m" # Low intensity purple text.
LWY="\e[2;33m" # Low intensity yellow text.
OFF="\e[0m"    # Turn off ANSI colors and formatting.

PREFIX=/usr/local
DLDIR=$(xdg-user-dir DOWNLOAD)
DOCDIR=$(xdg-user-dir DOCUMENTS)
SCRFLR=$HOME/.elluminate
REBASEF="git config pull.rebase false"
AUTGN="./autogen.sh --prefix=$PREFIX"
SNIN="sudo ninja -C build install"
DISTRO=$(lsb_release -sc)
DDTL=1.2.2

# Build dependencies, recommended and script-related packages.
DEPS="arc-theme aspell bear build-essential ccache check cmake cowsay doxygen \
fonts-noto freeglut3-dev graphviz gstreamer1.0-libav gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly imagemagick libaom-dev \
libasound2-dev libavif-dev libavahi-client-dev libblkid-dev libbluetooth-dev \
libclang-11-dev libegl1-mesa-dev libexif-dev libfontconfig1-dev libdrm-dev \
libfreetype6-dev libfribidi-dev libgbm-dev libgeoclue-2-dev \
libgif-dev libgraphviz-dev libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev libharfbuzz-dev libheif-dev \
libi2c-dev libibus-1.0-dev libinput-dev libinput-tools libjpeg-dev \
libkmod-dev liblua5.2-dev liblz4-dev libmenu-cache-dev libmount-dev \
libopenjp2-7-dev libosmesa6-dev libpam0g-dev libpoppler-cpp-dev \
libpoppler-dev libpoppler-private-dev libpulse-dev libraw-dev \
librsvg2-dev libsdl1.2-dev libscim-dev libsndfile1-dev libspectre-dev \
libssl-dev libsystemd-dev libtiff5-dev libtool libudev-dev libudisks2-dev \
libunibreak-dev libunwind-dev libusb-1.0-0-dev libwebp-dev libxcb-keysyms1-dev \
libxcursor-dev libxinerama-dev libxkbcommon-x11-dev libxkbfile-dev \
lxmenu-data libxrandr-dev libxss-dev libxtst-dev lolcat manpages-dev \
manpages-posix-dev meson mlocate nasm ninja-build papirus-icon-theme \
texlive-base unity-greeter-badges valgrind wayland-protocols wmctrl \
xdotool xserver-xephyr xwayland"

# Latest development code.
CLONEFL="git clone https://git.enlightenment.org/core/efl.git"
CLONETY="git clone https://git.enlightenment.org/apps/terminology.git"
CLONE26="git clone https://git.enlightenment.org/core/enlightenment.git"
CLONEPH="git clone https://git.enlightenment.org/apps/ephoto.git"
CLONERG="git clone https://git.enlightenment.org/apps/rage.git"
CLONEVI="git clone https://git.enlightenment.org/apps/evisum.git"
CLONEXP="git clone https://git.enlightenment.org/apps/express.git"
CLONECR="git clone https://git.enlightenment.org/apps/ecrire.git"
CLONEVE="git clone https://git.enlightenment.org/tools/enventor.git"
CLONEDI="git clone https://git.enlightenment.org/apps/edi.git"
CLONENT="git clone https://github.com/vtorri/entice"

# “MN” stands for Meson——the Meson build system.
PROG_MN="efl terminology enlightenment ephoto evisum rage express ecrire enventor edi entice"

# Uncomment the following to force messages to display in English
# during the build process (bug reporting).
#
# export LC_ALL=C

# ---------
# FUNCTIONS
# ---------

# Audible feedback (error, sudo prompt...). Make sure the sound is turned on and loud enough.
beep_attention() {
  paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
}

beep_question() {
  paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
}

beep_exit() {
  paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
}

beep_ok() {
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga
}

# Hints.
# 1/2: Plain build with well tested default values.
# 3: A feature-rich, decently optimized build; however, occasionally technical glitches do happen...
# 4: Same as above, but running Enlightenment as a Wayland compositor is still considered experimental.
#
menu_sel() {
  if [ $INPUT -lt 1 ]; then
    echo
    printf "1  $BDG%s $OFF%s\n\n" "INSTALL Enlightenment now"
    printf "2  $LWG%s $OFF%s\n\n" "Update and REBUILD Enlightenment"
    printf "3  $LWP%s $OFF%s\n\n" "Update and rebuild Enlightenment in RELEASE mode"
    printf "4  $LWY%s $OFF%s\n\n" "Update and rebuild Enlightenment with WAYLAND support"

    sleep 1 && printf "$ITA%s $OFF%s\n\n" "Or press Ctrl+C to quit."
    read INPUT
  fi
}

sel_menu() {
  if [ $INPUT -lt 1 ]; then
    echo
    printf "1  $LWG%s $OFF%s\n\n" "INSTALL Enlightenment now"
    printf "2  $BDG%s $OFF%s\n\n" "Update and REBUILD Enlightenment"
    printf "3  $BDP%s $OFF%s\n\n" "Update and rebuild Enlightenment in RELEASE mode"
    printf "4  $BDY%s $OFF%s\n\n" "Update and rebuild Enlightenment with WAYLAND support"

    sleep 1 && printf "$ITA%s $OFF%s\n\n" "Or press Ctrl+C to quit."
    read INPUT
  fi
}

bin_deps() {
  sudo apt update && sudo apt full-upgrade

  sudo apt install $DEPS
  if [ $? -ne 0 ]; then
    printf "\n$BDR%s %s\n" "CONFLICTING OR MISSING .DEB PACKAGES"
    printf "$BDR%s %s\n" "OR DPKG DATABASE IS LOCKED."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

ls_dir() {
  COUNT=$(ls -d -- */ | wc -l)
  if [ $COUNT == 11 ]; then
    printf "$BDG%s $OFF%s\n\n" "All programs have been downloaded successfully."
    sleep 2
  elif [ $COUNT == 0 ]; then
    printf "\n$BDR%s %s\n" "OOPS! SOMETHING WENT WRONG."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  else
    printf "\n$BDY%s %s\n" "WARNING: ONLY $COUNT OF 11 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$BDY%s $OFF%s\n\n" "WAIT 12 SECONDS OR HIT CTRL+C TO QUIT."
    beep_attention
    sleep 12
  fi
}

mng_err() {
  printf "\n$BDR%s $OFF%s\n\n" "BUILD ERROR——TRY AGAIN LATER."
  beep_exit
  exit 1
}

chk_path() {
  if ! echo $PATH | grep -q $HOME/.local/bin; then
    echo -e '    export PATH=$HOME/.local/bin:$PATH' >>$HOME/.bash_aliases
    source $HOME/.bash_aliases
  fi
}

elap_start() {
  START=$(date +%s)
}

elap_stop() {
  DELTA=$(($(date +%s) - START))
  printf "\n$ITA%s $OFF%s\n" "Compilation and linking time: "
  eval "echo $(date -ud "@$DELTA" +'%H hr %M min %S sec')"
}

# Timestamp: See the date man page to convert epoch to human-readable date
# or visit https://www.epochconverter.com/
#
# To restore a backup, use the same command that was executed but with
# the source and destination reversed:
# e.g. cp -aR /home/riley/Documents/ebackups/E_1647849202/.e* /home/riley/
# (Then press Ctrl+Alt+End to restart Enlightenment if you are currently logged into.)
#
e_bkp() {
  TSTAMP=$(date +%s)
  mkdir -p $DOCDIR/ebackups

  mkdir $DOCDIR/ebackups/E_$TSTAMP &&
    cp -aR $HOME/.elementary $DOCDIR/ebackups/E_$TSTAMP &&
    cp -aR $HOME/.e $DOCDIR/ebackups/E_$TSTAMP
  sleep 2
}

# Used by EXTINGUISH.
# See https://github.com/batden/extinguish (companion script).
#
m_bkp() {
  mkdir -p $DOCDIR/mbackups

  mkdir -p $DOCDIR/mbackups/rlottie
  cp -aR $ESRC/rlottie/build $DOCDIR/mbackups/rlottie

  for I in $PROG_MN; do
    cd $ESRC/e26/$I
    mkdir -p $DOCDIR/mbackups/$I
    cp -aR $ESRC/e26/$I/build $DOCDIR/mbackups/$I
  done
}

p_bkp() {
  # Backup list of currently installed .deb packages.
  if [ ! -f $DOCDIR/pbackups/installed_pkgs.log ]; then
    mkdir -p $DOCDIR/pbackups

    apt-cache dumpavail >/tmp/apt-avail
    sudo dpkg --merge-avail /tmp/apt-avail &>/dev/null
    rm /tmp/apt-avail
    dpkg --get-selections >$DOCDIR/pbackups/installed_pkgs.log

    # Backup list of manually installed .deb packages.
    echo $(comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz |
      sed -n 's/^Package: //p' | sort -u)) >$DOCDIR/pbackups/manually_installed_pkgs.txt

    # Backup list of available repositories.
    grep -Erh ^deb /etc/apt/sources.list* >$DOCDIR/pbackups/available_repos.txt

    # Backup list of currently installed snap packages.
    snap list --all >$DOCDIR/pbackups/installed_snaps.txt
  fi
}

e_tokens() {
  echo $(date +%s) >>$HOME/.cache/ebuilds/etokens

  TOKEN=$(wc -l <$HOME/.cache/ebuilds/etokens)
  if [ "$TOKEN" -gt 2 ]; then
    echo
    # Questions: Enter either y or n, or press Enter to accept the default value (capital letter).
    beep_question
    read -t 12 -p "Do you want to back up your Enlightenment settings now? [y/N] " answer
    case $answer in
    [yY])
      e_bkp
      ;;
    [nN])
      printf "\n$ITA%s $OFF%s\n\n" "(no backup made... OK)"
      ;;
    *)
      printf "\n$ITA%s $OFF%s\n\n" "(no backup made... OK)"
      ;;
    esac
  fi
}

rstrt_e() {
  if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    enlightenment_remote -restart
    if [ -x /usr/bin/spd-say ]; then
      spd-say --language Rob 'enlightenment is awesome'
    fi
  fi
}

build_plain() {
  chk_path

  beep_attention
  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for I in $PROG_MN; do
    cd $ESRC/e26/$I
    printf "\n$BLD%s $OFF%s\n\n" "Building $I..."

    case $I in
    efl)
      meson -Dbuild-examples=false -Dbuild-tests=false \
        -Dlua-interpreter=lua -Dbindings= \
        build
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson build
      ninja -C build || mng_err
      ;;
    edi)
      meson -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib \
        build
      ninja -C build
      ;;
    *)
      meson build
      ninja -C build
      ;;
    esac

    beep_attention
    $SNIN
    sudo ldconfig
  done
}

rebuild_plain() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  rm -rf build
  meson -Dexample=false -Dbuildtype=plain \
    build
  ninja -C build
  $SNIN
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e26/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull
    rm -rf build
    echo

    case $I in
    efl)
      meson -Dbuild-examples=false -Dbuild-tests=false \
        -Dlua-interpreter=lua -Dbindings= \
        build
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson build
      ninja -C build || mng_err
      ;;
    edi)
      meson -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib \
        build
      ninja -C build
      ;;
    *)
      meson build
      ninja -C build
      ;;
    esac

    beep_attention
    $SNIN
    sudo ldconfig

    elap_stop
  done
}

rebuild_optim() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  echo
  sudo chown $USER build/.ninja*
  meson --reconfigure -Dexample=false -Dbuildtype=release \
    build
  ninja -C build
  $SNIN
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e26/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull

    case $I in
    efl)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dnative-arch-optimization=true -Dfb=true -Dharfbuzz=true \
        -Dlua-interpreter=lua -Delua=true -Dbindings=lua,cxx -Dbuild-tests=false \
        -Dbuild-examples=false -Devas-loaders-disabler= -Dbuildtype=release \
        build
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dbuildtype=release \
        build
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib \
        -Dbuildtype=release \
        build
      ninja -C build
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dbuildtype=release \
        build
      ninja -C build
      ;;
    esac

    $SNIN
    sudo ldconfig

    elap_stop
  done
}

rebuild_wld() {
  if [ "$XDG_SESSION_TYPE" == "tty" ] && [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$BDR%s $OFF%s\n\n" "PLEASE LOG IN TO THE DEFAULT DESKTOP ENVIRONMENT TO EXECUTE THIS SCRIPT."
    beep_exit
    exit 1
  fi

  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  echo
  sudo chown $USER build/.ninja*
  meson --reconfigure -Dexample=false -Dbuildtype=release \
    build
  ninja -C build
  $SNIN
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e26/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull

    case $I in
    efl)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dnative-arch-optimization=true -Dfb=true -Dharfbuzz=true \
        -Dlua-interpreter=lua -Delua=true -Dbindings=lua,cxx -Ddrm=true \
        -Dwl=true -Dopengl=es-egl -Dbuild-tests=false -Dbuild-examples=false \
        -Devas-loaders-disabler= -Dbuildtype=release \
        build
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dwl=true -Dbuildtype=release \
        build
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib \
        -Dbuildtype=release \
        build
      ninja -C build
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson --reconfigure -Dbuildtype=release \
        build
      ninja -C build
      ;;
    esac

    $SNIN
    sudo ldconfig

    elap_stop
  done
}

do_tests() {
  if [ -x /usr/bin/wmctrl ]; then
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
      wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    fi
  fi

  printf "\n\n$BLD%s $OFF%s\n" "System check..."

  if systemd-detect-virt -q --container; then
    printf "\n$BDR%s %s\n" "ELLUMINATE IS NOT INTENDED FOR USE INSIDE CONTAINERS."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi

  if [ $DISTRO == jammy ]; then
    printf "\n$BDG%s $OFF%s\n\n" "Ubuntu ${DISTRO^}... OK"
    sleep 1
  else
    printf "\n$BDR%s $OFF%s\n\n" "UNSUPPORTED OPERATING SYSTEM [ $(lsb_release -d | cut -f2) ]."
    beep_exit
    exit 1
  fi

  git ls-remote https://git.enlightenment.org/core/efl.git HEAD &>/dev/null
  if [ $? -ne 0 ]; then
    printf "\n$BDR%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$BDR%s $OFF%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    beep_exit
    exit 1
  fi

  [[ ! -d $HOME/.local/bin ]] && mkdir -p $HOME/.local/bin

  [[ ! -d $HOME/.cache/ebuilds ]] && mkdir -p $HOME/.cache/ebuilds
}

do_bsh_alias() {
  if [ ! -f $HOME/.bash_aliases ]; then
    touch $HOME/.bash_aliases

    cat >$HOME/.bash_aliases <<EOF
    # ----------------
    # GLOBAL VARIABLES
    # ----------------

    # Compiler and linker flags added by ELLUMINATE.
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

    # Parallel build.
    export MAKE="make -j$(($(nproc) * 2))"

    # This script adds the ~/.local/bin directory to your PATH environment variable if required.
EOF

    source $HOME/.bash_aliases
  fi
}

set_p_src() {
  echo
  beep_attention
  # Do not append a trailing slash (/) to the end of the path prefix.
  read -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/riley/Documents or /home/riley/testing): " mypath
  mkdir -p "$mypath"/sources
  ESRC="$mypath"/sources
  echo $ESRC >$HOME/.cache/ebuilds/storepath
  printf "\n%s\n\n" "You have chosen: $ESRC"
  sleep 2
}

get_preq() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  cd $DLDIR
  wget -c https://github.com/rockowitz/ddcutil/archive/refs/tags/v$DDTL.tar.gz
  tar xzvf v$DDTL.tar.gz -C $ESRC
  cd $ESRC/ddcutil-$DDTL
  $AUTGN
  make
  sudo make install
  rm -rf $DLDIR/v$DDTL.tar.gz
  echo

  cd $ESRC
  git clone https://github.com/Samsung/rlottie.git
  cd $ESRC/rlottie
  meson -Dexample=false -Dbuildtype=plain \
    build
  ninja -C build
  $SNIN
  sudo ldconfig
  echo
}

do_lnk() {
  sudo ln -sf /usr/local/etc/enlightenment/sysactions.conf /etc/enlightenment/sysactions.conf
  sudo ln -sf /usr/local/etc/enlightenment/system.conf /etc/enlightenment/system.conf
  sudo ln -sf /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
}

install_now() {
  clear
  printf "\n$BDG%s $OFF%s\n\n" "* INSTALLING ENLIGHTENMENT DESKTOP: PLAIN BUILD *"
  beep_attention
  do_bsh_alias
  bin_deps
  set_p_src
  get_preq

  cd $HOME
  mkdir -p $ESRC/e26
  cd $ESRC/e26

  printf "\n\n$BLD%s $OFF%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $CLONEFL
  echo
  $CLONETY
  echo
  $CLONE26
  echo
  $CLONEPH
  echo
  $CLONERG
  echo
  $CLONEVI
  echo
  $CLONEXP
  echo
  $CLONECR
  echo
  $CLONEVE
  echo
  $CLONEDI
  echo
  printf "\n\n$BLD%s $OFF%s\n\n" "Fetching source code from vtorri's github repo..."
  $CLONENT
  echo

  ls_dir
  build_plain

  printf "\n%s\n\n" "Almost done..."

  mkdir -p $HOME/.elementary/themes

  sudo mkdir -p /etc/enlightenment
  do_lnk

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  m_bkp
  p_bkp

  sudo updatedb
  beep_ok

  printf "\n\n$BDY%s %s" "Initial setup wizard tips:"
  printf "\n$BDY%s %s" "“Update checking” —— you can disable this feature because it serves no useful purpose."
  printf "\n$BDY%s $OFF%s\n\n\n" "“Network management support” —— Connman is not needed (ignore the warning message)."
  # Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Desktop, you can safely delete them if it bothers you.

  echo
  cowsay "Now reboot your computer then select Enlightenment on the login screen... \
  That's All Folks!" | lolcat -a
  echo

  cp -f $DLDIR/elluminate.sh $HOME/.local/bin
}

update_go() {
  clear
  printf "\n$BDG%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: PLAIN BUILD *"

  cp -f $SCRFLR/elluminate.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/elluminate.sh
  sleep 1

  rebuild_plain

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  if [ -f /usr/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment.desktop
  fi

  sudo updatedb
  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo
}

release_go() {
  clear
  printf "\n$BDP%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: RELEASE BUILD *"

  cp -f $SCRFLR/elluminate.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/elluminate.sh
  sleep 1

  rebuild_optim

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  if [ -f /usr/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment.desktop
  fi

  sudo updatedb
  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo
}

wld_go() {
  clear
  printf "\n$BDY%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: WAYLAND BUILD *"

  cp -f $SCRFLR/elluminate.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/elluminate.sh
  sleep 1

  rebuild_wld

  sudo mkdir -p /usr/share/wayland-sessions
  sudo ln -sf /usr/local/share/wayland-sessions/enlightenment.desktop \
    /usr/share/wayland-sessions/enlightenment.desktop

  sudo updatedb
  beep_ok

  if [ "$XDG_SESSION_TYPE" == "x11" ] || [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo
    cowsay -f www "Now log out of your existing session and press Ctrl+Alt+F3 to switch to tty3, \
        then enter your credentials and type: enlightenment_start" | lolcat -a
    echo
    # Wait a few seconds for the Wayland session to start.
    # When you're done, type exit
    # Pressing Ctrl+Alt+F1 will bring you back to the login screen.
  else
    echo
    cowsay -f www "That's it. Now type: enlightenment_start"
    echo
    # If Enlightenment fails to start, relaunch the script and select option 3.
    # After the build is complete type exit, then go back to the login screen.
  fi
}

main() {
  trap '{ printf "\n$BDR%s $OFF%s\n\n" "KEYBOARD INTERRUPT."; exit 130; }' INT

  INPUT=0
  printf "\n$BLD%s $OFF%s\n" "Please enter the number of your choice:"

  if [ ! -x /usr/local/bin/enlightenment_start ]; then
    menu_sel
  else
    sel_menu
  fi

  if [ $INPUT == 1 ]; then
    do_tests
    install_now
  elif [ $INPUT == 2 ]; then
    do_tests
    update_go
  elif [ $INPUT == 3 ]; then
    do_tests
    release_go
  elif [ $INPUT == 4 ]; then
    do_tests
    wld_go
  else
    beep_exit
    exit 1
  fi
}

main
