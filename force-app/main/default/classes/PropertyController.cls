/**
 * PropertyController - Comprehensive Apex class demonstrating Platform Developer I exam concepts
 * 
 * EXAM TOPICS COVERED:
 * - Apex class structure and syntax
 * - Properties (automatic and custom)
 * - Methods (instance and static)
 * - Collections (List, Set, Map)
 * - SOQL queries (basic, relationship, aggregate)
 * - DML operations (insert, update, delete, upsert)
 * - Exception handling
 * - Governor limits awareness
 * - 'with sharing' keyword for security
 * 
 * EXAM TIP: Understand the difference between 'with sharing' and 'without sharing'
 * - 'with sharing' enforces record-level security (respects org-wide defaults, sharing rules)
 * - 'without sharing' ignores record-level security
 * - If not specified, class inherits sharing from calling class
 */
public with sharing class PropertyController {
    
    // EXAM TIP: Static variables are shared across all instances and persist for transaction
    private static Integer queryCount = 0;
    
    // EXAM TIP: Instance variables are unique to each instance
    private String propertyType;
    
    // EXAM TIP: Automatic properties (get/set) - syntactic sugar for getters/setters
    public String SearchCity { get; set; }
    public Decimal MaxRent { get; set; }
    
    /**
     * Constructor - EXAM TIP: Constructors have same name as class, no return type
     */
    public PropertyController() {
        this.SearchCity = '';
        this.MaxRent = 0;
    }
    
    /**
     * Parameterized constructor - EXAM TIP: You can have multiple constructors (overloading)
     */
    public PropertyController(String city, Decimal maxRent) {
        this.SearchCity = city;
        this.MaxRent = maxRent;
    }
    
    /**
     * Instance method demonstrating basic SOQL
     * EXAM TIP: Instance methods require an object instance to call
     * 
     * SOQL CONCEPTS:
     * - SELECT fields FROM object
     * - WHERE clause for filtering
     * - ORDER BY for sorting
     * - LIMIT for restricting results (Governor Limit: 50,000 rows per transaction)
     */
    public List<Property__c> searchProperties() {
        // EXAM TIP: Always use List<SObject> for query results, even if expecting one record
        List<Property__c> properties = [
            SELECT Id, Name, Address__c, City__c, State__c, 
                   Monthly_Rent__c, Bedrooms__c, Bathrooms__c, Status__c
            FROM Property__c
            WHERE City__c = :SearchCity
              AND Monthly_Rent__c <= :MaxRent
              AND Status__c = 'Available'
            ORDER BY Monthly_Rent__c ASC
            LIMIT 100
        ];
        
        queryCount++;
        return properties;
    }
    
    /**
     * Static method demonstrating relationship queries
     * EXAM TIP: Static methods can be called without instantiating the class
     * Use ClassName.methodName() syntax
     * 
     * RELATIONSHIP QUERY CONCEPTS:
     * - Parent-to-Child: Uses __r relationship name (plural)
     * - Child-to-Parent: Uses __r relationship name (singular) with dot notation
     * - EXAM TIP: You can go up 5 levels but only down 1 level in a single query
     */
    public static List<Property__c> getPropertiesWithTenants() {
        return [
            SELECT Id, Name, Address__c, City__c,
                   (SELECT Id, Name, Email__c, Tenant_Status__c 
                    FROM Tenants__r 
                    WHERE Tenant_Status__c = 'Active'),
                   (SELECT Id, Name, Request_Type__c, Request_Status__c
                    FROM Maintenance_Requests__r
                    WHERE Request_Status__c != 'Completed')
            FROM Property__c
            WHERE Status__c = 'Occupied'
        ];
    }
    
    /**
     * Demonstrates child-to-parent relationship queries
     * EXAM TIP: Use relationship name (without __c) and __r suffix to traverse up
     */
    public static List<Tenant__c> getTenantsWithPropertyInfo() {
        return [
            SELECT Id, Name, Email__c,
                   Property__r.Name,
                   Property__r.Address__c,
                   Property__r.City__c,
                   Property__r.Monthly_Rent__c
            FROM Tenant__c
            WHERE Tenant_Status__c = 'Active'
        ];
    }
    
    /**
     * Demonstrates aggregate SOQL
     * EXAM TIP: Aggregate functions: COUNT(), SUM(), AVG(), MIN(), MAX()
     * GROUP BY and HAVING clauses work like SQL
     */
    public static Map<String, Decimal> getAverageRentByCity() {
        Map<String, Decimal> cityToAvgRent = new Map<String, Decimal>();
        
        // EXAM TIP: Use AggregateResult for aggregate queries
        List<AggregateResult> results = [
            SELECT City__c, AVG(Monthly_Rent__c) avgRent
            FROM Property__c
            WHERE Monthly_Rent__c != null
            GROUP BY City__c
            HAVING AVG(Monthly_Rent__c) > 0
        ];
        
        // EXAM TIP: Use get() method with alias or field name to extract aggregate values
        for (AggregateResult aresult : results) {
            String city = (String)aresult.get('City__c');
            Decimal avgRent = (Decimal)aresult.get('avgRent');
            cityToAvgRent.put(city, avgRent);
        }
        
        
        return cityToAvgRent;
    }
    
    /**
     * Demonstrates DML operations and bulkification
     * EXAM TIP: CRITICAL - Always write bulkified code that handles collections
     * Governor Limit: 150 DML statements per transaction
     * 
     * BAD: DML inside loop
     * GOOD: Collect records, perform DML once outside loop
     */
    public static void updatePropertyStatus(Set<Id> propertyIds, String newStatus) {
        // EXAM TIP: Use Set<Id> for unique IDs, List when order matters or duplicates allowed
        
        // Query records to update
        List<Property__c> propertiesToUpdate = [
            SELECT Id, Status__c
            FROM Property__c
            WHERE Id IN :propertyIds
        ];
        
        // EXAM TIP: Bulkified - process collection, not individual records
        for (Property__c prop : propertiesToUpdate) {
            prop.Status__c = newStatus;
        }
        
        // EXAM TIP: Single DML statement for entire collection (bulkified)
        update propertiesToUpdate;
    }
    
    /**
     * Demonstrates insert operation with error handling
     * EXAM TIP: DML operations can throw exceptions - always handle them
     */
    public static Id createProperty(Property__c newProperty) {
        try {
            // EXAM TIP: Insert returns void, but populates Id field on success
            insert newProperty;
            return newProperty.Id;
        } catch (DmlException e) {
            // EXAM TIP: DmlException provides detailed error information
            System.debug('Error inserting property: ' + e.getMessage());
            System.debug('Failed on field: ' + e.getDmlFieldNames(0));
            System.debug('Error on line: ' + e.getLineNumber());
            throw e; // Re-throw to caller
        }
    }
    
    /**
     * Demonstrates Database methods for partial success
     * EXAM TIP: Database.insert/update/delete/upsert allow partial success
     * Regular DML (insert/update/delete) is all-or-nothing
     */
    public static List<Database.SaveResult> createPropertiesSafe(List<Property__c> properties) {
        // EXAM TIP: allOrNone=false allows partial success
        // Returns SaveResult array with success/error info for each record
        Database.SaveResult[] results = Database.insert(properties, false);
        
        // Process results
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                // EXAM TIP: GetErrors() returns array of Database.Error objects
                for (Database.Error err : results[i].getErrors()) {
                    System.debug('Error on record ' + i + ': ' + err.getMessage());
                    System.debug('Failed fields: ' + err.getFields());
                }
            }
        }
        
        return results;
    }
    
    /**
     * Demonstrates upsert operation
     * EXAM TIP: Upsert inserts new records and updates existing ones
     * Requires external ID field or uses Id field by default
     */
    public static void upsertProperties(List<Property__c> properties) {
        // EXAM TIP: Upsert uses Id field if specified, otherwise needs external ID
        upsert properties;
    }
    
    /**
     * Demonstrates delete and undelete
     * EXAM TIP: Deleted records go to Recycle Bin for 15 days
     * Can be recovered with undelete
     */
    public static void deleteOldProperties(Integer daysOld) {
        Date cutoffDate = Date.today().addDays(-daysOld);
        
        List<Property__c> oldProperties = [
            SELECT Id
            FROM Property__c
            WHERE CreatedDate < :cutoffDate
              AND Status__c = 'Sold'
        ];
        
        // EXAM TIP: Delete using list of records or list of IDs
        delete oldProperties;
        
        // Records can be undeleted if needed
        // undelete oldProperties;
    }
    
    /**
     * Demonstrates collections: List, Set, Map
     * EXAM TIP: Know when to use each collection type!
     * 
     * List: Ordered, allows duplicates, indexed
     * Set: Unordered, no duplicates, faster for contains() checks  
     * Map: Key-value pairs, fast lookups by key
     */
    public static void demonstrateCollections() {
        // LIST - Ordered collection, allows duplicates
        List<String> cities = new List<String>{'San Francisco', 'New York', 'San Francisco'};
        cities.add('Chicago');
        String firstCity = cities.get(0); // Index access
        Integer size = cities.size();
        
        // SET - Unordered, unique elements only
        Set<String> uniqueCities = new Set<String>{'San Francisco', 'New York', 'San Francisco'};
        // uniqueCities now contains only 2 elements (duplicates removed)
        Boolean hasChicago = uniqueCities.contains('Chicago'); // Fast lookup
        uniqueCities.add('Chicago');
        
        // MAP - Key-value pairs
        Map<Id, Property__c> propertyMap = new Map<Id, Property__c>();
        Map<String, Integer> cityCount = new Map<String, Integer>();
        
        // EXAM TIP: Common pattern - map by Id for fast lookup
        List<Property__c> properties = [SELECT Id, Name, City__c FROM Property__c LIMIT 100];
        for (Property__c prop : properties) {
            propertyMap.put(prop.Id, prop);
            
            // Count properties per city
            if (cityCount.containsKey(prop.City__c)) {
                cityCount.put(prop.City__c, cityCount.get(prop.City__c) + 1);
            } else {
                cityCount.put(prop.City__c, 1);
            }
        }
        
        // Iterate over map
        for (String city : cityCount.keySet()) {
            Integer count = cityCount.get(city);
            System.debug(city + ' has ' + count + ' properties');
        }
    }
    
    /**
     * Demonstrates control flow structures
     * EXAM TIP: if/else, for loops, while loops, do-while, switch
     */
    public static String categorizeProperty(Property__c prop) {
        String category;
        
        // IF-ELSE
        if (prop.Monthly_Rent__c == null) {
            category = 'Unknown';
        } else if (prop.Monthly_Rent__c < 1000) {
            category = 'Budget';
        } else if (prop.Monthly_Rent__c < 2000) {
            category = 'Standard';
        } else if (prop.Monthly_Rent__c < 3000) {
            category = 'Premium';
        } else {
            category = 'Luxury';
        }
        
        // SWITCH statement (EXAM TIP: Available in Apex)
        switch on prop.Status__c {
            when 'Available' {
                System.debug('Property is available');
            }
            when 'Occupied' {
                System.debug('Property is occupied');
            }
            when 'Maintenance' {
                System.debug('Property under maintenance');
            }
            when else {
                System.debug('Unknown status');
            }
        }
        
        return category;
    }
    
    /**
     * Demonstrates different loop types
     * EXAM TIP: Know all loop variations for the exam
     */
    public static void demonstrateLoops(List<Property__c> properties) {
        // Traditional for loop with index
        for (Integer i = 0; i < properties.size(); i++) {
            Property__c prop = properties[i];
            System.debug('Property ' + i + ': ' + prop.Name);
        }
        
        // Enhanced for loop (most common)
        for (Property__c prop : properties) {
            System.debug('Property: ' + prop.Name);
        }
        
        // While loop
        Integer counter = 0;
        while (counter < properties.size()) {
            Property__c prop = properties[counter];
            counter++;
        }
        
        // Do-while loop (executes at least once)
        Integer index = 0;
        do {
            if (index < properties.size()) {
                Property__c prop = properties[index];
            }
            index++;
        } while (index < properties.size());
    }
    
    /**
     * EXAM TIP: Static methods to access static variables
     */
    public static Integer getQueryCount() {
        return queryCount;
    }
    
    /**
     * EXAM TIP: Reset static variable (useful in tests)
     */
    public static void resetQueryCount() {
        queryCount = 0;
    }
}
