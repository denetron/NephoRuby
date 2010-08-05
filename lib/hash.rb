class Hash
  def to_http_params
    self.map {|k,v| "#{k.to_s}=#{v.to_s}" }.join("&")
  end
end