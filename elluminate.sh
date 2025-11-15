#!/bin/bash
# shellcheck disable=SC1091 disable=SC2164 disable=SC2126

# This script makes it easy to install or update Enlightenment and other applications
# based on the Enlightenment Foundation Libraries (EFL) on your Ubuntu, Kubuntu,
# or Xubuntu LTS desktop system.

# Supported distribution: Jammy Jellyfish.

# ELLUMINATE.SH takes care of downloading, configuring, and building everything
# you need to enjoy the very latest version of the Enlightenment environment
# (DEB packages——if they exist——often lag far behind). Once installed,
# you can update your Enlightenment desktop whenever you like.

# In order not to force our existing users to reinstall everything from scratch,
# the (legacy) directory name “e26” is kept as it was before the transition
# to “e27” (Enlightenment 0.27).

# Optional: Additional steps may be taken to achieve optimal results.
# Please refer to the comments of the build_plain() function.

# Tip: Set your terminal scrollback to unlimited, so that you can always scroll up
# to see the previous output.

# See README.md for instructions on how to use this script.
# See also the repository's wiki for post-installation hints.

# Heads up!
# Enlightenment programs compiled from git source code will inevitably conflict
# with those installed from DEB packages. Therefore, remove all previous
# binary installations of EFL, Enlightenment, and related applications
# before running this script.

# Also note that ELLUMINATE.SH is not compatible with non-standard package managers such as Nix.

# We recommend that you perform a complete uninstall of your Enlightenment desktop if you plan
# to upgrade your system to the newer LTS version of the distribution,
# to ensure a smooth reinstallation of the environment afterwards.

# ELLUMINATE.SH is licensed under a Creative Commons Attribution 4.0 International License,
# in memory of Aaron Swartz.
# See https://creativecommons.org/licenses/by/4.0/

# If you find our scripts useful, please consider starring our repositories or
# donating via PayPal (see README.md) to show your support. Thank you!

# --- Color and formatting ---
green_bright="\e[1;38;5;118m"
magenta_bright="\e[1;38;5;201m"
orange_bright="\e[1;38;5;208m"
yellow_bright="\e[1;38;5;226m"
blue_bright="\e[1;38;5;74m"
red_bright="\e[1;38;5;1m"
green_dim="\e[2;38;5;118m"
magenta_dim="\e[2;38;5;201m"
orange_dim="\e[2;38;5;208m"
bold="\e[1m"
italic="\e[3m"
off="\e[0m"

# --- Paths and aliases ---
PREFIX=/usr/local
dldir=$(xdg-user-dir DOWNLOAD)
docdir=$(xdg-user-dir DOCUMENTS)
scrflr=$HOME/.elluminate
rebasef="git config pull.rebase false"
autgn="./autogen.sh --prefix=$PREFIX"
snin="sudo ninja -C build install"
smil="sudo make install"
distro=$(lsb_release -sc)
ddctl=2.2.3

# --- Build dependencies, recommended and script-related packages ---
deps=(
  arc-theme
  aspell
  bear
  build-essential
  ccache
  check
  cmake
  cowsay
  doxygen
  fonts-noto
  freeglut3-dev
  graphviz
  gstreamer1.0-libav
  gstreamer1.0-plugins-bad
  gstreamer1.0-plugins-good
  gstreamer1.0-plugins-ugly
  hwdata
  i2c-tools
  imagemagick
  libaom-dev
  libasound2-dev
  libavahi-client-dev
  libavif-dev
  libblkid-dev
  libbluetooth-dev
  libclang-11-dev
  libegl1-mesa-dev
  libexif-dev
  libfontconfig-dev
  libdrm-dev
  libfreetype-dev
  libfribidi-dev
  libgbm-dev
  libgeoclue-2-dev
  libgif-dev
  libgraphviz-dev
  libgstreamer1.0-dev
  libgstreamer-plugins-base1.0-dev
  libharfbuzz-dev
  libheif-dev
  libi2c-dev
  libibus-1.0-dev
  libinput-dev
  libinput-tools
  libjansson-dev
  libjpeg-dev
  libjson-c-dev
  libkmod-dev
  liblua5.2-dev
  liblz4-dev
  libmenu-cache-dev
  libmount-dev
  libopenjp2-7-dev
  libosmesa6-dev
  libpam0g-dev
  libpoppler-cpp-dev
  libpoppler-dev
  libpoppler-private-dev
  libpulse-dev
  libraw-dev
  librsvg2-dev
  libsdl1.2-dev
  libscim-dev
  libsndfile1-dev
  libspectre-dev
  libssl-dev
  libsystemd-dev
  libtiff5-dev
  libtool
  libudev-dev
  libudisks2-dev
  libunibreak-dev
  libunwind-dev
  libusb-1.0-0-dev
  libwebp-dev
  libxcb-keysyms1-dev
  libxcursor-dev
  libxinerama-dev
  libxkbcommon-x11-dev
  libxkbfile-dev
  lxmenu-data
  libxrandr-dev
  libxss-dev
  libxtst-dev
  libyuv-dev
  lolcat
  manpages-dev
  manpages-posix-dev
  meson
  ninja-build
  papirus-icon-theme
  texlive-base
  texlive-font-utils
  unity-greeter-badges
  valgrind
  wayland-protocols
  wmctrl
  xdotool
  xserver-xephyr
  xwayland
)

# --- Source repositories of Enlightenment programs ---
clonefl="git clone https://git.enlightenment.org/enlightenment/efl.git"
clonety="git clone https://git.enlightenment.org/enlightenment/terminology.git"
clone26="git clone https://git.enlightenment.org/enlightenment/enlightenment.git"
cloneph="git clone https://git.enlightenment.org/enlightenment/ephoto.git"
clonerg="git clone https://git.enlightenment.org/enlightenment/rage.git"
clonevi="git clone https://git.enlightenment.org/enlightenment/evisum.git"
clonexp="git clone https://git.enlightenment.org/enlightenment/express.git"
clonecr="git clone https://git.enlightenment.org/enlightenment/ecrire.git"
cloneve="git clone https://git.enlightenment.org/enlightenment/enventor.git"
clonedi="git clone https://git.enlightenment.org/enlightenment/edi.git"
clonent="git clone https://git.enlightenment.org/vtorri/entice.git"
cloneft="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-forecasts.git"
clonepn="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-penguins.git"
clonepl="git clone https://git.enlightenment.org/enlightenment/enlightenment-module-places.git"
clonete="git clone https://github.com/dimmus/eflete.git"

# --- Programs to be built using the Meson build system ---
prog_mn=(
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
  eflete
)

# --- Audible feedback on most systems ---
beep_attention() {
  aplay --quiet /usr/share/sounds/sound-icons/percussion-50.wav 2>/dev/null
}

beep_complete() {
  aplay --quiet /usr/share/sounds/sound-icons/glass-water-1.wav 2>/dev/null
}

beep_exit() {
  aplay --quiet /usr/share/sounds/sound-icons/pipe.wav 2>/dev/null
}

beep_ok() {
  aplay --quiet /usr/share/sounds/sound-icons/trumpet-12.wav 2>/dev/null
}

beep_question() {
  aplay --quiet /usr/share/sounds/sound-icons/guitar-13.wav 2>/dev/null
}

# --- Menu hints and prompts ---
# 1: A no-frills, plain build.
# 2: A feature-rich, decently optimized build on Xorg; recommended for most users.
# 3: Similar to the above, but running Enlightenment as a Wayland compositor is still considered experimental.
# Avoid the third option with Nvidia drivers.
menu_selec() {
  is_einstl=$1

  echo
  if [ "$is_einstl" == false ]; then
    printf "1  $green_bright%s $off%s\n\n" "INSTALL the Enlightenment ecosystem now" | pv -qL 20
    printf "2  $magenta_dim%s $off%s\n\n" "(Update and rebuild the ecosystem in release mode)" | pv -qL 30
    printf "3  $orange_dim%s $off%s\n\n" "(Update and rebuild the ecosystem with Wayland support)" | pv -qL 30
  else
    printf "1  $green_dim%s $off%s\n\n" "(Install the Enlightenment ecosystem now)" | pv -qL 30
    printf "2  $magenta_bright%s $off%s\n\n" "Update and rebuild the ecosystem in RELEASE mode" | pv -qL 20
    printf "3  $orange_bright%s $off%s\n\n" "Update and rebuild the ecosystem with WAYLAND support" | pv -qL 24
  fi

  sleep 1 && printf "$italic%s $off%s\n\n" "Or press Ctrl+C to quit."
  read -r usr_input
}

# --- Disk space check ---
disk_spc() {
  free_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')

  if [ "$free_space" -lt 3 ]; then
    printf "\n$red_bright%s %s\n" "INSUFFICIENT DISK SPACE. AT LEAST 3 GB REQUIRED."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

# --- Binary dependencies check ---
bin_deps() {
  if ! sudo apt install "${deps[@]}"; then
    printf "\n$red_bright%s %s\n" "CONFLICTING OR MISSING DEB PACKAGES"
    printf "$red_bright%s %s\n" "OR DPKG DATABASE IS LOCKED."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

# --- Source dependencies check ---
cnt_dir() {
  count=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)

  if [ ! -d efl ] || [ ! -d enlightenment ]; then
    printf "\n$red_bright%s %s\n" "FAILED TO DOWNLOAD MAIN COMPONENT."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
  # Tip: You can try to download the missing file(s) manually (see clonefl or clone26),
  # then rerun the script and select option 1 again; or relaunch the script at a later time.
  # In both cases, be sure to enter the same path for the Enlightenment source folders as you used before.

  case $count in
  15)
    printf "$green_bright%s $off%s\n\n" "All programs have been downloaded successfully."
    beep_complete
    sleep 2
    ;;
  0)
    printf "\n$red_bright%s %s\n" "OOPS! SOMETHING WENT WRONG."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
    ;;
  *)
    printf "\n$yellow_bright%s %s\n" "WARNING: ONLY $count OF 15 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$yellow_bright%s $off%s\n\n" "WAIT 12 SECONDS OR HIT CTRL+C TO EXIT NOW."
    beep_attention
    sleep 12
    ;;
  esac
}

# --- Error handler ---
mng_err() {
  printf "\n$red_bright%s $off%s\n\n" "BUILD ERROR——TRY AGAIN LATER."
  beep_exit
  exit 1
}

# --- Backup Enlightenment and Terminology settings ---
e_bkp() {
  tstamp=$(date +%s)

  if [ -d "$docdir/ebackups" ]; then
    rm -rf "$docdir/ebackups"

    mkdir -p "$docdir/ebackups/e_$tstamp" "$docdir/ebackups/eterm_$tstamp"
    cp -aR "$HOME/.elementary" "$HOME/.e" "$docdir/ebackups/e_$tstamp" &>/dev/null
    cp -aR "$HOME/.config/terminology" "$docdir/ebackups/eterm_$tstamp" &>/dev/null

    sleep 2
  fi
  # Timestamp: See the date man page to convert epoch to a human-readable date
  # or visit https://www.epochconverter.com/
  # To restore a backup, use the same commands that were run, but with the source
  # and destination reversed, similar to this, in a terminal:
  # cp -aR /home/riley/Documents/ebackups/e_1747988712/.elementary/ /home/riley/
  # cp -aR /home/riley/Documents/ebackups/e_1747988712/.e/ /home/riley/
  # cp -aR /home/riley/Documents/ebackups/eterm_1747988712/terminology/config/ /home/riley/.config/terminology/
  # cp -aR /home/riley/Documents/ebackups/eterm_1747988712/terminology/themes/ /home/riley/.config/terminology/
  # Then close the terminal and press Ctrl+Alt+End to restart Enlightenment if you are logged in.
}

# --- User interaction tokens ---
e_tokens() {
  printf '%(%s)T\n' -1 >>"$HOME/.cache/ebuilds/etokens"
  mapfile -t lines <"$HOME/.cache/ebuilds/etokens"
  token=${#lines[@]}

  if [[ "$token" -eq 10 ]]; then
    printf "\n$blue_bright%s %s" "Thank you $LOGNAME, for your trust and fidelity!"
    printf "\n$blue_bright%s $off%s\n\n" "Looks like you're on the right track..."
    sleep 2
    sl | lolcat
    sleep 2
  elif [[ "$token" -gt 4 ]]; then
    echo
    # Questions: Enter either y or n, or press Enter to accept the default value (capital letter).
    beep_question
    read -r -t 12 -p "Do you want to back up your Enlightenment and Terminology settings now? [y/N] " answer
    case $answer in
    y | Y)
      e_bkp
      printf "\n$italic%s $off%s\n\n" "(Done... OK)"
      ;;
    n | N)
      printf "\n$italic%s $off%s\n\n" "(No backup made... OK)"
      ;;
    *)
      printf "\n$italic%s $off%s\n\n" "(No backup made... OK)"
      ;;
    esac
  fi
}

# --- Restart Enlightenment session ---
rstrt_e() {
  if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    enlightenment_remote -restart
    if [ -x /usr/bin/spd-say ]; then
      spd-say --language Rob 'enlightenment is awesome'
    fi
  fi
}

# --- Build plain mode ---
build_plain() {
# Add optional JXL support before executing the script?
# JPEG XL currently has to be compiled from source.
# If you need jxl support in efl, please follow the instructions below:
# https://gist.github.com/batden/0f45f8b8578ec70ee911b920b6eacd39
# Then change the option “-Devas-loaders-disabler=jxl” to “-Devas-loaders-disabler=” (no value at the end)
# whenever it's applicable.

  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for i in "${prog_mn[@]}"; do
    cd "$esrc/e26/$i"
    printf "\n$bold%s $off%s\n\n" "Building $i..."

    case $i in
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
    *)
      meson setup build -Dbuildtype=plain
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

# --- Optimized rebuild (Xorg) ---
rebuild_optim() {
  esrc=$(cat "$HOME/.cache/ebuilds/storepath")

  bin_deps
  e_tokens
  chk_ddctl

  cd "$esrc/rlottie"
  printf "\n$bold%s $off%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $rebasef && git pull
  echo
  sudo chown "$USER" build/.ninja*
  meson setup --reconfigure build -Dbuildtype=release \
    -Dexample=false
  ninja -C build
  beep_attention
  $snin
  sudo ldconfig

  for i in "${prog_mn[@]}"; do

    cd "$esrc/e26/$i"
    printf "\n$bold%s $off%s\n\n" "Updating $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

    case $i in
    efl)
      sudo chown "$USER" build/.ninja*
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
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=false
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    *)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

# --- Optimized rebuild (Wayland) ---
rebuild_wld() {
  esrc=$(cat "$HOME/.cache/ebuilds/storepath")

  if [ "$XDG_SESSION_TYPE" == "tty" ] && [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$red_bright%s $off%s\n\n" "PLEASE LOG IN TO THE DEFAULT DESKTOP ENVIRONMENT TO EXECUTE THIS SCRIPT."
    beep_exit
    exit 1
  fi

  bin_deps
  e_tokens
  chk_ddctl

  cd "$esrc/rlottie"
  printf "\n$bold%s $off%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $rebasef && git pull
  echo
  sudo chown "$USER" build/.ninja*
  meson setup --reconfigure build -Dbuildtype=release \
    -Dexample=false
  ninja -C build
  beep_attention
  $snin
  sudo ldconfig

  for i in "${prog_mn[@]}"; do

    cd "$esrc/e26/$i"
    printf "\n$bold%s $off%s\n\n" "Updating $i..."
    git reset --hard &>/dev/null
    $rebasef && git pull

    case $i in
    efl)
      sudo chown "$USER" build/.ninja*
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
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dwl=true
      ninja -C build || mng_err
      ;;
    edi)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release \
        -Dlibclang-headerdir=/usr/lib/llvm-11/include \
        -Dlibclang-libdir=/usr/lib/llvm-11/lib
      ninja -C build
      ;;
    *)
      sudo chown "$USER" build/.ninja*
      meson setup --reconfigure build -Dbuildtype=release
      ninja -C build
      ;;
    esac

    beep_attention
    $snin
    sudo ldconfig
  done
}

# --- System checks ---
do_tests() {
  if [ -x /usr/bin/wmctrl ]; then
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
      wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    fi
  fi

  printf "\n\n$bold%s $off%s\n" "System checks..."

  if systemd-detect-virt -q --container; then
    printf "\n$red_bright%s %s\n" "ELLUMINATE IS NOT INTENDED FOR USE INSIDE CONTAINERS."
    printf "$red_bright%s $off%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi

  if [ "$distro" == jammy ]; then
    printf "\n$green_bright%s $off%s\n\n" "Ubuntu ${distro^}... OK"
    sleep 1
  else
    printf "\n$red_bright%s $off%s\n\n" "UNSUPPORTED OPERATING SYSTEM [ $(lsb_release -d | cut -f2) ]."
    beep_exit
    exit 1
  fi

  if ! git ls-remote https://git.enlightenment.org/enlightenment/efl.git HEAD &>/dev/null; then
    printf "\n$red_bright%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$red_bright%s $off%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    beep_exit
    exit 1
  fi

  if [[ ! -d "$HOME/.local/bin" ]]; then
    mkdir -p "$HOME/.local/bin"
  fi

  if [[ ! -d "$HOME/.cache/ebuilds" ]]; then
    mkdir -p "$HOME/.cache/ebuilds"
  fi
}

# --- Create bash_aliases file ---
do_bsh_alias() {
  if [ -f "$HOME/.bash_aliases" ]; then
    mv -vb "$HOME/.bash_aliases" "$HOME/.bash_aliases_bak"
    echo
    touch "$HOME/.bash_aliases"
  else
    touch "$HOME/.bash_aliases"
  fi

  cat >"$HOME/.bash_aliases" <<EOF
    # Compiler and linker flags added by ELLUMINATE.
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=9
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

  source "$HOME/.bash_aliases"
}

# --- Set path for Enlightenment source folders ---
set_p_src() {
  echo
  beep_attention

  # Do not append a trailing slash (/) to the end of the path prefix.
  read -r -p "Please enter a path for the Enlightenment source folders \
  (e.g. /home/$LOGNAME/Documents or /home/$LOGNAME/testing): " mypath

  if [[ ! "$mypath" =~ ^/home/$LOGNAME.* ]]; then
    printf "\n$red_bright%s $off%s\n\n" "PATH MUST BE WITHIN YOUR HOME DIRECTORY (/home/$LOGNAME)."
    beep_exit
    exit 1
  fi

  echo
  read -r -p "Create directory $mypath/sources? [Y/n] " confirm

  if [[ $confirm =~ ^[Nn]$ ]]; then
    beep_exit
    exit 1
  fi

  mkdir -p "$mypath"/sources
  p_srcdir="$mypath"/sources
  echo "$p_srcdir" >"$HOME/.cache/ebuilds/storepath"
  printf "\n$green_bright%s $off%s\n\n" "You have chosen: $p_srcdir"
  sleep 1
}

# --- Fetch and install prerequisites ---
get_preq() {
  esrc=$(cat "$HOME/.cache/ebuilds/storepath")

  printf "\n\n$bold%s $off%s\n\n" "Installing prerequisites..."
  cd "$dldir"

  # See the ddcutil man page or visit https://www.ddcutil.com/commands/ for more information.
  wget https://github.com/rockowitz/ddcutil/archive/refs/tags/v$ddctl.tar.gz

  tar xzvf v$ddctl.tar.gz -C "$esrc"
  cd "$esrc/ddcutil-$ddctl"
  $autgn
  make
  $smil
  sudo ldconfig
  rm -rf "$dldir/v$ddctl.tar.gz"
  echo

  cd "$esrc"
  git clone https://github.com/Samsung/rlottie.git
  cd "$esrc/rlottie"
  meson setup build -Dbuildtype=plain \
    -Dexample=false
  ninja -C build
  $snin
  sudo ldconfig
  echo
}

# --- Ensure that Enlightenment system files are correctly installed ---
mv_sysfiles() {
  sudo mkdir -p /etc/enlightenment
  sudo mv -f /usr/local/etc/enlightenment/sysactions.conf /etc/enlightenment/sysactions.conf
  sudo mv -f /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
  sudo mv -f /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop
}

chk_pv() {
  if [ ! -x /usr/bin/pv ]; then
    printf "\n$bold%s $off%s\n\n" "Installing the pv command for menu animation..."
    sudo apt install -y pv
  fi
}

chk_sl() {
  if [ ! -x /usr/games/sl ]; then
    printf "\n$bold%s $off%s\n\n" "Installing the sl command for special animation..."
    sudo apt install -y sl
  fi
}

chk_ddctl() {
  if [ -d "$esrc/ddcutil-2.2.0" ]; then
    printf "\n$bold%s $off%s\n" "Updating ddcutil..."
    cd "$esrc/ddcutil-2.2.0"
    sudo make uninstall &>/dev/null
    cd .. && rm -rf "$esrc/ddcutil-2.2.0"
    cd "$dldir"
    wget https://github.com/rockowitz/ddcutil/archive/refs/tags/v$ddctl.tar.gz
    tar xzvf "v$ddctl.tar.gz" -C "$esrc"
    cd "$esrc/ddcutil-$ddctl"
    $autgn
    make
    $smil
    sudo ldconfig
    rm -rf "$dldir/v$ddctl.tar.gz"
    echo
  fi
}

install_now() {
  clear
  printf "\n$green_bright%s $off%s\n\n" "* INSTALLING ENLIGHTENMENT DESKTOP ENVIRONMENT: PLAIN BUILD ON XORG SERVER *"
  do_bsh_alias
  beep_attention
  bin_deps
  set_p_src
  get_preq

  cd "$HOME"
  mkdir -p "$esrc/e26"
  cd "$esrc/e26"

  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $clonefl
  echo
  $clonety
  echo
  $clone26
  echo
  $cloneph
  echo
  $clonerg
  echo
  $clonevi
  echo
  $clonexp
  echo
  $clonecr
  echo
  $cloneve
  echo
  $clonedi
  echo
  $clonent
  echo
  $cloneft
  echo
  $clonepn
  echo
  $clonepl
  printf "\n\n$bold%s $off%s\n\n" "Fetching source code from Dimmus' git repository..."
  $clonete
  echo

  cnt_dir
  build_plain
  mv_sysfiles

  if [ -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/local/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  if [ -f /usr/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  # Doxygen outputs HTML-based (as well as LaTeX-formatted) documentation. Click on e26/efl/build/html/index.html
  # to open the HTML documentation in your browser.
  # This takes a while to build, but it's a one-time thing.
  printf "\n\n$bold%s $off%s\n\n" "Generating the documentation for EFL..."
  sleep 1
  cd "$esrc/e26/efl/build/doc"
  doxygen

  # This will protect the file from accidental deletion.
  sudo chattr +i "$HOME/.cache/ebuilds/storepath"

  printf "\n%s\n\n" "All done!"
  beep_ok

  printf "\n\n$blue_bright%s %s" "INITIAL SETUP WIZARD TIPS:"
  printf "\n$blue_bright%s %s" '“Enable update checking” — You can disable this feature as it is not helpful for this type of installation.'
  printf "\n$blue_bright%s $off%s\n\n" '“Network management support” — Connman is not required. You can ignore the message that appears.'

  # Note: Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Desktop, you can safely delete them if it bothers you.

  echo
  cowsay "Now log out of your existing session, then select Enlightenment on the login screen... \
  That's All Folks!" | lolcat -a
  echo

  cp -f "$dldir/elluminate.sh" "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/elluminate.sh"

  exit 0
}

release_go() {
  clear
  printf "\n$magenta_bright%s $off%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON XORG SERVER *"

  # Check for available updates of the script folder first.
  cd "$scrflr" && git pull &>/dev/null
  cp -f elluminate.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/elluminate.sh"
  sleep 1

  rebuild_optim

  sudo mv -f /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop &>/dev/null

  if [ -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/local/share/wayland-sessions/enlightenment-wayland.desktop
  fi

  if [ -f /usr/share/wayland-sessions/enlightenment-wayland.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment-wayland.desktop
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
  printf "\n$orange_bright%s $off%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP ENVIRONMENT: RELEASE BUILD ON WAYLAND *"

  # Check for available updates of the script folder first.
  cd "$scrflr" && git pull &>/dev/null
  cp -f elluminate.sh "$HOME/.local/bin"
  chmod +x "$HOME/.local/bin/elluminate.sh"
  sleep 1

  rebuild_wld

  sudo mkdir -p /usr/share/wayland-sessions
  sudo mv -f /usr/local/share/wayland-sessions/enlightenment-wayland.desktop \
    /usr/share/wayland-sessions/enlightenment-wayland.desktop &>/dev/null

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
    # After the build is complete, type exit, then go back to the login screen.
  fi

  exit 0
}

# --- First, display the selection menu... ---
lo() {
  trap '{ printf "\n$red_bright%s $off%s\n\n" "KEYBOARD INTERRUPT."; exit 130; }' SIGINT

  usr_input=0
  printf "\n$bold%s $off%s\n" "Please enter the number of your choice:"

  if [ ! -x /usr/local/bin/enlightenment_start ]; then
    menu_selec false
  else
    menu_selec true
  fi
}

# --- Then get the user's choice ---
and_behold() {
  if [ "$usr_input" == 1 ]; then
    disk_spc
    do_tests
    install_now
  elif [ "$usr_input" == 2 ]; then
    do_tests
    release_go
  elif [ "$usr_input" == 3 ]; then
    do_tests
    wld_go
  else
    beep_exit
    exit 1
  fi
}

# --- Main entry point ---
main() {
  chk_pv
  chk_sl
  lo
  and_behold
}

main "$@"
