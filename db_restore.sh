# Restore a dump. Note that this will erase all esisting data.
# Usage: db_restore.sh <Path to database dump file>
DUMP=$1
CTR=`docker ps | grep mdr-db | awk '{print $1}'`
echo DUMP=$DUMP CTR=$CTR
cat $DUMP | docker exec -t $CTR  pg_restore -c -U mdr

