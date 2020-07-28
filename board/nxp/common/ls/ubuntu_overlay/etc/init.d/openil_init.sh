#!/bin/bash

while true;
    do
        /sbin/resize2fs /dev/disk/by-label/root ;
        if [ $? = 0 ];
        then
            break;
        else
            sleep 1;
        fi;
done
