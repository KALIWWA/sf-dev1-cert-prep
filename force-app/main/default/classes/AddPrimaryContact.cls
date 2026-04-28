/**
 * Queueable Apex class that inserts a Contact for each Account in a specific state.
 * Processes up to 200 Accounts with the specified BillingState and associates
 * a cloned Contact record to each Account.
 * 
 * @example
 * Contact con = new Contact(FirstName='Demo', LastName='Contact');
 * AddPrimaryContact job = new AddPrimaryContact(con, 'CA');
 * System.enqueueJob(job);
 */
public with sharing class AddPrimaryContact implements Queueable {
    
    private Contact contactTemplate;
    private String state;
    
    /**
     * Constructor that accepts a Contact sObject and a State abbreviation.
     * 
     * @param contact The Contact sObject to be cloned and inserted for each Account
     * @param state The State abbreviation to filter Accounts by BillingState
     */
    public AddPrimaryContact(Contact contact, String state) {
        this.contactTemplate = contact;
        this.state = state;
    }
    
    /**
     * Executes the queueable job to insert Contacts for Accounts.
     * Queries up to 200 Accounts with the specified BillingState and inserts
     * a cloned Contact associated to each Account.
     * 
     * @param context The QueueableContext provided by the platform
     */
    public void execute(QueueableContext context) {
        List<Account> accounts = [
            SELECT Id 
            FROM Account 
            WHERE BillingState = :state 
            LIMIT 200
        ];
        
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Account acc : accounts) {
            Contact clonedContact = contactTemplate.clone(false, false, false, false);
            clonedContact.AccountId = acc.Id;
            contactsToInsert.add(clonedContact);
        }
        
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}