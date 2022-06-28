#Calendar permission for all users default or specify user
#Reviewer to see everything; AvailabilityOnly on shows busy with no more details; #LimitedDetails shows whw
#and when; ...

Set-MailboxFolderPermission -identity mailbox@domain.com:\calendarname -User Default -AccessRights Reviewer
