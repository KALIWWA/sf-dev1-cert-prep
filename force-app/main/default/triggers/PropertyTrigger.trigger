/**
 * PropertyTrigger - Demonstrates Apex trigger fundamentals
 * 
 * EXAM TOPICS COVERED:
 * - Trigger syntax and structure
 * - Trigger context variables (Trigger.new, Trigger.old, etc.)
 * - Before vs After triggers
 * - Trigger handler pattern (best practice)
 * - Bulkification
 * 
 * EXAM TIP: Know all trigger context variables and when they're available!
 * 
 * TRIGGER CONTEXT VARIABLES:
 * - Trigger.new - List<SObject> of new versions (insert, update, undelete)
 * - Trigger.old - List<SObject> of old versions (update, delete)
 * - Trigger.newMap - Map<Id, SObject> of new versions (update, undelete)
 * - Trigger.oldMap - Map<Id, SObject> of old versions (update, delete)
 * - Trigger.isInsert, isUpdate, isDelete, isUndelete - Boolean flags
 * - Trigger.isBefore, isAfter - Boolean flags
 * - Trigger.size - Number of records
 * 
 * TRIGGER EXECUTION ORDER:
 * 1. System validation rules
 * 2. Before triggers
 * 3. Custom validation rules
 * 4. After triggers
 * 5. Assignment rules
 * 6. Auto-response rules
 * 7. Workflow rules
 * 8. Processes & Flows
 * 9. Escalation rules
 */
trigger PropertyTrigger on Property__c (before insert, before update, before delete,
                                        after insert, after update, after delete, after undelete) {
    
    // EXAM TIP: Best practice - use handler pattern to keep trigger logic organized
    // Trigger should only route to handler, not contain business logic
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            PropertyTriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            PropertyTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            PropertyTriggerHandler.beforeDelete(Trigger.old);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PropertyTriggerHandler.afterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            PropertyTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            PropertyTriggerHandler.afterDelete(Trigger.old);
        }
        else if (Trigger.isUndelete) {
            PropertyTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}