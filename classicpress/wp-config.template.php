<?php
define('DB_NAME', 'CP_DB_NAME');
define('DB_USER', 'CP_DB_USER');
define('DB_PASSWORD', 'CP_DB_PASSWORD');
define('DB_HOST', 'CP_DB_HOST');
define('DB_CHARSET', 'CP_DB_CHARSET');
define('DB_COLLATE', 'CP_DB_COLLATE');

define('AUTH_KEY', 'CP_AUTH_KEY');
define('SECURE_AUTH_KEY', 'CP_SECURE_AUTH_KEY');
define('LOGGED_IN_KEY', 'CP_LOGGED_IN_KEY');
define('NONCE_KEY', 'CP_NONCE_KEY');
define('AUTH_SALT', 'CP_AUTH_SALT');
define('SECURE_AUTH_SALT', 'CP_SECURE_AUTH_SALT');
define('LOGGED_IN_SALT', 'CP_LOGGED_IN_SALT');
define('NONCE_SALT', 'CP_NONCE_SALT');

$table_prefix  = 'CP_DB_TABLE_PREFIX';

define('WP_DEBUG', false);

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
	$_SERVER['HTTPS'] = 'on';
}

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
