# Raspberry Pi Scripts

This is just a repo that I decided to make out of spite because a bunch of morons called my bettercap script thing "skiddish" and they thought that I overcomplicated with using bash. Yes I am that petty.

For the bettercap script and such, it uses wlan1 so you will need an external adapter plugged into one of the Raspberry Pi ports. If you would like to read more on how I did this, you can consult the pwnagotchi manual install on any GNU/Linux: https://pwnagotchi.ai/installation/#installing-on-any-gnulinux

This is also how pwnagotchi works under the hood which I find really cool. Mine is pretty much identical minus the ML which I just didn't want to add. Reason I built it is because at the time I commuted by car and now by bus so I wanted to walk around with my Raspberry Pi Zero W plugged into a small power bank. After a bit of tweaks, I decided to set the channels to the Big 3 WiFi channels due to reasons such as interference, used the most, but also because the other channels would overlap with these 3 main channels. I can't recall exactly because it has been so long since I built this.

the tcpdump script is as boring as it gets, but I like it because of how simple it is. It just sniffs every packet on port eth0 because the idea was just to plug in the Raspberry Pi into an ethernet plug and if possible wall plug, leave, come back, and just pack it back up.

The same idea is with the responder script. Which I'm not so sure how effective it is these days, but I'm an idiot so who knows.

------

All scripts run on boot via service files and they work pretty well. For the responder, you need to be root to access the screen process, but in reality you probably won't do this that often except for testing.

------

Future plans:

- Add stuff like my eaphammer (Still working on that in my docker container, but can port it over.)
- Add responder to work on a possible AP (Yes you can do that, but I need to test to see if it still works on Windows.)
- Add scripts to scan the whole ip range (Will need to play around because this could require not being as detailed because of time.)

- Whatever else I concoct while sleep deprived and high on caffeine. 