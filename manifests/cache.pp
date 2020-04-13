#
# Module for managing keystone cache.
#
# == Parameters
#
# [*config_prefix*]
#   (Optional) Prefix for building the configuration dictionary for
#   the cache region. This should not need to be changed unless there
#   is another dogpile.cache region with the same configuration name.
#   (string value)
#   Defaults to $::os_service_default
#
# [*expiration_time*]
#   (Optional) Default TTL, in seconds, for any cached item in the
#   dogpile.cache region. This applies to any cached method that
#   doesn't have an explicit cache expiration time defined for it.
#   (integer value)
#   Defaults to $::os_service_default
#
# [*backend*]
#   (Optional) Dogpile.cache backend module. It is recommended that
#   Memcache with pooling (oslo_cache.memcache_pool) or Redis
#   (dogpile.cache.redis) be used in production deployments. (string value)
#   Defaults to $::os_service_default
#
# [*backend_argument*]
#   (Optional) Arguments supplied to the backend module. Specify this option
#   once per argument to be passed to the dogpile.cache backend.
#   Example format: "<argname>:<value>". (list value)
#   Defaults to $::os_service_default
#
# [*proxies*]
#   (Optional) Proxy classes to import that will affect the way the
#   dogpile.cache backend functions. See the dogpile.cache documentation on
#   changing-backend-behavior. (list value)
#   Defaults to $::os_service_default
#
# [*enabled*]
#   (Optional) Global toggle for caching. (boolean value)
#   Defaults to $::os_service_default
#
# [*debug_cache_backend*]
#   (Optional) Extra debugging from the cache backend (cache keys,
#   get/set/delete/etc calls). This is only really useful if you need
#   to see the specific cache-backend get/set/delete calls with the keys/values.
#   Typically this should be left set to false. (boolean value)
#   Defaults to $::os_service_default
#
# [*memcache_servers*]
#   (Optional) Memcache servers in the format of "host:port".
#   (dogpile.cache.memcache and oslo_cache.memcache_pool backends only).
#   (list value)
#   Defaults to $::os_service_default
#
# [*memcache_dead_retry*]
#   (Optional) Number of seconds memcached server is considered dead before
#   it is tried again. (dogpile.cache.memcache and oslo_cache.memcache_pool
#   backends only). (integer value)
#   Defaults to $::os_service_default
#
# [*memcache_socket_timeout*]
#   (Optional) Timeout in seconds for every call to a server.
#   (dogpile.cache.memcache and oslo_cache.memcache_pool backends only).
#   (floating point value)
#   Defaults to $::os_service_default
#
# [*memcache_pool_maxsize*]
#   (Optional) Max total number of open connections to every memcached server.
#   (oslo_cache.memcache_pool backend only). (integer value)
#   Defaults to $::os_service_default
#
# [*memcache_pool_unused_timeout*]
#   (Optional) Number of seconds a connection to memcached is held unused
#   in the pool before it is closed. (oslo_cache.memcache_pool backend only)
#   (integer value)
#   Defaults to $::os_service_default
#
# [*memcache_pool_connection_get_timeout*]
#   (Optional) Number of seconds that an operation will wait to get a memcache
#   client connection. (integer value)
#   Defaults to $::os_service_default
#
# [*manage_backend_package*]
#   (Optional) Whether to install the backend package for the cache.
#   Defaults to true
#
# [*token_caching*]
#   (Optional) Toggle for token system caching. This has no effect unless
#   cache_backend, cache_enabled and cache_memcache_servers is set.
#   Default to $::os_service_default
#
class keystone::cache(
  $config_prefix                        = $::os_service_default,
  $expiration_time                      = $::os_service_default,
  $backend                              = $::os_service_default,
  $backend_argument                     = $::os_service_default,
  $proxies                              = $::os_service_default,
  $enabled                              = $::os_service_default,
  $debug_cache_backend                  = $::os_service_default,
  $memcache_servers                     = $::os_service_default,
  $memcache_dead_retry                  = $::os_service_default,
  $memcache_socket_timeout              = $::os_service_default,
  $memcache_pool_maxsize                = $::os_service_default,
  $memcache_pool_unused_timeout         = $::os_service_default,
  $memcache_pool_connection_get_timeout = $::os_service_default,
  $manage_backend_package               = true,
  $token_caching                        = $::os_service_default,
){

  include keystone::deps

  # Pick old stry hierdata to keep backword compatibility
  $config_prefix_real       = pick($::keystone::cache_config_prefix, $config_prefix)
  $expiration_time_real     = pick($::keystone::cache_expiration_time, $expiration_time)
  $backend_real             = pick($::keystone::cache_backend, $backend)
  $backend_argument_real    = pick($::keystone::cache_backend_argument, $backend_argument)
  $proxies_real             = pick($::keystone::cache_proxies, $proxies)
  $enabled_real             = pick($::keystone::cache_enabled, $enabled)
  $debug_cache_backend_real = pick($::keystone::debug_cache_backend, $debug_cache_backend)
  $memcache_servers_real    = pick($::keystone::cache_memcache_servers, $memcache_servers)
  $memcache_dead_retry_real = pick($::keystone::memcache_dead_retry_real, $memcache_dead_retry)
  $memcache_socket_timeout_real = pick($::keytstone::memcache_socket_timeout_real, $memcache_socket_timeout)
  $memcache_pool_maxsize_real = pick($::keystone::memcache_pool_maxsize, $memcache_pool_maxsize)
  $memcache_pool_unused_timeout_real = pick($::keystone::memcache_pool_unused_timeout, $memcache_pool_unused_timeout)
  $memcache_pool_connection_get_timeout_real =
    pick($::keystone::memcache_pool_connection_get_timeout, $memcache_pool_connection_get_timeout)
  $manage_backend_package_real = pick($::keystone::manage_backend_package_real, $manage_backend_package)
  $token_caching_real      = pick($::keystone::token_caching, $token_caching)

  if is_string($memcache_servers_real) {
    $memcache_servers_array = split($memcache_servers_real, ',')
  } else {
    $memcache_servers_array = $memcache_servers_real
  }

  if !is_service_default($memcache_servers_real) {
    Service<| title == 'memcached' |> -> Anchor['keystone::service::begin']
  }

  keystone_config {
    'memcache/dead_retry':          value => $memcache_dead_retry_real;
    'memcache/pool_maxsize':        value => $memcache_pool_maxsize_real;
    'memcache/pool_unused_timeout': value => $memcache_pool_unused_timeout_real;
    'memcache/socket_timeout':      value => $memcache_socket_timeout_real;
    'token/caching':                value => $token_caching_real;
  }

  oslo::cache { 'keystone_config':
    config_prefix                        => $config_prefix_real,
    expiration_time                      => $expiration_time_real,
    backend                              => $backend_real,
    backend_argument                     => $backend_argument_real,
    proxies                              => $proxies_real,
    enabled                              => $enabled_real,
    debug_cache_backend                  => $debug_cache_backend_real,
    memcache_servers                     => $memcache_servers_array,
    memcache_dead_retry                  => $memcache_dead_retry_real,
    memcache_socket_timeout              => $memcache_socket_timeout_real,
    memcache_pool_maxsize                => $memcache_pool_maxsize_real,
    memcache_pool_unused_timeout         => $memcache_pool_unused_timeout_real,
    memcache_pool_connection_get_timeout => $memcache_pool_connection_get_timeout_real,
    manage_backend_package               => $manage_backend_package_real,
  }

}