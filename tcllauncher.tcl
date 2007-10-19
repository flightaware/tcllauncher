#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#
#
# $Id: tcllauncher.tcl,v 1.2 2007-10-19 22:33:54 karl Exp $
#

namespace eval ::tcllauncher {

proc doit {{argv ""}} {
    set prog [info nameofexecutable]
    set path [file split $prog]

    #
    # tcllauncher cannot be invoked directly as "tcllauncher" -- it must be
    # aliased to some other name
    #
    if {[lindex $path end] == "tcllauncher"} {
        puts stderr "tcllauncher cannot be invoked as \"tcllauncher\"; it must be copied or linked as some other name"
	exit 255
    }

    # if the last dir in the chain is "bin", swap in "lib/tcllauncher" in
    # its place and tag a ".tcl" onto the end of the path name.
    #
    # otherwise just look in the same directory where the instance of the
    # tcllauncher was found.
    #

    if {[lindex $path end-1] == "bin"} {
        set path [eval file join [lreplace $path end-1 end-1 lib tcllauncher]].tcl
    } else {
        set path $prog.tcl
    }

    # ok now source in the file we (tcllauncher) figured out is the one

    uplevel #0 source $path
}

if !$tcl_interactive {doit $argv}

}
