# sage-cookbook

[Sage2](http://sage2.sagecommons.org/) installer. Made for testing sage2 on my raspberry pis.
The *Test Kitchen* is using both Debian and Ubuntu and so it should work
fine for those systems also.

SAGE2 is the Scalable Amplified Group Environment.

### What it does

This cookbook installs [sage2]() via master branch of git.  What this cookbook
does to your system:

* creates a new user and group: `sage` with home of /opt/sage
* installs sage dependencies
  * ghostscript imagemagick libcap2-bin libnss3-tools libimage-exiftool-perl git-core
  * [nodejs](https://nodejs.org/en/) using the [nodejs-cookbook](https://supermarket.chef.io/cookbooks/nodejs)
    * _Note:_ TODO: this is a bit problematic on a pi - consider this step not done
* checkouts the latest sage2 from git
* sets up the ssl certs
  * TODO: Fix this - cert creation script not making great certs for anything but localhost - right now you have to manually becomes sage user and run the cert generation scripts: `sudo su - sage -c "cd ~/keys; ./GO-linux"`
* installs all the nodejs dependencies.

### trying it out

I'm just learning how sage is supposed to operate.  I've not bothered to tackle
putting in place system services management correctly yet.

See my GIST with
[helper scripts and notes ](https://gist.github.com/dayne/f6a473bf6929517d66703dcae8ffb53e) for how I'm using this cookbook and my pi.


### Credits

This effort and cookbook inspired by the SAAGE2 blog post: [sage2 on raspberry pi 3](http://sage2.sagecommons.org/2016/03/22/sage2-on-raspberry-pi-3/).  
