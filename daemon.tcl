#
# tcllauncher
#
# rough tclx-based copy of BSD 4.4's daemon library routine
#
# $Id: daemon.tcl,v 1.1 2008-03-31 06:51:07 karl Exp $
#

proc daemon {args} {
    set doClose 1
    set doChdir 1

    foreach arg $args {
        switch $arg {
	    "-noclose" {
	        set doClose 0
	    }

	    "-nochdir" {
	        set doChdir 0
	    }

	    default {
	        error "unrecognized option: $arg"
	    }
	}
    }

    set pid [fork]

    if {$pid != 0} {
        exit 0
    }

    id process group set

    if {$doChdir} {
        cd "/"
    }

    if {$doClose} {
        set fp [open /dev/null RDWR]
	dup $fp stdin
	dup $fp stdout
	dup $fp stderr
	close $fp
    }

    return
}
