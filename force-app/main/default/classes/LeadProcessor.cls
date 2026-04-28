/**
 * Batch Apex class to update Lead records with a specific LeadSource.
 * Processes all Lead records in the org and sets their LeadSource to 'Dreamforce'.
 * 
 * @example
 * LeadProcessor batch = new LeadProcessor();
 * Database.executeBatch(batch);
 */
public with sharing class LeadProcessor implements Database.Batchable<SObject> {
    
    /**
     * Collects all Lead records in the org for processing.
     * 
     * @param context The batch context provided by the platform
     * @return Database.QueryLocator containing all Lead records
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, LeadSource 
            FROM Lead
        ]);
    }
    
    /**
     * Processes a batch of Lead records and updates their LeadSource to 'Dreamforce'.
     * 
     * @param context The batch context provided by the platform
     * @param scope The list of Lead records to process in this batch
     */
    public void execute(Database.BatchableContext context, List<Lead> scope) {
        for (Lead lead : scope) {
            lead.LeadSource = 'Dreamforce';
        }
        
        update scope;
    }
    
    /**
     * Performs any post-processing after all batches have completed.
     * 
     * @param context The batch context provided by the platform
     */
    public void finish(Database.BatchableContext context) {
        // Post-processing logic can be added here if needed
    }
}