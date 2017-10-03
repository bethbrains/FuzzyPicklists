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
        String fpjson;
        String namespace = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'CMDTMockProvider'].NameSpacePrefix;

        if(namespace != null){
            fpjson = '[{"attributes":{"type":"fzpk__FuzzyPicklist__mdt","url":"/services/data/v40.0/sobjects/fzpk__FuzzyPicklist__mdt/m021I0000004uL9QAI"},"Id":"m021I0000004uL9QAI","DeveloperName":"Contact","fzpk__Object__c":"Contact","fzpk__Free_Text_Field__c":"Contact.Name","fzpk__Picklist_Field__c":"Contact.LeadSource","fzpk__Match_Last_Evaluated_Date_Time_Field__c":"Contact.CreatedDate","fzpk__Text_Last_Populated_Date_Time_Field__c":"Contact.LastModifiedDate","fzpk__Free_Text_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.Name"},"Id":"000000000000000AAA","DurableId":"Contact.Name","QualifiedApiName":"Name"},"fzpk__Picklist_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LeadSource"},"Id":"000000000000000AAA","DurableId":"Contact.LeadSource","QualifiedApiName":"LeadSource"},"fzpk__Match_Last_Evaluated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.CreatedDate"},"Id":"000000000000000AAA","DurableId":"Contact.CreatedDate","QualifiedApiName":"CreatedDate"},"fzpk__Text_Last_Populated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LastModifiedDate"},"Id":"000000000000000AAA","DurableId":"Contact.LastModifiedDate","QualifiedApiName":"LastModifiedDate"}}]';
        } else {
            fpjson = '[{"attributes":{"type":"FuzzyPicklist__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklist__mdt/m021F00000002PcQAI"},"Id":"m021F00000002PcQAI","DeveloperName":"Contact","Object__c":"Contact","Free_Text_Field__c":"Contact.Name","Picklist_Field__c":"Contact.LeadSource","Match_Last_Evaluated_Date_Time_Field__c":"Contact.CreatedDate","Text_Last_Populated_Date_Time_Field__c":"Contact.LastModifiedDate","Free_Text_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.Name"},"Id":"000000000000000AAA","DurableId":"Contact.Name","QualifiedApiName":"Name"},"Picklist_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LeadSource"},"Id":"000000000000000AAA","DurableId":"Contact.LeadSource","QualifiedApiName":"LeadSource"},"Match_Last_Evaluated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.CreatedDate"},"Id":"000000000000000AAA","DurableId":"Contact.CreatedDate","QualifiedApiName":"CreatedDate"},"Text_Last_Populated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LastModifiedDate"},"Id":"000000000000000AAA","DurableId":"Contact.LastModifiedDate","QualifiedApiName":"LastModifiedDate"}}]';
        }
        
        return (List<FuzzyPicklist__mdt>) JSON.deserialize(fpjson, List<FuzzyPicklist__mdt>.class );
    }

    private Object buildFPValues() {
        String fpvjson;
        String namespace = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'CMDTMockProvider'].NameSpacePrefix;

        if(namespace != null){
            fpvjson = '[{"attributes":{"type":"fzpk__FuzzyPicklistValue__mdt","url":"/services/data/v40.0/sobjects/fzpk__FuzzyPicklistValue__mdt/m011I0000004fc8QAA"},"Id":"m011I0000004fc8QAA","DeveloperName":"Web","fzpk__Picklist_API_Value__c":"Web","fzpk__FuzzyPicklist__c":"m021I0000004uL9QAI","fzpk__FuzzyPicklistPossibilities__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"fzpk__FuzzyPicklistPossibility__mdt","url":"/services/data/v40.0/sobjects/fzpk__FuzzyPicklistPossibility__mdt/m001I0000008udfQAA"},"fzpk__FuzzyPicklistValue__c":"m011I0000004fc8QAA","Id":"m001I0000008udfQAA","DeveloperName":"Smith","fzpk__Match_String__c":"Smith"}]}}]';
        } else {
            fpvjson = '[{"attributes":{"type":"FuzzyPicklistValue__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklistValue__mdt/m011F00000000hjQAA"},"Id":"m011F00000000hjQAA","DeveloperName":"Web","Picklist_API_Value__c":"Web","FuzzyPicklist__c":"m021F00000002PcQAI","FuzzyPicklistPossibilities__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"FuzzyPicklistPossibility__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklistPossibility__mdt/m001F00000000j1QAA"},"FuzzyPicklistValue__c":"m011F00000000hjQAA","Id":"m001F00000000j1QAA","DeveloperName":"Smith","Match_String__c":"Smith"}]}}]';
        }
        
        return (List<FuzzyPicklistValue__mdt>) JSON.deserialize(fpvjson, List<FuzzyPicklistValue__mdt>.class );
    }
}