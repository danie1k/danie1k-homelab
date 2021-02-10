<?php
$CONFIG = array (
    'trusted_domains' => [
        0 => 'nextcloud.{{ lab.domain_name }',
    ],
    'overwrite.cli.url' => 'https://nextcloud.{{ lab.domain_name }}',

    # Redis
    # https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/caching_configuration.html#id2
    'memcache.distributed' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => [
        'host' => 'redis.{{ docker.internal_network_name }}',
        'port' => 6379,
    ],

    # PostgreSQL
    'dbtype' => 'pgsql',
    'dbname' => 'nextcloud',
    'dbuser' => CHANGE_ME,
    'dbpassword' => CHANGE_ME,
    'dbhost' => 'postgres.{{ docker.internal_network_name }}',
    'dbport' => '5432',
    'dbtableprefix' => CHANGE_ME,
);
