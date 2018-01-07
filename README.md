[![Ruby Version](https://img.shields.io/badge/Ruby%20Version-2.3%2B-red.svg)]()
[![Patcher Revision](https://img.shields.io/badge/Patcher%20Revision-20171229-blue.svg)]()

:exclamation: This application is no longer needed for Neocron.  The updated launcher works via Wine on Linux.

This application is NOT supported by the Neocron Classic Team, nor is the Neocron Classic Team responsible for this application.  This is an application that is provided by myself, for the general public.
# Neocron Classic Patcher for Linux

So, this was my attempt at rewriting my current bash-based Neocron Classic for Linux Launcher in Ruby.  :heart: 

This version doesn't flip out on the **only** filename with a space in it, hint ``URI.escape``, and creates directories as they need to be created if the directory structure were to change.  Thus, this script can also be used to perform a new installation of a Neocron client.

To Do List:
* Ability for the patcher to pick up on deleted files (won't happen very often though I'd imagine, unless it's a huge restructure.  In that case, a new installation may be better).
* Exclude files
  * We don't want the patcher overwriting our hacks!
  * No, seriously though, the ability to exclude ``neocron.ini`` and ``rpos.ini`` for example would be beneficial.
  
# Usage
  Standard Usage:<br />
  ``patcher.rb --client=retail``<br /><br />
 
  Options:<br />
  ``--client`` The type of Neocron client (e.g. retail).  Will default to ``retail`` if nothing is specified. <br />
  ``--force`` This will force the patcher to do a file system check, and sets the local client patch level to "0".  This will also override the excluded files list!  Use with care.
  
# Requirements
  This was tested with Ruby v2.3.4, but previous versions _should_ work.  The only third-party gem used in this application is ``Trollop``, which can be installed by running ``gem install trollop``.  All other requirements are built into the standard Ruby stack.
  
  As of Revision ``20171229``, the trollop gem will automatically be installed if it's not detected.
  
# Directory Structure
This script assumes it is is placed a directory above your Neocron clients. For example, if you have the script in ```/home/<username>/Games/Neocron``` then the "RETAIL" client would be installed into ```/home/<username>/Games/Neocron/retail```

# Windows Usage
This script *can* be used to upgrade/install Neocron on Windows platforms as well.  But, you have to manually download and install Ruby.

You can download Ruby from https://rubyinstaller.org/downloads/.  I recommend the lastest v2.4.x branch as that is what this script was built on.  Run the installer, make sure the Ruby executable is added to your systems path.  You **DO NOT** need to install the MSYS2 toolkit.

If you already have the existing NCC Launcher installed to ```C:\Games\Neocron Classic\```, place the ```patcher.rb``` in ```C:\Games\Neocron Classic\clients\```.

Download the ```runNeocron.bat``` file and place it into the same directory as the ```patcher.rb```. 

To run Neocron, run the ```runNeocron.bat``` file!
You can also create a shortcut to this batch file on your desktop, change the icon, etc.
