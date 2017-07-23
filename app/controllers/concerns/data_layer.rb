module Concerns
  module DataLayer
    extend ActiveSupport::Concern

    included do
      helper_method :render_data_layer
      before_action :clean_data_layer
      after_action :store_data_layer_for_next_request
    end

    private

    def data_layer
      @_data_layer ||= []
    end

    def data_layer_for_next_request
      @_data_layer_for_next_request ||= []
    end

    def render_data_layer
      data_layer.to_json.html_safe
    end

    # @param [Array] data
    def push_to_data_layer(*data)
      Array.wrap(data).each do |item|
        data_layer.push(item)
      end
    end

    # @param [Array] data
    def push_to_data_layer_later(*data)
      Array.wrap(data).each do |item|
        data_layer_for_next_request.push(item)
      end
    end

    def clean_data_layer
      @_data_layer = Array.wrap(session.delete(:data_layer))
    end

    def store_data_layer_for_next_request
      session[:data_layer] = data_layer_for_next_request if data_layer_for_next_request.present?
    end
  end
end
