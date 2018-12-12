#!/bin/sh

  fsav --version|grep "^Database version"|awk '{print $3}'