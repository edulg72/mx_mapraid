#!/bin/bash

cd /var/www/mx_mapraid/scripts

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"

psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from ur; delete from mp;'

ruby scan_UR.rb $1 $2 -98.06 18.68 -96.06 18.18 0.5
ruby scan_UR.rb $1 $2 -98.56 18.18 -95.06 17.68 0.5
ruby scan_UR.rb $1 $2 -98.56 17.68 -94.56 17.18 0.5
ruby scan_UR.rb $1 $2 -98.56 17.18 -93.56 16.68 0.5
ruby scan_UR.rb $1 $2 -98.56 16.68 -93.56 16.18 0.5
ruby scan_UR.rb $1 $2 -98.56 16.18 -95.06 15.68 0.5
ruby scan_UR.rb $1 $2 -94.56 16.18 -93.56 15.68 0.5
ruby scan_UR.rb $1 $2 -97.06 15.68 -96.06 15.18 0.5

psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update ur set city_id = (select gid from cities_mapraid where ST_Contains(geom, ur.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update mp set city_id = (select gid from cities_mapraid where ST_Contains(geom, mp.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update mp set weight = 0 where weight is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from ur where city_id is null; delete from mp where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_ur;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_mp;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "update updates set updated_at = current_timestamp where object = 'ur';"

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
