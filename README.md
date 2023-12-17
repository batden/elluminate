# elluminate

A neat Bash script to build/install/update Enlightenment on Ubuntu 22.04 LTS.

Please take a look at the comments in the script before running it.

*See also [extinguish.sh](https://github.com/batden/extinguish) (companion script).*

## Get started

Before using elluminate, you'll need to install the git and sound-icons packages on your system.

Open a terminal window and type in the following:

```bash
sudo apt install git sound-icons
```

Next, clone the repository:

```bash
git clone https://github.com/batden/elluminate.git .elluminate
```

This creates a new hidden folder named .elluminate in your home directory.

Copy the elluminate.sh file from the new .elluminate folder to your download folder.

Navigate to the download folder and make the script executable:

```bash
chmod +x elluminate.sh
```

Then execute the script with:

```bash
./elluminate.sh
```

To run it again later, open a terminal and simply type:

```bash
elluminate.sh
```

(Use auto-completion: Just type *ell* and press Tab.)

## Update local repo

Check for updates at least once a week.
To update the local repository, change to ~/.elluminate/ and run:

```bash
git pull
```
