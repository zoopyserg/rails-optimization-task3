# Case Study:
1. Setting up the app.
(it was outdated - Rails 5 + Ruby 2.6.3 - had to switch from Mac to Ubuntu and do bundle update mimemagic)
2. Launching the app - the app was broken:
- uninitialized constant StatisticsController (it really was missing, had to create it)
After fixing, the app worked.
3. Setting up NewRelic:
NewRelic is a paid tool. They have a free option - NewRelic One. Setting up that.
Followed step-by-step instructions on NewRelic to set it up for Ruby on Rails + Postgres.
Made a newrelic.yml and added it to gitignore
Took a screenshot of an initial state.
4. Setting up PGHero:
Gotcha: I had to do "cat postgresql.conf" and add these lines to all configs I had:
````
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
````
Did not see any issues.
5. Setting up rack mini profiler
6. Setting up Bullet
7. Opened the app.
8. Bullet alert popped up suggesting I should add `includes(bus: :services) to the trip scope, so I did.
9. Rack mini profiler shows that I did two similar requests:
- one for @trips.each
- one for @trips.count (hitting the database the 2nd time)
Changed scope.to_a so that count performs on the array, not on the database.
No more questionable queries at the page. Going to optimize "Import" now.
10. Running bin/setup (with small.json)
Opening PGHero to find any issues.
36% of the query is used by an indexquery. Checking what indexes the app has.
The only index is in pghero table.
It's recommended to add indexes for relation ids, but not doing it for now. Still looking.
The top 5 slowest queries are related to the profiling tools I set up.
11. Looking at the import code.
Hugely unoptimized import code.
Optimizing.
The app is Rails 5, it doesn't support "insert_all" yet.
First I thought adding the "activerecord-import" gem.
But then I chose the approach of creating a raw SQL string for insertion.
It complained that I need to add uniqueness constrains to the city names so I did.
12. Lots of new errors related to PGHero. Decided to drop it. It's creating too much mess in the SQL logs.
13. Optimized the import code by converting it into raw SQL handling.
Import time is under 10 seconds for large.json (the budget was 1 minute).
14. Trying to load the page with 100k trips: took way to long. Stopped. Investigating how to speed up.
I notice that the SQL itself takes just a second.
But the fact that it renders 100k partias takes the longest.
Uniting it into a single partial.
15. Removing mini-profiler and bullet because they are messing up my newrelic stats
This made my optimized code load instantly (100k pages load in under a second)

Optimization completed.

# Lecture Notes:
1. Suggested Rails profiling tools:
+ Newrelic
+ PGHero
- PGBadger
- PG Monitoring
- PG Admin
- Grafana + Prometheus Postgres Exporter
- Rails Panel (Chrome Extension + gem 'meta_request')
+ Rack Mini Profiler
-- Memory Profile
-- Flame Graph
-- Stackprof
+ Bullet
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
