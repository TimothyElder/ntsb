#!/bin/bash
# Inspired by 
# https://www.codeenigma.com/community/blog/using-mdbtools-nix-convert-microsoft-access-mysql

# USAGE
# Rename your MDB file to migration-export.mdb 
# run ./mdb2sqlite.sh migration-export.mdb
# wait and wait a bit longer...

now=$(date +%s)
sqlite=sqlite3
fname=$1
sql=${fname/mdb/sqlite}
schema=${fname/mdb/schema}
dir=${fname/.mdb/}-$now

mkdir $dir

mdb-schema $fname sqlite > $dir/$schema

for i in $( mdb-tables $fname ); do 
  echo $i  
  mdb-export -D "%Y-%m-%d %H:%M:%S" -H -I sqlite $fname $i > $dir/$i.sql
done

< $dir/$schema $sqlite $sql

for f in $dir/*.sql ; do 
  echo $f 
  (echo 'BEGIN;'; cat $f; echo 'COMMIT;') | $sqlite $sql
  
done
echo "Using $dir"