public with sharing class CMDTUtil {

    public List<FuzzyPicklist__mdt> getFuzzyPicklists(List<Id> recordIds){
        String obj = String.valueof(recordIds[0].getSObjectType());
        return [SELECT Id
                , DeveloperName 
                , Object__c
                , Free_Text_Field__c
                , Picklist_Field__c
                , Match_Last_Evaluated_Date_Time_Field__c
                , Text_Last_Populated_Date_Time_Field__c
                , Free_Text_Field__r.QualifiedAPIName
                , Picklist_Field__r.QualifiedAPIName
                , Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName
                , Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName
                FROM FuzzyPicklist__mdt
                WHERE Object__c = :obj
               ];
        
    }

    public List<FuzzyPicklistValue__mdt> getFuzzyPicklistValuesWithPossibilities(List<FuzzyPicklist__mdt> fps){  
        return [SELECT Id
                , DeveloperName
                , Picklist_API_Value__c
                , FuzzyPicklist__c
                , (SELECT Id
                   , DeveloperName
                   , Match_String__c  
                   , FuzzyPicklistValue__c
                   FROM FuzzyPicklistPossibilities__r)
                FROM FuzzyPicklistValue__mdt
                WHERE FuzzyPicklist__c IN :fps];
    }
}
