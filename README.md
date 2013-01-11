# mp

A unix command line tool to generate random passwords from a master password. Written in Python.

## About

__License__ MIT/GPL
__Copyright__ Nick Pyett (contact@nickpyett.com)

## Installation

### OS X

You will need to add mp to either a directory that is in your PATH, or add a new directory to your PATH. I have a few command line tools in a directory in my home directory.

Add the following to the file at ~/.bash_profile.

PATH="/users/you/cli:${PATH}"

### Linux

To do.

### Windows

To do.

## Usage

mp [-a | -d] [-l] [service]

### List services

\# mp
or
\# mp -l

### Add service

\# mp -a twitter
\# Master password:
\# Password for service "twitter" copied to clipboard.

### Get password

\# mp twitter
\# Master password:
\# Password for service "twitter" copied to clipboard.

### Delete password

\# mp -d twitter
\# Are you sure you wish to delete the service "twitter"?
\# y
\# Service "twitter" deleted.