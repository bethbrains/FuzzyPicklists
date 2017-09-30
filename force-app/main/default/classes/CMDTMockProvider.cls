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
        String fpjson = '[{"attributes":{"type":"FuzzyPicklist__mdt","url":"/services/data/v40.0/sobjects/FuzzyPicklist__mdt/m021F00000002PcQAI"},"Id":"m021F00000002PcQAI","DeveloperName":"Contact","Object__c":"Contact","Free_Text_Field__c":"Contact.Name","Picklist_Field__c":"Contact.LeadSource","Match_Last_Evaluated_Date_Time_Field__c":"Contact.LastModifiedDate","Text_Last_Populated_Date_Time_Field__c":"Contact.LastModifiedDate","Free_Text_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.Name"},"Id":"000000000000000AAA","DurableId":"Contact.Name","QualifiedApiName":"Name"},"Picklist_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LeadSource"},"Id":"000000000000000AAA","DurableId":"Contact.LeadSource","QualifiedApiName":"LeadSource"},"Match_Last_Evaluated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LastModifiedDate"},"Id":"000000000000000AAA","DurableId":"Contact.LastModifiedDate","QualifiedApiName":"LastModifiedDate"},"Text_Last_Populated_Date_Time_Field__r":{"attributes":{"type":"FieldDefinition","url":"/services/data/v40.0/sobjects/FieldDefinition/Contact.LastModifiedDate"},"Id":"000000000000000AAA","DurableId":"Contact.LastModifiedDate","QualifiedApiName":"LastModifiedDate"}}]';
        return (List<FuzzyPicklist__mdt>) JSON.deserialize(fpjson, List<FuzzyPicklist__mdt>.class );
    }

    private Object buildFPValues() {
        String fpvjson = '[{"Id":"fpv1Id"';
        fpvjson += ',"DeveloperName":"Web"';
        fpvjson += ',"Picklist_API_Value__c":"Web"';
        fpvjson += ',"FuzzyPicklist__c":"fpId"}';
        fpvjson += ',{"Id":"fpv2Id"';
        fpvjson += ',"DeveloperName":"Other"';
        fpvjson += ',"Picklist_API_Value__c":"Other"';
        fpvjson += ',"FuzzyPicklist__c":"fpId"';
        fpvjson += '}]';
        return (List<FuzzyPicklistValue__mdt>) JSON.deserialize(fpvjson, List<FuzzyPicklistValue__mdt>.class );
    }
}