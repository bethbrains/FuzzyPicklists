public class FuzzyPicklists {
    
    public static void matchAllPicklists(List<Id> recordIds){
        //find all MDTs for the object
        List<FuzzyPicklist__mdt> fps = getFuzzyPicklists(recordIds);
        //find all relevant FuzzyPicklistValues and FuzzyPicklistPossibilities
        List<FuzzyPicklistValue__mdt> fpvs = getFuzzyPicklistValuesWithPossibilities(fps);
        //find full info from all IDs with
        //dynamic soql assembling free text field and picklist field as defined in fp
        String query = buildBaseQueryString(fps,recordIds)+' WHERE Id IN :recordIds';
        List<sObject> records = Database.query(query);

        Map<Id, sObject> recordsToUpdate = new Map<Id, sObject>();
        //for each FP, pass to matchPicklist
        for(FuzzyPicklist__mdt fp : fps){
            for(sObject rec : matchPicklist(fp, fpvs, records)){
                recordsToUpdate.put(rec.Id,rec);
            }
        }
        update recordsToUpdate.values();
    }
    
    public static List<sObject> matchPicklist(FuzzyPicklist__mdt fp, List<FuzzyPicklistValue__mdt> fpvs, List<sObject> records){
        List<sObject> recordsToUpdate = new List<sObject>();
        //for each record
        for(sObject rec : records){
            //only process if text has updated since last evaluation
            //or if picklist is still null
            Boolean matchFound = false;
            Boolean newValueFound = true;
            Boolean neverEvaluated = false;
            if (fp.Text_Last_Populated_Date_Time_Field__c != null && fp.Match_Last_Evaluated_Date_Time_Field__c != null) {
                newValueFound = getDateTime(rec,fp.Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName) > 
                    getDateTime(rec,fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName);
                neverEvaluated = getDateTime(rec,fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName) == null;
            }
            Boolean picklistBlank = getString(rec,fp.Picklist_Field__r.QualifiedAPIName) == null;
            if(newValueFound || picklistBlank || neverEvaluated){
                //loop fpvs
                for(FuzzyPicklistValue__mdt fpv : fpvs){
                    //make sure we're in the right fp since fpvs includes all fps for the object in question
                    if(fpv.FuzzyPicklist__c == fp.Id){
                        //loop FuzzyPicklistPossibility records comparing string value
                        for(FuzzyPicklistPossibility__mdt fpp : fpv.FuzzyPicklistPossibilities__r){
                            String textField = getString(rec,fp.Free_Text_Field__r.QualifiedAPIName);
                            if(stringsMatch(textField, fpp.Match_String__c)){
                                //when it matches
                                matchFound = true;
                                //write record.picklistvalue to FuzzyPicklistValue.picklistapivalue
                                rec.put(fp.Picklist_Field__r.QualifiedAPIName,fpv.Picklist_API_Value__c);
                                // This if is only needed for testing - there aren't any writeable datetime fields we can use
                                if (isUpdateable(rec.getSObjectType(), fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName)) {
                                    rec.put(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName,System.now());
                                }
                                recordsToUpdate.add(rec);
                            } 
                        }
                    }
                }
            }
            //if field has been updated and no match found for new value,
            //clear out picklist value so it can be re-qualified by a human.
            //may want this behind a setting.
            if(!matchFound && newValueFound && !picklistBlank){
                rec.put(fp.Picklist_Field__r.QualifiedAPIName,null);
                rec.put(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName,System.now());
                recordsToUpdate.add(rec);
            }
        }
        return recordsToUpdate;
    }
    
    public static List<FuzzyPicklist__mdt> getFuzzyPicklists(List<Id> recordIds){
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
    
    public static List<FuzzyPicklistValue__mdt> getFuzzyPicklistValuesWithPossibilities(List<FuzzyPicklist__mdt> fps){
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
    
    public static String buildBaseQueryString(List<FuzzyPicklist__mdt> fps, List<Id> recs){
        String obj = recs[0].getSObjectType().getDescribe().getName();
        // to avoid issues with the same field being used in multiple rules, add to a set to dedupe
        Set<String> fields = new Set<String> {'Id', 'Name'};
        for (FuzzyPicklist__mdt fp : fps) {
            fields.add(fp.Picklist_Field__r.QualifiedAPIName);
            fields.add(fp.Free_Text_Field__r.QualifiedAPIName);
            fields.add(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName);
            fields.add(fp.Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName);
        }
        // there is a possibility that there could be fields not populated in the metadata, so remove the null entry
        fields.remove(null);
        //build query string
        String query = 'SELECT ' + String.join(new List<String>(fields), ',') +  ' FROM ' + obj;
        system.debug(query);
        return query;
    }
    
    public static DateTime getDateTime(sObject rec, String fieldName){
        return (DateTime)rec.get(fieldName);
    }
    
    public static String getString(sObject rec, String fieldName){
        return (String)rec.get(fieldName);
    }
    
    public static Boolean stringsMatch(String string1, String string2){
        return string1 == string2;
    }

    public static Boolean isUpdateable(Schema.sObjectType sObjType, String fieldName) {
        Map<String, SObjectField> fields = sObjType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isUpdateable();
    }
    
}