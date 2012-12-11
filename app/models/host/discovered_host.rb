class DiscoveredHost < Host
  def populateFieldsFromFacts facts = self.facts_hash
    importer = super
    self.save
  end

end