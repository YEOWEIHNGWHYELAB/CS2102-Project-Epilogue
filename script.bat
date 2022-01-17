psql -d project_db -f schema.sql -U postgres
psql -d project_db -f data.sql -U postgres
psql -d project_db -f proc.sql -U postgres
