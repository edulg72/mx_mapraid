#!/bin/bash

cd /var/www/mx_mapraid/scripts/

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"

ruby scan_segments.rb $1 $2 -96.76 18.68 -96.49 18.59 0.09
ruby scan_segments.rb $1 $2 -96.76 18.59 -96.4 18.5 0.09
ruby scan_segments.rb $1 $2 -96.76 18.5 -96.31 18.41 0.09
ruby scan_segments.rb $1 $2 -96.85 18.41 -96.22 18.32 0.09
ruby scan_segments.rb $1 $2 -97.84 18.32 -97.57 18.23 0.09
ruby scan_segments.rb $1 $2 -97.03 18.32 -96.22 18.23 0.09
ruby scan_segments.rb $1 $2 -97.93 18.23 -97.57 18.14 0.09
ruby scan_segments.rb $1 $2 -97.39 18.23 -95.86 18.14 0.09
ruby scan_segments.rb $1 $2 -97.93 18.14 -95.77 18.05 0.09
ruby scan_segments.rb $1 $2 -98.2 18.05 -95.77 17.96 0.09
ruby scan_segments.rb $1 $2 -98.47 17.96 -95.77 17.87 0.09
ruby scan_segments.rb $1 $2 -98.56 17.87 -95.77 17.78 0.09
ruby scan_segments.rb $1 $2 -98.56 17.78 -95.86 17.69 0.09
ruby scan_segments.rb $1 $2 -95.32 17.78 -95.14 17.69 0.09
ruby scan_segments.rb $1 $2 -98.56 17.69 -95.77 17.6 0.09
ruby scan_segments.rb $1 $2 -95.5 17.69 -95.14 17.6 0.09
ruby scan_segments.rb $1 $2 -98.47 17.6 -95.14 17.51 0.09
ruby scan_segments.rb $1 $2 -98.38 17.51 -95.05 17.42 0.09
ruby scan_segments.rb $1 $2 -98.38 17.42 -94.96 17.33 0.09
ruby scan_segments.rb $1 $2 -98.38 17.33 -94.87 17.24 0.09
ruby scan_segments.rb $1 $2 -98.38 17.24 -94.06 17.15 0.09
ruby scan_segments.rb $1 $2 -98.29 17.15 -93.79 17.06 0.09
ruby scan_segments.rb $1 $2 -98.11 17.06 -93.88 16.97 0.09
ruby scan_segments.rb $1 $2 -98.2 16.97 -93.88 16.88 0.09
ruby scan_segments.rb $1 $2 -98.11 16.88 -93.97 16.79 0.09
ruby scan_segments.rb $1 $2 -98.29 16.79 -93.97 16.7 0.09
ruby scan_segments.rb $1 $2 -98.29 16.7 -93.97 16.61 0.09
ruby scan_segments.rb $1 $2 -98.47 16.61 -94.06 16.52 0.09
ruby scan_segments.rb $1 $2 -98.47 16.52 -94.06 16.43 0.09
ruby scan_segments.rb $1 $2 -98.56 16.43 -93.97 16.34 0.09
ruby scan_segments.rb $1 $2 -98.56 16.34 -93.97 16.25 0.09
ruby scan_segments.rb $1 $2 -98.29 16.25 -93.97 16.16 0.09
ruby scan_segments.rb $1 $2 -98.11 16.16 -95.14 16.07 0.09
ruby scan_segments.rb $1 $2 -94.42 16.16 -94.06 16.07 0.09
ruby scan_segments.rb $1 $2 -97.93 16.07 -95.32 15.98 0.09
ruby scan_segments.rb $1 $2 -94.15 16.07 -93.97 15.98 0.09
ruby scan_segments.rb $1 $2 -97.84 15.98 -95.41 15.89 0.09
ruby scan_segments.rb $1 $2 -97.21 15.89 -95.77 15.8 0.09
ruby scan_segments.rb $1 $2 -97.03 15.8 -95.95 15.71 0.09
ruby scan_segments.rb $1 $2 -96.76 15.71 -96.13 15.62 0.09

psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update segments set city_id = (select gid from cities_mapraid where ST_Contains(geom, ST_SetSRID(ST_Point(segments.longitude, segments.latitude), 4326)) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from segments where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'delete from streets where id in (select id from streets except select distinct street_id from segments);'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'update segments s1 set dc_density = (select count(*) from segments s2 where not s2.connected and s2.latitude between (s1.latitude - 0.01) and (s1.latitude + 0.01) and s2.longitude between (s1.longitude - 0.01) and (s1.longitude + 0.01)) where not s1.connected and s1.dc_density is null;'
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "delete from updates where object = 'segments';"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "insert into updates (updated_at, object) values (current_timestamp,'segments');"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "refresh materialized view vw_segments;"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c "refresh materialized view vw_streets;"
psql -h $POSTGRESQL_DB_HOST -d mx_mapraid -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
