@isTest
public with sharing class CMDTMockProvider implements System.StubProvider {

    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {
        
        if (stubbedMethodName == 'getFuzzyPicklists') {
            return buildFP();
        } else if (stubbedMethodName == 'getFuzzyPicklistValuesWithPossibilities'){
            return buildFPValues();
        } else {
            return null;
        }
    }

    private Object buildFP() {
        String fpjson = '[{"attributes":{"type":"FuzzyPicklist__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklist__mdt/m021F00000002PcQAI"},"Id":"m021F00000002PcQAI","DeveloperName":"Contact","Object__c":"Contact","Free_Text_Field__c":"Contact.Name","Picklist_Field__c":"Contact.LeadSource","Match_Last_Evaluated_Date_Time_Field__c":"Contact.CreatedDate","Text_Last_Populated_Date_Time_Field__c":"Contact.LastModifiedDate","Free_Text_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.Name"},"Id":"000000000000000AAA","DurableId":"Contact.Name","QualifiedApiName":"Name"},"Picklist_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LeadSource"},"Id":"000000000000000AAA","DurableId":"Contact.LeadSource","QualifiedApiName":"LeadSource"},"Match_Last_Evaluated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.CreatedDate"},"Id":"000000000000000AAA","DurableId":"Contact.CreatedDate","QualifiedApiName":"CreatedDate"},"Text_Last_Populated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LastModifiedDate"},"Id":"000000000000000AAA","DurableId":"Contact.LastModifiedDate","QualifiedApiName":"LastModifiedDate"}}]';
        return (List<FuzzyPicklist__mdt>) JSON.deserialize(fpjson, List<FuzzyPicklist__mdt>.class );
    }

    private Object buildFPValues() {
        String fpvjson = '[{"attributes":{"type":"FuzzyPicklistValue__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklistValue__mdt/m011F00000000hjQAA"},"Id":"m011F00000000hjQAA","DeveloperName":"Web","Picklist_API_Value__c":"Web","FuzzyPicklist__c":"m021F00000002PcQAI","FuzzyPicklistPossibilities__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"FuzzyPicklistPossibility__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklistPossibility__mdt/m001F00000000j1QAA"},"FuzzyPicklistValue__c":"m011F00000000hjQAA","Id":"m001F00000000j1QAA","DeveloperName":"Smith","Match_String__c":"Smith"}]}}]';
        return (List<FuzzyPicklistValue__mdt>) JSON.deserialize(fpvjson, List<FuzzyPicklistValue__mdt>.class );
    }
}