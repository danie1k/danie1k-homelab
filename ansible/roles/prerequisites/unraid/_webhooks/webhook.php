<?php

if (
    $_SERVER['REQUEST_METHOD'] === 'GET' or !array_key_exists('action', $_GET)
    && preg_match_all('/^[a-z]+$/', $_GET['action']) === 1
) {
    echo(shell_exec('/bin/bash {{ unraid.homelab_dir }}/webhooks/webhook_'.$_GET['action'].'.sh'));
    exit(0);
}

exit(1);
