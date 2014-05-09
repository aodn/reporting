
SET search_path = reporting, pg_catalog;

-- drop all current views
select admin.exec( 'drop view if exists '||schema||'.'||name||' cascade' ) 
	from admin.objects3 
	where kind = 'v' 
	and schema = 'reporting'


