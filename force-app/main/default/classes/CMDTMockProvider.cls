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
        String fpjson = '[{"Id":"fpID"';
        fpjson += ',"DeveloperName":"Test"';
        fpjson += ',"Object__c":"Contact"';
        fpjson += ',"Free_Text_Field__c":"Contact.Title"';
        fpjson += ',"Picklist_Field__c":"Contact.LeadSource"';
        fpjson += ',"Match_Last_Evaluated_Date_Time_Field__c":"Contact.LastModifiedDate"';
        fpjson += ',"Text_Last_Populated_Date_Time_Field__c":"Contact.CreatedDate"';
        fpjson += '}]';
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