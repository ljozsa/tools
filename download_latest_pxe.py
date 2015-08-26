#!/usr/bin/python

import re, requests, sys

url = sys.argv[1]

# get latest fedora compose
r = requests.get(url)
text = r.text
m = re.findall('href="(\d{4}-\d{2}-\d{2})', text)
m.sort()
latest = m[-1]

# find fedora version
compose_list = url + latest + '/'
r = requests.get(compose_list)
text = r.text
m = re.findall('href="(\d{2})/', text)
fedora_version = m[0]

compose_and_fedora_ver = compose_list + fedora_version + '/'

# find all files in pxetolive dir
complete_url = compose_and_fedora_ver + 'Cloud_Atomic/x86_64/pxetolive/'
r = requests.get(complete_url)
text = r.text
m = re.findall('href="([^"?]+)"', text)

# download all files from pxetolive dir
for file in m[1:]:
	r = requests.get(complete_url + file, stream=True)
	total_length = int(r.headers['content-length'])
	with open(file, 'wb') as f:
		dl = 0
		print "Downloading %s" %  file
		for chunk in r.iter_content(chunk_size=1024):
			if chunk:
				dl += len(chunk)
				f.write(chunk)
				f.flush()
				done = int(50 * dl / total_length)
				sys.stdout.write("\r[%s%s]" % ('=' * done, ' ' * (50-done)) )
				sys.stdout.flush()
		print '\n'
