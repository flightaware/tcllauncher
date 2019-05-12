# tcllauncher, a launcher program for Tcl applications.

tcllauncher is a way to have Tcl programs run out of /usr/local/bin under their own name, be installed in one place with their support files, and provides commands to facilitate server-oriented application execution.

While there is another wrapper system that also does this, that system produces a single executable that contains all the code and support files within a built-in virtual filesystem wrapped inside the executable. Tcllauncher keeps the support files distinct, typically in a subdirectory of /usr/local/lib that's named after the application.

This package is a freely available open source released under the liberal Berkeley copyright.  You can do virtually anything you like with it, such as modifying it, redistributing it, and selling it either in whole or in part.  See the file "license.terms" for complete information.

## UNIX Build

Building under most UNIX systems is easy, just run the configure script and then run make. For more information about the build process, see the tcl/unix/README file in the Tcl src dist. The following minimal example will install the extension in the /opt/tcl directory.

	$ cd tcllauncher
	$ autoconf
	$ ./configure --prefix=/opt/tcl
	$ make
	$ make install

## Hint

Beware it building against the source dirs instead of installed dirs and then not being able to find stuff.  If, for instace, you're building in /usr/fa, use something like

./configure --prefix=/usr/fa --with-tcl=/usr/fa/lib 

The --with-tcl is important!  Otherwise it will probably find the Tcl source in a parallel directory and build against that instead and cause problems later.

## Installation

The installation of a TEA package is structure like so:

         $exec_prefix
          /       \
        lib       bin
         |         |
   PACKAGEx.y   (dependent .dll files on Windows)
         |
  pkgIndex.tcl (.so|.dll files)

The main .so|.dll library file gets installed in the versioned PACKAGE directory, which is OK on all platforms because it will be directly referenced with by 'load' in the pkgIndex.tcl file.  Dependent DLL files on Windows must go in the bin directory (or other directory on the user's PATH) in order for them to be found.

FlightAware
---
FlightAware has released over a dozen applications  (under the free and liberal BSD license) into the open source community. FlightAware's repositories are available on GitHub for public use, discussion, bug reports, and contribution. Read more at https://flightaware.com/about/code/

