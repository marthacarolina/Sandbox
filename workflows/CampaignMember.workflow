<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ParticipantReminderEmails</fullName>
        <description>Reminder Emails for Participants</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>volunteer@daring-adventures.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Participant_Emails/Participant_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Reminder_email_2_days</fullName>
        <description>Reminder email 2 days before event</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>marthacv@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Benevon_Emails/Reminder_DDA</template>
    </alerts>
    <alerts>
        <fullName>Reminder_email_7_days</fullName>
        <description>Reminder email 7 days before event</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>marthacv@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Benevon_Emails/Reminder_DDA</template>
    </alerts>
</Workflow>
