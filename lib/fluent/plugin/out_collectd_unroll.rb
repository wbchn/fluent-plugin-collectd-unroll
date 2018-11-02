require 'fluent/plugin/output'

module Fluent
  class Plugin::CollectdUnrollOutput < Plugin::Output
    Fluent::Plugin.register_output('collectd_unroll', self)

    helpers :event_emitter

    config_param :tag, :string,
                  desc: "The output record tag name."

    def initialize
      super
    end

    def configure(conf)
      super
    end
    
    def process(tag, es)
      stream = MultiEventStream.new
      es.each { |time, record|
        record = inject_values_to_record(tag, time, record)
        stream.add(time, normalize_record(record))
      }

      router.emit_stream(@tag, stream)
    end

    private

    def normalize_record(record)
      if record.nil?
        return record
      end
      if !(record.has_key?('values')) || !(record.has_key?('dsnames')) || !(record.has_key?('dstypes')) || !(record.has_key?('host')) || !(record.has_key?('plugin')) || !(record.has_key?('plugin_instance')) || !(record.has_key?('type')) || !(record.has_key?('type_instance'))
        return record
      end
      
      # record['values'].each_with_index { |value, index|
      #   record[tag] = value
      #   record[record['dsnames'][index]] = value
      #   record['dstype_' + record['dsnames'][index]] = record['dstypes'][index]
      #   record['dstype'] = record['dstypes'][index]
      # }

      rec_plugin = record['plugin']
      rec_type = record['type']
      record[rec_plugin] = {rec_type => {}}
      if record['dsnames'].length == 1
        record[rec_plugin][rec_type] = record['values'].first
      else
        record['values'].each_with_index { |value, index|
          record[rec_plugin][rec_type][record['dsnames'][index]] = value
        }
        record['dstypes'] = record['dstypes'].uniq
      end

      record.delete('dstypes')
      record.delete('dsnames')
      record.delete('values')
      record
    end
  end
end
