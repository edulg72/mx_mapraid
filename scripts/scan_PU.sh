#!/bin/bash

cd /var/www/mx_mapraid/scripts

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from pu; delete from places;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'vacuum pu;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'vacuum places;'

ruby scan_PU.rb $1 $2 -98.06 18.68 -96.06 18.18 0.5
ruby scan_PU.rb $1 $2 -98.56 18.18 -95.06 17.68 0.5
ruby scan_PU.rb $1 $2 -98.56 17.68 -94.56 17.18 0.5
ruby scan_PU.rb $1 $2 -98.56 17.18 -93.56 16.68 0.5
ruby scan_PU.rb $1 $2 -98.56 16.68 -93.56 16.18 0.5
ruby scan_PU.rb $1 $2 -98.56 16.18 -95.06 15.68 0.5
ruby scan_PU.rb $1 $2 -94.56 16.18 -93.56 15.68 0.5
ruby scan_PU.rb $1 $2 -97.06 15.68 -96.06 15.18 0.5

psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update pu set city_id = (select gid from cities_mapraid where ST_Contains(geom, pu.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from pu where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_pu;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "update updates set updated_at = current_timestamp where object = 'pu';"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'vacuum pu;'

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
