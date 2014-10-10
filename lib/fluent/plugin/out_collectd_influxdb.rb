module Fluent
  class CollectdInfluxdbOutput < Output
    Fluent::Plugin.register_output('collectd_influxdb', self)

    def configure(conf)
      super
    end

    def emit(tag, es, chain)
      es.each { |time, record|
        record.each { |event|
          Engine.emit(rewrite_tag(tag, event), event['time'], normalize_record(event))
        }
      }

      chain.next
    end

    private

    def rewrite_tag(tag, event)
      @tags = [tag, event['host'].gsub(".","/"), event['plugin'], event['plugin_instance'], event['type'], event['type_instance']]
      tag = @tags.join(".").squeeze(".").gsub(/\.$/, '')
      tag
    end

    def normalize_record(record)
      record['values'].each_with_index { |value, index|
        record[record['dsnames'][index]] = value
      }
      keys = ['time', 'host', 'interval', 'plugin', 'plugin_instance', 'type', 'type_instance', 'values', 'dsnames', 'dstypes']
      keys.each { |key|
        record.delete(key)
      }
      record
    end
  end
end