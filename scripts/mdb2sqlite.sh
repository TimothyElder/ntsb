#!/bin/bash
# Inspired by 
# https://www.codeenigma.com/community/blog/using-mdbtools-nix-convert-microsoft-access-mysql

# USAGE
# Rename your MDB file to migration-export.mdb 
# run ./mdb2sqlite.sh migration-export.mdb
# wait and wait a bit longer...

sqlite=sqlite3
fname=$1
sql=${fname/mdb/sqlite}
schema=${fname/mdb/schema}

mdb-schema $fname sqlite > $schema

for i in $( mdb-tables $fname ); do 
  echo $i  
  mdb-export -D "%Y-%m-%d %H:%M:%S" -H -I sqlite $fname $i > $i.sql
done

< $schema $sqlite $sql

for f in *.sql ; do 
  echo $f 
  (echo 'BEGIN;'; cat $f; echo 'COMMIT;') | $sqlite $sql
  
done