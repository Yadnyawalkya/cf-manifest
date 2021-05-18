#!/usr/bin/env sh
#
# To manifest the contents of CloudForms packages that bundle lots of gems, we list the
# binary package's content using repoquery and use the directory names under either
# /opt/rh/*/gems or /opt/redhat/*/bundle/ruby/2.4.0/gems

set -uex

all_ver=(5.11)

for cfme_ver in ${all_ver[*]}; do
	repo="http://rhsm-pulp.corp.redhat.com/content/dist/layered/rhel8/x86_64/cfme/5.11/os/"
	cpe_prefix="cloudforms_managementengine:$cfme_ver"

	for name in cfme-amazon-smartstate; do
		pkg="$(dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 $name)"
		pkg=${pkg%.x86_64}
		pkg=${pkg%.noarch}
		# echo $pkg
		dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 -l $name \
			| grep "gems/" | awk -F / '{ print $7; }' | uniq \
			| while read gem; do
				echo "$cpe_prefix/$pkg:rubygem:$gem"
		done
	done | tee "cfme-$cfme_ver-rubygems-$1.mf"
done
