/*
 * tcllauncher.c --
 *
 *	This file implements a Tcl interface to an alternative Tcl launcher.
 *
 */

#include <tcl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "launcher.h"


/*
 *----------------------------------------------------------------------
 *
 * Launcher_Init --
 *
 *	Initialize the new package.  The string "Launcher" in the
 *	function name must match the PACKAGE declaration at the top of
 *	configure.in.
 *
 * Results:
 *	A standard Tcl result
 *
 * Side effects:
 *
 *----------------------------------------------------------------------
 */

int
Launcher_Init(Tcl_Interp *interp)
{
    /*
     * This may work with 8.0, but we are using strictly stubs here,
     * which requires 8.1.
     */
    if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_PkgRequire(interp, "Tcl", "8.1", 0) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_PkgProvide(interp, "tcllauncher", PACKAGE_VERSION) != TCL_OK) {
	return TCL_ERROR;
    }

    return TCL_OK;
}
