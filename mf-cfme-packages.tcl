#!/usr/bin/env tclsh
#
set pulp "http://pulp-read.dist.prod.ext.phx2.redhat.com"

set product "cloudforms_managementengine"

set post source/SRPMS	;# source rpm listing
#set post os				;# binary rpm listing

set REPOS {
    5.11 {
        cfme-5.11-for-rhel-8    content/dist/layered/rhel8/x86_64/cfme/5.11
    }
    5.10 {
        cf-me-5.10-for-rhel-7   content/dist/cf-me/server/5.10/x86_64
    }
}


foreach {version repos} $REPOS {
    set cpe "$product:$version/"
    set filename "cfme-$version.mf"
    set dnfargs {}
    foreach {repo path} $repos {
        set url "$pulp/$path/$post"
        puts "## $repo\t$url"
        lappend dnfargs --repofrompath=$repo,$url --repo=$repo
        exec dnf repoquery --repofrompath=$repo,$url --repo=$repo --latest-limit=1 -q \
            | sed -e {s/\.src$//} -e {s/-[0-9]\+:/-/g} \
            | sort -u \
            > $repo.mf
    }

    puts "## $filename"
    puts "+ [list dnf repoquery {*}$dnfargs --latest-limit=1 -q]"
    exec dnf repoquery {*}$dnfargs --latest-limit=1 -q \
            | sed -e {s/\.src$//} -e {s/-[0-9]\+:/-/g} \
            | sort -u \
            | sed -e "s,^,$cpe," \
            > $filename
}
