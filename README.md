# elluminate

A neat Bash script to build/install/update Enlightenment on Ubuntu 22.04 LTS.

Please take a look at the comments in the script before running it.

*See also [extinguish.sh](https://github.com/batden/extinguish) (companion script).*

## Get started

Before you start using elluminate, you'll need to install the packages git and sound-icons on your system.

Open a terminal window and type in the following:

```bash
sudo apt install git sound-icons
```

Next, clone this repository:

```bash
git clone https://github.com/batden/elluminate.git .elluminate
```

This creates a new hidden folder named **.elluminate** in your home directory.

Please copy the file elluminate.sh from this new folder to the download folder.

Now change to the download folder and make the script executable:

```bash
chmod +x elluminate.sh
```

Then issue the following command:

```bash
./elluminate.sh
```

On subsequent runs, open a terminal and simply type:

```bash
elluminate.sh
```

(Use auto-completion: Just type *ell* and press Tab.)

## Update local repository

Be sure to check for updates at least once a week.
In order to do this, change to ~/.elluminate/ and run:

```bash
git pull
```

That's it.

Mind the cows! :cow2: :cow2: :cow2:
