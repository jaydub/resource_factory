# == Type: resource_factory::defined_resource_factory
#
# The defined_resource_factory type does exactly the same thing as the
# resource_factory class, except you can create many instances rather than a
# singleton. In practice, this means you can use the class in hiera's
# classifier, and have the instances that the class creates be of the
# defined_resource_factory type, who in turn create the resources you
# want via hiera data.
#
# See the resource_factory class documentation and the module README for more of
# the big picture, and some useful examples.
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
# === Authors
#
# John Morton <jwm@angrymonkey.net.nz>
#
# === Copyright
#
# Copyright 2014 John Morton, unless otherwise noted.
#
define resource_factory::defined_resource_factory
(
  $hiera_key,
  $resource_type,
  $enable = true,
  $resource_creation = 'default',
  $merge = false,
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
