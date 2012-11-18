collection @reports



attributes :id, :reported_at, :host_id, :metrics

node :summary do |report|
	report.summaryStatus
  end
