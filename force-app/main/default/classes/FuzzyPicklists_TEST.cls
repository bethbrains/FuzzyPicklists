@isTest public class FuzzyPicklists_TEST {
    @isTest public static void test_getString() {
        Contact c = new Contact(LastName='Smith');
        String ln = FuzzyPicklists.getString(c,'LastName');
        System.assertEquals(c.LastName, ln);
    }
    @isTest public static void test_getDateTime() {
        Contact c = new Contact(LastName='Smith');
        insert c;
        c = [SELECT id, CreatedDate FROM Contact WHERE Id = :c.Id];
        Datetime dt = System.now();
        Datetime dt2 = FuzzyPicklists.getDateTime(c,'CreatedDate');
        System.assertEquals(dt.date(),dt2.date());
    }
    
    @istest public static void test_stringsMatch(){
        System.assert(true,FuzzyPicklists.stringsMatch('yes','yes'));
    }

    @isTest
    public static void test_mockedCMDT() {
        CMDTUtil mockCMDT = (CMDTUtil) Test.createStub(CMDTUtil.class, new CMDTMockProvider());
        FuzzyPicklists.cmdtUtil = mockCMDT;
        Contact c = new Contact(LastName='Smith');
        insert c;
        List<Id> ids = new List<Id>();
        ids.add(c.id);
        MatchFuzzyPicklists.matchPicklists(ids);
        c = [SELECT LeadSource FROM Contact WHERE Id = :c.Id];
        system.assertEquals('Web', c.LeadSource);

        // Need to delay an update to Contact as we are comparing created date and last modified date
        for(Integer i = 0; i<10000000; i++) {}
        c.LastName='Smythe';
        update c;
        MatchFuzzyPicklists.matchPicklists(ids);
        c = [SELECT LeadSource FROM Contact WHERE Id = :c.Id];
        system.assertEquals(null, c.LeadSource);
    }

    @isTest
    public static void test_CMDTUtil(){
        /* This test method is just for code coverage.
        We can't assert on the values that are returned because Custom Metadata Types are always visible to tests.
        There is no way of knowing if the org has created their own entries or not, so we can't predict the number
        or records returned or what their values might be. */
        CMDTUtil cmdtUtil = FuzzyPicklists.cmdtUtil;
        Contact c = new Contact(LastName='Smith');
        insert c;
        List<FuzzyPicklist__mdt> fp = cmdtUtil.getFuzzyPicklists(new List<Id>{c.Id});
        cmdtUtil.getFuzzyPicklistValuesWithPossibilities(fp);
    }
}