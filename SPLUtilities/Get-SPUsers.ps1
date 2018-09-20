
<#

Author:
Version:
Version History:

Purpose:

#>
<#

PS C:\Users\max> Get-PnPUser

  Id Title                                               LoginName                                                               Email               
  -- -----                                               ---------                                                               -----               
1545 Aaltola, Tuula (Nokia - FI/Espoo)                   i:0#.f|membership|tuula.aaltola@nokia.com                               tuula.aaltola@nok...
2256 Aaltonen, Kim (Nokia - US/Irving)                   i:0#.f|membership|kim.aaltonen@nokia.com                                kim.aaltonen@noki...
2620 Aanouze, Driss (Nokia - MA/Sale)                    i:0#.f|membership|driss.aanouze@nokia.com                               driss.aanouze@nok...
6542 Abarca Masip, Paula (EXT - CL/Santiago)             i:0#.f|membership|paula.abarca_masip.ext@nokia.com                      paula.abarca_masi...
 391 Abba, Mauro (Nokia - IT/Vimercate)                  i:0#.f|membership|mauro.abba@nokia.com                                  mauro.abba@nokia....


PS C:\Users\max> Get-PnPUser -Identity 56

Id Title                                    LoginName                                       Email
-- -----                                    ---------                                       -----
56 Morgenstein, Gerhard (Nokia - DE/Munich) i:0#.f|membership|gerhard.morgenstein@nokia.com gerhard.morgenstein@nokia.com


PS C:\Users\max> Get-PnPUser -Identity 56 | Select-Object -Property *


AadObjectId                    :
Alerts                         : {Microsoft.SharePoint.Client.Alert}
Email                          : gerhard.morgenstein@nokia.com
Groups                         : {1978, 1977, 1751, 5879...}
IsEmailAuthenticationGuestUser :
IsShareByEmailGuestUser        : False
IsSiteAdmin                    : True
UserId                         : Microsoft.SharePoint.Client.UserIdInfo
Id                             : 56
IsHiddenInUI                   : False
LoginName                      : i:0#.f|membership|gerhard.morgenstein@nokia.com
Title                          : Morgenstein, Gerhard (Nokia - DE/Munich)
PrincipalType                  : User
Context                        : OfficeDevPnP.Core.PnPClientContext
Tag                            :
Path                           : Microsoft.SharePoint.Client.ObjectPathIdentity
ObjectVersion                  :
ServerObjectIsNull             : False
TypedObject                    : Microsoft.SharePoint.Client.User

#>
