#!/bin/bash

# This script allows you to easily and safely install Enlightenment, along with
# other applications based on the Enlightenment Foundation Libraries (EFL),
# in your Ubuntu, Kubuntu or Xubuntu LTS desktop system.

# Supported distribution: Jammy Jellyfish.

# ELLUMINATE.SH takes care of downloading, configuring and building everything you
# need to enjoy the very latest version of the Enlightenment environment
# (DEB packages, if they exist, tend to lag far behind). Once installed,
# you can update your Enlightenment desktop whenever you like.

# Facultative: Additional steps may be taken in order to achieve optimal results.
# Please refer to the comments of the build_plain() function.

# Tip: Set your terminal scrollback to unlimited so that you can scroll up
# to look at earlier output at any time.

# See README.md for instructions on how to use this script.
# See also the repository's wiki for post-installation hints.

# Heads up!
# Enlightenment programs compiled from git source code will inevitably come into conflict
# with the ones installed from DEB packages. Therefore, remove any previous binary
# installations of EFL, Enlightenment and related applications before running
# this script.

# We recommend doing a complete uninstallation of your Enlightenment desktop if you plan
# to upgrade your system to the newer LTS version of the distribution, in order to
# ensure a smooth reinstallation of the environment afterward.

# ELLUMINATE.SH is licensed under a Creative Commons Attribution 4.0 International License,
# in memory of Aaron Swartz.
# See https://creativecommons.org/licenses/by/4.0/

# Got a GitHub account? Please consider starring our repositories to show your support.
# Thank you!

# ---------------
# USER VARIABLES
# ---------------
# (These variables are not available to be used outside of this script.)

BLD="\e[1m"    # Bold text.
ITA="\e[3m"    # Italic text.
BDR="\e[1;31m" # Bold red text.
BDG="\e[1;32m" # Bold green text.
BTC="\e[1;96m" # Bright cyan text.
BDP="\e[1;35m" # Bold purple text.
BDY="\e[1;33m" # Bold yellow text.
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
SMIL="sudo make install"
DISTRO=$(lsb_release -sc)
DDTL=2.0.0

# Build dependencies, recommended and script-related packages.
DEPS="acpid arc-theme aspell bear build-essential ccache check cmake cowsay doxygen \
fonts-noto freeglut3-dev graphviz gstreamer1.0-libav gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly hwdata i2c-tools imagemagick \
libaom-dev libasound2-dev libavahi-client-dev libavif-dev libblkid-dev \
libbluetooth-dev libclang-11-dev libegl1-mesa-dev libexif-dev libfontconfig-dev \
libdrm-dev libfreetype-dev libfribidi-dev libgbm-dev libgeoclue-2-dev \
libgif-dev libgraphviz-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
libharfbuzz-dev libheif-dev libi2c-dev libibus-1.0-dev libinput-dev libinput-tools \
libjansson-dev libjpeg-dev libjson-c-dev libkmod-dev liblua5.2-dev liblz4-dev \
libmenu-cache-dev libmount-dev libopenjp2-7-dev libosmesa6-dev libpam0g-dev \
libpoppler-cpp-dev libpoppler-dev libpoppler-private-dev libpulse-dev libraw-dev \
librsvg2-dev libsdl1.2-dev libscim-dev libsndfile1-dev libspectre-dev \
libssl-dev libsystemd-dev libtiff5-dev libtool libudev-dev libudisks2-dev \
libunibreak-dev libunwind-dev libusb-1.0-0-dev libwebp-dev \
libxcb-keysyms1-dev libxcursor-dev libxinerama-dev libxkbcommon-x11-dev \
libxkbfile-dev lxmenu-data libxrandr-dev libxss-dev libxtst-dev libyuv-dev \
lolcat manpages-dev manpages-posix-dev meson ninja-build papirus-icon-theme \
pv texlive-base texlive-font-utils unity-greeter-badges valgrind \
wayland-protocols wmctrl xdotool xserver-xephyr xwayland"

# Latest source code available.
CLONEFL="git clone https://git.enlightenment.org/enlightenment/efl.git"
CLONETY="git clone https://git.enlightenment.org/enlightenment/terminology.git"
CLONE26="git clone https://git.enlightenment.org/enlightenment/enlightenment.git"
CLONEPH="git clone https://git.enlightenment.org/enlightenment/ephoto.git"
CLONERG="git clone https://git.enlightenment.org/enlightenment/rage.git"
CLONEVI="git clone https://git.enlightenment.org/enlightenment/evisum.git"
CLONEXP="git clone https://git.enlightenment.org/enlightenment/express.git"
CLONECR="git clone https://git.enlightenment.org/enlightenment/ecrire.git"
CLONEVE="git clone https://git.enlightenment.org/enlightenment/enventor.git"
CLONEDI="git clone https://git.enlightenment.org/enlightenment/edi.git"
CLONENT="git clone https://git.enlightenment.org/vtorri/entice.git"
CLONEFT="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts.git"
CLONEPN="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-penguins.git"
CLONEPL="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-places.git"
CLONETE="git clone https://github.com/dimmus/eflete.git"

# “MN” stands for Meson——the Meson build system.
PROG_MN="
efl
terminology
enlightenment
ephoto
rage
evisum
express
ecrire
enventor
edi
entice
enlightenment-module-forecasts
enlightenment-module-penguins
enlightenment-module-places
eflete"

# Bug reporting: Before using this script, uncomment the following (remove the leading # character)
# to force messages to display in English during the build process.
# export LC_ALL=C

# ---------
# FUNCTIONS
# ---------

# Audible feedback (event, sudo prompt...) on most systems.
beep_dl_complete() {
  aplay --quiet /usr/share/sounds/sound-icons/glass-water-1.wav 2>/dev/null
}

beep_attention() {
  aplay --quiet /usr/share/sounds/sound-icons/percussion-50.wav 2>/dev/null
}

beep_question() {
  aplay --quiet /usr/share/sounds/sound-icons/guitar-13.wav 2>/dev/null
}

beep_exit() {
  aplay --quiet /usr/share/sounds/sound-icons/pipe.wav 2>/dev/null
}

beep_ok() {
  aplay --quiet /usr/share/sounds/sound-icons/trumpet-12.wav 2>/dev/null
}

# Hints.
# 1: A no frill, plain build.
# 2: A feature-rich, decently optimized build on Xorg; recommended for most users.
# 3: Similar to the above, but running Enlightenment as a Wayland compositor is still considered experimental.
# Avoid the third option with Nvidia drivers.
#
menu_sel() {
  if [ $INPUT -lt 1 ]; then
    echo
    printf "1  $BDG%s $OFF%s\n\n" "INSTALL the Enlightenment ecosystem now" | pv -qL 20
    printf "2  $LWP%s $OFF%s\n\n" "Update and rebuild the ecosystem in release mode" | pv -qL 20
    printf "3  $LWY%s $OFF%s\n\n" "Update and rebuild the ecosystem with Wayland support" | pv -qL 20

    sleep 1 && printf "$ITA%s $OFF%s\n\n" "Or press Ctrl+C to quit."
    read INPUT
  fi
}

sel_menu() {
  if [ $INPUT -lt 1 ]; then
    echo
    printf "1  $LWG%s $OFF%s\n\n" "Install the Enlightenment ecosystem now" | pv -qL 20
    printf "2  $BDP%s $OFF%s\n\n" "Update and rebuild the ecosystem in RELEASE mode" | pv -qL 20
    printf "3  $BDY%s $OFF%s\n\n" "Update and rebuild the ecosystem with WAYLAND support" | pv -qL 20

    sleep 1 && printf "$ITA%s $OFF%s\n\n" "Or press Ctrl+C to quit."
    read INPUT
  fi
}

# Check binary dependencies.
bin_deps() {
  if ! sudo apt install $DEPS; then
    printf "\n$BDR%s %s\n" "CONFLICTING OR MISSING DEB PACKAGES"
    printf "$BDR%s %s\n" "OR DPKG DATABASE IS LOCKED."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

# Check source dependencies.
cnt_dir() {
  COUNT=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)

  if [ ! -d efl ] || [ ! -d enlightenment ]; then
    printf "\n$BDR%s %s\n" "FAILED TO DOWNLOAD MAIN COMPONENT."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
    # You can try downloading the missing file(s) manually (see CLONEFL or CLONE26), then relaunch
    # the script and select option 1 again; or relaunch the script at a later time.
    # In both cases, be sure to enter the same path for the Enlightenment source
    # folders as you previously used.
  fi

  case $COUNT in
  15)
    printf "$BDG%s $OFF%s\n\n" "All programs have been downloaded successfully."
    beep_dl_complete
    sleep 2
    ;;
  0)
    printf "\n$BDR%s %s\n" "OOPS! SOMETHING WENT WRONG."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
    ;;
  *)
    printf "\n$BDY%s %s\n" "WARNING: ONLY $COUNT OF 15 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$BDY%s $OFF%s\n\n" "WAIT 12 SECONDS OR HIT CTRL+C TO EXIT NOW."
    beep_attention
    sleep 12
    ;;
  esac
}

mng_err() {
  printf "\n$BDR%s $OFF%s\n\n" "BUILD ERROR——TRY AGAIN LATER."
  beep_exit
  exit 1
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
# To restore a backup, use the same commands that were executed but with
# the source and destination reversed, similar to this:
# cp -aR /home/riley/Documents/ebackups/E_1716048561/.elementary/ /home/riley/
# cp -aR /home/riley/Documents/ebackups/E_1716048561/.e/ /home/riley/
# cp -aR /home/riley/Documents/ebackups/ETERM_1716048561/terminology/config/ /home/riley/.config/terminology/
# cp -aR /home/riley/Documents/ebackups/ETERM_1716048561/terminology/themes/ /home/riley/.config/terminology/
# (Then press Ctrl+Alt+End to restart Enlightenment if you are currently logged into.)
#
e_bkp() {
  TSTAMP=$(date +%s)

  if [ -d $DOCDIR/ebackups ]; then
    rm -rf $DOCDIR/ebackups
    mkdir -p $DOCDIR/ebackups/E_$TSTAMP && mkdir -p $DOCDIR/ebackups/ETERM_$TSTAMP &&
      cp -aR $HOME/.elementary $DOCDIR/ebackups/E_$TSTAMP &&
      cp -aR $HOME/.e $DOCDIR/ebackups/E_$TSTAMP &&
      cp -aR $HOME/.config/terminology $DOCDIR/ebackups/ETERM_$TSTAMP
    sleep 2
  else
    mkdir -p $DOCDIR/ebackups/E_$TSTAMP && mkdir -p $DOCDIR/ebackups/ETERM_$TSTAMP &&
      cp -aR $HOME/.elementary $DOCDIR/ebackups/E_$TSTAMP &&
      cp -aR $HOME/.e $DOCDIR/ebackups/E_$TSTAMP &&
      cp -aR $HOME/.config/terminology $DOCDIR/ebackups/ETERM_$TSTAMP
    sleep 2
  fi
}

e_tokens() {
  echo $(date +%s) >>$HOME/.cache/ebuilds/etokens

  TOKEN=$(wc -l <$HOME/.cache/ebuilds/etokens)

  if [ "$TOKEN" -gt 3 ]; then
    echo
    # Questions: Enter either y or n, or press Enter to accept the default value (capital letter).
    beep_question
    read -t 12 -p "Do you want to back up your Enlightenment and Terminology settings now? [y/N] " answer
    case $answer in
    y | Y)
      e_bkp
      ;;
    n | N)
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

# BEFORE EXECUTING THE SCRIPT...
#
# Add optional JXL support?
# JPEG XL currently has to be compiled from source. If you really need jxl
# support in efl, please follow the instructions below:
# https://gist.github.com/batden/0f45f8b8578ec70ee911b920b6eacd39
#
# Then change the option “-Devas-loaders-disabler=jxl” to
# “-Devas-loaders-disabler=” whenever it's applicable.
#
build_plain() {
  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for I in $PROG_MN; do
    cd $ESRC/e26/$I
    printf "\n$BLD%s $OFF%s\n\n" "Building $I..."

    case $I in
    efl)
      meson setup build -Dbuildtype=plain \
        -Dfb=true \
        -Dbuild-tests=false \
        -Dlua-interpreter=lua \
        -Devas-loaders-disabler=jxl \
        -Dglib=true \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson setup build -Dbuildtype=plain
      ninja -C build || mng_err
      ;;
    edi)
      meson setup build -Dbuildtype=plain \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    eflete)
      meson setup build -Dbuildtype=plain \
        -Dwerror=false
      ninja -C build
      ;;
    *)
      meson setup build -Dbuildtype=plain
      ninja -C build
      ;;
    esac

    beep_attention
    $SNIN
    sudo ldconfig
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
  meson setup --reconfigure build -Dbuildtype=release \
    -Dexample=false
  ninja -C build
  beep_attention
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
      meson setup --reconfigure build -Dbuildtype=release \
        -Dnative-arch-optimization=true \
        -Dfb=true \
        -Dharfbuzz=true \
        -Dlua-interpreter=lua \
        -Delua=true \
        -Dbindings=lua,cxx \
        -Devas-loaders-disabler=jxl \
        -Dglib=true \
        -Dopengl=full \
        -Ddrm=false \
        -Dwl=false \
        -Dbuild-tests=false \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=false
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    eflete)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Denable-audio=true -Dwerror=false
      ninja -C build
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $SNIN
    sudo ldconfig

    elap_stop
  done
}

rebuild_wld() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)

  if [ "$XDG_SESSION_TYPE" == "tty" ] && [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$BDR%s $OFF%s\n\n" "PLEASE LOG IN TO THE DEFAULT DESKTOP ENVIRONMENT TO EXECUTE THIS SCRIPT."
    beep_exit
    exit 1
  fi

  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  echo
  sudo chown $USER build/.ninja*
  meson setup --reconfigure build -Dbuildtype=release \
    -Dexample=false
  ninja -C build
  beep_attention
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
      meson setup --reconfigure build -Dbuildtype=release \
        -Dnative-arch-optimization=true \
        -Dfb=true \
        -Dharfbuzz=true \
        -Dlua-interpreter=lua \
        -Delua=true \
        -Dbindings=lua,cxx \
        -Devas-loaders-disabler=jxl \
        -Dglib=true \
        -Dopengl=es-egl \
        -Ddrm=true \
        -Dwl=true \
        -Dbuild-tests=false \
        -Ddocs=true
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=true
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    eflete)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Denable-audio=true -Dwerror=false
      ninja -C build
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
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

  if ! git ls-remote http://git.enlightenment.org/enlightenment/efl.git HEAD &>/dev/null; then
    printf "\n$BDR%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$BDR%s $OFF%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    beep_exit
    exit 1
  fi

  if ! test -d "$HOME/.local/bin"; then
    mkdir -p "$HOME/.local/bin"
  fi

  if ! test -d "$HOME/.cache/ebuilds"; then
    mkdir -p "$HOME/.cache/ebuilds"
  fi
}

do_bsh_alias() {
  if [ -f $HOME/.bash_aliases ]; then
    mv -vb $HOME/.bash_aliases $HOME/.bash_aliases_bak
    echo
    touch $HOME/.bash_aliases
  else
    touch $HOME/.bash_aliases
  fi

  cat >$HOME/.bash_aliases <<EOF
    # ---------------------
    # ENVIRONMENT VARIABLES
    # ---------------------
    # (These variables can be accessed from any shell sessions.)

    # Compiler and linker flags added by ELLUMINATE.
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig

    # Keyring service workaround for Enlightenment.
    # You also need to autostart some additional services at startup for this to work:
    # See the repository's wiki (Startup Applications) for more info.
    #
    if printenv | grep -q 'XDG_CURRENT_DESKTOP=Enlightenment'; then
      export SSH_AUTH_SOCK=/run/user/${UID}/keyring/ssh
    fi
EOF

  source $HOME/.bash_aliases
}

set_p_src() {
  echo
  beep_attention

  # Do not append a trailing slash (/) to the end of the path prefix,
  # and double-check the path you entered before validating.
  #
  read -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/$LOGNAME/Documents or /home/$LOGNAME/testing): " mypath
  mkdir -p "$mypath"/sources
  SRCDIR="$mypath"/sources
  echo $SRCDIR >$HOME/.cache/ebuilds/storepath
  printf "\n%s\n\n" "You have chosen: $SRCDIR"
  sleep 2
}

# Fetch and install prerequisites.
get_preq() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)

  printf "\n\n$BLD%s $OFF%s\n\n" "Installing prerequisites..."
  cd $DLDIR

  #  See the ddcutil man page or visit https://www.ddcutil.com/commands/ for more information.
  #
  wget https://github.com/rockowitz/ddcutil/archive/refs/tags/v$DDTL.tar.gz

  tar xzvf v$DDTL.tar.gz -C $ESRC
  cd $ESRC/ddcutil-$DDTL
  $AUTGN
  make
  $SMIL
  sudo ldconfig
  rm -rf $DLDIR/v$DDTL.tar.gz
  echo

  cd $ESRC
  git clone https://github.com/Samsung/rlottie.git
  cd $ESRC/rlottie
  meson setup build -Dbuildtype=plain \
    -Dexample=false
  ninja -C build
  $SNIN
  sudo ldconfig
  echo
}

do_link() {
  sudo ln -sf /usr/local/etc/enlightenment/sysactions.conf /etc/enlightenment/sysactions.conf
  sudo ln -sf /usr/local/etc/enlightenment/system.conf /etc/enlightenment/system.conf
  sudo ln -sf /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
}

install_now() {
  clear
  printf "\n$BDG%s $OFF%s\n\n" "* INSTALLING ENLIGHTENMENT DESKTOP ENVIRONMENT: PLAIN BUILD ON XORG SERVER *"
  do_bsh_alias
  beep_attention
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
  $CLONENT
  echo
  $CLONEFT
  echo
  $CLONEPN
  echo
  $CLONEPL
  printf "\n\n$BLD%s $OFF%s\n\n" "Fetching source code from Dimmus' git repository..."
  $CLONETE
  echo

  cnt_dir
  build_plain

  # Doxygen outputs HTML-based (as well as LaTeX-formatted) documentation. Click on e26/efl/build/html/index.html
  # to open the HTML documentation in your browser.
  #
  printf "\n\n$BOLD%s $OFF%s\n\n" "Generating the documentation for EFL..."
  cd $ESRC/e26/efl/build/doc
  doxygen

  sudo mkdir -p /etc/enlightenment
  do_link

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  # Protect this file from accidental deletion.
  sudo chattr +i $HOME/.cache/ebuilds/storepath

  printf "\n%s\n\n" "All done!"
  beep_ok

  printf "\n\n$BTC%s %s" "INITIAL SETUP WIZARD TIPS:"
  printf "\n$BTC%s %s" '“Update checking” —— you can disable this feature because it serves no useful purpose.'
  printf "\n$BTC%s $OFF%s\n\n" '“Network management support” —— Connman is not needed (ignore the warning message).'

  # Note: Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Desktop, you can safely delete them if it bothers you.

  echo
  cowsay "Now log out of your existing session then select Enlightenment on the login screen... \
  That's All Folks!" | lolcat -a
  echo

  cp -f $DLDIR/elluminate.sh $HOME/.local/bin

  exit 0
}

release_go() {
  clear
  printf "\n$BDP%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON XORG SERVER *"

  # Check for available updates of the script folder first.
  cd $SCRFLR && git pull &>/dev/null
  cp -f elluminate.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/elluminate.sh
  sleep 1

  rebuild_optim

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  if [ -f /usr/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment.desktop
  fi

  if [ -f /usr/local/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/local/share/wayland-sessions/enlightenment.desktop
  fi

  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo

  exit 0
}

wld_go() {
  clear
  printf "\n$BDY%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON WAYLAND *"

  cd $SCRFLR && git pull &>/dev/null
  cp -f elluminate.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/elluminate.sh
  sleep 1

  rebuild_wld

  sudo mkdir -p /usr/share/wayland-sessions
  sudo ln -sf /usr/local/share/wayland-sessions/enlightenment.desktop \
    /usr/share/wayland-sessions/enlightenment.desktop

  beep_ok

  if [ "$XDG_SESSION_TYPE" == "x11" ] || [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo
    cowsay -f www "Now log out of your existing session and press Ctrl+Alt+F3 to switch to tty3, \
        then enter your credentials and type: enlightenment_start" | lolcat -a
    echo
    # Wait a few seconds for the Wayland session to start.
    # When you're done, type exit
    # Pressing Ctrl+Alt+F1 (or Ctrl+Alt+F7) will bring you back to the login screen.
  else
    echo
    cowsay -f www "That's it. Now type: enlightenment_start"
    echo
    # If Enlightenment fails to start, relaunch the script and select option 2.
    # After the build is complete type exit, then go back to the login screen.
  fi

  exit 0
}

chk_pv() {
  if [ ! -x /usr/bin/pv ]; then
    printf "\n$BLD%s $OFF%s\n\n" "Installing pv command for menu animation..."
    sudo apt install -y pv
  fi
}

# Lo and behold (“bhd”)!
#
# Display the selection menu...
#
lo() {
  trap '{ printf "\n$BDR%s $OFF%s\n\n" "KEYBOARD INTERRUPT."; exit 130; }' INT

  INPUT=0
  printf "\n$BLD%s $OFF%s\n" "Please enter the number of your choice:"

  if [ ! -x /usr/local/bin/enlightenment_start ]; then
    menu_sel
  else
    sel_menu
  fi
}

# and get the user's choice.
bhd() {
  if [ $INPUT == 1 ]; then
    do_tests
    install_now
  elif [ $INPUT == 2 ]; then
    do_tests
    release_go
  elif [ $INPUT == 3 ]; then
    do_tests
    wld_go
  else
    beep_exit
    exit 1
  fi
}

chk_pv
lo
bhd
