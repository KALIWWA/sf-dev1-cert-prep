/**
 * PropertyDataFactory - Test data factory pattern
 * 
 * EXAM TOPICS COVERED:
 * - Test data factory pattern (best practice)
 * - @TestVisible annotation
 * - Test data isolation
 * - Bulk record creation
 * - Reusable test methods
 * 
 * EXAM TIP: Test Data Factory Benefits:
 * - Centralizes test data creation
 * - Ensures consistent test data
 * - Makes tests more maintainable
 * - Reduces code duplication
 * - Easier to update when object schema changes
 * 
 * EXAM TIP: @TestVisible allows test classes to access private methods/variables
 */
@isTest
public class PropertyDataFactory {
    
    /**
     * Create a single Property with default values
     * EXAM TIP: Provide reasonable defaults but allow overrides
     */
    public static Property__c createProperty() {
        return createProperty('123 Test St', 'San Francisco', 'California', '94102');
    }
    
    /**
     * Create a Property with specific address details
     */
    public static Property__c createProperty(String address, String city, String state, String zip) {
        Property__c prop = new Property__c(
            Address__c = address,
            City__c = city,
            State__c = state,
            Zip_Code__c = zip,
            Property_Type__c = 'Single Family',
            Bedrooms__c = 3,
            Bathrooms__c = 2,
            Square_Feet__c = 1500,
            Monthly_Rent__c = 2500,
            Status__c = 'Available',
            Description__c = 'Test property for unit tests'
        );
        return prop;
    }
    
    /**
     * Create multiple Properties
     * EXAM TIP: Support bulk operations for governor limit testing
     */
    public static List<Property__c> createProperties(Integer count) {
        List<Property__c> properties = new List<Property__c>();
        
        for (Integer i = 0; i < count; i++) {
            properties.add(createProperty(
                i + ' Test Street',
                'Test City ' + i,
                'California',
                '9410' + Math.mod(i, 10)
            ));
        }
        
        return properties;
    }
    
    /**
     * Create and insert a single Property
     * EXAM TIP: Separate creation from insertion for flexibility
     */
    public static Property__c insertProperty() {
        Property__c prop = createProperty();
        insert prop;
        return prop;
    }
    
    /**
     * Create and insert multiple Properties
     */
    public static List<Property__c> insertProperties(Integer count) {
        List<Property__c> properties = createProperties(count);
        insert properties;
        return properties;
    }
    
    /**
     * Create a Tenant linked to a Property
     */
    public static Tenant__c createTenant(Id propertyId) {
        return new Tenant__c(
            Name = 'Test Tenant',
            Property__c = propertyId,
            Email__c = 'test@example.com',
            Phone__c = '555-0100',
            Lease_Start_Date__c = Date.today(),
            Lease_End_Date__c = Date.today().addYears(1),
            Credit_Score__c = 720,
            Security_Deposit__c = 2500,
            Tenant_Status__c = 'Active'
        );
    }
    
    /**
     * Create multiple Tenants for testing
     */
    public static List<Tenant__c> createTenants(Id propertyId, Integer count) {
        List<Tenant__c> tenants = new List<Tenant__c>();
        
        for (Integer i = 0; i < count; i++) {
            tenants.add(new Tenant__c(
                Name = 'Test Tenant ' + i,
                Property__c = propertyId,
                Email__c = 'test' + i + '@example.com',
                Phone__c = '555-010' + i,
                Tenant_Status__c = 'Active'
            ));
        }
        
        return tenants;
    }
    
    /**
     * Create and insert a Tenant
     */
    public static Tenant__c insertTenant(Id propertyId) {
        Tenant__c tenant = createTenant(propertyId);
        insert tenant;
        return tenant;
    }
    
    /**
     * Create a Maintenance Request
     */
    public static Maintenance_Request__c createMaintenanceRequest(Id propertyId) {
        return new Maintenance_Request__c(
            Property__c = propertyId,
            Request_Type__c = 'Plumbing',
            Priority__c = 'Medium',
            Request_Status__c = 'New',
            Description__c = 'Test maintenance request',
            Estimated_Cost__c = 500
        );
    }
    
    /**
     * Create multiple Maintenance Requests
     */
    public static List<Maintenance_Request__c> createMaintenanceRequests(Id propertyId, Integer count) {
        List<Maintenance_Request__c> requests = new List<Maintenance_Request__c>();
        List<String> types = new List<String>{'Plumbing', 'Electrical', 'HVAC', 'Appliance'};
        
        for (Integer i = 0; i < count; i++) {
            requests.add(new Maintenance_Request__c(
                Property__c = propertyId,
                Request_Type__c = types[Math.mod(i, types.size())],
                Priority__c = 'Medium',
                Request_Status__c = 'New',
                Description__c = 'Test request ' + i
            ));
        }
        
        return requests;
    }
    
    /**
     * Create and insert Maintenance Requests
     */
    public static List<Maintenance_Request__c> insertMaintenanceRequests(Id propertyId, Integer count) {
        List<Maintenance_Request__c> requests = createMaintenanceRequests(propertyId, count);
        insert requests;
        return requests;
    }
    
    /**
     * Create a complete property setup with tenant and requests
     * EXAM TIP: Composite method for complex test scenarios
     */
    public static PropertyTestData createCompletePropertySetup() {
        // Insert property
        Property__c prop = insertProperty();
        
        // Insert tenant
        Tenant__c tenant = insertTenant(prop.Id);
        
        // Insert maintenance requests
        List<Maintenance_Request__c> requests = insertMaintenanceRequests(prop.Id, 3);
        
        // Return wrapper with all data
        return new PropertyTestData(prop, tenant, requests);
    }
    
    /**
     * Wrapper class to return multiple related records
     * EXAM TIP: Inner classes useful for organizing test data
     */
    public class PropertyTestData {
        public Property__c property { get; set; }
        public Tenant__c tenant { get; set; }
        public List<Maintenance_Request__c> maintenanceRequests { get; set; }
        
        public PropertyTestData(Property__c prop, Tenant__c ten, List<Maintenance_Request__c> reqs) {
            this.property = prop;
            this.tenant = ten;
            this.maintenanceRequests = reqs;
        }
    }
}