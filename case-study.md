1. Learning Rails profiling tools:
- Newrelic
- PGHero
- PGBadger
- PG Monitoring
- PG Admin
- Grafana + Prometheus Postgres Exporter
- Rails Panel (Chrome Extension + gem 'meta_request')
- Rack Mini Profiler
-- Memory Profile
-- Flame Graph
-- Stackprof
- Bullet
2. Analyzing main problems:
- Indexes
-- btree (for <, >, =, <=, >=) - constant search time - created using add_index
-- hash - worse than btree
-- gist - for geometric data, e.g. for rectangles on maps + framework for creating custom indexes
-- gin - for data that consists of multiple values, e.g. text search, jsonb, array
-- index for jsonb value - t.index (data -> 'key')
- multicolumn
- partial - for queries that use only a part of the index
- Unnecessary joins
- JSON vs JSONB
- JSONB vs MongoDB
3. PSQL commands:
\timing - show time of query execution
\x - toggle expanded output
\di - show indexes
explain - show query plan, don't perform the query
explain analyze - show query plan and perform the query
explain.depesz.com - analyze query plan
pghero - paste SQL and hit visualize
4. Alerts for cap of how many milliseconds a query can take
5. Newrelic screenshots
6. Strong Migrations
7. Data-Migrate
8. Present/Any/Exists (slow/faster/fastest)
9. N+1 queries
joins - filtering intersections
preload - book.preload(:author) - always 2 queries - no access to the author attributes, so book.where(authors: {name: 'John'}) will not work
eager_load - left outer join - 1 query - access to the author attributes: books.eager_load(:author).where(authors: {name: 'John'})
includes - tries to guess the best strategy - preload or eager_load - it's better to choose manually
10. Select/Pluck
select - only necessary columns
pluck - only necessary columns
11. Transaction
transaction do
  # code
end
