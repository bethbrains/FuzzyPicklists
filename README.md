# Fuzzy Picklists
So you want a demographic field?
Do it right or don't bother.

## Installation Links
Current release: v1.0

[Production/Developer Orgs](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1I000001K4f5)

[Sandbox Orgs](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1I000001K4f5)

## Doing Demographics Right

The words we use to describe ourselves are important. Organizations should allow constituents to self-identify on key demographics in their own terms. Organizations have a conflicting need to report categorized demographic information to funders and others who need high level overviews of constituent populations. FuzzyPicklists allows organizations to retain a constituent's own identity words *and* pull categorized information for funder reports easily. 

Obviously the pattern here applies beyond demographic fields to anywhere where free text input is more efficient than an unwieldy picklist. 

At a high level, on any object, you have a free text field and a picklist field. When the free text field is updated, the app checks the org's own "dictionary" of known possible values for the text field and finds the corresponding categorized value and puts it in a corresponding picklist field. Both the free text value and the categorized value are retained on the record. Hooray!

## Install

1. <img>[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com)</img>
2. Login with your dev hub org. 
3. Automation will fire to create a new scratch org with this repo installed.
4. *Please note it may take a few minutes for the scratch org to be ready for use.*

## How to Create a New Fuzzy Picklist

### Object Configuration
On the object where you want one or more FuzzyPicklists, create the following for each FP:
1. A text field
2. A corresponding datetime text last updated field (hidden)
3. A picklist field
4. A corresponding datetime picklist last updated field (hidden)

### Custom Metadata Configuration 
For each FP, 
1. Create a FP record, looking up to the corresponding object and four corresponding fields. 
2. For each possible categorized picklist value, create a FuzzyPicklistValue, looking up to the corresponding FP. 
3. For each possible string match for each FPV, create a FuzzyPicklistPossibility, looking up to the corresponding FPV. 

### Automation Configuration 
1. For each object with a FP, create a new Process Builder that fires on create or edit.
2. Create a node for each FP free text field, checking if the text value has changed. If it has, execute a record update the free text datetime field with NOW(). Have each criteria node continue evaluating, not stop. 
3. Create a final node with no criteria* that calls apex "Match Fuzzy Picklists" and passes the record Id in to variable "recordId".
*This works because the code makes sure each picklist field needs updating before updating it, but it could slow save times on records. Best practice for performance tbd. 

## Ongoing Use

### List View To-Dos
Set up a list view for each object or FP to surface records that didn't match on a FPP string. Categorize them manually and update the picklist. Watch for patterns and create new FPP records as needed. 

## Technical Contents

### Custom Metadata Types

#### FuzzyPicklist
1. Represents a single FP, with lookups to the object and four related fields.
    1. Suggested naming convention- objectName:FuzzyPicklistName

#### FuzzyPicklistValue
1. Represents a single possible categorized value for a given FP.
    1. Suggested naming convention- FuzzyPicklistName:Value

#### FuzzyPicklistPossibility
1. Represents a single possible matching string for a given FuzzyPicklistValue. 
    1. Suggested naming convention- FuzzyPicklistName:Value:Possibility

### Apex Classes

#### MatchFuzzyPicklists
A global invocable method that can be called via process builder. Takes a set of Ids, or in the case of PB invocation, a single Id. 

#### FuzzyPicklists
The brains of the operation. Takes a set of Ids [assumed to all be of the same object], finds all Fuzzy Picklists configured for that object, and checks each record to see if it needs to have any of its FPs updated. Updates happen if picklist value is null or if the free text field has been updated since the picklist was last evaluated (based on a corresponding datetime field for each field).
If no match is found in the FPPs, the picklist is left blank (or cleared out in the case of anupdated text field) and it can be manually categorized and updated.

## Issues/Roadmap

1. Allow for regex strings in FPPs.
2. UI that consolidates all records of any object with any uncategorized FPs for centralized manual categorization...? Would this be helpful, or is the List View suggestion adequate?
