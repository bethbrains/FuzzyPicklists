global class MatchFuzzyPicklists {
    @InvocableMethod(label='Match Fuzzy Picklists' description='Matches all fuzzy picklists on these records.')
    global static void matchPicklists(List<Id> recordId) {
        List<Id> recordIds = recordId;
        FuzzyPicklists.matchAllPicklists(recordIds);
    }
}