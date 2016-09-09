# Vindicia Select

## Queue Processes
> We will process the background jobs to gather transactions into a temporary transaction table, to send the transactions to Vindicia Select, and to pull transactions back from Vindicia Select
1. create_declined_batches - This will create the MySQL table and prepare to format to send to Vindicia Select.
* Status: Entry
2. send_for_capture - This is sending to Vindicia Select by calling the API Bill transactions
* Status: Awaiting Approval
3. fetch_billing_results - This job will call Vindicia Select's API to determine the status of a billed transaction.
* Status: fetched?
4. sending_to_genesys: Sending to Genesys
* Status PB or Captured.
