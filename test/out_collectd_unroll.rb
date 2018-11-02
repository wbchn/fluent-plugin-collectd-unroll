
require 'fluent/test/driver/output'
require 'fluent/plugin/out_collectd_unroll'


class CollectdUnrollOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type collectd_unroll
    tag foo.filtered
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::CollectdUnrollOutput, tag='test_tag').configure(conf)
  end

  def test_rewrite_tag
    d = create_driver %[
      type collectd_nest
      tag test_tag
    ]

    d.run do
      d.emit({
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin1', "plugin_instance" => 'plugin_instance',
        "type" => 'type1', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
    end

    assert_equal 1, d.emits.length
    assert_equal "test_tag", d.emits[0][0]
  end

  def test_normalize_record
    d = create_driver %[
      type collectd_nest
    ]

    d.run do
      d.emit({
        "time" => 1000, "host" => 'host_v', "interval" => 5,
        "plugin" => 'plugin_v', "plugin_instance" => 'plugin_instance_v',
        "type" => 'type_v', "type_instance" => 'type_instance_v',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
    end

    assert_equal d.records[0]['plugin_v']['type_v']['n1'], 'v1'
    assert_equal d.records[0]['plugin_v']['type_v']['n2'], 'v2'
    assert_equal d.records[0].has_key?('host'), true
    assert_equal d.records[0]['plugin'], 'plugin_v'
    assert_equal d.records[0]['type'], 'type_v'
    assert_equal d.records[0]['plugin_instance'], 'plugin_instance_v'
    assert_equal d.records[0]['type_instance'], 'type_instance_v'
    assert_equal d.records[0]['dstypes'], 't1'
  end

end
