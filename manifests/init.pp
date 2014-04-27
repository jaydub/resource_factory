# == Class: resource_factory
#
# The base resource_factory class instantiates resource type specific factories
# from  a hash found in hiera. These factories, in turn, instantiate specific
# resources (both built in and defined in manifests) from particular hashes in
# hiera, sparing you the tedium of rolling custom classes to do the same thing.
#
# === Parameters
#
# [hiera_key]
#   Key in your hiera data sources to look up, the contents being in a form
#   that the built in create_resources function can combine with the resource
#   type to create instances of it. Defaults to 'resources_factories'.
#
# [resource_type]
#   The name of the resource that create_resources function will produce from
#   the data in our hiera key.
#   Defaults to: resource_factory::defined_resource_factory
#
# [enable]
#   Toggles the execution of the class on or off. Defaults to on, fairly
#   obviously. It can be handy to toggle it off for specific nodes under
#   unusual circumstances, but you'll probably get better results disabling
#   specific factories.
#
# [resource_creation]
#   Sets how the resources are created, as either the default, virtual or
#   exported resources. Defaults to 'default'.
#
# [merged]
#   Sets whether to use the hiera_key in the most specific hiera source, or
#   merged from all matching sources. Defaults to 'true', merging all factory
#   definitions.
#
# === Examples
#
# You will pretty much only ever use this in the context of hiera, so these
# examples are in hiera YAML.
#
# 1) Drop resource factory into the included classes in your most common hiera
# file, eg.
#
#  ---
#  classes:
#     resource_factory
#      ...
#
# 2) Now you can add instances of the 'resources_factories' key in various
# places. For example, if you execpt to define a bunch of apt related resources
# at some Debian derived distro level, add the following there:
#
# resource_factories:
#  'apt_source_factory':
#    hiera_key:      apt_sources
#    resource_type:  apt::source
#    merge:          true
#  'apt_ppa_factory':
#    hiera_key:      apt_ppas
#    resource_type:  apt::ppa
#    merge:          true
#  'apt_conf_factory':
#    hiera_key:      apt_confs
#    resource_type:  apt::conf
#    merge:          true
#
# Then you can set those hiera keys with your particular resources, eg:
#
# apt_confs:
#   'proxy':
#    content: 'Acquire::http { Proxy "http://apt-cacher:3142/"; };'
#    priority: 10
#
# In this case I've set 'merge' to true, for the general repositories plus more
# specific repositories approach, however you can override that behaviour by
# setting that particular factory again in a higher priority context. If you
# want to eliminate a factory for a particular node, set it their
# with enable: false.
#
# === Authors
#
# John Morton <jwm@angrymonkey.net.nz>
#
# === Copyright
#
# Copyright 2014 John Morton, unless otherwise noted.
#
class resource_factory
(
  $hiera_key = 'resource_factories',
  $resource_type = 'resource_factory::defined_resource_factory',
  $enable = true,
  $resource_creation = 'default',
  $merge = true,
)
{
  if $enable {
    case $resource_creation {
      'export':  { $res_type = "@@${resource_type}"}
      'virtual': { $res_type = "@${resource_type}"}
      default:   { $res_type = $resource_type}
    }
    if $merge {
      $data = hiera_hash($hiera_key, {})
    }
    else{
      $data = hiera($hiera_key, {})
    }
    create_resources($res_type, $data)
  }
}
