#!/usr/bin/env sh
#
# To manifest the contents of CloudForms packages that bundle lots of gems, we list the
# binary package's content using repoquery and use the directory names under either
# /opt/rh/*/gems or /opt/redhat/*/bundle/ruby/2.4.0/gems

set -uex

cfme_ver="5.11"
brew_tag="cfme-$cfme_ver-rhel-7"
repo="http://rhsm-pulp.corp.redhat.com/content/dist/layered/rhel8/x86_64/cfme/$cfme_ver/os/"
cpe_prefix="cloudforms_managementengine:$cfme_ver"

for name in cfme-gemset cfme-amazon-smartstate; do
	pkg="$(dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 $name)"
	pkg=${pkg%.x86_64}
	pkg=${pkg%.noarch}
	dnf repoquery --repofrompath=1,$repo --repoid=1 --latest-limit=1 -l $name \
		| sed -ne 's@/opt/\(rh/\)\?[^/]\+/\(gems\|vendor/bundle/ruby/[^/]\+/gems\)/\([^/]\+\)$@\3@p' \
		| while read gem; do
			echo "$cpe_prefix/$pkg:rubygem:$gem"
	done
done | tee "$brew_tag.rubygems.mf"
