# esteem

**A neat Bash script to build and install Enlightenment 25 on Ubuntu :kiss:**

Please take a look at the comments in the script (lines beginning with '#') before running it.

*See also [meetse.sh](https://github.com/batden/meetse)*

## Get started

Before you start using esteem, you'll need to install Git on your system.

Open a terminal window and type in the following:

```bash
sudo apt install git
```

Next, clone this repository:

```bash
git clone https://github.com/batden/esteem.git .esteem
```

This creates a new hidden folder named **.esteem** in your home directory.

Please copy the file esteem.sh from this new folder to the download folder.

Now change to the download folder and make the script executable:

```bash
chmod +x esteem.sh
```

Then issue the following command:

```bash
./esteem.sh
```

On subsequent runs, open a terminal and simply type:

```bash
esteem.sh
```

(Use tab completion: Just type *est* and press Tab)

### Update local repository

Be sure to check for updates at least once a week.
In order to do this, change to ~/.esteem/ and run:

```bash
git pull
```

That's it.

Mind the cows! :cow2: :cow2: :cow2:
