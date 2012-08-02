#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#

package require Tclx

namespace eval ::tcllauncher {

#
# require_group - require a certain group ID, exit with message to stderr if not
#
proc require_group {group} {
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
proc require_user_and_group {user group} {

    # try group first because if we're root we might not be after setting
    # user

    require_group $group

    require_user $user
}

#
# daemonize - rough tclx-based copy of BSD 4.4's daemon library routine
#

proc daemonize {args} {
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

#
# pidfile_verify - insane checks of pid file
#
proc pidfile_verify {} {
    variable pfh

    if {[catch {fstat $pfh(fp)} stat] == 1} {
        error "programming error"
    }

    set dev [keylget stat dev]
    set ino [keylget stat ino]

    if {$dev != $pfh(dev) || $ino != $pfh(ino)} {
        error "programming error"
    }

    return 0
}

#
# pidfile_read - given a path and the name of a pid variable, set the
#  PID into the variable
#
proc pidfile_read {path _pid} {
    variable pfh

    upvar $_pid pid

    set fp [open $path "RDONLY"]
    set pid [read -nonewline $fp]
    close $fp

    set pfh(path) $path
}

#
# pidfile_open - given an optional path to a directory and optional permissions,
#  open the file, try to lock it, get its contents.  Return the pid contained
#  therein if there is one and the lock failed.  (Somebody's already got the
#  pid.)
#
#  else you've got the lock and call pidfile_write to get your pid in there
#
proc pidfile_open {{path "/var/run"} {mode 0600}} {
    variable pfh

    set pidfile $path/$::argv0.pid
    set pfh(path) $pidfile

    # Open the PID file and obtain exclusive lock.
    # We truncate PID file here only to remove old PID immediately,
    # PID file will be truncated again in pidfile_write(), so
    # pidfile_write() can be called multiple times.

    set fp [open $pidfile "RDWR CREAT"]

    # try to lock the file

    if {![flock -write -nowait $fp]} {
        # failed to lock the file, read it for the pid of the owner
        set pid [read -nonewline $fp]

	# if we can get an integer out of it, return that
	if {[scan $pid %d pid] > 0} {
	    close $fp
	    return $pid
	}
    }

    # i got the lock

    # can fstat really fail on a file i have open?
    set stat [fstat $fp]

    set pfh(fp) $fp
    set pfh(dev) [keylget stat dev]
    set pfh(ino) [keylget stat ino]

    return 0
}

#
# pidfile_write - write my pid into the pid file
#
proc pidfile_write {} {
    variable pfh

    pidfile_verify 

    set fp $pfh(fp)

    ftruncate -fileid $fp 0

    puts $fp [pid]
    flush $fp
}

#
# pidfile_close - close the pid file
#
proc pidfile_close {} {
    variable pfh

    pidfile_verify

    close $pfh(fp)
}

#
# pidfile_remove - remove the pidfile, unlock the lock, and close it
#
proc pidfile_remove {} {
    variable pfh

    pidfile_verify

    file delete $pfh(path)
    funlock $pfh(fp)

    close $pfh(fp)
}





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

    # ok now source in the file we (tcllauncher) figured out is the one

    uplevel #0 source $path
}

if !$tcl_interactive {main $argv}

}

