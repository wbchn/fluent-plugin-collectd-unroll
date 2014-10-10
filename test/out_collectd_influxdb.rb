require 'fluent/test'
require 'fluent/plugin/out_collectd_influxdb'


class CollectdInfluxdbOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type collectd_influxdb
    tag foo.filtered
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::CollectdInfluxdbOutput, tag='test_tag').configure(conf)
  end

  def test_rewrite_tag
    d = create_driver %[
      type collectd_influxdb
    ]

    d.run do
      d.emit([{
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin', "plugin_instance" => 'plugin_instance',
        "type" => 'type', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      }])
      d.emit([{
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin', "plugin_instance" => '',
        "type" => 'type', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      }])
      d.emit([{
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin', "plugin_instance" => 'plugin_instance',
        "type" => '', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      }])
      d.emit([{
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin', "plugin_instance" => 'plugin_instance',
        "type" => 'type', "type_instance" => '',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      }])
    end

    assert_equal 4, d.emits.length
    assert_equal "test_tag.host.plugin.plugin_instance.type.type_instance", d.emits[0][0]
    assert_equal "test_tag.host.plugin.type.type_instance", d.emits[1][0]
    assert_equal "test_tag.host.plugin.plugin_instance.type_instance", d.emits[2][0]
    assert_equal "test_tag.host.plugin.plugin_instance.type", d.emits[3][0]
  end

  def test_normalize_record
    d = create_driver %[
      type collectd_influxdb
    ]

    d.run do
      d.emit([{
        "time" => 1000, "host" => 'v', "interval" => 5,
        "plugin" => 'v', "plugin_instance" => 'v',
        "type" => 'v', "type_instance" => 'v',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      }])
    end

    assert_equal [{"n1"=>"v1", "n2"=>"v2"}], d.records
  end

end