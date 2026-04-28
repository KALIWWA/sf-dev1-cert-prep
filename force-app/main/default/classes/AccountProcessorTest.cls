@isTest
private class AccountProcessorTest {
    
    /**
     * Test AccountProcessor.countContacts with multiple accounts
     * Covers full code coverage with a simple positive scenario
     */
    @isTest
    static void testCountContacts() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        
        // Create contacts for the accounts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < accounts.size(); i++) {
            // Create varying number of contacts per account
            Integer contactCount = i + 1; // 1, 2, 3, 4, 5 contacts
            for (Integer j = 0; j < contactCount; j++) {
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + i + '-' + j,
                    AccountId = accounts[i].Id
                ));
            }
        }
        insert contacts;
        
        // Collect account IDs
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // Call the future method
        Test.startTest();
        AccountProcessor.countContacts(accountIds);
        Test.stopTest();
        
        // Verify the counts for each account
        List<Account> updatedAccounts = [
            SELECT Id, Number_Of_Contacts__c 
            FROM Account 
            WHERE Id IN :accountIds 
            ORDER BY Name
        ];
        
        for (Integer i = 0; i < updatedAccounts.size(); i++) {
            System.assertEquals(i + 1, updatedAccounts[i].Number_Of_Contacts__c, 
                'Account should have correct contact count');
        }
    }
}