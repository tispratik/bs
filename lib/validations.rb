def validates_positive_or_zero(*attr_names)
  configuration = { :message => "cannot be negative" }
  configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
  validates_each attr_names do |m, a, v| m.errors.add(a, configuration[:message]) if v<0 end
end