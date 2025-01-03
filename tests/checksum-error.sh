assert_dir=$(mktemp -d)
migrations=$(mktemp -d)
db=$(mktemp)

cp ./migrations_template/s1-user.sql "$migrations"
cp ./migrations_template/s2-tweet.sql "$migrations"

tiny-sqlite-migrate --db "$db" --migrations "$migrations" >/dev/null

rm "$migrations/s1-user.sql"
cp ./migrations_template/s1-user-modified.sql "$migrations"

exit_code=0
tiny-sqlite-migrate --db "$db" --migrations "$migrations" >"$assert_dir/actual.txt" || exit_code=$?

if [ "$exit_code" -ne 1 ]; then
  echo "Error: Expected exit code 1, got $exit_code"
  exit 1
fi

cat >"$assert_dir/expected.txt" <<EOF
[CHECKSUM ERROR] s1-user-modified.sql
Migration ID      : 1
Database checksum : 381f19ca9e779d2eba9dc782173648f4
File checksum     : d99159a81c0783db8803674d16cba5e2
EOF

diff --unified --color=always "$assert_dir/expected.txt" "$assert_dir/actual.txt"

sqlite3 "$db" "SELECT name FROM sqlite_master WHERE type='table';" >"$assert_dir/actual.txt"

cat >"$assert_dir/expected.txt" <<EOF
migrations
sqlite_sequence
user
tweet
EOF

diff --unified --color=always "$assert_dir/expected.txt" "$assert_dir/actual.txt"
