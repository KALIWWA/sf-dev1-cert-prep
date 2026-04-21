# Platform Developer I Certification - Complete Study Guide

## Table of Contents
1. [Salesforce Fundamentals](#salesforce-fundamentals)
2. [Data Modeling & Management](#data-modeling--management)
3. [Logic & Process Automation](#logic--process-automation)
4. [Apex Basics](#apex-basics)
5. [Apex Database Operations](#apex-database-operations)
6. [Apex Triggers](#apex-triggers)
7. [Testing](#testing)
8. [Debug & Deployment](#debug--deployment)

---

## Salesforce Fundamentals (8%)

### Key Concepts
- **Multitenancy**: Shared infrastructure model where multiple organizations run on same platform
- **MVC Architecture**: Model (database), View (UI), Controller (business logic)
- **Org Types**: Production, Sandbox, Developer Edition, Scratch Orgs

### App Building Fundamentals
- **Declarative vs Programmatic**:
  - **Declarative** (clicks, not code): Flows, Process Builder, Validation Rules, Formula Fields
  - **Programmatic** (code): Apex, Visualforce, Lightning Web Components
  - **Rule**: Always try declarative first!

### In This Project
- See custom objects (Property__c, Tenant__c) for declarative features
- See validation rules and formula fields in Property__c

---

## Data Modeling & Management (13%)

### Field Types

| Type | Use Case | Example in Project |
|------|----------|-------------------|
| Text | Short strings | Address__c, City__c |
| Long Text Area | Large text blocks | Description__c |
| Number | Integers/decimals | Bedrooms__c, Bathrooms__c |
| Currency | Money values | Monthly_Rent__c, Purchase_Price__c |
| Date/DateTime | Date tracking | Purchase_Date__c |
| Picklist | Predefined values | Status__c, Property_Type__c |
| Checkbox | Boolean | Is_Available__c |
| Email/Phone | Contact info | Email__c, Phone__c |
| Formula | Calculated | Full_Address__c, Days_On_Market__c |
| Roll-Up Summary | Aggregate child records | Total_Maintenance_Requests__c |

### Relationships

**Lookup Relationship**:
- Optional parent-child link
- Parent deletion options: Clear field (SetNull) or Prevent (Restrict)
- No roll-up summaries
- Example: Tenant__c to Property__c

**Master-Detail Relationship**:
- Required parent-child link
- Cascading delete (delete parent = delete children)
- Roll-up summary fields available
- Child inherits parent's sharing
- Example: Maintenance_Request__c to Property__c

**Junction Object** (Many-to-Many):
- Object with 2 master-detail relationships
- First M-D becomes "primary" master

### Validation Rules

**Functions to Know**:
- `ISBLANK()` - Check if field is empty
- `ISPICKVAL()` - Check picklist value
- `REGEX()` - Pattern matching
- `TODAY()`, `NOW()` - Current date/time
- `TEXT()` - Convert picklist to text
- `AND()`, `OR()`, `NOT()` - Logic operators

**Example from Project**:
```
// Zip code format validation
NOT(OR(
  REGEX(Zip_Code__c, "[0-9]{5}"),
  REGEX(Zip_Code__c, "[0-9]{5}-[0-9]{4}")
))
```

---

## Logic & Process Automation (16%)

### Formula Fields

**Common Functions**:
- String: `LEFT()`, `RIGHT()`, `MID()`, `LEN()`, `CONTAINS()`, `SUBSTITUTE()`
- Math: `ROUND()`, `CEILING()`, `FLOOR()`, `ABS()`, `MAX()`, `MIN()`
- Date: `TODAY()`, `NOW()`, `YEAR()`, `MONTH()`, `DAY()`, `ADDMONTHS()`
- Logical: `IF()`, `CASE()`, `AND()`, `OR()`, `NOT()`, `ISBLANK()`, `ISNULL()`

**Example from Project**:
```
// Full_Address formula
Address__c & ", " & City__c & ", " & TEXT(State__c) & " " & Zip_Code__c

// Days_On_Market formula
TODAY() - DATEVALUE(CreatedDate)
```

### Process Automation Tools

| Tool | When to Use |
|------|-------------|
| Formula Fields | Real-time calculations, read-only |
| Validation Rules | Data quality, prevent bad data |
| Flows | Complex automation, screen flows, scheduled actions |
| Apex Triggers | When declarative can't do it, bulk operations |

---

## Apex Basics (8%)

### Class Structure

```apex
public with sharing class MyClass {
    // Static variable - shared across all instances
    private static Integer counter = 0;
    
    // Instance variable - unique per instance
    private String name;
    
    // Automatic property
    public String City { get; set; }
    
    // Constructor
    public MyClass() {
        this.name = '';
    }
    
    // Instance method
    public void instanceMethod() {
        // Requires object instance to call
    }
    
    // Static method
    public static void staticMethod() {
        // Can be called without instance
        // MyClass.staticMethod()
    }
}
```

### Collections

**List** - Ordered, allows duplicates, indexed:
```apex
List<String> cities = new List<String>{'SF', 'NYC'};
cities.add('LA');
String first = cities[0]; // or cities.get(0)
```

**Set** - Unordered, unique only, fast lookups:
```apex
Set<Id> propertyIds = new Set<Id>();
propertyIds.add(someId);
Boolean exists = propertyIds.contains(someId);
```

**Map** - Key-value pairs:
```apex
Map<Id, Property__c> propMap = new Map<Id, Property__c>();
Map<String, Integer> cityCount = new Map<String, Integer>();
propMap.put(id, property);
Property__c prop = propMap.get(id);
```

### Control Flow

**If-Else**:
```apex
if (condition) {
    // code
} else if (otherCondition) {
    // code
} else {
    // code
}
```

**Switch** (on Integers, Strings, Enums, SObjects):
```apex
switch on variable {
    when value1 {
        // code
    }
    when value2, value3 {
        // multiple values
    }
    when else {
        // default
    }
}
```

**Loops**:
```apex
// For loop with index
for (Integer i = 0; i < list.size(); i++) {
    SObject obj = list[i];
}

// Enhanced for loop (most common)
for (SObject obj : list) {
    // process obj
}

// While loop
while (condition) {
    // code
}

// Do-while (executes at least once)
do {
    // code
} while (condition);
```

---

## Apex Database Operations (13%)

### SOQL Basics

**Basic Query**:
```apex
List<Property__c> props = [
    SELECT Id, Name, City__c, Monthly_Rent__c
    FROM Property__c
    WHERE City__c = 'San Francisco'
      AND Monthly_Rent__c > 2000
    ORDER BY Monthly_Rent__c ASC
    LIMIT 100
];
```

**Bind Variables**:
```apex
String city = 'San Francisco';
Decimal maxRent = 3000;

List<Property__c> props = [
    SELECT Id, Name
    FROM Property__c
    WHERE City__c = :city
      AND Monthly_Rent__c <= :maxRent
];
```

### Relationship Queries

**Parent-to-Child (down one