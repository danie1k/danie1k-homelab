#/bin/sh
set -e

# [string] TCP address to listen for http connections (default ":8428")
export VM__httpListenAddr='0.0.0.0:{{ services.victoriametrics.ingest.port.http }}'

# Whether to enable IPv6 for listening and dialing.
# By default only IPv4 TCP and UDP is used
#export VM__enableTCP6=1

# [size] The maximum size in bytes of a single DataDog POST request
# to /api/v1/series (default 67108864).
#export VM__datadog_maxInsertRequestSize=

# Whether to deny queries outside of the configured -retentionPeriod. When set,
# then /api/v1/query_range would return '503 Service Unavailable' error for
# queries with 'from' value outside -retentionPeriod. This may be useful when
# multiple data sources with distinct retentions are hidden behind query-tee
#export VM__denyQueriesOutsideRetention=1

# Whether to use pread() instead of mmap() for reading data files.
# By default mmap() is used for 64-bit arches and pread() is used for 32-bit
# arches, since they cannot read data files bigger than 2^32 bytes in memory.
# mmap() is usually faster for reading small data chunks than pread()
#export VM__fs_disableMmap=1

# [duration] The maximum duration for waiting in the queue for insert requests
# due to -maxConcurrentInserts (default 1m0s)
#export VM__insert_maxQueueDuration=

# [int] The maximum number of concurrent inserts. Default value should work for
# most cases, since it minimizes the overhead for concurrent inserts. This
# option is tighly coupled with -insert.maxQueueDuration (default 32)
#export VM__maxConcurrentInserts=

# [int] The number of precision bits to store per each value. Lower precision
# bits improves data compression at the cost of precision loss (default 64)
#export VM__precisionBits=

# region: Importing
# -----------------------------------------------------------------------------

# [duration] Trim timestamps when importing csv data to this duration.
# Minimum practical duration is 1ms. Higher duration (i.e. 1s) may be used for
# reducing disk space usage for timestamp data (default 1ms)
#export VM__csvTrimTimestamp=

# [size] The maximum length in bytes of a single line accepted
# by /api/v1/import; the line length can be limited with 'max_rows_per_line'
# query arg passed to /api/v1/export (default 104857600).
#export VM__import_maxLineLen=

#endregion


# region: Labels
# -----------------------------------------------------------------------------

# [int] The maximum length of label values in the accepted time series. Longer
# label values are truncated. In this case the vm_too_long_label_values_total
# metric at /metrics page is incremented (default 16384)
#export VM__maxLabelValueLen=

# [int] The maximum number of labels accepted per time series. Superfluous
# labels are dropped. In this case the vm_metrics_with_dropped_labels_total
# metric at /metrics page is incremented (default 30)
export VM__maxLabelsPerTimeseries=100

# [string] Optional path to a file with relabeling rules, which are applied to
# all the ingested metrics. The path can point either to local file or to http
# url.
# See https://docs.victoriametrics.com/#relabeling for details.
# The config is reloaded on SIGHUP signal
#export VM__relabelConfig=

# Whether to log metrics before and after relabeling with -relabelConfig. If
# the -relabelDebug is enabled, then the metrics aren't sent to storage.
# This is useful for debugging the relabeling configs
#export VM__relabelDebug=

# Whether to sort labels for incoming samples before writing them to storage.
# This may be needed for reducing memory usage at storage when the order of
# labels in incoming samples is random. For example, if m{k1="v1",k2="v2"} may
# be sent as m{k2="v2",k1="v1"}.
# Enabled sorting for labels can slow down ingestion performance a bit
#export VM__sortLabels=

#endregion


# region: Memory Cache
# -----------------------------------------------------------------------------

# [size] Allowed size of system memory VictoriaMetrics caches may occupy. This
# option overrides -memory.allowedPercent if set to a non-zero value. Too low a
# value may increase the cache miss rate usually resulting in higher CPU and
# disk IO usage. Too high a value may evict too much data from OS page cache
# resulting in higher disk IO usage (default 0).
#export VM__memory_allowedBytes=

# [float] Allowed percent of system memory VictoriaMetrics caches may occupy.
# See also -memory.allowedBytes. Too low a value may increase cache miss rate
# usually resulting in higher CPU and disk IO usage. Too high a value may evict
# too much data from OS page cache which will result in higher disk IO usage
# (default 60)
#export VM__memory_allowedPercent=

#endregion


# region: Data compaction (merging)
# -----------------------------------------------------------------------------

# [int] The maximum number of CPU cores to use for big merges.
# Default value is used if set to 0
#export VM__bigMergeConcurrency=

# [int] The maximum number of CPU cores to use for small merges.
# Default value is used if set to 0
#export VM__smallMergeConcurrency=

# [duration] The delay before starting final merge for per-month partition
# after no new data is ingested into it. Final merge may require additional
# disk IO and CPU resources. Final merge may increase query speed and reduce
# disk space usage in some cases. Zero value disables final merge
#export VM__finalMergeDelay=

#endregion


# region: Scraping
# -----------------------------------------------------------------------------

# [duration] Leave only the first sample in every time series per each discrete
# interval equal to -dedup.minScrapeInterval > 0.
# See https://docs.victoriametrics.com/#deduplication
# and https://docs.victoriametrics.com/#downsampling
#export VM__dedup_minScrapeInterval=

# [string] Value for 'instance' label, which is added to self-scraped metrics
# (default "self")
#export VM__selfScrapeInstance=

# [duration] Interval for self-scraping own metrics at /metrics page
#export VM__selfScrapeInterval=

# [string] Value for 'job' label, which is added to self-scraped metrics
# (default "victoria-metrics")
#export VM__selfScrapeJob=

#endregion


# =============================================================================
# region: Storage
# =============================================================================

# [string] Path to storage data (default "victoria-metrics-data")
export VM__storageDataPath='{{ vm_storage_dir }}'

# [value] Data with timestamps outside the retentionPeriod is automatically
# deleted (default 1 month)
# Supported suffixes: h (hour), d (day), w (week), y (year).
export VM__retentionPeriod='6'

# [size] Overrides max size for indexdb/dataBlocks cache (default 0).
# See https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#cache-tuning
#export VM__storage_cacheSizeIndexDBDataBlocks=

# [size] Overrides max size for indexdb/indexBlocks cache (default 0).
# See https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#cache-tuning
#export VM__storage_cacheSizeIndexDBIndexBlocks=

# [size] Overrides max size for storage/tsid cache (default 0).
# See https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#cache-tuning
#export VM__storage_cacheSizeStorageTSID=

# [int] The maximum number of unique series can be added to the storage during
# the last 24 hours. Excess series are logged and dropped. This can be useful
# for limiting series churn rate. See also -storage.maxHourlySeries
#export VM__storage_maxDailySeries=

# [int] The maximum number of unique series can be added to the storage during
# the last hour. Excess series are logged and dropped. This can be useful for
# limiting series cardinality. See also -storage.maxDailySeries
#export VM__storage_maxHourlySeries=

# [size] The minimum free disk space at -storageDataPath after which the
# storage stops accepting new data (default 10000000).
export VM__storage_minFreeDiskSpaceBytes='100MB'

#endregion


# =============================================================================
# region: Logging
# =============================================================================

# Whether to log new series. This option is for debug purposes only. It can
# lead to performance issues when big number of new series are ingested
# into VictoriaMetrics
#export VM__logNewSeries=

# Whether to disable writing timestamps in logs
#export VM__loggerDisableTimestamps=1

# [int] Per-second limit on the number of ERROR messages. If more than the
# given number of errors are emitted per second, the remaining errors are
# suppressed. Zero values disable the rate limit
#export VM__loggerErrorsPerSecondLimit=

# [string] Format for logs. Possible values: default, json (default "default")
#export VM__loggerFormat=

# [string] Minimum level of errors to log.
# Possible values: INFO, WARN, ERROR, FATAL, PANIC (default "INFO")
export VM__loggerLevel='{{ services.victoriametrics.log_level }}'

# [string] Output for the logs.
# Supported values: stderr, stdout (default "stderr")
export VM__loggerOutput='stderr'

# [string] Timezone to use for timestamps in logs. Timezone must be a valid
# IANA Time Zone. For example: America/New_York, Europe/Berlin, Etc/GMT+3
# or Local (default "UTC")
export VM__loggerTimezone='{{ docker_config.container_timezone }}'

# [int] Per-second limit on the number of WARN messages. If more than the given
# number of warns are emitted per second, then the remaining warns are
# suppressed. Zero values disable the rate limit
export VM__loggerWarnsPerSecondLimit=0

#endregion


# =============================================================================
# region: Auth Keys
# =============================================================================

# [string] Authorization key for accessing /config page. It must be passed via authKey query arg
#export VM__configAuthKey=
# [string] authKey for metrics' deletion via /api/v1/admin/tsdb/delete_series and /tags/delSeries
#export VM__deleteAuthKey=
# [string] authKey, which must be passed in query string to /internal/force_flush pages
#export VM__forceFlushAuthKey=
# [string] authKey, which must be passed in query string to /internal/force_merge pages
#export VM__forceMergeAuthKey=
# [string] Auth key for /metrics. It must be passed via authKey query arg. It overrides httpAuth.* settings
#export VM__metricsAuthKey=
# [string] Auth key for /debug/pprof. It must be passed via authKey query arg. It overrides httpAuth.* settings
#export VM__pprofAuthKey=
# [string] Optional authKey for resetting rollup cache via /internal/resetRollupResultCache call
#export VM__search_resetCacheAuthKey=
# [string] authKey, which must be passed in query string to /snapshot* pages
#export VM__snapshotAuthKey=

#endregion


# =============================================================================
# region: HTTP
# =============================================================================


# [duration] Incoming http connections are closed after the configured timeout.
# This may help to spread the incoming load among a cluster of services BEHIND
# A LOAD BALANCER. Please note that the real timeout may be bigger by up to 10%
# as a protection against the thundering herd problem (default 2m0s)
#export VM__http_connTimeout=

# Disable compression of HTTP responses to save CPU resources.
# By default compression is enabled to save network bandwidth
#export VM__http_disableResponseCompression=1

# [duration] Timeout for incoming idle http connections (default 1m0s)
#export VM__http_idleConnTimeout=

# [duration] The maximum duration for a graceful shutdown of the HTTP server.
# A highly loaded server may require increased value for a graceful shutdown
# (default 7s)
#export VM__http_maxGracefulShutdownDuration=

# [string] An optional prefix to add to all the paths handled by http server.
# For example, if '-http.pathPrefix=/foo/bar' is set, then all the http
# requests will be handled on '/foo/bar/*' paths. This may be useful for
# proxied requests.
# See https://www.robustperception.io/using-external-urls-and-proxies-with-prometheus
#export VM__http_pathPrefix=

# [duration] Optional delay before http server shutdown. During this delay, the
# server returns non-OK responses from /health page, so load balancers can
# route new requests to other servers
#export VM__http_shutdownDelay=

# HTTP Basic Auth -------------------------------------------------------------
# The authentication is disabled if -httpAuth.username is empty.
# The authentication is disabled if -httpAuth.password is empty.

# [string] Password for HTTP Basic Auth.
#export VM__httpAuth_password=
# [string] Username for HTTP Basic Auth
#export VM__httpAuth_username=

# TLS -------------------------------------------------------------------------
# The provided key files are automatically re-read every second,
# so they can be dynamically updated

# Whether to enable TLS (aka HTTPS) for incoming requests. -tlsCertFile and
# -tlsKeyFile must be set if -tls is set
{% if not services.victoriametrics.ingest.https|bool %}#{% endif %}export VM__tls=1

# [string] Path to file with TLS certificate. Used only if -tls is set.
# Prefer ECDSA certs instead of RSA certs as RSA certs are slower.
{% if not services.victoriametrics.ingest.https|bool %}#{% endif %}export VM__tlsCertFile='{{ unraid.tls_storage_dir }}/cert.pem'

# [string] Path to file with TLS key. Used only if -tls is set.
{% if not services.victoriametrics.ingest.https|bool %}#{% endif %}export VM__tlsKeyFile='{{ unraid.tls_storage_dir }}/privkey.pem'

#endregion

# =============================================================================
# region: Search
# =============================================================================

# [duration] The maximum duration since the current time for response data,
# which is always queried from the original raw data, without using the
# response cache. Increase this value if you see gaps in responses due to time
# synchronization issues between VictoriaMetrics and data sources.
# See also -search.disableAutoCacheReset (default 5m0s)
#export VM__search_cacheTimestampOffset=

# Whether to disable automatic response cache reset if a sample with timestamp
# outside -search.cacheTimestampOffset is inserted into VictoriaMetrics
#export VM__search_disableAutoCacheReset=

# Whether to disable response caching. This may be useful during data
# backfilling
#export VM__search_disableCache=

# [duration] The time when data points become visible in query results after
# the collection. Too small value can result in incomplete last points for
# query results (default 30s)
#export VM__search_latencyOffset=

# [duration] Log queries with execution time exceeding this value.
# Zero disables slow query logging (default 5s)
#export VM__search_logSlowQueryDuration=

# [int] The maximum number of concurrent search requests. It shouldn't be high,
# since a single request can saturate all the CPU cores.
# See also -search.maxQueueDuration (default 8)
#export VM__search_maxConcurrentRequests=

# [duration] The maximum duration for /api/v1/export call (default 720h0m0s)
#export VM__search_maxExportDuration=

# [int] The maximum points per a single timeseries returned
# from /api/v1/query_range. This option doesn't limit the number of scanned raw
# samples in the database. The main purpose of this option is to limit the
# number of per-series points returned to graphing UI such as Grafana. There is
# no sense in setting this limit to values bigger than the horizontal r
# esolution of the graph (default 30000)
#export VM__search_maxPointsPerTimeseries=

# [duration] The maximum duration for query execution (default 30s)
#export VM__search_maxQueryDuration=

# [size] The maximum search query length in bytes (default 16384).
#export VM__search_maxQueryLen=

# [duration] The maximum time the request waits for execution
# when -search.maxConcurrentRequests limit is reached.
# See also -search.maxQueryDuration (default 10s)
#export VM__search_maxQueueDuration=

# [int] The maximum number of raw samples a single query can process across all
# time series. This protects from heavy queries, which select unexpectedly high
# number of raw samples.
# See also -search.maxSamplesPerSeries (default 1000000000)
#export VM__search_maxSamplesPerQuery=

# [int] The maximum number of raw samples a single query can scan per each time
# series. This option allows limiting memory usage (default 30000000)
#export VM__search_maxSamplesPerSeries=

# [duration] The maximum interval for staleness calculations. By default it is
# automatically calculated from the median interval between samples. This flag
# could be useful for tuning Prometheus data model closer to Influx-style data
# model.
# See https://prometheus.io/docs/prometheus/latest/querying/basics/#staleness
#export VM__search_maxStalenessInterval=

# [duration] The maximum duration for /api/v1/status/* requests (default 5m0s)
#export VM__search_maxStatusRequestDuration=

# [duration] The maximum step when /api/v1/query_range handler adjusts points
# with timestamps closer than -search.latencyOffset to the current time.
# The adjustment is needed because such points may contain incomplete data
# (default 1m0s)
#export VM__search_maxStepForPointsAdjustment=

# [int] The maximum number of tag keys returned from /api/v1/labels
# (default 100000)
#export VM__search_maxTagKeys=

# [int] The maximum number of tag value suffixes returned from /metrics/find
# (default 100000)
#export VM__search_maxTagValueSuffixesPerSearch=

# [int] The maximum number of tag values returned
# from /api/v1/label/<label_name>/values (default 100000)
#export VM__search_maxTagValues=

# [int] The maximum number of unique time series each search can scan. This
# option allows limiting memory usage (default 300000)
#export VM__search_maxUniqueTimeseries=

# [duration] The minimum interval for staleness calculations. This flag could
# be useful for removing gaps on graphs generated from time series with
# irregular intervals between samples.
# See also '-search.maxStalenessInterval'
#export VM__search_minStalenessInterval=

# [int] Query stats for /api/v1/status/top_queries is tracked on this number of
# last queries. Zero value disables query stats tracking (default 20000)
#export VM__search_queryStats_lastQueriesCount=

# [duration] The minimum duration for queries to track in query stats
# at /api/v1/status/top_queries. Queries with lower duration are ignored
# in query stats (default 1ms)
#export VM__search_queryStats_minQueryDuration=


#endregion


# =============================================================================
# region: 3rd party integrations
# =============================================================================

# Graphite --------------------------------------------------------------------

# [string] TCP and UDP address to listen for Graphite plaintext data.
# Usually :2003 must be set. Doesn't work if empty
export VM__graphiteListenAddr={% if services.victoriametrics.ingest.port.graphite | trim != '' %}'0.0.0.0:{{ services.victoriametrics.ingest.port.graphite }}'{% endif %}

# [duration] Trim timestamps for Graphite data to this duration.
# Minimum practical duration is 1s. Higher duration (i.e. 1m) may be used for
# reducing disk space usage for timestamp data (default 1s)
#export VM__graphiteTrimTimestamp=

# InfluxDB --------------------------------------------------------------------

# [array] Comma-separated list of database names to return from /query
# and /influx/query API. This can be needed for accepting data from Telegraf
# plugins such as https://github.com/fangli/fluent-plugin-influxdb
export VM__influx_databaseNames='influxdb'

# [size] The maximum size in bytes for a single InfluxDB line during parsing.
# Default: 262144
#export VM__influx_maxLineSize=

# [string] Default label for the DB name sent over '?db={db_name}' query
# parameter (default "db")
#export VM__influxDBLabel=

# [string] TCP and UDP address to listen for InfluxDB line protocol data.
# Usually :8189 must be set. Doesn't work if empty.
# This flag isn't needed when ingesting data over HTTP - just send it
# to http://<victoriametrics>:8428/write
#export VM__influxListenAddr={% if services.influxdb.ingest.port.http | trim != '' %}'0.0.0.0:{{ services.influxdb.ingest.port.http }}'{% endif %}

# [string] Separator for '{measurement}{separator}{field_name}' metric name
# when inserted via InfluxDB line protocol (default "_")
#export VM__influxMeasurementFieldSeparator=

# Uses '{field_name}' as a metric name while ignoring '{measurement}'
# and '-influxMeasurementFieldSeparator'
#export VM__influxSkipMeasurement=

# Uses '{measurement}' instead of '{measurement}{separator}{field_name}'
# for metric name if InfluxDB line contains only a single field
#export VM__influxSkipSingleField=

# [duration] Trim timestamps for InfluxDB line protocol data to this duration.
# Minimum practical duration is 1ms. Higher duration (i.e. 1s) may be used for
# reducing disk space usage for timestamp data (default 1ms)
export VM__influxTrimTimestamp='1s'


# OpenTSDB --------------------------------------------------------------------

# [string] TCP address to listen for OpentTSDB HTTP put requests.
# Usually :4242 must be set. Doesn't work if empty
export VM__opentsdbHTTPListenAddr={% if services.victoriametrics.ingest.port.opentsdb | trim != '' %}'0.0.0.0:{{ services.victoriametrics.ingest.port.opentsdb }}'{% endif %}

# [string] TCP and UDP address to listen for OpentTSDB metrics.
# Telnet put messages and HTTP /api/put messages are simultaneously served
# on TCP port. Usually :4242 must be set. Doesn't work if empty
export VM__opentsdbListenAddr={% if services.victoriametrics.ingest.port.opentsdb | trim != '' %}'0.0.0.0:{{ services.victoriametrics.ingest.port.opentsdb }}'{% endif %}

# [duration] Trim timestamps for OpenTSDB 'telnet put' data to this duration.
# Minimum practical duration is 1s. Higher duration (i.e. 1m) may be used for
# reducing disk space usage for timestamp data (default 1s)
#export VM__opentsdbTrimTimestamp=

# [duration] Trim timestamps for OpenTSDB HTTP data to this duration.
# Minimum practical duration is 1ms. Higher duration (i.e. 1s) may be used for
# reducing disk space usage for timestamp data (default 1ms)
#export VM__opentsdbhttpTrimTimestamp=

# [size] The maximum size of OpenTSDB HTTP put request. Default: 33554432
#export VM__opentsdbhttp_maxInsertRequestSize=


# Prometheus ------------------------------------------------------------------

# [size] The maximum size in bytes of a single Prometheus remote_write API
# request (default 33554432)
#export VM__maxInsertRequestSize=

# Set this flag to true if the database doesn't contain Prometheus stale
# markers, so there is no need in spending additional CPU time on its handling.
# Staleness markers may exist only in data obtained from Prometheus scrape
# targets
#export VM__search_noStaleMarkers=1

# [int] The number of number in the cluster of scrapers. It must be an unique
# value in the range 0 ... promscrape.cluster.membersCount-1 across scrapers
# in the cluster
#export VM__promscrape_cluster_memberNum=

# [int] The number of members in a cluster of scrapers. Each member must have
# an unique -promscrape.cluster.memberNum
# in the range 0 ... promscrape.cluster.membersCount-1 . Each member then
# scrapes roughly 1/N of all the targets. By default cluster scraping
# is disabled, i.e. a single scraper scrapes all the targets
#export VM__promscrape_cluster_membersCount=

# [int] The number of members in the cluster, which scrape the same targets.
# If the replication factor is greater than 2, then the deduplication must be
# enabled at remote storage side (default 1).
# See https://docs.victoriametrics.com/#deduplication
#export VM__promscrape_cluster_replicationFactor=

# [string] Optional path to Prometheus config file with 'scrape_configs'
# section containing targets to scrape. The path can point to local file and
# to http url.
# See https://docs.victoriametrics.com/#how-to-scrape-prometheus-exporters-such-as-node-exporter
export VM__promscrape_config='{{ services.victoriametrics.prometheus.config_file_path }}'

# [duration] Interval for checking for changes in '-promscrape.config' file.
# By default the checking is disabled. Send SIGHUP signal in order to force
# config check for changes
#export VM__promscrape_configCheckInterval=

# Checks -promscrape.config file for errors and unsupported fields and then
# exits. Returns non-zero exit code on parsing errors and emits these errors
# to stderr. See also -promscrape.config.strictParse command-line flag.
# Pass -loggerLevel=ERROR if you don't need to see info messages in the output.
#export VM__promscrape_config_dryRun=

# Whether to deny unsupported fields in -promscrape.config . Set to false in
# order to silently skip unsupported fields (default true)
#export VM__promscrape_config_strictParse=

# [duration] Interval for checking for changes in Consul. This works only if
# consul_sd_configs is configured in '-promscrape.config' file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config
#export VM__promscrape_consulSDCheckInterval=

# [duration] Wait time used by Consul service discovery.
# Default value is used if not set
#export VM__promscrape_consul_waitTime=

# [duration] Interval for checking for changes in digital ocean. This works
# only if digitalocean_sd_configs is configured in '-promscrape.config'
# file (default 1m0s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#digitalocean_sd_config
#export VM__promscrape_digitaloceanSDCheckInterval=

# Whether to disable sending 'Accept-Encoding: gzip' request headers to all
# the scrape targets. This may reduce CPU usage on scrape targets at the cost
# of higher network bandwidth utilization. It is possible to
# set 'disable_compression: true' individually per each 'scrape_config' section
# in '-promscrape.config' for fine grained control
#export VM__promscrape_disableCompression=1

# Whether to disable HTTP keep-alive connections when scraping all the targets.
# This may be useful when targets has no support for HTTP keep-alive
# connection. It is possible to set 'disable_keepalive: true' individually per
# each 'scrape_config' section in '-promscrape.config' for fine grained
# control. Note that disabling HTTP keep-alive may increase load on both
# vmagent and scrape targets
export VM__promscrape_disableKeepAlive=1

# [int] The maximum number of concurrent requests to Prometheus autodiscovery
# API (Consul, Kubernetes, etc.) (default 100)
#export VM__promscrape_discovery_concurrency=

# [duration] The maximum duration for waiting to perform API requests if more
# than -promscrape.discovery.concurrency requests are simultaneously performed
# Default: 1m0s
#export VM__promscrape_discovery_concurrentWaitTime=

# [duration] Interval for checking for changes in dns. This works only if
# dns_sd_configs is configured in '-promscrape.config' file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config
#export VM__promscrape_dnsSDCheckInterval=

# [duration] Interval for checking for changes in docker. This works only if
# docker_sd_configs is configured in '-promscrape.config' file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#docker_sd_config
#export VM__promscrape_dockerSDCheckInterval=

# [duration] Interval for checking for changes in dockerswarm. This works only
# if dockerswarm_sd_configs is configured in '-promscrape.config'
# file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dockerswarm_sd_config
#export VM__promscrape_dockerswarmSDCheckInterval=

# Whether to drop original labels for scrape targets at /targets
# and /api/v1/targets pages. This may be needed for reducing memory usage when
# original labels for big number of scrape targets occupy big amounts of
# memory. Note that this reduces debuggability for improper per-target
# relabeling configs
#export VM__promscrape_dropOriginalLabels=

# [duration] Interval for checking for changes in ec2. This works only
# if ec2_sd_configs is configured in '-promscrape.config' file (default 1m0s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config
#export VM__promscrape_ec2SDCheckInterval=

# [duration] Interval for checking for changes in eureka. This works only
# if eureka_sd_configs is configured in '-promscrape.config' file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#eureka_sd_config
#export VM__promscrape_eurekaSDCheckInterval=

# [duration] Interval for checking for changes in 'file_sd_config'.
# Default: 5m0s
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config
#export VM__promscrape_fileSDCheckInterval=

# [duration] Interval for checking for changes in gce. This works only
# if gce_sd_configs is configured in '-promscrape.config' file (default 1m0s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#gce_sd_config
#export VM__promscrape_gceSDCheckInterval=

# [duration] Interval for checking for changes in http endpoint service
# discovery. This works only if http_sd_configs is configured
# in '-promscrape.config' file (default 1m0s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#http_sd_config
#export VM__promscrape_httpSDCheckInterval=

# [duration] Interval for checking for changes in Kubernetes API server.
# This works only if kubernetes_sd_configs is configured
# in '-promscrape.config' file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config
#export VM__promscrape_kubernetesSDCheckInterval=

# [duration] How frequently to reload the full state from Kuberntes
# API server (default 30m0s)
#export VM__promscrape_kubernetes_apiServerTimeout=

# [int] The maximum number of droppedTargets to show at /api/v1/targets page.
# Increase this value if your setup drops more scrape targets during relabeling
# and you need investigating labels for all the dropped targets. Note that the
# increased number of tracked dropped targets may result in increased memory
# usage (default 1000)
#export VM__promscrape_maxDroppedTargets=

# [size] The maximum size of http response headers from Prometheus scrape
# targets (default 4096)
#export VM__promscrape_maxResponseHeadersSize=

# [size] The maximum size of scrape response in bytes to process from
# Prometheus targets. Bigger responses are rejected (default 16777216)
#export VM__promscrape_maxScrapeSize=

# [size] The minimum target response size for automatic switching to stream
# parsing mode, which can reduce memory usage (default 1000000).
# See https://docs.victoriametrics.com/vmagent.html#stream-parsing-mode
#export VM__promscrape_minResponseSizeForStreamParse=

# Whether to disable sending Prometheus stale markers for metrics when scrape
# target disappears. This option may reduce memory usage if stale markers
# aren't needed for your setup. This option also disables populating the
# scrape_series_added metric.
# See https://prometheus.io/docs/concepts/jobs_instances/#automatically-generated-labels-and-time-series
#export VM__promscrape_noStaleMarkers=

# [duration] Interval for checking for changes in openstack API server. This
# works only if openstack_sd_configs is configured in '-promscrape.config'
# file (default 30s).
# See https://prometheus.io/docs/prometheus/latest/configuration/configuration/#openstack_sd_config
#export VM__promscrape_openstackSDCheckInterval=

# [int] Optional limit on the number of unique time series a single scrape
# target can expose.
# See https://docs.victoriametrics.com/vmagent.html#cardinality-limiter
#export VM__promscrape_seriesLimitPerTarget=

# Whether to enable stream parsing for metrics obtained from scrape targets.
# This may be useful for reducing memory usage when millions of metrics are
# exposed per each scrape target. It is posible to set 'stream_parse: true'
# individually per each 'scrape_config' section in '-promscrape.config'
# for fine grained control
#export VM__promscrape_streamParse=

# Whether to suppress 'duplicate scrape target' errors.
# See https://docs.victoriametrics.com/vmagent.html#troubleshooting
#export VM__promscrape_suppressDuplicateScrapeTargetErrors=

# Whether to suppress scrape errors logging. The last error for each target
# is always available at '/targets' page even if scrape errors logging
# is suppressed
#export VM__promscrape_suppressScrapeErrors=

#endregion
