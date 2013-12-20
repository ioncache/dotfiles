#!/usr/bin/env python
#####################
#     Bcrypt V3     #
#    By Stealth-    #
#####################
# http://www.stealth-x.com/apps/bcrypt.php
# This code is public domain, do with it as you please
# I just ask you keep a header with a link to my site
import sys
import time
import hashlib
import getpass
class CryptError(Exception):
	def __init__(self, reason):
		self.reason = reason

	def __str__(self):
		return self.reason

class Cryptor():
	def __init__(self):
		pass

	def __hash__(self, password):
		dump = ''
		oldmd5 = password
		while len(dump) <= 10:
			md5 = hashlib.md5(oldmd5)
			for character in md5.hexdigest():
				if character.isdigit():
					if character != '0':
						dump += character
			oldmd5 = md5
		return dump[:10]

	def __chkpassword__(self):
		try:
			null = self.hash
		except AttributeError:
			err = 'No password set. Set via Cryptor.SetPassphrase(string)'
			raise CryptError(err)

	def __translate__(self, character, times, direction):
		num = ord(character)
		for null in range(0,times):
			if direction == 1:
				num += 1
				if num == 256:
					num = 0
			elif direction == 0:
				num -= 1
				if num == -1:
					num = 255
			else:
				err = 'Valid values for \'direction\' are 1 (forward) or 0 (reverse)'
				raise CryptError(err)
		return chr(num)

	def __brand__(self, data, pos, method):
		if pos == 0:
			if method == 0:
				if data[:6] != ':6263:':
					err = 'Cannot decrypt: Not Bcrypt encrypted data'
					raise CryptError(err)
				else:
					return data[6:]
			else:
				return ':raw:' + data

		elif pos == 1:
			if method == 0:
				if data[:5] != ':raw:':
					err = 'Cannot decrypt: Incorrect passphrase'
					raise CryptError(err)
				else:
					return data[5:]
			else:
				return ':6263:' + data

	def __crypt__(self, string, method):
		string = self.__brand__(string, 0, method)
		self.__chkpassword__()
		if not isinstance(string, str):
			err = '\'plaintext\' must be a string'
			raise CryptError(err)
		else:
			for loop in range(0, 2):
				hashloc = 0
				output = ''
				for character in string:
					if method == 1 or method == 0:
						output += self.__translate__(character, int(self.hash[hashloc]), method)
					else:
						err = 'Valid values for \'method\' are 1 (encrypt) or 0 (decrypt)'
						raise CryptError(err)
					hashloc += 1
					if hashloc == 10:
						hashloc = 0
				string = output
			return self.__brand__(output, 1, method)

	def __file__(self, title, out, method):
		try:
			handle = open(title,'rb')
			plaintext = handle.read()
			handle.close()
			handle = open(out, 'wb')
			handle.write(self.__crypt__(plaintext, method))
			handle.close()
		except IOError:
			err = 'Not a (existing) file/No write permission'
			raise CryptError(err)
		except CryptError:
			dump = open(title,'wb')
			dump.write(plaintext)
			dump.close()
			raise

	def Encrypt(self, plaintext):
		return self.__crypt__(plaintext, 1)

	def Decrypt(self, plaintext):
		return self.__crypt__(plaintext, 0)

	def EncryptFile(self, InputFile, OutputFile):
		self.__file__(InputFile, OutputFile, 1)

	def DecryptFile(self, InputFile, OutputFile):
		self.__file__(InputFile, OutputFile, 0)

	def SetPassphrase(self, passphrase):
		self.hash = self.__hash__(passphrase)

def __parseargs__():
	from optparse import OptionParser
	parser = OptionParser(usage='usage: %prog [options] [filename]\nhttp://www.stealth-x.com/apps/bcrypt.php')
	parser.add_option('-o', dest='output', metavar='file', default='', help='Output to a different file')
	parser.add_option('-t', dest='text', metavar='\'example\'', default='', help='Encrypt/decrypt a text string rather than [filename]')
	parser.add_option('-p', dest='password', metavar='password123', default='', help='Specify password on the command line. Not recommended.')
	return parser.parse_args()

if __name__ == '__main__':
	interface = Cryptor()
	options = __parseargs__()
	flags = options[0]

	if not flags.password:
		interface.SetPassphrase(getpass.getpass())
	else:
		interface.SetPassphrase(flags.password)

	t = time.time()
	try:
		if not flags.text:
			try:
				filename = options[1][0]

			except IndexError:
				print 'No file specified.'
				print sys.argv[0] + ' -h for help.'
				raise SystemExit

			else:
				if flags.output:
					destination = flags.output
				else:
					destination = filename
				try:
					interface.DecryptFile(filename, destination)
					sys.stdout.write('Decryption')

				except CryptError, e:
					if str(e) == 'Cannot decrypt: Not Bcrypt encrypted data':
						interface.EncryptFile(filename, destination)
						sys.stdout.write('Encryption')
					else:
						raise

			splittime = str(time.time()-t).split('.')	
			sys.stdout.write(' completed in ' + splittime[0] + '.' + splittime[1][:1] + ' seconds.\n')
			sys.stdout.flush()

		else:
			try:
				raw = ''
				for character in flags.text.split(':'):
					try:
						raw += chr(int(character, 16))
					except ValueError:
						pass
				output = interface.Decrypt(raw)

			except CryptError, e:
				if str(e) == 'Cannot decrypt: Not Bcrypt encrypted data':
					raw = interface.Encrypt(flags.text)
					output = ''
					for character in raw:
						output += '%02X:' % ord(character)
				else:
					raise

			print repr(output)[1:-1]

	except CryptError, e:
		if str(e) == 'Cannot decrypt: Incorrect passphrase':
			print 'Incorrect passphrase.\nThe data could not be decrypted.'
		else:
			print 'Unexpected error: ' + str(e)
