# Salesforce Platform Developer I Certification - Study Project

## 🎯 Purpose
This project contains a comprehensive **Property Management System** designed to help you prepare for the Salesforce Platform Developer I (DEV-I) certification exam. It covers all major exam topics with practical, working examples.

## 📊 Exam Coverage

| Topic | Weight | Components in This Project |
|-------|--------|----------------------------|
| Salesforce Fundamentals | 8% | Custom Objects, Standard Features |
| Data Modeling & Management | 13% | Objects, Fields, Relationships, Validation Rules |
| Logic & Process Automation | 16% | Flows, Validation Rules, Formula Fields |
| Apex Basics | 8% | Classes, Properties, Methods, Collections |
| Apex Database Operations | 13% | SOQL, SOSL, DML |
| Apex Triggers | 13% | Trigger Handlers, Bulkification |
| Testing | 13% | Test Classes, Coverage, Best Practices |
| User Interface | 8% | Lightning Web Components |
| Debug & Deployment | 8% | Debug Logs, Deployment Strategies |


## 🏗️ Project Structure

```
Property Management System
├── Custom Objects
│   ├── Property__c (Main object with various field types)
│   ├── Tenant__c (Lookup to Property)
│   └── Maintenance_Request__c (Junction object)
├── Apex Classes
│   ├── PropertyController - SOQL, DML, Collections
│   ├── PropertyTriggerHandler - Trigger Pattern
│   ├── TenantService - Service Layer Pattern
│   ├── MaintenanceRequestManager - Complex DML
│   ├── PropertyDataFactory - Test Data Factory
│   └── SOQLExamples - Query Practice
├── Triggers
│   ├── PropertyTrigger - Before/After patterns
│   └── MaintenanceRequestTrigger - Bulkification
├── Flows
│   ├── Property_Onboarding - Screen Flow
│   └── Update_Maintenance_Status - Record-Triggered
└── LWC
    └── propertySearcher - Basic component with Apex integration
```

## 🚀 Quick Start

### Prerequisites
- Salesforce CLI installed
- VS Code with Salesforce Extensions
- Access to a Developer Edition org or Scratch org

### Deployment Steps

1. **Authorize your org:**
   ```bash
   sf org login web --alias DevOrg
   ```

2. **Deploy the metadata:**
   ```bash
   sf project deploy start --target-org DevOrg
   ```

3. **Assign permission set:**
   ```bash
   sf org assign permset --name Property_Manager --target-org DevOrg
   ```

4. **Open the org:**
   ```bash
   sf org open --target-org DevOrg
   ```

5. **Import sample data (optional):**
   ```bash
   sf data import tree --plan data/sample-data-plan.json --target-org DevOrg
   ```

### For Scratch Orgs

```bash
# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias dev1-scratch --set-default

# Deploy
sf project deploy start

# Assign permission set
sf org assign permset --name Property_Manager

# Open org
sf org open
```

## 📚 Study Resources

### Main Documentation
- **STUDY_GUIDE.md** - Detailed explanations of every concept with code references
- **PRACTICE_QUESTIONS.md** - 50+ exam-style questions with detailed answers

### Code Examples by Topic

#### Data Modeling
- `objects/Property__c` - All field types, validation rules, formula fields
- `objects/Tenant__c` - Lookup relationships, picklists
- `objects/Maintenance_Request__c` - Master-detail, roll-up summary

#### Apex Fundamentals
- `PropertyController.cls` - Classes, methods, properties, collections
- `SOQLExamples.cls` - Every SOQL pattern you need

#### Database Operations
- `TenantService.cls` - DML operations, error handling
- `MaintenanceRequestManager.cls` - Database methods, partial success

#### Triggers
- `PropertyTrigger.trigger` - Trigger context variables
- `PropertyTriggerHandler.cls` - Handler pattern, bulkification

#### Testing
- All `*Test.cls` files - Test patterns, assertions, data factory
- `PropertyDataFactory.cls` - @testSetup, test data isolation

#### Automation
- `flows/Property_Onboarding.flow` - Screen flows
- `flows/Update_Maintenance_Status.flow` - Record-triggered flows

#### UI
- `lwc/propertySearcher` - LWC basics, @api, @wire, events

## 💡 Study Tips

1. **Read the code comments** - Every file contains detailed explanations
2. **Run the tests** - Execute test classes to see concepts in action
3. **Modify and experiment** - Change code and observe the results
4. **Use Debug Logs** - Practice debugging techniques
5. **Review STUDY_GUIDE.md** - Read concept explanations before diving into code
6. **Take practice quizzes** - Test your knowledge with PRACTICE_QUESTIONS.md

## 🔑 Key Concepts Demonstrated

### Governor Limits
- Bulkification patterns throughout
- Collection usage instead of loops with queries
- Efficient SOQL (no queries in loops)

### Best Practices
- Trigger handler pattern
- Test data factory
- Service layer separation
- Error handling
- Security considerations (with sharing)

### Common Exam Topics
- Trigger context variables (Trigger.new, Trigger.old, etc.)
- SOQL relationship queries (parent-to-child, child-to-parent)
- DML vs Database methods
- Test class structure (@isTest, @testSetup)
- Collection types (List, Set, Map) and when to use each

## 📖 Recommended Study Order

1. Review **STUDY_GUIDE.md** for concept overview
2. Study **Custom Objects** to understand data modeling
3. Read **Apex Classes** with focus on comments
4. Examine **Triggers** and handler pattern
5. Study **Test Classes** to understand testing
6. Review **Flows** for declarative automation
7. Explore **LWC** for UI basics
8. Complete **PRACTICE_QUESTIONS.md**
9. Practice in the org
10. Take official practice exam

## 🎓 Certification Resources

- [Trailhead: Platform Developer I Certification](https://trailhead.salesforce.com/credentials/platformdeveloperi)
- [Exam Guide](https://trailhead.salesforce.com/help?article=Salesforce-Certified-Platform-Developer-I-Exam-Guide)
- [Trailmix: Platform Developer I Prep](https://trailhead.salesforce.com/users/strailhead/trailmixes/prepare-for-your-salesforce-platform-developer-i-credential)

## 🤝 Contributing

This is a learning project. Feel free to:
- Add more examples
- Improve documentation
- Add practice questions
- Suggest better patterns

## 📝 License

This project is for educational purposes. Use freely for certification preparation.

## ✅ Pre-Exam Checklist

Before taking the exam, ensure you can:
- [ ] Explain all Salesforce relationship types
- [ ] Write triggers with proper bulkification
- [ ] Create test classes with 75%+ coverage
- [ ] Write SOQL queries (basic and relationship)
- [ ] Understand governor limits and how to avoid them
- [ ] Explain trigger context variables
- [ ] Use collections (List, Set, Map) appropriately
- [ ] Handle DML errors properly
- [ ] Understand when to use declarative vs programmatic
- [ ] Debug using debug logs

## 🆘 Getting Help

If you get stuck:
1. Review the inline code comments
2. Check STUDY_GUIDE.md for concept explanations
3. Use Salesforce Developer Forums
4. Join Trailblazer Community
5. Review Salesforce documentation

---

**Good luck with your certification! 🚀**