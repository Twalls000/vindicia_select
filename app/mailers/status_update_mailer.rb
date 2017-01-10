class StatusUpdateMailer < ApplicationMailer
  RECIPIENTS = Rails.env.production? ? "wspencer@gannett.com,hghavami@gannett.com,rverhey@gannett.com" : "rverhey@gannett.com"
  SENDER     = "Vindicia Select #{Rails.env.capitalize} <vindicia_select_#{Rails.env}@gannett.com>"

  default to:   RECIPIENTS,
          from: SENDER

  def status_email
    set_up_variables
    subject = "Vindicia Select #{Rails.env.capitalize} Status"
    subject += " - Potential Issue" if @potential_issues || @too_many_jobs

    mail subject: subject
  end

  private

  def set_up_variables
    @status_classes = [DeclinedCreditCardTransaction, DeclinedCreditCardBatch]

    @audit_trail_errors = AuditTrail.joins(:declined_credit_card_transaction).where("declined_credit_card_transactions.status = 'in_error'").group(:declined_credit_card_transaction_id).map(&:event)

    @in_error_jobs = Delayed::Job.where("last_error is not NULL").map(&:last_error)

    @non_added_sites = Site.where(gci_unit: Site.select(:gci_unit).map(&:gci_unit) - MarketPublication.select(:gci_unit).map(&:gci_unit)).order(:name)
    @non_added_sites = @non_added_sites.inject({}) do |hash,site|
      hash[site.name] =
        DeclinedCreditCard.on_db(site.gci_unit).count rescue "No CCVC"
      hash
    end

    @potential_issues = @status_classes.map { |c| c.group(:status).count.keys }.flatten.include?("queued_to_send")

    @too_many_jobs = Delayed::Job.count > @in_error_jobs.count && @in_error_jobs.count != 0
  end
end
