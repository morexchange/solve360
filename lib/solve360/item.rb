module Solve360
  module Item
    
    def self.included(model)
      model.extend ClassMethods
      model.send(:include, HTTParty)
      model.instance_variable_set(:@field_mapping, {})
      model.instance_variable_set(:@category_mapping, {})
    end
    
    # Base Item fields
    attr_accessor :id, :name, :typeid, :created, :updated, :viewed, :ownership, :flagged
    
    # Base item collections
    attr_accessor :fields, :related_items, :related_items_to_add, :categories, :categories_to_add
    
    def initialize(attributes = {})
      attributes.symbolize_keys!
      
      self.fields = {}
      self.related_items = []
      self.related_items_to_add = []
      self.categories = []
      self.categories_to_add = []
      
      [:fields, :related_items].each do |collection|
        self.send("#{collection}=", attributes[collection]) if attributes[collection]
        attributes.delete collection
      end

      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end
    
    # @see Base::map_human_attributes
    def map_human_fields
      self.class.map_human_fields(self.fields)
    end
    
    # Save the attributes for the current record to the CRM
    #
    # If the record is new it will be created on the CRM
    # 
    # @return [Hash] response values from API
    def save
      response = []
      
      if self.ownership.blank?
        self.ownership = Solve360::Config.config.default_ownership
      end
      
      if new_record?
        response = self.class.request(:post, "/#{self.class.resource_name}", to_request)
        
        if !response["response"]["errors"]
          if response["response"]["item"]
            self.id = response["response"]["item"]["id"]
          elsif response["response"]["data"]
            self.id = response["response"]["data"]["id"]
          end
        end
      else
        response = self.class.request(:put, "/#{self.class.resource_name}/#{id}", to_request)
      end
      
      if response["response"]["errors"]
        message = response["response"]["errors"].map {|k,v| "#{k}: #{v}" }.join("\n")
        raise Solve360::SaveFailure, message
      else
        related_items.concat(related_items_to_add)
        categories.concat(categories_to_add)

        response
      end

    end
    
    def new_record?
      self.id == nil
    end
    
    def to_request
      json = {}
      
      map_human_fields.collect {|key, value| json[key] = value.to_s}
      json[:ownership] = ownership
      
      [:related_items, :categories].each do |list_name|
        list = self.instance_variable_get('@' + list_name.to_s + '_to_add')
        json_field = list_name.to_s.gsub('_', '')
        if list.size > 0
          json[json_field] = {}
          json[json_field][:add] = []
          list.each do |list_item|
            json[json_field][:add] << list_item
          end
        end
      end
      
      json.to_json
    end
    
    def add_related_item(item)
      related_items_to_add << item
    end
    
    def add_category(category)
      categories_to_add << self.class.map_category(category)
    end
    
    module ClassMethods
    
      # Map human map_human_fields to API fields
      # 
      # @param [Hash] human mapped fields
      # @example
      #   map_attributes("First Name" => "Steve", "Description" => "Web Developer")
      #   => {:firstname => "Steve", :custom12345 => "Web Developer"}
      # 
      # @return [Hash] API mapped attributes
      #
      def map_human_fields(fields)
        mapped_fields = {}

        field_mapping.each do |human, api|
          mapped_fields[api] = fields[human] if !fields[human].blank?
        end

        mapped_fields
      end
      
      # As ::map_api_fields but API -> human
      #
      # @param [Hash] API mapped attributes
      # @example
      #   map_attributes(:firstname => "Steve", :custom12345 => "Web Developer")
      #   => {"First Name" => "Steve", "Description" => "Web Developer"}
      #
      # @return [Hash] human mapped attributes
      def map_api_fields(fields)
        fields.stringify_keys!
        
        mapped_fields = {}

        field_mapping.each do |human, api|
          mapped_fields[human] = fields[api] if !fields[api].blank?
        end
        
        mapped_fields
      end
      
      def map_category(category)
        category_value = category
        category_value = category_mapping[category] if !category_mapping[category].blank?
        
        category_value
      end
      
      # Create a record in the API
      #
      # @param [Hash] field => value as configured in Item::fields
      def create(fields, options = {})
        new_record = self.new(fields)
        new_record.save
        new_record
      end
      
      # Find records
      # 
      # @param [Integer, Symbol] id of the record on the CRM or :all
      def find(id)
        if id == :all
          find_all
        else
          find_one(id)
        end
      end
      
      # Find a single record
      # 
      # @param [Integer] id of the record on the CRM
      def find_one(id)
        response = request(:get, "/#{self.resource_name}/#{id}")
        construct_record_from_singular(response)
      end
      
      # Find all records
      def find_all
        response = request(:get, "/#{self.resource_name}/", "<request><layout>1</layout></request>")
        construct_record_from_collection(response)
      end
      
      # Send an HTTP request
      # 
      # @param [Symbol, String] :get, :post, :put or :delete
      # @param [String] url of the resource 
      # @param [String, nil] optional string to send in request body
      def request(verb, uri, body = "")
        send(verb, HTTParty.normalize_base_uri(Solve360::Config.config.url) + uri,
          :headers => {"Content-type" => "application/json", "Accepts" => "application/json"},
          :body => body,
          :basic_auth => {:username => Solve360::Config.config.username, :password => Solve360::Config.config.token})
      end
      
      def construct_record_from_singular(response)
        item = response["response"]["item"]
        item.symbolize_keys!
        
        item[:fields] = map_api_fields(item[:fields])
      
        record = new(item)
        
        if response["response"]["relateditems"]
          related_items = response["response"]["relateditems"]["relatedto"]
        
          if related_items.kind_of?(Array)
            record.related_items.concat(related_items)
          else
            record.related_items = [related_items]
          end
        end
        
        if response["response"]["categories"]
          categories = response["response"]["categories"]["category"]
          
          if categories.kind_of?(Array)
            record.categories.concat(categories)
          else
            record.categories = [categories]
          end
        end
        
        record
      end
      
      def construct_record_from_collection(response)
        response["response"].collect do |item|  
          item = item[1]
          if item.respond_to?(:keys)
            attributes = {}
            attributes[:id] = item["id"]
          
            attributes[:fields] = map_api_fields(item)

            record = new(attributes)
          end
        end.compact
      end
      
      def resource_name
        self.name.to_s.demodulize.underscore.pluralize
      end

      def map_fields(&block)        
        @field_mapping.merge! yield
      end
      
      def map_categories(&block)
        @category_mapping.merge! yield
      end
        
      def field_mapping
        @field_mapping
      end
      
      def category_mapping
        @category_mapping
      end
    end
  end
end