#
# pidfile actions
#
# Tcl-ized, TclX-ized, studied copy of FreeBSD's pidfile library
#
# $Id: pidfile.tcl,v 1.1 2008-03-25 06:12:10 karl Exp $
#

package require Tclx

#
# pidfile_verify -
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
# pidfile_read - 
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
# pidfile_open -
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
# pidfile_write -
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
# pidfile_close -
#
proc pidfile_close {} {
    variable pfh

    pidfile_verify

    close $pfh(fp)
}

#
# pidfile_remove -
#
proc pidfile_remove {} {
    variable pfh

    pidfile_verify

    file delete $pfh(path)
    funlock $pfh(fp)

    close $pfh(fp)
}




