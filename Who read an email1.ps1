
Get-MessageTrackingLog -Sender mike.nash@contoso.com -MessageSubject "Company newsletter" -Start (Get-Date).AddHours(-48) -EventId RECEIVE | Select MessageID

$msgs = Search-MessageTrackingReport -Identity mike.nash@contoso.com -BypassDelegateChecking -MessageId b4699b83d1084712b2b746582ceedc15@contoso.com


$report = Get-MessageTrackingReport -Identity $msgs.MessageTrackingReportId -BypassDelegateChecking -resultsize 10000


$recipienttrackingevents = @($report | Select -ExpandProperty RecipientTrackingEvents)
$outline = @()
$recipients = $recipienttrackingevents | select recipientaddress
foreach ($recipient in $recipients) {

    $events = Get-MessageTrackingReport -Identity $msg.MessageTrackingReportId -BypassDelegateChecking `
    -RecipientPathFilter $recipient.RecipientAddress -ReportTemplate RecipientPath
        
     $line = $events.RecipientTrackingEvents[-1] | Select RecipientAddress,Status,EventDescription 
	$outline += $line
}