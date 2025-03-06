# elluminate

A neat Bash script to build/install/update Enlightenment on Ubuntu 22.04 LTS.

Please take a look at the comments in the script before running it.

> [!NOTE]
> It may be useful to keep a record of the pre-existing system status before proceeding with the installation.
>
> Check out our [backup script](https://gist.github.com/batden/993b5ee997b3df2c3b075907a1dff116).

## Getting started

Before using elluminate, you may need to install the git and sound-icons packages on your system if they aren't already there.

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

Then, execute the script with:

```bash
./elluminate.sh
```

To run it again later, open a terminal and simply type:

```bash
elluminate.sh
```

> [!TIP]
> Use auto-completion: Type _ell_ and press the Tab key.

That's it.

You can uninstall Enlightenment and related applications from your computer at any time.

See [extinguish.sh](https://github.com/batden/extinguish).

## In the picture

![GitHub Image](/images/enlightenment_desktop.jpg)

_Please help us continue promoting this fantastic desktop environment.
Over the years, writing bash scripts, translations, documentation, and bug reports has been a substantial endeavour._

[Donate with PayPal](https://www.paypal.com/donate/?hosted_button_id=QGXWYZWH5QP5E) :trophy:
