/**
 * PropertyTriggerHandler - Trigger handler pattern for Property__c
 * 
 * EXAM TOPICS COVERED:
 * - Trigger handler pattern (best practice)
 * - Bulkification (processing collections, not individual records)
 * - Governor limits awareness
 * - Field history tracking
 * - Record locking and recursion prevention
 * 
 * EXAM TIP: Handler pattern benefits:
 * - Separates logic from trigger
 * - Easier to test
 * - Prevents recursion
 * - Maintains single responsibility principle
 * - Makes code more maintainable
 * 
 * BULKIFICATION RULES:
 * - Never put SOQL/DML inside loops
 * - Use collections to process multiple records
 * - Use Maps for efficient lookups
 * - Governor Limit: 150 DML statements per transaction
 * - Governor Limit: 100 SOQL queries per transaction
 */
public class PropertyTriggerHandler {
    
    // EXAM TIP: Static variable to prevent recursion
    private static Boolean isExecuting = false;
    
    /**
     * Before Insert - Runs before records are inserted
     * EXAM TIP: Use before triggers to modify field values before save
     * Record doesn't have Id yet in before insert
     */
    public static void beforeInsert(List<Property__c> newProperties) {
        if (isExecuting) return;
        isExecuting = true;
        
        // Validate and set default values
        for (Property__c prop : newProperties) {
            // Set Is_Available based on Status
            if (prop.Status__c == 'Available') {
                prop.Is_Available__c = true;
            } else {
                prop.Is_Available__c = false;
            }
            
            // Ensure description is not empty
            if (String.isBlank(prop.Description__c)) {
                prop.Description__c = 'No description provided';
            }
        }
        
        isExecuting = false;
    }
    
    /**
     * Before Update - Runs before records are updated
     * EXAM TIP: Trigger.oldMap available here - use to compare old vs new values
     */
    public static void beforeUpdate(List<Property__c> newProperties, Map<Id, Property__c> oldPropertiesMap) {
        if (isExecuting) return;
        isExecuting = true;
        
        for (Property__c prop : newProperties) {
            Property__c oldProp = oldPropertiesMap.get(prop.Id);
            
            // EXAM TIP: Always check if field value changed before taking action
            if (prop.Status__c != oldProp.Status__c) {
                // Update Is_Available when status changes
                prop.Is_Available__c = (prop.Status__c == 'Available');
                
                // Prevent changing from Sold to other status
                if (oldProp.Status__c == 'Sold' && prop.Status__c != 'Sold') {
                    prop.addError('Cannot change status of sold property');
                }
            }
            
            // Prevent reducing rent on occupied properties
            if (prop.Status__c == 'Occupied' && 
                prop.Monthly_Rent__c != oldProp.Monthly_Rent__c &&
                prop.Monthly_Rent__c < oldProp.Monthly_Rent__c) {
                prop.Monthly_Rent__c.addError('Cannot reduce rent on occupied property');
            }
        }
        
        isExecuting = false;
    }
    
    /**
     * Before Delete - Runs before records are deleted
     * EXAM TIP: Use to prevent deletion based on conditions
     */
    public static void beforeDelete(List<Property__c> oldProperties) {
        if (isExecuting) return;
        isExecuting = true;
        
        // Prevent deletion of occupied properties
        for (Property__c prop : oldProperties) {
            if (prop.Status__c == 'Occupied') {
                prop.addError('Cannot delete occupied property. Change status first.');
            }
        }
        
        isExecuting = false;
    }
    
    /**
     * After Insert - Runs after records are inserted and have Ids
     * EXAM TIP: Use after triggers when you need the record Id or need to update related records
     */
    public static void afterInsert(List<Property__c> newProperties) {
        if (isExecuting) return;
        isExecuting = true;
        
        // Create initial maintenance request for new properties
        createInitialMaintenanceRequests(newProperties);
        
        isExecuting = false;
    }
    
    /**
     * After Update - Runs after records are updated
     * EXAM TIP: Common use case - update related records
     */
    public static void afterUpdate(List<Property__c> newProperties, Map<Id, Property__c> oldPropertiesMap) {
        if (isExecuting) return;
        isExecuting = true;
        
        Set<Id> changedToOccupied = new Set<Id>();
        
        for (Property__c prop : newProperties) {
            Property__c oldProp = oldPropertiesMap.get(prop.Id);
            
            // Track properties that changed to Occupied
            if (prop.Status__c == 'Occupied' && oldProp.Status__c != 'Occupied') {
                changedToOccupied.add(prop.Id);
            }
        }
        
        // Update related tenant records
        if (!changedToOccupied.isEmpty()) {
            updateRelatedTenants(changedToOccupied);
        }
        
        isExecuting = false;
    }
    
    /**
     * After Delete - Runs after records are deleted
     * EXAM TIP: Record is already deleted, only Trigger.old available
     */
    public static void afterDelete(List<Property__c> oldProperties) {
        if (isExecuting) return;
        isExecuting = true;
        
        // Log deleted properties (in real scenario, might send notification)
        for (Property__c prop : oldProperties) {
            System.debug('Property deleted: ' + prop.Name + ' at ' + prop.Address__c);
        }
        
        isExecuting = false;
    }
    
    /**
     * After Undelete - Runs after records are restored from Recycle Bin
     * EXAM TIP: Less common but can be tested on exam
     */
    public static void afterUndelete(List<Property__c> newProperties) {
        if (isExecuting) return;
        isExecuting = true;
        
        // Set status to Available for undeleted properties
        List<Property__c> toUpdate = new List<Property__c>();
        for (Property__c prop : newProperties) {
            toUpdate.add(new Property__c(
                Id = prop.Id,
                Status__c = 'Available'
            ));
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        
        isExecuting = false;
    }
    
    /**
     * Helper method - Create initial inspection maintenance request
     * EXAM TIP: Extract complex logic into helper methods for readability and testing
     */
    private static void createInitialMaintenanceRequests(List<Property__c> properties) {
        List<Maintenance_Request__c> requests = new List<Maintenance_Request__c>();
        
        // EXAM TIP: Bulkified - process all records in collection
        for (Property__c prop : properties) {
            requests.add(new Maintenance_Request__c(
                Property__c = prop.Id,
                Request_Type__c = 'Other',
                Priority__c = 'Low',
                Request_Status__c = 'New',
                Description__c = 'Initial property inspection'
            ));
        }
        
        // EXAM TIP: Single DML statement outside loop
        if (!requests.isEmpty()) {
            insert requests;
        }
    }
    
    /**
     * Helper method - Update tenant status when property becomes occupied
     * EXAM TIP: Use Maps for efficient lookups, avoid nested loops
     */
    private static void updateRelatedTenants(Set<Id> propertyIds) {
        // EXAM TIP: Query related records once, not in a loop
        List<Tenant__c> tenants = [
            SELECT Id, Tenant_Status__c, Property__c
            FROM Tenant__c
            WHERE Property__c IN :propertyIds
              AND Tenant_Status__c = 'Applicant'
        ];
        
        // Update tenant status
        for (Tenant__c tenant : tenants) {
            tenant.Tenant_Status__c = 'Active';
        }
        
        if (!tenants.isEmpty()) {
            update tenants;
        }
    }
}