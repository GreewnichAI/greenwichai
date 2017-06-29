d:
cd \www\srip
call rake pertrac:clean
call rake pertrac:sync
zip d:\zzz\pertrac_current.zip pertrac_current.mdb
