#
# tcllauncher.tcl - tcl code that tcllauncher uses to do its thing
#
#
# $Id: tcllauncher.tcl,v 1.1 2007-10-15 03:30:48 karl Exp $
#

namespace eval ::tcllauncher {

proc doit {{argv ""}} {
    puts "argv0: $::argv0"
    puts "info script: [info script]"
    puts "info nameofexecutable: [info nameofexecutable]"
    puts "doit: $argv"
}

if !$tcl_interactive {doit $argv}

}
