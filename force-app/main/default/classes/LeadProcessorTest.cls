/**
 * Test class for LeadProcessor batch class.
 * Validates batch processing of Lead records and LeadSource updates.
 */
@isTest
private class LeadProcessorTest {
    
    /**
     * Test setup method to create 200 Lead records for batch testing.
     */
    @TestSetup
    static void setupTestData() {
        List<Lead> leads = new List<Lead>();
        
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Status = 'Open - Not Contacted',
                LeadSource = 'Web'
            ));
        }
        
        insert leads;
    }
    
    /**
     * Tests the LeadProcessor batch class processes all Lead records
     * and updates their LeadSource to 'Dreamforce'.
     * Validates 100% code coverage by executing all batch methods.
     */
    @isTest
    static void shouldUpdateLeadSource_WhenBatchExecutes() {
        // Given - 200 Lead records with LeadSource = 'Web' from @TestSetup
        List<Lead> leadsBeforeBatch = [SELECT Id, LeadSource FROM Lead];
        Assert.areEqual(200, leadsBeforeBatch.size(), 'Should have 200 leads from setup');
        
        for (Lead lead : leadsBeforeBatch) {
            Assert.areEqual('Web', lead.LeadSource, 'Initial LeadSource should be Web');
        }
        
        // When - Execute the LeadProcessor batch
        Test.startTest();
        LeadProcessor batch = new LeadProcessor();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Then - Verify all Lead records were updated to 'Dreamforce'
        List<Lead> leadsAfterBatch = [SELECT Id, LeadSource FROM Lead];
        Assert.areEqual(200, leadsAfterBatch.size(), 'Should still have 200 leads');
        
        for (Lead lead : leadsAfterBatch) {
            Assert.areEqual('Dreamforce', lead.LeadSource, 
                'LeadSource should be updated to Dreamforce');
        }
    }
    
    /**
     * Tests the LeadProcessor batch class with no Lead records.
     * Validates batch handles empty scope gracefully.
     */
    @isTest
    static void shouldCompleteSuccessfully_WhenNoLeadsExist() {
        // Given - Delete all leads from @TestSetup
        delete [SELECT Id FROM Lead];
        List<Lead> leadsBeforeBatch = [SELECT Id FROM Lead];
        Assert.areEqual(0, leadsBeforeBatch.size(), 'Should have no leads');
        
        // When - Execute the LeadProcessor batch
        Test.startTest();
        LeadProcessor batch = new LeadProcessor();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Then - Verify batch completes without errors
        List<Lead> leadsAfterBatch = [SELECT Id FROM Lead];
        Assert.areEqual(0, leadsAfterBatch.size(), 'Should still have no leads');
    }
}