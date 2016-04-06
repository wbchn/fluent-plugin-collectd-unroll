# Output filter plugin to rewrite Collectd JSON output to unroll into a flat json

Rewrites the message coming from Collectd to store as a flat json. Can be used in Elasticsearch to display metrics.

## Installation

Use RubyGems:
If you use td-agent

    td-agent-gem install fluent-plugin-collectd-unroll

If you use fluentd

    gem install fluent-plugin-collectd-unroll

## Configuration

    <match pattern>
      type collectd_unroll
    </match>

If following record is passed:

```js
[{"time" => 1000, "host" => 'host_v', "interval" => 5, "plugin" => 'plugin_v', "plugin_instance" => 'plugin_instance_v', "type" => 'type_v', "type_instance" => 'type_instance_v', "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']}]
```

then you got new record like below:

```js
[{"n1"=>"v1", "n2"=>"v2"}]
```

and the record tag will be changed to

```js
host_v.plugin_v.plugin_instance_v.type_v.type_instance_v
```

Empty values in "plugin", "plugin_instance", "type" or "type_instance" will not be copied into the new tag name


## WARNING

* This plugin was written to deal with a specific use-case, might not be the best fit for everyone. If you need more configurability/features, create a PR


## Copyright

<table>
  <tr>
    <td>Author</td><td>Manoj Sharma <vigyanik@gmail.com></td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
