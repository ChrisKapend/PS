
<#
.Synopsis
   Create Multiple sharedmailbox on an exchange online tenant with multiple domain and give permission
.DESCRIPTION
   Cmdlet created for AVZ to bypass the signature issue of autmapped sharedmailbox
   The cmdlet take as parameter the username who will be member of the shared mailboxes and a list of domain to created shared mailboxes for
.EXAMPLE
   Created for user CKapend@dathcom.com the following sharedmailbox: ckapend@majibora.com, ckapend@nyukilogistics.com, ckapend@avzpower.com and gives to user ckapend@dathcom.com
   Send and read permission to those sharedmailboxes.

   New-MultiDomainUserMailbox -userPrincipalName ckapend@dathcom.com -domains "majibora.com", "nyukilogistics.com", "avzpower.com" -Verbose

.EXAMPLE
   $username = ckapend@dathcom.com
   $domain = "majibora.com", "nyukilogistics.com", "avzpower.com"
   New-MultiDomainUserMailbox -userPrincipalName $username -domain $domain or New-MultiDomainUserMailbox -upn $username -dom $domain
.Author
   Chris Kapend
#>


#creating the user's mailboxes
function New-MultiDomainUserMailbox{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param(
        #user principal name in the form user@domain.com domain.being the actual user's default domain.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("upn")] 
        [String]
        $userPrincipalName,

        #The list of different domains that the user's mailboxes will be created294019
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("dom")]
        [String[]]
        $domains
    )
    process{
            try{
        #Getting Admin Credential

        #Controls
        #ExchangeOnlineManagement Module and AzureAD Module

        #Connect and Import 
        Import-Module ExchangeOnlineManagement, AzureAD
        Connect-ExchangeOnline
        Connect-AzureAD

        #Get User mailbox from exchange and check his existance
        Write-Verbose "Username: $userPrincipalName"
        Write-Verbose "domains: $domains"
        $user = Get-Mailbox $userPrincipalName -ErrorAction stop
        Write-Verbose "searching for $userPrincipalName mailbox"
        Write-Verbose "mailbox found"
        #Checking the domains
        $domains | Get-AzureADDomain -ErrorAction Stop
        #Get user's alias & primary domain from username part before the @
        $userName = $(($userPrincipalName -split '@')[0])
        $defaultDomain = $(($userPrincipalName -split '@')[1])

        #for each domain
        for($i = 0; $i -lt $domains.Length; $i++){
            Write-Verbose "Creating mailbox for domain $($domains[$i])" #verbose
            $sharedMailbox = "$userName@$($domains[$i])"
            New-Mailbox -Shared -Name "$(($user.DisplayName)[$i])" -PrimarySmtpAddress $sharedMailbox -ErrorAction stop
            Write-Verbose "Shared Mailbox Created"
            Write-Verbose "Changing the default upn to match the user's upn"
            #chaging the user's upn the current upn is firstnamelastname@sharedmailbox.com
            Get-AzureADUser -Filter "mail eq '$sharedMailbox'" -ErrorAction stop | Set-AzureADUser -UserPrincipalName "$sharedMailbox" -ErrorAction Stop
            $smtpAliases = (Get-Mailbox $sharedMailbox).EmailAddresses
            $smtpToRemove = '"'+("$(($smtpAliases.Where({$_ -ceq "SMTP:$sharedMailbox"}, 'Split')[1]) -replace "smtp:",'')" -replace " ",'","')+'"'
            #Removing the multiple aliases created on the sharedmailbox
            Set-Mailbox $sharedMailbox -MicrosoftOnlineServicesID $sharedMailbox -EmailAddresses @{remove=$smtpToRemove} -DisplayName $user.DisplayName -ErrorAction stop
            Add-RecipientPermission -Identity $sharedMailbox -Trustee $user.userPrincipalName -AccessRights SendAs -ErrorAction stop
            Add-MailboxPermission -AccessRights FullAccess -User $user.userPrincipalName -Identity $sharedMailbox -AutoMapping $false -ErrorAction stop
        }
    }
    catch{
            Write-Verbose "An Error occured, fuction will exit"
            Write-Verbose "Consult the content of '$($Error[0])' for further troubleshooting"
            Write-Host -ForegroundColor Yellow "Full Error Name $($Error[0].Exception.GetType().FullName)"
            Write-Host -ForegroundColor Yellow "Use New-MultiDomainUserMailbox with the -verbose for troubleshooting" -BackgroundColor Red
        }
    }
}
