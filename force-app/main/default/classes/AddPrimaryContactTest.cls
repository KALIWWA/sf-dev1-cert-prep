/**
 * Test class for AddPrimaryContact Queueable class.
 * Validates Contact insertion for Accounts in a specific state.
 */
@isTest
private class AddPrimaryContactTest {
    
    /**
     * Test setup method to create 50 Accounts for NY and 50 Accounts for CA.
     */
    @TestSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        
        // Create 50 Accounts for BillingState NY
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(
                Name = 'NY Account ' + i,
                BillingState = 'NY'
            ));
        }
        
        // Create 50 Accounts for BillingState CA
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(
                Name = 'CA Account ' + i,
                BillingState = 'CA'
            ));
        }
        
        insert accounts;
    }
    
    /**
     * Tests the AddPrimaryContact Queueable class inserts Contacts
     * for the 50 CA Accounts but not for the NY Accounts.
     * Validates 100% code coverage by executing the queueable job.
     */
    @isTest
    static void shouldInsertContactsForCAAccounts_WhenJobExecutes() {
        // Given - 50 NY and 50 CA Accounts from @TestSetup
        List<Account> nyAccounts = [SELECT Id FROM Account WHERE BillingState = 'NY'];
        List<Account> caAccounts = [SELECT Id FROM Account WHERE BillingState = 'CA'];
        
        Assert.areEqual(50, nyAccounts.size(), 'Should have 50 NY accounts');
        Assert.areEqual(50, caAccounts.size(), 'Should have 50 CA accounts');
        
        // Verify no Contacts exist before job execution
        List<Contact> contactsBeforeJob = [SELECT Id FROM Contact];
        Assert.areEqual(0, contactsBeforeJob.size(), 'Should have no contacts initially');
        
        // Create a Contact template
        Contact contactTemplate = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact'
        );
        
        // When - Execute the AddPrimaryContact job for CA state
        Test.startTest();
        AddPrimaryContact job = new AddPrimaryContact(contactTemplate, 'CA');
        System.enqueueJob(job);
        Test.stopTest();
        
        // Then - Verify Contacts were inserted for CA Accounts only
        List<Contact> contactsAfterJob = [
            SELECT Id, AccountId, FirstName, LastName 
            FROM Contact
        ];
        
        Assert.areEqual(50, contactsAfterJob.size(), 
            'Should have inserted 50 contacts for CA accounts');
        
        // Verify all Contacts are associated with CA Accounts
        Set<Id> caAccountIds = new Set<Id>();
        for (Account acc : caAccounts) {
            caAccountIds.add(acc.Id);
        }
        
        for (Contact con : contactsAfterJob) {
            Assert.isTrue(caAccountIds.contains(con.AccountId), 
                'Contact should be associated with a CA account');
            Assert.areEqual('Primary', con.FirstName, 
                'Contact FirstName should match template');
            Assert.areEqual('Contact', con.LastName, 
                'Contact LastName should match template');
        }
        
        // Verify no Contacts were inserted for NY Accounts
        List<Contact> nyContacts = [
            SELECT Id 
            FROM Contact 
            WHERE AccountId IN :nyAccounts
        ];
        Assert.areEqual(0, nyContacts.size(), 
            'Should have no contacts for NY accounts');
    }
    
    /**
     * Tests the AddPrimaryContact Queueable class handles empty results
     * gracefully when no Accounts match the specified state.
     */
    @isTest
    static void shouldCompleteSuccessfully_WhenNoAccountsMatchState() {
        // Given - 50 NY and 50 CA Accounts from @TestSetup
        List<Contact> contactsBeforeJob = [SELECT Id FROM Contact];
        Assert.areEqual(0, contactsBeforeJob.size(), 'Should have no contacts initially');
        
        // Create a Contact template
        Contact contactTemplate = new Contact(
            FirstName = 'Test',
            LastName = 'Contact'
        );
        
        // When - Execute job for a state with no Accounts (TX)
        Test.startTest();
        AddPrimaryContact job = new AddPrimaryContact(contactTemplate, 'TX');
        System.enqueueJob(job);
        Test.stopTest();
        
        // Then - Verify no Contacts were inserted
        List<Contact> contactsAfterJob = [SELECT Id FROM Contact];
        Assert.areEqual(0, contactsAfterJob.size(), 
            'Should have no contacts when no accounts match state');
    }
}