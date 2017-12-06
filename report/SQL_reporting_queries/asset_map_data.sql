SET SEARCH_PATH = report_test, public;

with line as (
select facility, subfacility, product, platform_code, date_start, date_end, ST_DumpPoints(geom) as dp from asset_map
where ST_GeometryType(geom) IN ('ST_LineString', 'ST_MultiLineString'))

select facility, subfacility, product, platform_code, date_start, date_end, st_x(geom) as lon, st_y(geom) as lat, 'Point' as geometry_type from asset_map
where ST_GeometryType(geom) = 'ST_Point'

union all

select facility, subfacility, product, platform_code, date_start, date_end, st_x((dp).geom) as lon, st_y((dp).geom) as lat, 'Line' as geometry_type from line;