/**
 * PropertyControllerTest - Test class for PropertyController
 * 
 * EXAM TOPICS COVERED:
 * - @isTest annotation
 * - @testSetup for test data creation
 * - Test methods
 * - System.assert methods
 * - Test coverage requirements (75% minimum)
 * - Positive and negative testing
 * - Bulk testing (200+ records)
 * - Test data isolation
 * 
 * EXAM TIP: Test Class Best Practices:
 * - Use @testSetup to create reusable test data
 * - Test positive, negative, and bulk scenarios
 * - Use meaningful assert messages
 * - Test governor limits with 200+ records
 * - Aim for 100% coverage, minimum 75% required
 * - Test as different user if testing sharing rules
 * 
 * ASSERTION METHODS:
 * - System.assert(condition, message)
 * - System.assertEquals(expected, actual, message)
 * - System.assertNotEquals(expected, actual, message)
 */
@isTest
private class PropertyControllerTest {
    
    /**
     * @testSetup - Runs once before all test methods
     * EXAM TIP: Use for creating common test data
     * Data persists across test methods in same class
     */
    @testSetup
    static void setupTestData() {
        // Create test properties using data factory
        List<Property__c> properties = PropertyDataFactory.insertProperties(5);
        
        // Create tenant for first property
        PropertyDataFactory.insertTenant(properties[0].Id);
        
        // Create maintenance requests
        PropertyDataFactory.insertMaintenanceRequests(properties[0].Id, 3);
    }
    
    /**
     * Test constructor and basic SOQL
     * EXAM TIP: Test positive case first
     */
    @isTest
    static void testSearchProperties() {
        // Query test data
        Property__c testProp = [SELECT Id, City__c, Monthly_Rent__c FROM Property__c LIMIT 1];
        
        // Test with constructor and instance method
        Test.startTest();
        PropertyController controller = new PropertyController(testProp.City__c, testProp.Monthly_Rent__c + 1000);
        List<Property__c> results = controller.searchProperties();
        Test.stopTest();
        
        // EXAM TIP: Always include assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should find at least one property');
        System.assertEquals(testProp.City__c, results[0].City__c, 'Should match search city');
    }
    
    /**
     * Test relationship queries
     * EXAM TIP: Test parent-to-child queries
     */
    @isTest
    static void testGetPropertiesWithTenants() {
        Test.startTest();
        List<Property__c> results = PropertyController.getPropertiesWithTenants();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        // Verify relationship query worked
        for (Property__c prop : results) {
            System.assertEquals('Occupied', prop.Status__c, 'Property should be occupied');
        }
    }
    
    /**
     * Test child-to-parent queries
     */
    @isTest
    static void testGetTenantsWithPropertyInfo() {
        Test.startTest();
        List<Tenant__c> results = PropertyController.getTenantsWithPropertyInfo();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should find tenants');
        // Verify relationship traversal
        System.assertNotEquals(null, results[0].Property__r, 'Property relationship should exist');
        System.assertNotEquals(null, results[0].Property__r.Name, 'Should access parent field');
    }
    
    /**
     * Test aggregate SOQL
     * EXAM TIP: Test aggregate queries separately
     */
    @isTest
    static void testGetAverageRentByCity() {
        Test.startTest();
        Map<String, Decimal> results = PropertyController.getAverageRentByCity();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should have city averages');
        
        // Verify aggregate calculation
        for (String city : results.keySet()) {
            Decimal avgRent = results.get(city);
            System.assert(avgRent > 0, 'Average rent should be positive');
        }
    }
    
    /**
     * Test DML operations - update
     * EXAM TIP: Test DML with multiple records for bulkification
     */
    @isTest
    static void testUpdatePropertyStatus() {
        List<Property__c> properties = [SELECT Id FROM Property__c LIMIT 3];
        Set<Id> propertyIds = new Set<Id>();
        for (Property__c prop : properties) {
            propertyIds.add(prop.Id);
        }
        
        Test.startTest();
        PropertyController.updatePropertyStatus(propertyIds, 'Maintenance');
        Test.stopTest();
        
        // Verify update
        List<Property__c> updated = [SELECT Id, Status__c FROM Property__c WHERE Id IN :propertyIds];
        for (Property__c prop : updated) {
            System.assertEquals('Maintenance', prop.Status__c, 'Status should be updated');
        }
    }
    
    /**
     * Test insert with exception handling
     * EXAM TIP: Test both success and failure scenarios
     */
    @isTest
    static void testCreateProperty() {
        Property__c newProp = PropertyDataFactory.createProperty();
        
        Test.startTest();
        Id propId = PropertyController.createProperty(newProp);
        Test.stopTest();
        
        System.assertNotEquals(null, propId, 'Should return valid Id');
        
        // Verify record exists
        Property__c inserted = [SELECT Id, Address__c FROM Property__c WHERE Id = :propId];
        System.assertEquals(newProp.Address__c, inserted.Address__c, 'Address should match');
    }
    
    /**
     * Test insert with validation error
     * EXAM TIP: Test negative scenarios with try/catch
     */
    @isTest
    static void testCreatePropertyWithError() {
        Property__c badProp = new Property__c();
        // Missing required fields will cause DML exception
        
        Test.startTest();
        try {
            PropertyController.createProperty(badProp);
            System.assert(false, 'Should have thrown exception');
        } catch (DmlException e) {
            // EXAM TIP: Verify exception was caught
            System.assert(true, 'Expected exception was thrown');
        }
        Test.stopTest();
    }
    
    /**
     * Test Database methods for partial success
     * EXAM TIP: Test Database.insert vs regular insert
     */
    @isTest
    static void testCreatePropertiesSafe() {
        List<Property__c> properties = new List<Property__c>();
        properties.add(PropertyDataFactory.createProperty()); // Valid
        properties.add(new Property__c()); // Invalid - missing required fields
        properties.add(PropertyDataFactory.createProperty('456 Test', 'Austin', 'Texas', '78701')); // Valid
        
        Test.startTest();
        List<Database.SaveResult> results = PropertyController.createPropertiesSafe(properties);
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return 3 results');
        System.assertEquals(true, results[0].isSuccess(), 'First should succeed');
        System.assertEquals(false, results[1].isSuccess(), 'Second should fail');
        System.assertEquals(true, results[2].isSuccess(), 'Third should succeed');
    }
    
    /**
     * Test collections usage
     * EXAM TIP: Test methods that demonstrate collection types
     */
    @isTest
    static void testDemonstrateCollections() {
        Test.startTest();
        PropertyController.demonstrateCollections();
        Test.stopTest();
        
        // EXAM TIP: For methods with no return value, just verify no exceptions
        System.assert(true, 'Method executed without error');
    }
    
    /**
     * Test control flow - categorization
     */
    @isTest
    static void testCategorizeProperty() {
        Property__c prop = PropertyDataFactory.createProperty();
        prop.Monthly_Rent__c = 500;
        
        Test.startTest();
        String category = PropertyController.categorizeProperty(prop);
        Test.stopTest();
        
        System.assertEquals('Budget', category, 'Should categorize as Budget');
        
        // Test other categories
        prop.Monthly_Rent__c = 1500;
        category = PropertyController.categorizeProperty(prop);
        System.assertEquals('Standard', category, 'Should categorize as Standard');
        
        prop.Monthly_Rent__c = 2500;
        category = PropertyController.categorizeProperty(prop);
        System.assertEquals('Premium', category, 'Should categorize as Premium');
        
        prop.Monthly_Rent__c = 4000;
        category = PropertyController.categorizeProperty(prop);
        System.assertEquals('Luxury', category, 'Should categorize as Luxury');
    }
    
    /**
     * Test bulk operations - Governor Limit testing
     * EXAM TIP: Always test with 200+ records to verify bulkification
     */
    @isTest
    static void testBulkOperations() {
        // Create 250 properties
        List<Property__c> bulkProperties = PropertyDataFactory.createProperties(250);
        
        Test.startTest();
        insert bulkProperties;
        
        // Update all properties
        Set<Id> propertyIds = new Set<Id>();
        for (Property__c prop : bulkProperties) {
            propertyIds.add(prop.Id);
        }
        PropertyController.updatePropertyStatus(propertyIds, 'Occupied');
        Test.stopTest();
        
        // Verify all updated
        List<Property__c> updated = [SELECT Id, Status__c FROM Property__c WHERE Id IN :propertyIds];
        System.assertEquals(250, updated.size(), 'Should update all 250 records');
        
        for (Property__c prop : updated) {
            System.assertEquals('Occupied', prop.Status__c, 'All should be Occupied');
        }
    }
    
    /**
     * Test static variable tracking
     * EXAM TIP: Test static variables and their behavior
     */
    @isTest
    static void testQueryCount() {
        PropertyController.resetQueryCount();
        
        Property__c testProp = [SELECT Id, City__c, Monthly_Rent__c FROM Property__c LIMIT 1];
        PropertyController controller = new PropertyController(testProp.City__c, 3000);
        
        Test.startTest();
        controller.searchProperties();
        controller.searchProperties();
        Test.stopTest();
        
        Integer count = PropertyController.getQueryCount();
        System.assertEquals(2, count, 'Should track 2 queries');
    }
}
