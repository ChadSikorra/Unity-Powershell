Function Test-UnityEmailAlert {

  <#
      .SYNOPSIS
      Test email alert notification by sending a test alert to all configured email destinations. 
      .DESCRIPTION
      Test email alert notification by sending a test alert to all configured email destinations. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID or Object of a Alert Config..
      .EXAMPLE
      Test-UnityEmailAlert

      Test email alert notification by sending a test alert to all configured email destinations.
  #>

  [CmdletBinding(DefaultParameterSetName="Refresh")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object of Alert Config')]
    [Object[]]$ID = '0'
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/alertConfig/<id>/action/testEmailAlert'
    $Type = 'Alert'
    $StatusCode = 204
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

      Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

        If ($ObjectID) {

            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST'

            If ($request.StatusCode -eq $StatusCode) {

                Write-Host "$Type send to $($Object.destinationEmails)"
              
              }  # End If ($request.StatusCode -eq $StatusCode)
            } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
