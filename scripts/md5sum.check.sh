#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
# Last Updated: 2023-08-09
#
# DESCRIPTION:
# Performs md5sum check and saves the output in a text file (md5sum.check.txt)
#
# USAGE:
# 1. Move the script file into the folder you want to perform md5sum check
# 2. Go to that folder and run the script using the command: 
#   ./md5sum.check.sh
#
# REQUIREMENTS:
# - md5sum
#
###########################################################################################
date >> md5sum.check.txt
echo "find *md5 -type f | parallel -j 6 md5sum -c >> md5sum.check.txt"
find *md5 -type f | parallel -j 6 md5sum -c >> md5sum.check.txt
date >> md5sum.check.txt
echo "Done" >> md5sum.check.txt
