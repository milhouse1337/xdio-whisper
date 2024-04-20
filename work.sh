#!/bin/bash

echo "" > xdio.log
node client.js & tail -f xdio.log
