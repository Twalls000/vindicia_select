class Select
  def self.call(method_name, params = {})
    Vindicia::Connection.call("Select",method_name.to_sym,params)
  end
end
