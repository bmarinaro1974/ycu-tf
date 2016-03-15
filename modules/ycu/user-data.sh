#!/bin/bash

yum -y update ycu-tools
chef-config -d=${domain} -r=${chef_role} -e=${environment} -c
