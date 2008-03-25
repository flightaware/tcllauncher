#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#
#
# $Id: tcllauncher.tcl,v 1.7 2008-03-25 22:19:27 karl Exp $
#

namespace eval ::tcllauncher {

#
# require_group - require a certain group ID, exit with message to stderr if not
#
proc require_group {group} {
    package require Tclx

    if {[id group] == $group} {
	return
    }

    # see if we can set to that group, maybe we're root?
    if {[catch {id group $group} result] == 1} {
	puts stderr "requires and can't set to group '$group': $result"
	exit 254
    }

    return
}

#
# require_user - require a certain user ID, exit with message to stderr if not
#
proc require_user {user} {
    package require Tclx

    if {[id user] == $user} {
	return
    }

    # see if we can set to that group, maybe we're root?
    if {[catch {id user $user} result] == 1} {
	puts stderr "requires and can't set to user '$user': $result"
	exit 253
    }

    return
}

#
# require_user_and_group - require the invoker to either be of a certain
#  user and group or if they're superuser or some kind of equivalent,
#  force this process to have the specified user (uid) and group (gid)
#
require_user_and_group {user group} {

    # try group first because if we're root we might not be after setting
    # user

    require_group $group

    require_user $user
}

#
# this is the code that gets called when Tcl launches because the
# tcllauncher "version" of Tcl jimmies the command line to make it
# so.
#
# this routine must now figure out what to do to launch the app
# 
#
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

    set ::argv0 $shortName

    # ok now source in the file we (tcllauncher) figured out is the one

    uplevel #0 source $path
}

if !$tcl_interactive {doit $argv}

}
