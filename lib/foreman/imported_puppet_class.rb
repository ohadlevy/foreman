class Foreman::ImportedPuppetClass
  attr_reader :name, :module, :parameters

  def initialize opts = { }
    @name = opts["name"] || raise("must provide a puppet class name")
    @module     = opts["module"]
    @parameters = opts["params"] || { }
  end

  def to_s
    name and self.module ? "#{self.module}::#{name}" : name
  end

  # for now, equality is based on class name, and not on parameters
  def ==(other)
    name == other.name && self.module == other.module
  end

  def parameters?
    @parameters.empty?
  end
end