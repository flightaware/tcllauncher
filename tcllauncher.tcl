#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#

package require Tclx

#
# this is the code that gets called when Tcl launches because the
# tcllauncher "version" of Tcl jimmies the command line to make it
# so.
#
# this routine must now figure out what to do to launch the app
# 
#
proc main {{argv ""}} {
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

    set ::argv0 $shortName
    set initialArgv $argv

    # ok now source in the file we (tcllauncher) figured out is the one

    if {[catch {uplevel #0 source $path} catchResult] == 1} {
        append ::errorInfo "\n    from tcllauncher running \"[string trim "$::argv0 $initialArgv"]\""
	puts stderr $::errorInfo
        exit 255
    }

    exit 0
}

if {!$tcl_interactive} {
    main $argv
}

