/* 
 *  COPYRIGHT (c) 1989-2007.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be found in
 *  the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id: rtems_init.c,v 1.2 2007/09/17 20:46:23 joel Exp $
 */

#define MAIN_USE_NETWORKING
#define MAIN_USE_REQUIRES_COMMAND_LINE

#include <bsp.h>

#include <assert.h>
#include <pthread.h>
#include <stdlib.h>

#include <rtems/rtems_bsdnet.h>
#include "rtems_networkconfig.h"

extern rtems_configuration_table  BSP_Configuration;

/*
 *  Using GNAT's Distributed Systems Annex support requires
 *  each node in the system to have different pid's.  In a
 *  single CPU RTEMS system, it is always one.  This lets the
 *  user override the RTEMS default.
 */
#ifdef GNAT_PID
  #include <unistd.h>

  pid_t getpid()
  {
    return GNAT_PID;
  }
#endif

static int   argc     = 1;
static char  arg0[20] = "rtems";
static char *argv[20] = { arg0 };

#if defined(MAIN_USE_REQUIRES_COMMAND_LINE)

#define COMMAND_LINE_MAXIMUM 200

#include <stdio.h>
#include <ctype.h>

void parse_arguments(
  char   *buffer,
  size_t  maximum_length
)
{
  char   *cp;
  char   *linebuf = buffer;
  size_t  length;

  for (;;) {

    /*
     * Set up first argument
     */
    #if 0
      argc = 1;
      strcpy (arg0, "rtems");
      argv[0] = arg0;
    #endif

#if (defined (MAIN_COMMAND_LINE))
    strncpy (linebuf, MAIN_COMMAND_LINE, maximum_length);
#else
    /*
     * Read a line
     */
    printf (">>> %s ", argv[0]);
    fflush (stdout);
    fgets (linebuf, maximum_length, stdin);

    length = strnlen( linebuf, maximum_length );
    if ( linebuf[length - 1] == '\n' || linebuf[length - 1] == '\r' ) {
       linebuf[length - 1] = '\0';
    }
#endif

    /*
     * Break line into arguments
     */
    cp = linebuf;
    for (;;) {
      while (isspace (*cp))
        *cp++ = '\0';
      if (*cp == '\0')
        break;
      if (argc >= ((sizeof argv / sizeof argv[0]) - 1)) {
        printf ("Too many arguments.\n");
        argc = 0;
        break;
      }
      argv[argc++] = cp;
      while (!isspace (*cp)) {
        if (*cp == '\0')
          break;
        cp++;
      }
    }
    if (argc > 1) {
      argv[argc] = NULL;
      break;
    }
    printf ("You must give some arguments!\n");
  }

  #if 0
    {
      int   i;
      for (i=0; i<argc ; i++ ) {
        printf( "argv[%d] = ***%s***\n", i, argv[i] );
      }
      printf( "\n" );
    }
  #endif 
}


#endif

/*
 *  By having the POSIX_Init thread create a second thread just
 *  to invoke gnat_main, we can override all default attributes
 *  of the "Ada environment task".  Otherwise, we would be
 *  stuck with the defaults set by RTEMS.
 */
 
void *start_gnat_main( void * argument )
{
  extern int gnat_main ( int argc, char **argv, char **envp );

  /*
   * This is scoped to match the Ada program.
   */
  char command_line[ COMMAND_LINE_MAXIMUM ];

  #if defined(MAIN_USE_REQUIRES_COMMAND_LINE)
    parse_arguments( command_line, COMMAND_LINE_MAXIMUM );
  #endif

  (void) gnat_main ( argc, argv, 0 );

  exit( 0 );

  return 0;
}

#ifndef GNAT_MAIN_STACKSPACE
  #define GNAT_MAIN_STACKSPACE 0
#endif

void *POSIX_Init( void *argument )
{
  pthread_t       thread_id;
  pthread_attr_t  attr;
  size_t          stacksize;
  int             status;
  extern  size_t  _ada_pthread_minimum_stack_size();

  #if defined(MAIN_USE_NETWORKING)
    printk("Initializing Network\n");
    rtems_bsdnet_initialize_network ();
  #endif

  status = pthread_attr_init( &attr );
  assert( !status );

  stacksize = GNAT_MAIN_STACKSPACE * 1024;
  if ( stacksize < _ada_pthread_minimum_stack_size() )
    stacksize = _ada_pthread_minimum_stack_size();

  status = pthread_attr_setstacksize( &attr, stacksize );
  assert( !status );

  status = pthread_create( &thread_id, &attr, start_gnat_main, NULL );
  assert( !status );

  pthread_exit( 0 );
  return 0;
}

/* configuration information */

/* Standard output and a clock tick so time passes */
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER

/* We need to be able to create sockets */
#define CONFIGURE_LIBIO_MAXIMUM_FILE_DESCRIPTORS	20

/* This is overkill but is definitely enough to run the network stack */
#define CONFIGURE_MAXIMUM_TASKS                         20
#define CONFIGURE_MAXIMUM_SEMAPHORES                    20

/* We want a clock tick every millisecond */
#define CONFIGURE_MICROSECONDS_PER_TICK RTEMS_MILLISECONDS_TO_MICROSECONDS(1)

/* The initialization task is a POSIX Initialization thread with default attributes */
#define CONFIGURE_POSIX_INIT_THREAD_TABLE

/* We are using GNAT/RTEMS with a maximum of 20 Ada tasks and no fake Ada tasks. */
/* A fake Ada task is a task created outside the Ada run-time that calls into Ada. */
#define CONFIGURE_GNAT_RTEMS
#define CONFIGURE_MAXIMUM_ADA_TASKS      20
#define CONFIGURE_MAXIMUM_FAKE_ADA_TASKS 0

/* Account for any extra task stack size */
#define CONFIGURE_MEMORY_OVERHEAD        (GNAT_MAIN_STACKSPACE)

#define CONFIGURE_INIT

#include <rtems/confdefs.h>
