assert_dir=$(mktemp -d)
migration_dir=$(mktemp -d)
db=$(mktemp)

cp ./migrations/s1-user.sql "$migration_dir"
tiny-sqlite-migrate --db "$db" --migrations "$migration_dir"

cp ./migrations/s2-tweet.sql "$migration_dir"
tiny-sqlite-migrate --db "$db" --migrations "$migration_dir" --validate-only >"$assert_dir/actual.txt"

cat >"$assert_dir/expected.txt" <<EOF
[CHECKSUM MATCH] s1-user.sql
[NOT APPLIED]    s2-tweet.sql
EOF

diff --unified --color=always "$assert_dir/expected.txt" "$assert_dir/actual.txt"