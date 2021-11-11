<?php
$CONFIG = array (
    'trusted_domains' => [
        0 => 'nextcloud.{{ lab_domain_name }',
    ],
    'overwrite.cli.url' => 'https://nextcloud.{{ lab_domain_name }}',

    # Redis
    # https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/caching_configuration.html#id2
    'memcache.distributed' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => [
        'host' => '{{ services.nextcloud.redis_host }}',
        'port' => '{{ services.nextcloud.redis_port }}',
    ],

    # PostgreSQL
    'dbtype' => 'pgsql',
    'dbname' => '{{ services.nextcloud.postgres_dbname }}',
    'dbuser' => '{{ services.nextcloud.postgres_user }}',
    'dbpassword' => '{{ services.nextcloud.postgres_password }}',
    'dbhost' => '{{ services.nextcloud.postgres_host }}',
    'dbport' => '{{ services.nextcloud.postgres_port }}',
    'dbtableprefix' => '{{ services.nextcloud.postgres_dbtableprefix }}',
);
