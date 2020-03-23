#!/usr/bin/env sh
#
# To manifest the contents of CloudForms packages that bundle lots of gems, we list the
# binary package's content using repoquery and use the directory names under either
# /opt/rh/*/gems or /opt/redhat/*/bundle/ruby/2.4.0/gems

set -uex

all_ver=(5.10)

for cfme_ver in ${all_ver[*]}; do
	repo="http://pulp-read.dist.prod.ext.phx2.redhat.com/content/dist/cf-me/server/$cfme_ver/x86_64/os"
	cpe_prefix="cloudforms_managementengine:$cfme_ver"

	for name in cfme-gemset cfme-amazon-smartstate dbus-api-service httpd-configmap-generator; do
		pkg="$(dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 $name)"
		pkg=${pkg%.x86_64}
		pkg=${pkg%.noarch}
		#echo $pkg
		dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 -l $name \
			| sed -ne 's@/opt/\(rh/\)\?[^/]\+/\(gems\|vendor/bundle/ruby/[^/]\+/gems\)/\([^/]\+\)$@\3@p' \
			| while read gem; do
				echo "$cpe_prefix/$pkg:rubygem:$gem"
		done
	done | tee "cfme-$cfme_ver-rubygems-$1.mf"
done
