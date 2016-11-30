#!/bin/bash
sleep 1 && ledoff /dev/input/volbutton && evdump /dev/input/volbutton | vaalum.native http://music.local:4000
