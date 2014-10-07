/*
 * MassTree.jl binding for Julia (C) 2014 Duane Johnson
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, subject to the conditions
 * listed in the Masstree LICENSE file. These conditions include: you must
 * preserve this copyright notice, and you cannot mention the copyright
 * holders in advertising related to the Software without their permission.
 * The Software is provided WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED. This
 * notice is a summary of the Masstree LICENSE file; the license in that file
 * is legally binding.
 */
// -*- mode: c++ -*-
// mttest: key/value tester
//

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/select.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/utsname.h>
#include <limits.h>
#if HAVE_NUMA_H
#include <numa.h>
#endif
#if HAVE_SYS_EPOLL_H
#include <sys/epoll.h>
#endif
#if HAVE_EXECINFO_H
#include <execinfo.h>
#endif
#if __linux__
#include <asm-generic/mman.h>
#endif
#include <fcntl.h>
#include <assert.h>
#include <string.h>
#include <pthread.h>
#include <math.h>
#include <signal.h>
#include <errno.h>
#ifdef __linux__
#include <malloc.h>
#endif
#include "nodeversion.hh"
#include "kvstats.hh"
#include "query_masstree.hh"
#include "masstree_tcursor.hh"
#include "masstree_insert.hh"
#include "masstree_remove.hh"
#include "masstree_scan.hh"
#include "timestamp.hh"
#include "json.hh"
#include "kvtest.hh"
#include "kvrandom.hh"
#include "kvrow.hh"
#include "kvio.hh"
#include "clp.h"
#include <algorithm>
#include <numeric>

/* minimum set of globals necessary for compiling */
volatile uint64_t globalepoch = 1;
kvtimestamp_t initial_timestamp;
pthread_mutex_t rec_mu;
volatile bool recovering = false;
Masstree::default_table *tree;
/* end minimum set of globals */

#ifdef __cplusplus
extern "C" {
#endif

struct MasstreeWrapper {
  Masstree::default_table *tree;
  threadinfo *ti;
  query<row_type> q;
};

typedef struct MasstreeWrapper MasstreeWrapper_t;

MasstreeWrapper* mt_create() {
  MasstreeWrapper* mt = (MasstreeWrapper*)malloc(sizeof(MasstreeWrapper));

  mt->ti = threadinfo::make(threadinfo::TI_PROCESS, -1);
  mt->tree = new Masstree::default_table;
  mt->tree->initialize(*mt->ti);

  // int nlogger = 1;
  // logset* logs = logset::make(nlogger);
  // mt->ti->set_logger(&logs->log(ti->index() % nlogger));

  return mt;
}

void mt_destroy(MasstreeWrapper* mt) {
  // mt->ti->destroy(); /* destructor not yet defined? */
  // mt->tree->destroy(*mt->ti);
  delete mt->tree;
}

/* String : String */

void mt_put_str_str(MasstreeWrapper *mt, char* key, char* value) {
  Str k = Str(key), v = Str(value);
  mt->q.run_replace(mt->tree->table(), k, v, *mt->ti);
}

const char* mt_get_str_str(MasstreeWrapper *mt, char* key) {
  Str k = Str(key), v;
  if(mt->q.run_get1(mt->tree->table(), k, 0, v, *mt->ti)) {
    // Convert from Str to String so we can get a null-terminated c_str
    String result = String(v.s, v.len);
    return result.c_str();
  } else {
    return NULL;
  }
}

/* String : Integer */

void mt_put_str_int(MasstreeWrapper *mt, char* key, uint32_t value) {
  Str k = Str(key), v = Str((char *)&value, sizeof(value));
  mt->q.run_replace(mt->tree->table(), k, v, *mt->ti);
}

uint32_t mt_get_str_int(MasstreeWrapper *mt, char* key) {
  Str k = Str(key), v;
  if(mt->q.run_get1(mt->tree->table(), k, 0, v, *mt->ti)) {
    assert(v.len == 4);
    return (uint32_t)*v.s;
  } else {
    /* unholy sentinal value here--is there a better (and equally fast) way? */
    return (uint32_t)-1;
  }
}

/* Integer : String */

void mt_put_int_str(MasstreeWrapper *mt, uint32_t key, char* value) {
  Str k = Str((char *)&key, 4), v = Str(value);
  mt->q.run_replace(mt->tree->table(), k, v, *mt->ti);
}

const char* mt_get_int_str(MasstreeWrapper *mt, uint32_t key) {
  Str k = Str((char *)&key, 4), v;
  if(mt->q.run_get1(mt->tree->table(), k, 0, v, *mt->ti)) {
    // Convert from Str to String so we can get a null-terminated c_str
    String result = String(v.s, v.len);
    return result.c_str();
  } else {
    return NULL;
  }
}

/* Integer : String */

void mt_put_int_int(MasstreeWrapper *mt, uint32_t key, uint32_t value) {
  Str k = Str((char *)&key, 4), v = Str((char *)&value, sizeof(value));
  mt->q.run_replace(mt->tree->table(), k, v, *mt->ti);
}

uint32_t mt_get_int_int(MasstreeWrapper *mt, uint32_t key) {
  Str k = Str((char *)&key, 4), v;
  if(mt->q.run_get1(mt->tree->table(), k, 0, v, *mt->ti)) {
    assert(v.len == 4);
    return (uint32_t)*v.s;
  } else {
    /* unholy sentinal value here--is there a better (and equally fast) way? */
    return (uint32_t)-1;
  }
}


#ifdef __cplusplus
}
#endif
