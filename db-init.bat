psql -d cs2102project -f DB/schema.sql -U postgres
psql -d cs2102project -f DB/data.sql -U postgres
psql -d cs2102project -f DB/proc.sql -U postgres
