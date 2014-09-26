/* 
 * tclAppInit.c --
 *
 *	Provides a default version of the main program and Tcl_AppInit
 *	procedure for Tcl applications (without Tk).
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994-1997 Sun Microsystems, Inc.
 * Copyright (c) 1998-1999 by Scriptics Corporation.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: tclAppInit.c,v 1.7 2008-11-12 22:12:51 karl Exp $
 */

#include "tcl.h"
#include <stdlib.h>
#include "launcher.h"

#define TCL_LOCAL_MAIN_HOOK launcher_main_hook


/*
 *----------------------------------------------------------------------
 *
 * launcher_main_hook --
 *
 *	This is the launcher's main hook that gets called just before
 *      tcl_main.
 *
 * Results:
 *	Rewrites the program's main's argv and argc to stuff a tcl
 *      filename in as argv[1].
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */
int launcher_main_hook _ANSI_ARGS_((int *argcPtr, char ***argvPtr)) {
    char **newArgv;
    int    newArgc = *argcPtr + 1;
    int    i;

    newArgv = (char **)malloc (sizeof(char *) * newArgc);
    newArgv[0] = **argvPtr;
    newArgv[1] = TCLLAUNCHER_FILE;

    for (i = 2; i < newArgc; i++) {
        newArgv[i] = *(*argvPtr + i - 1);
    }

    *argvPtr = newArgv;
    *argcPtr = newArgc;

    return 0;
}


/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tcl_Main never returns here, so this procedure never
 *	returns either.
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */

int
main(argc, argv)
    int argc;			/* Number of command-line arguments. */
    char **argv;		/* Values of command-line arguments. */
{
    /*
     * The following #if block allows you to change the AppInit
     * function by using a #define of TCL_LOCAL_APPINIT instead
     * of rewriting this entire file.  The #if checks for that
     * #define and uses Tcl_AppInit if it doesn't exist.
     */

#ifndef TCL_LOCAL_APPINIT
#define TCL_LOCAL_APPINIT Tcl_AppInit    
#endif
    extern int TCL_LOCAL_APPINIT _ANSI_ARGS_((Tcl_Interp *interp));

    /*
     * The following #if block allows you to change how Tcl finds the startup
     * script, prime the library or encoding paths, fiddle with the argv,
     * etc., without needing to rewrite Tcl_Main()
     */

#ifdef TCL_LOCAL_MAIN_HOOK
    extern int TCL_LOCAL_MAIN_HOOK _ANSI_ARGS_((int *argc, char ***argv));
#endif

#ifdef TCL_LOCAL_MAIN_HOOK
    TCL_LOCAL_MAIN_HOOK(&argc, &argv);
#endif

    Tcl_Main(argc, argv, TCL_LOCAL_APPINIT);

    return 0;			/* Needed only to prevent compiler warning. */
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in the interp's result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */

int
Tcl_AppInit(interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{
    if ((Tcl_Init)(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

    if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
	return TCL_ERROR;
    }
    if (Tcl_PkgRequire(interp, "Tcl", "8.1", 0) == NULL) {
	return TCL_ERROR;
    }

    /*
     * package require the tcllauncher package so that the helper routines
     * will get loaded via the normal package mechanism.  doing it this
     * way then tcllauncher apps don't have to package require tcllauncher
     */
    if (Tcl_PkgRequire (interp, PACKAGE_NAME, PACKAGE_VERSION, 1) == NULL) {
        return TCL_ERROR;
    }

    /*
     * Call Tcl_CreateCommand for application-specific commands, if
     * they weren't already created by the init procedures called above.
     */

    /*
     * Specify a user-specific startup file to invoke if the application
     * is run interactively.  Typically the startup file is "~/.apprc"
     * where "app" is the name of the application.  If this line is deleted
     * then no user-specific startup file will be run under any conditions.
     */

#ifdef DJGPP
    Tcl_SetVar(interp, "tcl_rcFileName", "~/tclsh.rc", TCL_GLOBAL_ONLY);
#else
    Tcl_SetVar(interp, "tcl_rcFileName", "~/.tclshrc", TCL_GLOBAL_ONLY);
#endif
    return TCL_OK;
}
