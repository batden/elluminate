# elluminate

A premium bash script to build, install, or update Enlightenment on Ubuntu 22.04 LTS.

Please refer to the script comments for hints and additional information.

> [!NOTE]
> It may be useful to keep a record of the pre-existing system status before proceeding with the installation.
>
> Check out our [backup script](https://gist.github.com/batden/993b5ee997b3df2c3b075907a1dff116).

## Installation

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

The next time you run the script, simply open a terminal and type:

```bash
elluminate.sh
```

> [!TIP]
> Use auto-completion: Type _ell_ and press the Tab key.

That's it.

## Uninstallation

You can uninstall Enlightenment and related applications from your computer at any time.

See [extinguish.sh](https://github.com/batden/extinguish).

## In the Picture

![GitHub Image](/images/enlightenment.jpg)

_Please help us continue to promote this fantastic desktop environment.
Over the years, writing bash scripts, translations, documentation, and bug reports has been a considerable effort._

[Donate with PayPal](/home/batden/Downloads/pp.png)](<https://www.paypal.com/donate/?hosted_button_id=QGXWYZWH5QP5E)[>!
