# Advanced usage
This document presents detailed instructions on using the LSST binary distribution for more advanced use cases.

### How to develop your own package on top of the LSST stack
If you need to develop your own software package which depends on other packages already present on the LSST stack, or need to modify an existing package, you can proceed as presented below.

First, you need to instruct EUPS to use a database on your `$HOME` directory, in addition to the database already included in the binary distribution of the LSST stack. Let's say you are using `$HOME/eups` for this purpose. For setting up your environment (this is a one-time process) do:

* Create the EUPS database:

	```bash
	$ mkdir -p $HOME/eups/ups_db
	```
	
* Initialize the environment variable EUPS_PATH. Add to your shell profile:

	```bash
	export EUPS_PATH=$HOME/eups
	```
	
* Each time you want to work with a particular version of the stack source its bootstrap script. For instance, for working with version `12.0` on a Linux machine do:

	```bash
	$ source /cvmfs/lsst.in2p3.fr/software/linux-x86_64/lsst-v12.0/loadLSST.bash
	```
	
  Please note that there are versions of the `loadLSST.*` bootstrap script to be used with other shell flavors (such as CSH, ZSH and KSH). Look in the same directory to see what is available for your version of interest. You may want to add this line to your shell profile so your environment is set for every session.
  
  After bootstraping your LSST environment, the value of the `$EUPS_PATH` variable will be modified to contain both your own path (i.e.  `$HOME/eups`) and the path of the binary distribution (i.e. `/cvmfs/lsst.in2p3.fr/software/linux-x86_64/lsst-v12.0`).
  
Once your environment is ready, you can start developing against the stack. Let's say you want to improve one of the packages of the stack, namely, `obs_cfht`, and your work is kept on a particular branch. You need first to checkout the relevant branch and instruct EUPS to use that package:

* Clone the package into your `$HOME` directory:

	```bash
	$ cd $HOME
	$ git clone https://github.com/lsst/obs_cfht -b tickets/DM-1380
	$ cd obs_cfht
	```
	
*  EUPS setup and build the package you just cloned

	```bash
	$ setup -k -r .
	$ scons opt=3
	```
	
*  EUPS declare this package (`obs_cfht`) and its version (`my_obs_cfht`)

	```bash
	$ eups declare -r . obs_cfht my_obs_cfht
	```
	
*	From now on, you are using your own version of `obs_cfht`. If you want to verify, do:

	```bash
	$ eups list | grep obs_cfht
	```
	
*	If you don't want to use your private version any longer (perhaps, your modifications were merged into master), you can tell EUPS so:

	```bash
	$ eups undeclare obs_cfht my_obs_cfht
	```
	
*Acknowledgements: thanks to [Dominique Boutigny](https://github.com/boutigny) for providing this use case and helping validating the solution.*


## Doesn't work for you? Do you have a different use case not covered here?

If this document did not solve your problem or you have a use case not covered here let us know by [opening an issue](https://github.com/airnandez/lsst-cvmfs/issues).
