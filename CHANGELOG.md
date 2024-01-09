# Changelog

## 1.7.1-rc1

* **BREAKING CHANGES**:

    * Migrated to Alpine + Nginx + php-fpm. This allowed to reduce memory usage from ~300MB to ~40MB!
    * Changed versioning convention from `cpXXX-revYYY` to `CLASSICPRESS_VERSION-rRELEASE_NUMBER`
    * Migrated from `APACHE_RUN_USER_ID` and `APACHE_RUN_GROUP_ID` to shared between host and container group `press(gid=2048)`.
    * `wp-config.template.php` now contains `define('WP_AUTO_UPDATE_CORE', false);` which should stop CP from auto-updating (this is added only to new installations, so it may be that you must add it manually to your config)
