class Api::C2kTransController < ApiController

  def create
    @c2k_trans = DeclinedCreditCardTransaction.new(api_params)
    saved_successfully = @c2k_trans.save

    if saved_successfully
      @batch = DeclinedCreditCardBatch.create(gci_unit: @c2k_trans.gci_unit,
                                              pub_code: @c2k_trans.pub_code,
                                              status: "completed",
                                              declined_credit_card_transactions: [@c2k_trans])
    end

    if saved_successfully
      render json: {id: @c2k_trans.id}, status: :created
    else
      render json: json_error_response(@c2k_trans), status: 412
    end
  end

private

  def api_params
    params.require(:transaction).permit(
      :gci_unit,
      :pub_code,
      :account_number,
      :batch_date,
      :batch_id,
      :amount,
      :currency,
      :division_number,
      :merchant_transaction_id,
      :select_transaction_id,
      :subscription_id,
      :subscription_start_date,
      :previous_billing_date,
      :previous_billing_count,
      :customer_id,
      :credit_card_account_hash,
      :credit_card_expiration_date,
      :account_holder_name,
      :billing_address_line1,
      :billing_address_line2,
      :billing_address_line3,
      :billing_addr_city,
      :billing_address_county,
      :billing_address_district,
      :billing_address_postal_code,
      :affiliate_id,
      :affiliate_sub_id,
      :billing_statement_identifier,
      :auth_code,
      :avs_code,
      :cvn_code,
      :name_values,
      :payment_method_id,
      :declined_timestamp,
      :charge_status
    )
  end

end
