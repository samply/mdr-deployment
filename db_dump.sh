# Take a snapshot of the entire MDR database
mkdir -p mdr-db
CTR=`docker ps | grep mdr-db | awk '{print $1}'`
echo CTR=$CTR
docker exec -t $CTR  pg_dumpall -c -U mdr > images/mdr-db/dump_$(date +"%Y-%m-%d_%H_%M_%S").sql

