# tcllauncher, a launcher program for Tcl applications.

tcllauncher is a way to have Tcl programs run out of /usr/local/bin under their own name, be installed in one place with their support files, and provides commands to facilitate server-oriented application execution.

While there is another wrapper system that also does this, that system produces a single executable that contains all the code and support files within a built-in virtual filesystem wrapped inside the executable. Tcllauncher keeps the support files distinct, typically in a subdirectory of /usr/local/lib that's named after the application.


This package is a freely available open source released under the liberal Berkeley copyright.  You can do virtually anything you like with it, such as modifying it, redistributing it, and selling it either in whole or in part.  See the file "license.terms" for complete information.

## Contents

The following is a short description of the files you will find in
the sample extension.

Makefile.in	Makefile template.  The configure script uses this file to
		produce the final Makefile.

README.md		This file

aclocal.m4	Generated file.  Do not edit.  Autoconf uses this as input
		when generating the final configure script.  See "tcl.m4"
		below.

configure	Generated file.  Do not edit.  This must be regenerated
		anytime configure.in or tclconfig/tcl.m4 changes.

configure.in	Configure script template.  Autoconf uses this file as input
		to produce the final configure script.

pkgIndex.tcl.in Package index template.  The configure script will use
		this file as input to create pkgIndex.tcl.

launcher.c	No C functions, just a stub.  Tcllauncher messes with Tcl startup more than anything.

launcher.h	Very litle, as in launcher.c above.

tcllauncher.c	Tcllauncher package initialization C function.

tclAppInit.c	A slightly modified copy of TclAppInit.c from the Tcl
                source code.

tclconfig/	This directory contains various template files that build
		the configure script.  They should not need modification.

	install-sh	Program used for copying binaries and script files
			to their install locations.

	tcl.m4		Collection of Tcl autoconf macros.  Included by
			aclocal.m4 to define SC_* macros.

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

## Windows build

The recommended method to build extensions under windows is to use the Msys + Mingw build process. This provides a Unix-style build while generating native Windows binaries. Using the Msys + Mingw build tools means that you can use the same configure script as per the Unix build to create a Makefile. See the tcl/win/README file for the URL of the Msys + Mingw download.

If you have VC++ then you may wish to use the files in the win subdirectory and build the extension using just VC++. These files have been designed to be as generic as possible but will require some additional maintenance by the project developer to synchronise with the TEA configure.in and Makefile.in files. Instructions for using the VC++ makefile are written in the first part of the Makefile.vc file.

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
