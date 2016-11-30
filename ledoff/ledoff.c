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
 * Writes one evdev event from the struct 'from' into
 * the file 'to'.
 * Returns 0 if successful, a nonzero integer otherwise.
 */
int write_event(FILE * const to, struct input_event *from){
  size_t s = fwrite(from, sizeof(struct input_event), 1, to);
  if(s != 1){
    return 1;
  }
  return 0;
}

/**
 * Turns the Griffin PowerMate LED off.
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
  FILE * const fdev = fopen(dev_path, "w");
  if(fdev == NULL){
    fprintf(stderr, "Could not open file %s: %s\n", dev_path, strerror(errno));
    return 1;
  }

  struct input_event off = {.type = EV_MSC , .code = MSC_PULSELED, .value = 0};
  struct input_event sync;

  int res = 0;
  res = write_event(fdev, &off);
  if(res != 0){
    return -1;
  }
  res = write_event(fdev, &sync);
  if(res != 0){
    return -1;
  }
}

