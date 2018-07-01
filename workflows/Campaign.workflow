<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Add_Expenses</fullName>
        <description>Add all the expenses and put the sum in Actual Cost in Campaign</description>
        <field>ActualCost</field>
        <formula>Contract_Reservation_Fee__c  +  Fee_paid_by_DA__c  +  Salary_Wages__c  +  Supplies_Cost__c  +  Transportation_Gas__c  +  Transportation_Rental__c</formula>
        <name>Add Expenses</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>total_expenses_for_campaign</fullName>
        <actions>
            <name>Add_Expenses</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5 OR 6</booleanFilter>
        <criteriaItems>
            <field>Campaign.Contract_Reservation_Fee__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Fee_paid_by_DA__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Salary_Wages__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Supplies_Cost__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Transportation_Gas__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Transportation_Rental__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>adds all the expenses and records it in the total fields.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
