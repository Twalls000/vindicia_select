class DeclinedCreditCard < Base
  self.table_name = :ccdc
  self.primary_key = [:prbtch, :prspub, :prpact]

  alias_attribute :pub_code,        :prspub
  alias_attribute :batch_id,        :prbtch
  alias_attribute :batch_date,      :prbdat
  alias_attribute :account_number,  :prpact
  alias_attribute :amount,          :prcamt
  alias_attribute :debit_amount,    :prdamt
  alias_attribute :decline_status,  :prnsts
  alias_attribute :decline_reason,  :prndcr
  alias_attribute :audit_date,      :udtdat
  alias_attribute :audit_time,      :udttim
  # These aliases are for the Credit Card model
  alias_attribute :card_number,     :crdnbr
  alias_attribute :card_type,       :ccctyp
  alias_attribute :expiration_date, :cccexd
  alias_attribute :name,            :ccname
  alias_attribute :address_line1,   :ccadr1
  alias_attribute :address_line2,   :ccadr2
  alias_attribute :city_state,      :ccctst
  alias_attribute :zip_code,        :pozip5
  # This alias is for the Subscription model
  alias_attribute :customer_id,     :'hsper#'
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

  belongs_to :subscription, foreign_key: [:prspub, :prpact]
  belongs_to :credit_card, foreign_key: [:prspub, :prpact]

  # attribute_names
  def self.summary(gci_unit:, pub_code:, limit:, start_keys:, end_keys:)
    self.on_db(gci_unit).
      where("prspub=? and (prbtch>=? and prbdat>=? and prpact>?)",
        pub_code, keys[:batch_id], keys[:batch_date], keys[:account_number]).
      select("#{gci_unit}, ccdc.*, subscrip.hsper#, ccrd.crdnbr, ccrd.ccctyp, ccrd.cccexd, " +
        "ccrd.ccname, ccrd.ccadr1, ccrd.ccadr2, ccrd.ccctst, ccrd.pozip5, crdctl.cmmer# as division_number, " +
        "prbs.fnam, prbs.lnam, addr.unnbr, addr.predir, addr.street, addr.boxnbr, addr.suffix, " +
        "addr.pstdir, addr.suntyp, addr.sunnbr, addr.city, addr.astate, addr.cntry, addr.pozip5 ").
      joins(:subscription, :credit_card,
        " INNER JOIN crdctl ON crdctl.cmpub = '#{ pub_code }' and crdctl.cmctyp = ccrd.ccctyp",
        " INNER JOIN prbs ON prbs.cusnbr = subscrip.hsper# ",
        " INNER JOIN addr ON addr.adrnbr = subscrip.hsadr# ").
      limit(limit).
      order("ccdc.prspub ASC, ccdc.prbtch ASC, ccdc.prbdat ASC, ccdc.prpact ASC")
  end

  def self.first_record_by_date(date, gci_unit, pub_code)
    self.on_db(gci_unit).where("prspub=? and prbdat>=?", pub_code, date.strftime("%Y%m%d").to_i).
    limit(1).order("ccdc.prbtch ASC, ccdc.prbdat ASC, ccdc.prpact ASC")
  end

  def batch_keys
    { batch_id: batch_id.strip,
      batch_date: batch_date.zero? ? Date.today.strftime("%Y%m%d").to_i : batch_date,
      account_number: account_number }
  end

  def declined_timestamp
    Time.strptime("#{audit_date} #{audit_time.to_s.rjust(6, '0')}", "%Y%m%d %H%M%S")  rescue nil
  end

  def merchant_transaction_id
    "#{ gci_unit }-#{ prspub }-#{ prbtch }-#{ prbdat }-#{ prpact }"
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
end
