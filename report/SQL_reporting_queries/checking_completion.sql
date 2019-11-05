SELECT 
    viewname
    FROM pg_catalog.pg_views
    WHERE schemaname = 'reporting' 
    AND viewname LIKE '%_view'
    ORDER BY viewname
