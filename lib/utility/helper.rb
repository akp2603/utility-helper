require "utility/helper/version"

module Utility
  module Helper

    def self.all_keys_present?(params, mandatory_keys)
      absent_keys = mandatory_keys.select {|key| params[key].blank?}.map!(&:to_s)
      raise(::CustomErrors::InvalidRequest, error: {params: "Mandatory keys #{absent_keys.join(', ')} missing in params!"}) if absent_keys.present?
      return 200, ApiStatusList::OK.deep_dup
    end

    def self.any_key_present?(params, keys)
      keys.each do |key|
        return 200, ApiStatusList::OK.deep_dup if params[key].present?
      end
      return 400, ApiStatusList::INVALID_REQUEST.deep_dup.merge("message" => "Any of the keys #{keys.join("/")} must be present in params")
    end

    def self.get_field_to_id_mapping(model, field)
      return model.pluck(field.to_sym, :id).to_h
    end

    def self.get_id_to_field_mapping(model, field, ids = nil)
      model = model.where(id: ids) if ids.present?
      return model.pluck(:id, field.to_sym).to_h
    end

    def self.success_status_code?(response_code)
      return (response_code.to_s =~ /2\d\d/) ? true : false
    end

    def self.convert_dictionary_to_array_of_hash(dictionary)
      dictionary.map do |key, value|
        {
          id: key,
          name: value
        }
      end
    end

    def self.fetch_value_from_hash(hash, keys=[])
      return nil if hash.blank?
      return hash[keys.first] if keys.length == 1
      first_key = keys.first
      remaining_keys = keys[1..-1]
      fetch_value_from_hash(hash[first_key], remaining_keys)
    end

    def self.fetch_value_from_object(object, keys=[])
      return nil if object.blank?
      return object.send(keys.first) if keys.length == 1
      first_key = keys.first
      remaining_keys = keys[1..-1]
      fetch_value_from_object(object.send(first_key), remaining_keys)
    end

    def self.calculate_mean_and_deviation(data)
      response = {
        total: 0,
        mean: 0,
        standard_deviation: 0
      }
      return response if data.blank?
      no_of_item = data.length
      response[:total] = data.sum
      response[:mean] = (response[:total]/ no_of_item).round(2)
    response[:standard_deviation] = (Math.sqrt((data.map{|x| (x - response[:mean]) ** 2}.sum) / no_of_item)).round(2)
      return response
    end

  end
end
