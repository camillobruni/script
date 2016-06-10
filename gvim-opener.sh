#!/bin/bash

gvim () {
  command gvim --remote-silent "$@" || command gvim "$@"
}

gvim "$@"
