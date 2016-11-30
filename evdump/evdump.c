/* 
 * Copyright (C) 2016 Romain Primet
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the COPYING file for details.
 */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <linux/input.h>

/** 
 * Reads one evdev event from the file 'from' into
 * the struct 'to'.
 * Returns 0 if successful, a nonzero integer otherwise.
 */
int read_event(struct input_event *to, FILE * const from){
    size_t s = fread(to, sizeof(struct input_event), 1, from);
    if (s < 1){
      return 1;
    }
    return 0;
}

/**
 * Dumps evdev events converted to text on the standard output.
 * i.e. this is a simplified and machine-parseable version of evtest
 *
 * Events are dumped one per line according to the following format
 * 
 * timestamp type code value 
 * 
 * where:
 *   - timestamp is displayed as sec.usec 
 *   - type and code are unsigned integers
 *   - value is a signed integer
 */
int main(int argc, char *argv[]){
  if(argc != 2){
    fprintf(stderr, "Usage: %s device_path\n", argv[0]);
    return 1;
  }

  char *dev_path = argv[1];
  const char *prefix = "/dev/input";
  if (strncmp(prefix, dev_path, strlen(prefix)) != 0){
    fprintf(stderr, "Warning: device %s does not seem to be an evdev file\n", dev_path);
  }
  FILE * const fdev = fopen(dev_path, "r");
  if(fdev == NULL){
    fprintf(stderr, "Could not open file %s: %s\n", dev_path, strerror(errno));
    return 1;
  }

  struct input_event curr_event;
  for(;;){
    int res = read_event(&curr_event, fdev);
    if (res != 0){
      return 1;
    }
    printf("%d.%d %d %d %d\n", curr_event.time.tv_sec, curr_event.time.tv_usec, curr_event.type, curr_event.code, curr_event.value);
    fflush(stdout);
  }
}
