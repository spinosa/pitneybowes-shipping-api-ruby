module PBShipping
  class ApiObject
    include Enumerable

    def initialize(values=nil)
      @values = {}
      if values != nil
        self.update(values)
      end
    end

    def self.convert_to_api_object(values)
      case values
      when Array
        values.map { |v| self.convert_to_api_object(v) }
      when Hash
        self.new(values)
      else
        values
      end
    end
    
    def update(values)
      values.each do |k, v|
        if v.is_a?(Array) || v.is_a?(Hash)
          new_v = self.class.convert_to_api_object(v)
        else
          new_v = v
        end
        @values[k.to_sym] = new_v
      end
      instance_eval do
        add_accessors(@values.keys)
      end
    end    

    def [](k)
      @values[k.to_sym]
    end

    def []=(k, v)
      update({k => v})
    end
    
    def keys
      @values.keys
    end

    def values
      @values.values
    end

    def to_s(*args)
      JSON.pretty_generate @values
    end

    def to_json(*a)
      JSON.dump(@values)
    end

    def as_json(*a)
      @values.as_json(*a)
    end

    def to_hash
      @values
    end

    def each(&blk)
      @values.each(&blk)
    end

    def key?(k)
      @values.key?(k)
    end
    
    if RUBY_VERSION < '1.9.2'
      def respond_to?(symbol)
        @values.has_key?(symbol) || super
      end
    end

    def inspect()
      "#<#{self.class}:0x#{self.object_id.to_s(16)}}> json: " + self.to_s
    end
    
    def create_accessor(k_name, k_index)
      metaclass.instance_eval do
        define_method(k_name) { @values[k_index] }
        define_method(:"#{k_name}=") do |v|
          @values[k_index] = v unless k_index == ''
        end
      end
    end
    
    def add_accessors(keys)
      keys.each do |k|
        orig_k = k
        while respond_to?(k) do
          k = "_#{k}".to_sym
        end
        create_accessor(k, orig_k)
      end
    end
    
    def metaclass
      class << self
        self
      end
    end

  end
end
