public class FuzzyPicklists {
    
    public static void matchAllPicklists(List<Id> recordIds){
        //find all MDTs for the object
        List<FuzzyPicklist__mdt> fps = getFuzzyPicklists(recordIds);
        system.debug(fps);
        //for each MDT, pass to matchPicklist
        List<sObject> recordsToUpdate = new List<sObject>();
        for(FuzzyPicklist__mdt fp : fps){
            recordsToUpdate.addAll(matchpicklist(fp, recordIds));
        }
        if(recordsToUpdate.size()>0 && recordsToUpdate != null){
            update recordsToUpdate;
        }
    }
    
    public static List<sObject> matchPicklist(FuzzyPicklist__mdt fp, List<id> recordIds){
        //find all relevant FuzzyPicklistValues
        List<FuzzyPicklistValue__mdt> fpvs = getFuzzyPicklistValues(fp);
        //find all relevant FuzzyPicklistPossibilities
        List<FuzzyPicklistPossibility__mdt> fpps = getFuzzyPicklistPossibilities(fpvs); 
        //find full info from all IDs with
        //dynamic soql assembling free text field and picklist field as defined in fp
        //this could be more scalable but works for now
        List<sObject> records = Database.query(buildBaseQueryString(fp)+' WHERE Id IN :recordIds');
        List<sObject> recordsToUpdate = new List<sObject>();
        //for each record
        for(sObject rec : records){
            //only process if text has updated since last evaluation
            //or if picklist is still null
            Boolean matchFound = false;
            if((DateTime)rec.get(fp.Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName) > 
               (DateTime)rec.get(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName)
               || (String)rec.get(fp.Picklist_Field__r.QualifiedAPIName) == null
               || (DateTime)rec.get(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName) == null
              ){
                  //loop FuzzyPicklistPossibility records comparing string value
                  for(FuzzyPicklistPossibility__mdt fpp : fpps){
                      if((String)rec.get(fp.Free_Text_Field__r.QualifiedAPIName) == fpp.Match_String__c){
                          //when it matches
                          //loop FuzzyPicklistValue records comparing fpv.ID to fpp.fpv
                          matchFound = true;
                          for(FuzzyPicklistValue__mdt fpv : fpvs){
                              if(fpp.FuzzyPicklistValue__c == fpv.Id){
                                  //when it matches
                                  //write record.picklistvalue to FuzzyPicklistValue.picklistapivalue
                                  rec.put(fp.Picklist_Field__r.QualifiedAPIName,fpv.Picklist_API_Value__c);
                                  rec.put(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName,System.now());
                                  recordsToUpdate.add(rec);
                              }
                          } 
                      } 
                  }
              }
            //if field has been updated and no match found to new value,
            //clear out picklist value so it can be re-qualified by a human.
            //may want this behind a setting.
            if(!matchFound 
               && (DateTime)rec.get(fp.Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName) > 
               (DateTime)rec.get(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName) 
               && (String)rec.get(fp.Picklist_Field__r.QualifiedAPIName) != null){
                   rec.put(fp.Picklist_Field__r.QualifiedAPIName,null);
                   rec.put(fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName,System.now());
                   recordsToUpdate.add(rec);
               }
        }
        return recordsToUpdate;
    }
    
    public static List<FuzzyPicklist__mdt> getFuzzyPicklists(List<Id> recordIds){
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
                WHERE Object__c = :String.valueof(recordIds[0].getSObjectType())
               ];
        
    }
    
    public static List<FuzzyPicklistValue__mdt> getFuzzyPicklistValues(FuzzyPicklist__mdt fp){
        return [SELECT Id
                , DeveloperName
                , Picklist_API_Value__c
                , FuzzyPicklist__c
                FROM FuzzyPicklistValue__mdt
                WHERE FuzzyPicklist__c = :fp.Id];
    }
    
    public static List<FuzzyPicklistPossibility__mdt> getFuzzyPicklistPossibilities(List<FuzzyPicklistValue__mdt> fpvs){
        return [SELECT Id
                , DeveloperName
                , Match_String__c  
                , FuzzyPicklistValue__c
                FROM FuzzyPicklistPossibility__mdt
                WHERE FuzzyPicklistValue__c IN :fpvs];
    }
    
    public static String buildBaseQueryString(FuzzyPicklist__mdt fp){
        String query = 'SELECT Id, Name';
        query += ', '+fp.Picklist_Field__r.QualifiedAPIName;
        query += ', '+fp.Free_Text_Field__r.QualifiedAPIName;
        query += ', '+fp.Match_Last_Evaluated_Date_Time_Field__r.QualifiedAPIName;
        query += ', '+fp.Text_Last_Populated_Date_Time_Field__r.QualifiedAPIName;
        query += ' FROM '+fp.Object__c;
        system.debug(query);
        return query;
    }
    
}