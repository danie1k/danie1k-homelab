<pre><?php

if (
    $_SERVER['REQUEST_METHOD'] === 'GET' or !array_key_exists('action', $_GET)
    && preg_match_all('/^[a-z]+$/', $_GET['action']) === 1
) {
    echo(shell_exec('/bin/bash /usr/local/emhttp_webhook_handler.sh '.$_GET['action']));
    exit(0);
}

exit(1);
