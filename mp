#!/usr/bin/env python
# 
# mp
# 
# Generate a complex password for each of your services from
# a single master password.
# 
# v 0.1

from sys import exit
import os
import argparse
import pickle
from getpass import getpass
from re import sub
from bcrypt import hashpw, gensalt
from xerox import copy

# Add our arguments, a boolean to add or delete a service,
# a boolean for listing and the service itself
parser = argparse.ArgumentParser(description='Create and read passwords from a master password. Passwords are pasted to your clipboard. This script uses a file stored in your /tmp directory.')
group = parser.add_mutually_exclusive_group()
group.add_argument('-a', '--add', action='store_true', help='add or update a service')
group.add_argument('-d', '--delete', action='store_true', help='delete a service')
parser.add_argument('-l', '--list', action='store_true', help='list services (default)')
parser.add_argument('service', type=str, help='the service (e.g. twitter)', nargs='?')

# Parse and store in some nicer vars
args = parser.parse_args()
adding, deleting, listing, service = args.add, args.delete, args.list, args.service

# If we have no arguments, default to list
if not adding and not deleting and not listing and not service:
	listing = True

# Change your salts file path here
salts_path = os.getenv('HOME') + '/.mpsalts'

def main(service):
	
	# Check salts file exists, or create it
	if not os.path.exists(salts_path):
		output = open(salts_path, 'wb')
		salts = {}
		salts = pickle.dump(salts, output)
		print "This script just created the file %s. Don't delete it unless you want to change all your passwords." % salts_path
	else:
		output = open(salts_path, 'r+b')
		salts = pickle.load(output)
	
	if listing:
		if salts:
			print "Services:"
			for salt in salts:
				print "  " + salt
			exit()
		else:
			print "No services to list. Run \"mp -a service\" to add one."
			exit()
	elif adding:
		# Check to see if we already have a salt for the service, as if
		# we overwrite, the password will change.
		try:
			salt = salts[service]
		except:
			salt = False
		
		update = False
		
		if salt:
			# Check if the user wishes to update the password for this service
			print "Do you wish to update the password for the service \"%s\"?" % service
			yn = raw_input(">").lower()
			
			if yn == 'y' or yn == 'yes':
				update = True
				salts.pop(service)
			else:
				exit(1)
				
		if not salt or update:
			# If we don't have a salt, or can update, update the salt dict and
			# salt dump
			salts = dict(salts.items() + {service:gensalt()}.items())
			output.seek(0)
			output.truncate()
			pickle.dump(salts, output)
	
	try:
		salt = salts[service]
	except:
		print "Service \"%s\" not recognised. Run \"mp -a %s\" to add it." % (service, service)
		exit(0)
	
	if deleting:
		print "Are you sure you wish to delete the service \"%s\"?" % service
		yn = raw_input(">").lower()
		
		if yn == 'y' or yn == 'yes':
			salts.pop(service)
			output.seek(0)
			output.truncate()
			pickle.dump(salts, output)
			print "Service \"%s\" deleted." % service
			exit(0)
		else:
			exit(1)
	
	# Get the password
	password = getpass("Master password:")
	
	# Hash a password with the premade salt and format it
	hashed = hashpw(password, salts[service])
	hashed = sub(ur"([^A-Za-z0-9]+)", "", hashed)
	hashed = hashed[len(hashed)-12:]
	
	# Add the password to the clipboard
	copy(hashed)

	print "Password for service \"%s\" copied to clipboard." % service
	exit(1)

if __name__ == '__main__':
	main(service)