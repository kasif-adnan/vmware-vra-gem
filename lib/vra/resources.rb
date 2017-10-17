# frozen_string_literal: true

#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
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
  class Resources
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # @return [Array[Vra::Resource]] - returns an array of all the resources owned by the user
    # @param [Vra::Client]
    def self.all(client)
      items = client.http_get_paginated_array!("/catalog-service/api/consumer/resources")
      items.map { |item| Vra::Resource.new(client, data: item) }
    end

    # @return [Array[Vra::Resource]] - returns an array of all the resources owned by the user
    def all_resources
      self.class.all(client)
    end

    def by_id(id)
      Vra::Resource.new(client, id: id)
    end
  end
end
