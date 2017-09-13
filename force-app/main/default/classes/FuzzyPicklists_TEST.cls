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
        System.assertEquals(c.CreatedDate, dt);
    }
}