#!/bin/bash

timestamp=`date +%m%d%Y-%N`
filename="cfme-manifest$timestamp.txt"
dirpath="/home/$(whoami)/prodsec/manifests"
filepath="$dirpath/manifest.txt"
pwd=$(pwd)

# getting packages
bash mf-cfme-510-gems.sh $timestamp
bash mf-cfme-511-gems.sh $timestamp
tclsh mf-cfme-packages.tcl

# generating full files
touch cfme-manifest.mf
cat cfme-5.10.mf > cfme-manifest.mf
cat cfme-5.10-rubygems-$timestamp.mf >> cfme-manifest.mf
cat cfme-5.11.mf >> cfme-manifest.mf
cat cfme-5.11-rubygems-$timestamp.mf >> cfme-manifest.mf

# merger
cd $dirpath;
git add .
git stash
git checkout master
git reset HEAD~5
git add .
git stash
git pull origin master

sed -i '\|cloudforms_managementengine|d' $filepath
git add $filepath
git commit -m "Removed packages from CloudForms manifest $timestamp"

cat "$pwd/cfme-manifest.mf" >> $filepath

git add $filepath
git commit -m "Updated packages from CloudForms manifest $timestamp"
