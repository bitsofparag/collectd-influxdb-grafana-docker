[meta]
  # Where the metadata/raft database is stored
  dir = "/var/lib/influxdb/meta"

[data]
  # The directory where the TSM storage engine stores TSM files.
  dir = "/var/lib/influxdb/data"
  # The directory where the TSM storage engine stores WAL files.
  wal-dir = "/var/lib/influxdb/wal"

[[collectd]]
  enabled = true
  bind-address = ""
  database = "mydb"
  typesdb = "/var/lib/influxdb/data/types.db"

[[udp]]
  enabled = true
  bind-address = ":8086"
  database = "mydb"
  batch-size = 100