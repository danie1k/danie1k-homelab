<?php
// Source: https://github.com/prasathmani/tinyfilemanager/blob/master/config-sample.php

/**
 * AUTH
 */
$use_auth = false;
$auth_users = array(
    //'admin' => '$2y$10$/K.hjNr84lLNDt8fTXjoI.DBp6PpeyoJ.mGwrrLuCZfAwfSAGqhOW', //admin@123
    //'user' => '$2y$10$Fg6Dz8oH9fPoZ2jJan5tZuv6Z4Kp7avtQ9bDfrdRntXtPeiMAZyGO' //12345
);
$readonly_users = array(
    //'user'
);

/**
 * UI
 */
$use_highlightjs = true;    // Enable highlight.js (https://highlightjs.org/) on view's page
$highlightjs_style = 'vs';  // highlight.js style
$edit_files = true;         // Enable ace.js (https://ace.c9.io/) on view's page
$sticky_navbar = true;      // Sticky Nav bar
// Online office Docs Viewer
// Availabe rules are 'google', 'microsoft' or false
// google => View documents using Google Docs Viewer
// microsoft => View documents using Microsoft Web Apps Viewer
// false => disable online doc viewer
$online_viewer = false;


$http_host = '{{ tinyfilemanager.http_host }}';
$root_path = '{{ tinyfilemanager.root_path }}';
$root_url = '';


// user specific directories
// array('Username' => 'Directory path', 'Username2' => 'Directory path', ...)
$directories_users = array();

// input encoding for iconv
$iconv_input_encoding = 'UTF-8';

// date() format for file modification date
// Doc - https://www.php.net/manual/en/datetime.format.php
$datetime_format = 'Y-m-d H:i:s';

$allowed_file_extensions = '';    // Allowed file extensions for create and rename files
$allowed_upload_extensions = '';  // Allowed file extensions for upload files

$favicon_path = '/favicon.ico';

$exclude_items = array(    // Files and folders to excluded from listing
    'favicon.ico',
    'index.php',
    'config.php',
);



$default_timezone = '{{ docker_config.container_timezone | default("UTC", true) }}';
$max_upload_size_bytes = 5000;



// OFF => Don't check connection IP, defaults to OFF
// AND => Connection must be on the whitelist, and not on the blacklist
// OR  => Connection must be on the whitelist, or not on the blacklist
$ip_ruleset = 'OFF';
$ip_silent = true;    // Should users be notified of their block?

// IP-addresses, both ipv4 and ipv6
$ip_whitelist = array(
    '127.0.0.1', '::1',

);

// IP-addresses, both ipv4 and ipv6
$ip_blacklist = array(
    '0.0.0.0', '::',
);
