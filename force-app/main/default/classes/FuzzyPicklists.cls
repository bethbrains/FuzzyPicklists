public class FuzzyPicklists {

    // This property allows us to mock the return of Custom Metadata Types in tests 
    @testVisible
    private static CMDTUtil cmdtUtil {
        get {
            if (cmdtUtil == null) {
                cmdtUtil = new CMDTUtil();
            }
            return cmdtUtil;
        }
        set;
    }
    
    public static void matchAllPicklists(List<Id> recordIds){
        //find all MDTs for the object
        List<FuzzyPicklist__mdt> fps = cmdtUtil.getFuzzyPicklists(recordIds);
        System.debug(fps);
        //find all relevant FuzzyPicklistValues and FuzzyPicklistPossibilities
        List<FuzzyPicklistValue__mdt> fpvs = cmdtUtil.getFuzzyPicklistValuesWithPossibilities(fps);
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
        //TODO: add regex evaluation
        return string1 == string2;
    }

    public static Boolean isUpdateable(Schema.sObjectType sObjType, String fieldName) {
        Map<String, SObjectField> fields = sObjType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isUpdateable();
    }
    
}
