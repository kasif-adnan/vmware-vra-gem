# frozen_string_literal: true
#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) 2022 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Vra
  class RequestParameters
    def initialize
      @entries = {}
    end

    # @param key [String] - the name of the key
    # @param value_data [Hash] - the data of the key name
    # @note - the value_data must have type and value property in the hash
    def set_parameters(key, value_data, parent = nil)
      value_type = value_data[:type] || value_data["type"]
      data_value = value_data[:value] || value_data["value"]

      if value_type
        if parent.nil?
          set(key, value_type, data_value)
        else
          parent.add_child(Vra::RequestParameter.new(key, value_type, data_value))
        end
      else
        if parent.nil?
          p = set(key, nil, nil)
        else
          p = Vra::RequestParameter.new(key, nil, nil)
          parent.add_child(p)
        end

        value_data.each do |k, data|
          set_parameters(k, data, p)
        end
      end
    end

    def set(key, type, value)
      if key.to_s.include? "~"
        split_key = key.to_s.split("~")
        parent = nil
        split_key.each_with_index do |item, index|
          if index == 0
            if @entries[item].nil?
              @entries[item] = Vra::RequestParameter.new(item, nil, nil)
            end
            parent = @entries[item]
          elsif index == (split_key.count - 1)
            c = Vra::RequestParameter.new(item, type, value)
            parent.add_child(c)
          else
            p = Vra::RequestParameter.new(item, nil, nil)
            parent.add_child(p)
            parent = p
          end
        end
      else
        @entries[key] = Vra::RequestParameter.new(key, type, value)
      end
    end

    def delete(key)
      @entries.delete(key)
    end

    def all_entries
      @entries.values
    end

    def to_h
      hash = {}

      @entries.each do |k, v|
        hash.merge!(v.to_h)
      end

      hash
    end

    def to_vra
      hash = {
        'inputs': {},
      }

      @entries.each do |_, v|
        hash[:inputs].merge!(v.to_vra)
      end

      hash
    end
  end

  class RequestParameter
    attr_accessor :key, :type, :value, :children
    def initialize(key, type, value)
      @key   = key
      @type  = type
      @value = value
      @children = []
    end

    def add_child(child)
      @children.push(child)
    end

    def to_h
      hash = {}

      if @children.count > 0
        hash[@key] = {}

        @children.each do |c|
          hash[@key].merge!(c.to_h)
        end
      else
        hash[@key] = format_value
      end

      hash
    end

    def to_vra
      hash = {}
      if @children.count > 0
        hash[@key] = {}

        hash[@key]["inputs"] = {}

        @children.each do |c|
          hash[@key]["inputs"].merge!(c.to_vra)
        end
      else
        hash[@key] = format_value
      end

      hash.each_with_object({}) { |(key, value), h| h[key.to_s] = value }
    end

    def format_value
      case @type
      when "integer"
        @value.to_i
      when "string"
        @value
      when "boolean"
        @value.to_s == "true"
      else
        @value
      end
    end
  end
end
