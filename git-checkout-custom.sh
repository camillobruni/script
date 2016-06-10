#!/bin/bash

 git checkout $@ || (git checkout `git branch | grep $@`)
