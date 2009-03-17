module RSolr::Ext::Response::Facetable
  
  # represents a facet value; which is a field value and its hit count
  class FacetValue
    attr_reader :value,:hits
    def initialize(value,hits)
      @value,@hits=value,hits
    end
  end
  
  # represents a facet; which is a field and its values
  class Facet
    attr_reader :field
    attr_accessor :values
    def initialize(field)
      @field=field
      @values=[]
    end
  end

  # @response.facets.each do |facet|
  #   facet.field
  # end
  # "caches" the result in the @facets instance var
  def facets
    # memoize!
    @facets ||= (
      facet_fields.inject([]) do |acc,(facet_field_name,values_and_hits_list)|
        acc << facet = Facet.new(facet_field_name)
        # the values_and_hits_list is an array where a value is immediately followed by it's hit count
        # so we shift off an item (the value)
        while value = values_and_hits_list.shift
          # and then shift off the next to get the hit value
          facet.values << FacetValue.new(value, values_and_hits_list.shift)
          # repeat until there are no more pairs in the values_and_hits_list array
        end
        acc
      end
    )
  end

  # pass in a facet field name and get back a Facet instance
  def facet_by_field_name(name)
    @facets_by_field_name ||= {}
    @facets_by_field_name[name] ||= (
      facets.detect{|facet|facet.field.to_s == name.to_s}
    )
  end
  
  def facet_counts
    @facet_counts ||= self[:facet_counts] || {}
  end

  # Returns the hash of all the facet_fields (ie: {'instock_b' => ['true', 123, 'false', 20]}
  def facet_fields
    @facet_fields ||= facet_counts[:facet_fields] || {}
  end

  # Returns all of the facet queries
  def facet_queries
    @facet_queries ||= facet_counts[:facet_queries] || {}
  end
  
end # end Facets