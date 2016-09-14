class DeclinedCreditCard < Base
  include SendToGenesys
  self.table_name = :ccvc
  self.primary_key = [:vsppub, :vsbtch, :vsbdat, :vspact]

  alias_attribute :pub_code,        :vsppub
  alias_attribute :batch_id,        :vsbtch
  alias_attribute :batch_date,      :vsbdat
  alias_attribute :account_number,  :vspact
  alias_attribute :credit_amount,   :vscamt
  alias_attribute :debit_amount,    :vsdamt
  alias_attribute :decline_status,  :vsrscd
  alias_attribute :decline_reason,  :vsrstx
  alias_attribute :audit_date,      :udtdat
  alias_attribute :audit_time,      :udttim
  alias_attribute :auth_code,       :vsrscd
  alias_attribute :avs_code,        :vsnavs
  alias_attribute :customer_id,     :vsctid
  alias_attribute :audit_timestamp, :vstmst
  # These aliases are for the Credit Card model
  alias_attribute :card_number,     :crdnbr
  alias_attribute :card_type,       :ccctyp
  alias_attribute :expiration_date, :cccexd
  alias_attribute :name,            :ccname
  alias_attribute :address_line1,   :ccadr1
  alias_attribute :address_line2,   :ccadr2
  alias_attribute :city_state,      :ccctst
  alias_attribute :zip_code,        :pozip5
  # This alias is for the Customer model
  alias_attribute :first_name,      :fnam
  alias_attribute :last_name,       :lnam
  # This alias is for the Address model
  alias_attribute :unit_number,     :unnbr
  alias_attribute :pre_direction,   :predir
  alias_attribute :street_name,     :street
  alias_attribute :box_number,      :boxnbr
  #alias_attribute :         ,      :suffix Let's use the actual suffix name
  alias_attribute :post_direction,  :pstdir
  alias_attribute :subunit_type,    :suntyp
  alias_attribute :subunit_number,  :sunnbr
  alias_attribute :city_name,       :city
  alias_attribute :state,           :astate
  alias_attribute :country,         :cntry
  #alias_attribute :        ,       :pozip5 N/A because of name conflict

  # This alias is for the Card Control model
  alias_attribute :division_number, :'cmmer#'

  belongs_to :subscription, foreign_key: [:vsppub, :vspact]
  belongs_to :credit_card, foreign_key: [:vsppub, :vspact]

  # attribute_names
  def self.summary(gci_unit:, pub_code:, limit:, start_keys:, end_keys: {})
    self.on_db(gci_unit).
      where(*self.summary_where_params(pub_code, start_keys, end_keys)).
      select("#{gci_unit}, ccvc.*, ccrd.crdnbr, ccrd.ccctyp, ccrd.cccexd, " +
        "ccrd.ccname, ccrd.ccadr1, ccrd.ccadr2, ccrd.ccctst, ccrd.pozip5, crdctl.cmmer#, " +
        "prbs.fnam, prbs.lnam, addr.unnbr, addr.predir, addr.street, addr.boxnbr, addr.suffix, " +
        "addr.pstdir, addr.suntyp, addr.sunnbr, addr.city, addr.astate, addr.cntry, addr.pozip5 ").
      joins(:subscription, :credit_card,
        " INNER JOIN crdctl ON crdctl.cmpub = '#{ pub_code }' and crdctl.cmctyp = ccrd.ccctyp",
        " INNER JOIN prbs ON prbs.cusnbr = ccvc.vsctid ",
        " INNER JOIN addr ON addr.adrnbr = subscrip.hsadr# ").
      limit(limit).
      order("ccvc.vsppub ASC, ccvc.vsbtch ASC, ccvc.vsbdat ASC, ccvc.vspact ASC")
  end

  def self.first_record_by_date(date, gci_unit, pub_code)
    self.on_db(gci_unit).where("vsppub=? and vsbdat>=?", pub_code, date.strftime("%Y%m%d").to_i).
    limit(1).order("ccvc.vsbtch ASC, ccvc.vsbdat ASC, ccvc.vspact ASC")
  end

  def self.summary_where_params(pub_code, start_keys, end_keys)
    query_string = ->(addl_params){
      ["vsppub=? and ((vsbtch=? and vsbdat=? and vspact>?) or (vsbtch=? and vsbdat>?) or vsbtch>? ) #{addl_params}"] }
    addl_params = " and (vsbtch<?) or (vsbtch=? and vsbdat<?) or (vsbtch=? and vsbdat=? and vspact<?)"  unless end_keys.empty?

    params = query_string.call(addl_params)
    params += [pub_code, start_keys[:batch_id], start_keys[:batch_date], start_keys[:account_number],
      start_keys[:batch_id], start_keys[:batch_date], start_keys[:batch_id]]
    params += [end_keys[:batch_id], end_keys[:batch_id], end_keys[:batch_date],
      end_keys[:batch_id], end_keys[:batch_date], end_keys[:account_number]]  unless end_keys.empty?

    params
  end

  def batch_keys
    { batch_id: batch_id.strip,
      batch_date: batch_date.zero? ? Date.today.strftime("%Y%m%d").to_i : batch_date,
      account_number: account_number }
  end

  def declined_timestamp
    begin
      Time.strptime(audit_timestamp)
    rescue
      Time.strptime("#{audit_date} #{audit_time.to_s.rjust(6, '0')}", "%Y%m%d %H%M%S")  rescue nil
    end
  end

  def merchant_transaction_id
    "#{ gci_unit }-#{ vsppub }-#{ vsbtch }-#{ vsbdat }-#{ vspact }"
  end

  def account_holder_name
    name.blank? ? "#{ first_name.strip } #{ last_name.strip }" : name.strip
  end

  def billing_address_line1
    use_alternate_address? ? build_address_line1 : address_line1.strip
  end

  def billing_address_line2
    use_alternate_address? ? build_address_line2 : address_line2.strip
  end

  def billing_addr_city
    use_alternate_address? ? city_name.strip : city_state.split(",").first.strip
  end

  def billing_address_district
    use_alternate_address? ? state.strip : city_state.split(",").last.strip
  end

  def billing_address_postal_code
    use_alternate_address? ? pozip5 : zip_code
  end

  def use_alternate_address?
    address_line1.blank? || zip_code.zero?
  end

  def build_address_line1
    "#{post_direction.strip} #{pre_direction.strip} #{street_name.strip} #{suffix.strip} #{post_direction.strip}".strip
  end

  def build_address_line2
    "#{subunit_type.strip} #{subunit_number.strip}".strip
  end

  def save

  end

end
