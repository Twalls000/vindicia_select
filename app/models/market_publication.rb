class MarketPublication
  def self.all(sort_by: :pub_code)
    VINDICIA_SELECT_SITES.sort_by do |site|
      site[sort_by] || site[:pub_code]
    end
  end
end
