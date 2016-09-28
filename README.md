# Vindicia Select

## Queue Processes
We will process the background jobs to gather transactions into a temporary transaction table, to send the transactions to Vindicia Select, and to pull transactions back from Vindicia Select
### declined_batches
Create the table entries Declined Credit Card Batches. The submitted job will create the Declined Credit Card Transactions.

* Status: Entry

### send_for_capture
This is sending to Vindicia Select by calling the API Select.billTransactions

* Status: queued_to_send (in process to send)
* Status: pending (sent)
* Status: in_error

### fetch_billing_results
This job will call Vindicia Select's API to retrieve transactions that are ready to be returned.

* Status: processed (Funds were captured)
* Status: printed_bill (Funds were not captured, set to printed bill)
* Status: in_error

### failed_billing_results: This is a daily job to set status for transactions with no reply.

* Status: no_reply
