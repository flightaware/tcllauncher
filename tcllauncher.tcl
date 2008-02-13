#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#
#
# $Id: tcllauncher.tcl,v 1.5 2008-02-13 17:18:22 karl Exp $
#

namespace eval ::tcllauncher {

proc doit {{argv ""}} {
    set prog [info nameofexecutable]

    # have we been invoked as a shell?  If so, prog is empty, get it from
    # the SHELL environment variable
    if {$prog == ""} {
	set prog $::env(SHELL)
    }

    set path [file split $prog]
    set shortName [lindex $path end]

    #
    # tcllauncher cannot be invoked directly as "tcllauncher" -- it must be
    # aliased to some other name
    #
    if {$shortName == "tcllauncher"} {
        puts stderr "tcllauncher cannot be invoked as \"tcllauncher\"; it must be copied or linked as some other name"
	exit 255
    }

    # if the last dir in the chain is "bin", swap in "lib/tcllauncher" in
    # its place and tag a ".tcl" onto the end of the path name.
    #
    # otherwise just look in the same directory where the instance of the
    # tcllauncher was found.
    #

    #puts stderr "path '$path', prog '$prog', shortName '$shortName'"

    if {[lindex $path end-1] == "bin"} {
	# this version looks for ../lib/tcllauncher/$shortName.tcl`
	#set path [eval file join [lreplace $path end-1 end-1 lib tcllauncher]]

	# this version looks for ../lib/$shortName/main.tcl

        set ::launchdir [eval file join [lreplace $path end-1 end lib $shortName]]
        set path [eval file join $::launchdir main.tcl]
    } else {
        set path $prog.tcl
    }

    if {![file readable $path]} {
	puts stderr "$shortName: can't read '$path' (tcllauncher)"
	exit 254
    }

    # ok now source in the file we (tcllauncher) figured out is the one

    uplevel #0 source $path
}

if !$tcl_interactive {doit $argv}

}
