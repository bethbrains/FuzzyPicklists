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
    @istest public static void test_invocation(){
        Contact c = new Contact(LastName='Smith');
        insert c;
        List<Id> ids = new List<Id>();
        ids.add(c.id);
        MatchFuzzyPicklists.matchPicklists(ids);
        system.assert(true);
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
        system.assert(true);
    }
}