# TIL_HSS_DiameterAdapter-25_11_1 Architecture

## Process Inventory
### Group: TIL_HSS_DiameterAdapter
| Path |
| :--- |
| [TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Interface/JMSXMLServiceRequestReply.2.process](#tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreply2process) |
| [TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Interface/JMSXMLServiceRequestReply.process](#tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreplyprocess) |
| [TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Sub/MainProcess.2.process](#tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocess2process) |
| [TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Sub/MainProcess.process](#tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocessprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Common/Private/RenderBackEndError.process](#tilhssdiameteradapterconnectivityservicescommonprivaterenderbackenderrorprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/LoadErrorCodes.process](#tilhssdiameteradapterconnectivityservicesdiameterprivateloaderrorcodesprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequestOneGroup.process](#tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestonegroupprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequestOneServer.process](#tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestoneserverprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequest.process](#tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Public/LoadAllDiameterErrorCodes.process](#tilhssdiameteradapterconnectivityservicesdiameterpublicloadalldiametererrorcodesprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Public/ReloadAllDiameterErrorCodes.process](#tilhssdiameteradapterconnectivityservicesdiameterpublicreloadalldiametererrorcodesprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/InitializeConnection.process](#tilhssdiameteradapterconnectivityserviceshsspublicinitializeconnectionprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/NormalizeCTN.process](#tilhssdiameteradapterconnectivityserviceshsspublicnormalizectnprocess) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/UserDataRequest.2.process](#tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequest2process) |
| [TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/UserDataRequest.process](#tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequestprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/CVV2Filter.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringcvv2filterprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/ExceptionSchemaFilter.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringexceptionschemafilterprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/Security/CVV2Filter.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsecuritycvv2filterprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/ServiceExceptionFilter.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringserviceexceptionfilterprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SpecialExceptions/GetSpecialExceptionList.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionsgetspecialexceptionlistprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SpecialExceptions/TraceSpecialException.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionstracespecialexceptionprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SystemExceptionFilter.process](#tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsystemexceptionfilterprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Interface/ServiceExceptionHandler.process](#tilhssdiameteradapterutilityservicesexceptionhandlinginterfaceserviceexceptionhandlerprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Interface/SystemExceptionHandler.process](#tilhssdiameteradapterutilityservicesexceptionhandlinginterfacesystemexceptionhandlerprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Private/MapException.process](#tilhssdiameteradapterutilityservicesexceptionhandlingprivatemapexceptionprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Public/MapAnyException.process](#tilhssdiameteradapterutilityservicesexceptionhandlingpublicmapanyexceptionprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/ServiceExceptionHandler.process](#tilhssdiameteradapterutilityservicesexceptionhandlingserviceexceptionhandlerprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Shutdown BWEngine.process](#tilhssdiameteradapterutilityservicesexceptionhandlingshutdownbwengineprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Interface/OperationReply.process](#tilhssdiameteradapterutilityservicesinterfaceoperationreplyprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Interface/Private/PublishToRetryQueue.process](#tilhssdiameteradapterutilityservicesinterfaceprivatepublishtoretryqueueprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogEnd.process](#tilhssdiameteradapterutilityserviceslogginglogendprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogError.process](#tilhssdiameteradapterutilityserviceslogginglogerrorprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogFatal.process](#tilhssdiameteradapterutilityserviceslogginglogfatalprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogStart.process](#tilhssdiameteradapterutilityserviceslogginglogstartprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/Private/WriteToLog.process](#tilhssdiameteradapterutilityservicesloggingprivatewritetologprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/CSAuditEnd.process](#tilhssdiameteradapterutilityservicesloggingpubliccsauditendprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/CSAuditStart.process](#tilhssdiameteradapterutilityservicesloggingpubliccsauditstartprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/WriteToLog.process](#tilhssdiameteradapterutilityservicesloggingpublicwritetologprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/AuditEvent.process](#tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureauditeventprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/EmptyAuditCache.process](#tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureemptyauditcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/RemoveFromAuditCache.process](#tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureremovefromauditcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/UpdateAuditCache.process](#tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureupdateauditcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/CustomServiceExceptionHandlerInterface.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncapturecustomserviceexceptionhandlerinterfaceprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/EmptyAuditErrorCache.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureemptyauditerrorcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/RemoveFromAuditErrorCache.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureremovefromauditerrorcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/ServiceExceptionClient.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureserviceexceptionclientprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/SystemExceptionClient.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncapturesystemexceptionclientprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/UpdateAuditErrorCache.process](#tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureupdateauditerrorcacheprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/Public/ShutdownCleanUp.process](#tilhssdiameteradapterutilityservicesvfleclientpublicshutdowncleanupprocess) |
| [TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/Public/StartupInitialisation.process](#tilhssdiameteradapterutilityservicesvfleclientpublicstartupinitialisationprocess) |

## Visual Flow Diagrams

#### Process: TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Interface/JMSXMLServiceRequestReply.2.process {: #tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreply2process }

![tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreply2process process flow](tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreply2process.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Interface/JMSXMLServiceRequestReply.process {: #tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreplyprocess }

![tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreplyprocess process flow](tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailsinterfacejmsxmlservicerequestreplyprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Sub/MainProcess.2.process {: #tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocess2process }

![tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocess2process process flow](tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocess2process.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/BusinessServices/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/Sub/MainProcess.process {: #tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocessprocess }

![tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocessprocess process flow](tilhssdiameteradapterbusinessservicescustomermanagementcustomerprofilemanagementcustomeridentitymanagementretrievehsslocationdetailssubmainprocessprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Common/Private/RenderBackEndError.process {: #tilhssdiameteradapterconnectivityservicescommonprivaterenderbackenderrorprocess }

![tilhssdiameteradapterconnectivityservicescommonprivaterenderbackenderrorprocess process flow](tilhssdiameteradapterconnectivityservicescommonprivaterenderbackenderrorprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/LoadErrorCodes.process {: #tilhssdiameteradapterconnectivityservicesdiameterprivateloaderrorcodesprocess }

![tilhssdiameteradapterconnectivityservicesdiameterprivateloaderrorcodesprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterprivateloaderrorcodesprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequestOneGroup.process {: #tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestonegroupprocess }

![tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestonegroupprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestonegroupprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequestOneServer.process {: #tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestoneserverprocess }

![tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestoneserverprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestoneserverprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Private/SendRequest.process {: #tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestprocess }

![tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterprivatesendrequestprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Public/LoadAllDiameterErrorCodes.process {: #tilhssdiameteradapterconnectivityservicesdiameterpublicloadalldiametererrorcodesprocess }

![tilhssdiameteradapterconnectivityservicesdiameterpublicloadalldiametererrorcodesprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterpublicloadalldiametererrorcodesprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/Diameter/Public/ReloadAllDiameterErrorCodes.process {: #tilhssdiameteradapterconnectivityservicesdiameterpublicreloadalldiametererrorcodesprocess }

![tilhssdiameteradapterconnectivityservicesdiameterpublicreloadalldiametererrorcodesprocess process flow](tilhssdiameteradapterconnectivityservicesdiameterpublicreloadalldiametererrorcodesprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/InitializeConnection.process {: #tilhssdiameteradapterconnectivityserviceshsspublicinitializeconnectionprocess }

![tilhssdiameteradapterconnectivityserviceshsspublicinitializeconnectionprocess process flow](tilhssdiameteradapterconnectivityserviceshsspublicinitializeconnectionprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/NormalizeCTN.process {: #tilhssdiameteradapterconnectivityserviceshsspublicnormalizectnprocess }

![tilhssdiameteradapterconnectivityserviceshsspublicnormalizectnprocess process flow](tilhssdiameteradapterconnectivityserviceshsspublicnormalizectnprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/UserDataRequest.2.process {: #tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequest2process }

![tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequest2process process flow](tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequest2process.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/ConnectivityServices/HSS/Public/UserDataRequest.process {: #tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequestprocess }

![tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequestprocess process flow](tilhssdiameteradapterconnectivityserviceshsspublicuserdatarequestprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/CVV2Filter.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringcvv2filterprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringcvv2filterprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringcvv2filterprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/ExceptionSchemaFilter.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringexceptionschemafilterprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringexceptionschemafilterprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringexceptionschemafilterprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/Security/CVV2Filter.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsecuritycvv2filterprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsecuritycvv2filterprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsecuritycvv2filterprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/ServiceExceptionFilter.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringserviceexceptionfilterprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringserviceexceptionfilterprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringserviceexceptionfilterprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SpecialExceptions/GetSpecialExceptionList.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionsgetspecialexceptionlistprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionsgetspecialexceptionlistprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionsgetspecialexceptionlistprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SpecialExceptions/TraceSpecialException.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionstracespecialexceptionprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionstracespecialexceptionprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringspecialexceptionstracespecialexceptionprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Filtering/SystemExceptionFilter.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsystemexceptionfilterprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsystemexceptionfilterprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingfilteringsystemexceptionfilterprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Interface/ServiceExceptionHandler.process {: #tilhssdiameteradapterutilityservicesexceptionhandlinginterfaceserviceexceptionhandlerprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlinginterfaceserviceexceptionhandlerprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlinginterfaceserviceexceptionhandlerprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Interface/SystemExceptionHandler.process {: #tilhssdiameteradapterutilityservicesexceptionhandlinginterfacesystemexceptionhandlerprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlinginterfacesystemexceptionhandlerprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlinginterfacesystemexceptionhandlerprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Private/MapException.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingprivatemapexceptionprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingprivatemapexceptionprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingprivatemapexceptionprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Public/MapAnyException.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingpublicmapanyexceptionprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingpublicmapanyexceptionprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingpublicmapanyexceptionprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/ServiceExceptionHandler.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingserviceexceptionhandlerprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingserviceexceptionhandlerprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingserviceexceptionhandlerprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/ExceptionHandling/Shutdown BWEngine.process {: #tilhssdiameteradapterutilityservicesexceptionhandlingshutdownbwengineprocess }

![tilhssdiameteradapterutilityservicesexceptionhandlingshutdownbwengineprocess process flow](tilhssdiameteradapterutilityservicesexceptionhandlingshutdownbwengineprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Interface/OperationReply.process {: #tilhssdiameteradapterutilityservicesinterfaceoperationreplyprocess }

![tilhssdiameteradapterutilityservicesinterfaceoperationreplyprocess process flow](tilhssdiameteradapterutilityservicesinterfaceoperationreplyprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Interface/Private/PublishToRetryQueue.process {: #tilhssdiameteradapterutilityservicesinterfaceprivatepublishtoretryqueueprocess }

![tilhssdiameteradapterutilityservicesinterfaceprivatepublishtoretryqueueprocess process flow](tilhssdiameteradapterutilityservicesinterfaceprivatepublishtoretryqueueprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogEnd.process {: #tilhssdiameteradapterutilityserviceslogginglogendprocess }

![tilhssdiameteradapterutilityserviceslogginglogendprocess process flow](tilhssdiameteradapterutilityserviceslogginglogendprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogError.process {: #tilhssdiameteradapterutilityserviceslogginglogerrorprocess }

![tilhssdiameteradapterutilityserviceslogginglogerrorprocess process flow](tilhssdiameteradapterutilityserviceslogginglogerrorprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogFatal.process {: #tilhssdiameteradapterutilityserviceslogginglogfatalprocess }

![tilhssdiameteradapterutilityserviceslogginglogfatalprocess process flow](tilhssdiameteradapterutilityserviceslogginglogfatalprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/LogStart.process {: #tilhssdiameteradapterutilityserviceslogginglogstartprocess }

![tilhssdiameteradapterutilityserviceslogginglogstartprocess process flow](tilhssdiameteradapterutilityserviceslogginglogstartprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/Private/WriteToLog.process {: #tilhssdiameteradapterutilityservicesloggingprivatewritetologprocess }

![tilhssdiameteradapterutilityservicesloggingprivatewritetologprocess process flow](tilhssdiameteradapterutilityservicesloggingprivatewritetologprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/CSAuditEnd.process {: #tilhssdiameteradapterutilityservicesloggingpubliccsauditendprocess }

![tilhssdiameteradapterutilityservicesloggingpubliccsauditendprocess process flow](tilhssdiameteradapterutilityservicesloggingpubliccsauditendprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/CSAuditStart.process {: #tilhssdiameteradapterutilityservicesloggingpubliccsauditstartprocess }

![tilhssdiameteradapterutilityservicesloggingpubliccsauditstartprocess process flow](tilhssdiameteradapterutilityservicesloggingpubliccsauditstartprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/Logging/Public/WriteToLog.process {: #tilhssdiameteradapterutilityservicesloggingpublicwritetologprocess }

![tilhssdiameteradapterutilityservicesloggingpublicwritetologprocess process flow](tilhssdiameteradapterutilityservicesloggingpublicwritetologprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/AuditEvent.process {: #tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureauditeventprocess }

![tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureauditeventprocess process flow](tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureauditeventprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/EmptyAuditCache.process {: #tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureemptyauditcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureemptyauditcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureemptyauditcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/RemoveFromAuditCache.process {: #tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureremovefromauditcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureremovefromauditcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureremovefromauditcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/AuditEventCapture/UpdateAuditCache.process {: #tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureupdateauditcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureupdateauditcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientauditeventcaptureupdateauditcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/CustomServiceExceptionHandlerInterface.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncapturecustomserviceexceptionhandlerinterfaceprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncapturecustomserviceexceptionhandlerinterfaceprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncapturecustomserviceexceptionhandlerinterfaceprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/EmptyAuditErrorCache.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureemptyauditerrorcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureemptyauditerrorcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureemptyauditerrorcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/RemoveFromAuditErrorCache.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureremovefromauditerrorcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureremovefromauditerrorcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureremovefromauditerrorcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/ServiceExceptionClient.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureserviceexceptionclientprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureserviceexceptionclientprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureserviceexceptionclientprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/SystemExceptionClient.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncapturesystemexceptionclientprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncapturesystemexceptionclientprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncapturesystemexceptionclientprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/ExceptionCapture/UpdateAuditErrorCache.process {: #tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureupdateauditerrorcacheprocess }

![tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureupdateauditerrorcacheprocess process flow](tilhssdiameteradapterutilityservicesvfleclientexceptioncaptureupdateauditerrorcacheprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/Public/ShutdownCleanUp.process {: #tilhssdiameteradapterutilityservicesvfleclientpublicshutdowncleanupprocess }

![tilhssdiameteradapterutilityservicesvfleclientpublicshutdowncleanupprocess process flow](tilhssdiameteradapterutilityservicesvfleclientpublicshutdowncleanupprocess.svg)

[↑ Back to Inventory](#process-inventory)

#### Process: TIL_HSS_DiameterAdapter/UtilityServices/VFLE/Client/Public/StartupInitialisation.process {: #tilhssdiameteradapterutilityservicesvfleclientpublicstartupinitialisationprocess }

![tilhssdiameteradapterutilityservicesvfleclientpublicstartupinitialisationprocess process flow](tilhssdiameteradapterutilityservicesvfleclientpublicstartupinitialisationprocess.svg)

[↑ Back to Inventory](#process-inventory)


## Global Variables
| Name | Value | Status |
| :--- | :--- | :--- |
| BW_GLOBAL_TRUSTED_CA_STORE | `file:////opt/tibco/vodafo&#x200B;ne/certificates` | ✅ OK |
| DirLedger | `.` | ✅ OK |
| DirTrace | `.` | ✅ OK |
| Env/AuditEvents/ConnectivityService/MIG_EnableAuditToDB | `true` | ✅ OK |
| Env/AuditEvents/ConnectivityService/MIG_EnableHeaderAudit | `false` | ✅ OK |
| Env/AuditEvents/ConnectivityService/MIG_EnableMessageAudit | `false` | ✅ OK |
| Env/AuditEvents/FrameworkService/MIG_EnableAuditToDB | `true` | ✅ OK |
| Env/AuditEvents/FrameworkService/MIG_EnableHeaderAudit | `true` | ✅ OK |
| Env/AuditEvents/FrameworkService/MIG_EnableMessageAudit | `true` | ✅ OK |
| Env/AuditEvents/GLB_CachePublishIntervalInMS | `10000` | ✅ OK |
| Env/AuditEvents/GLB_MaxMessages | `2000` | ✅ OK |
| Env/Certificates/BW/SOAP/MIG_Filename | `BW` | ✅ OK |
| Env/Certificates/ClientA/SOAP/MIG_Filename | `ClientA` | ✅ OK |
| Env/Certificates/ClientB/SOAP/MIG_Filename | `ClientB` | ✅ OK |
| Env/Diameter/ErrorCodes/GLB_KeyRefreshIntervalDays | `86400000...` | ✅ OK |
| Env/Diameter/ErrorCodes/GLB_KeyRefreshStartTime | `2009 AUG 31 06:32:00 GMT...` | ✅ OK |
| Env/Encryption/Blowfish/MIG_CustomPadding | `0808080808080808` | ✅ OK |
| Env/Encryption/Blowfish/MIG_EncoderType | `Blowfish/ECB/NoPadding` | ✅ OK |
| Env/Encryption/Blowfish/MIG_Key | `#!haN36YV2dQOdbpWDFgGYm8TI+kir...` | ✅ OK |
| Env/Encryption/DES3/MIG_Init_Vector | `#!Jd+NYpHk0EcIwLb8g6XZath&#x200B;JsgPRvzAz/fECwiUqM0dASsJz&#x200B;/kgrtzqIGnj5h3hA` | ✅ OK |
| Env/Encryption/DES3/MIG_Key | `#!5KTXUNntqrkfJQMaoVTGTX6vs/98...` | ✅ OK |
| Env/Encryption/GLB_Debug | `false` | ✅ OK |
| Env/Encryption/GLB_KeyRefreshIntervalDays | `1...` | ✅ OK |
| Env/Encryption/GLB_KeyRefreshStartTime | `2009 AUG 31 06:31:00 GMT...` | ✅ OK |
| Env/Encryption/GLB_UseDatabase | `true` | ✅ OK |
| Env/Encryption/MIG_Roles | `TIL,ETU,RETAIL_DB` | ✅ OK |
| Env/Encryption/RSA/Keys/Composite/MIG_Modulus | `#!N8SvfQRT4m5Bcyy1rE/rl/2/Pbtp...` | ✅ OK |
| Env/Encryption/RSA/Keys/Composite/MIG_PrivateExponent | `#!dNsohNBtbJY1rC+onmfjBQ2WWCF2...` | ✅ OK |
| Env/Encryption/RSA/Keys/Composite/MIG_PublicExponent | `#!/AVURcCMzKyAMMYNkC56jyiMKNC+...` | ✅ OK |
| Env/Encryption/RSA/Keys/Default/MIG_Private | `#!6SAdM/5vbUmaK5qxYyLGesiuUP4P...` | ✅ OK |
| Env/Encryption/RSA/Keys/Default/MIG_Public | `#!BcOoW7BQUKfFhl1f/NGk4E/Xg/ed...` | ✅ OK |
| Env/Encryption/RSA/Keys/PEM/MIG_Private | `#!3pNOBDu+lioqJwTdCsv+YYBTGIhA...` | ✅ OK |
| Env/Encryption/RSA/Keys/PEM/MIG_Public | `#!zeeoV2gCdK4LMboUedhqqPVMBUaY...` | ✅ OK |
| Env/Encryption/RSA/MIG_EncoderType | `RSA/ECB/PKCS1Padding` | ✅ OK |
| Env/Encryption/RSA/MIG_Modulus_Bits | `1024...` | ✅ OK |
| Env/Exceptions/Categories/GLB_Business | `BUSINESS` | ✅ OK |
| Env/Exceptions/Handling/MIG_ServerEnabled | `true` | ✅ OK |
| Env/Exceptions/MIG_CanShutdown | `true` | ✅ OK |
| Env/Exceptions/MIG_ExtendedResultStatus | `true` | ✅ OK |
| Env/Exceptions/Notification/MIG_ServiceOperationList | `Service:Operation` | ✅ OK |
| Env/Exceptions/SpecialExceptions/GLB_Filename | `/opt/tibco/vodafone/Speci&#x200B;alExceptions.xml` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_Authenticate_ApplicationID | `16777217` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_Disconnect_Reason_Code | `0` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_Host | `uk-ph-tstil-bw01` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_Realm | `ims.mnc015.mcc234.3gppnet&#x200B;work.org` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_VendorID | `10415` | ✅ OK |
| Env/HSS/Diameter/Client/MIG_VendorName | `HSS` | ✅ OK |
| Env/HSS/Diameter/ConnectionPlan/MIG_LoopCount | `1` | ✅ OK |
| Env/HSS/Diameter/ConnectionPlan/MIG_LoopDelayMS | `1000` | ✅ OK |
| Env/HSS/Diameter/ConnectionPlan/MIG_SecondaryServerDelayMS | `100` | ✅ OK |
| Env/HSS/Diameter/ConnectionPlan/MIG_ServerDelayMS | `100` | ✅ OK |
| Env/HSS/Diameter/Destination/MIG_Host | `|VODAFONE,hss1.ims.mnc015&#x200B;.mcc234.3gppnetwork.org|V&#x200B;IRGINMEDIA,HSS01tb.epc.mn&#x200B;c038.mcc234.3gppnetwork.o&#x200B;rg|` | ✅ OK |
| Env/HSS/Diameter/Destination/MIG_Realm | `|VODAFONE,ims.mnc015.mcc2&#x200B;34.3gppnetwork.org|VIRGIN&#x200B;MEDIA,epc.mnc038.mcc234.3&#x200B;gppnetwork.org|` | ✅ OK |
| Env/HSS/Diameter/ErrorHandling/CommunicationException/GLB_ExceptionNames | `java.net.SocketException,&#x200B;java.net.ConnectException&#x200B;` | ✅ OK |
| Env/HSS/Diameter/ErrorHandling/ConnectionException/GLB_ExceptionNames | `com.vf.til.connection.Con&#x200B;nectionException` | ✅ OK |
| Env/HSS/Diameter/ErrorHandling/GLB_TrySecondaryErrorCodes | `413,457,412` | ✅ OK |
| Env/HSS/Diameter/ErrorHandling/LoginTimeout/GLB_ExceptionNames | `com.vf.til.connection.Con&#x200B;nectionTimeoutException` | ✅ OK |
| Env/HSS/Diameter/GLB_CSName | `HSS` | ✅ OK |
| Env/HSS/Diameter/GLB_Debug | `false` | ✅ OK |
| Env/HSS/Diameter/GLB_IgnoreInitializationError | `true` | ✅ OK |
| Env/HSS/Diameter/GLB_LogPrefix | `../../tra/domain/` | ✅ OK |
| Env/HSS/Diameter/GLB_LogSuffix | `/application/logs/HSS/` | ✅ OK |
| Env/HSS/Diameter/GLB_MoreErrorCodes | `` | ✅ OK |
| Env/HSS/Diameter/GLB_SuccessErrorCodes | `2001` | ✅ OK |
| Env/HSS/Diameter/MIG_LoginTimeoutMS | `10000` | ✅ OK |
| Env/HSS/Diameter/MIG_MaxConnections | `8` | ✅ OK |
| Env/HSS/Diameter/MIG_TimeoutMS | `30000` | ✅ OK |
| Env/HSS/Diameter/MIG_URL | `aaa://localhost:3872,aaa:&#x200B;//localhost:3872` | ✅ OK |
| Env/HSS/Diameter/UDR/GLB_3GPPVendorId | `10415` | ✅ OK |
| Env/HSS/Diameter/UDR/GLB_ApplicationId | `16777217` | ✅ OK |
| Env/HSS/Diameter/UDR/GLB_OrginHost | `uk-ph-tstil-bw01.ims.mnc0&#x200B;15.mcc234.3gppnetwork.org&#x200B;` | ✅ OK |
| Env/HSS/Diameter/UDR/GLB_VendorName | `HSS` | ✅ OK |
| Env/HTTP/SOAP/MIG_Host | `localhost` | ✅ OK |
| Env/HTTP/SOAP/MIG_Port | `8888` | ✅ OK |
| Env/HTTP/XML/MIG_DefaultEncoding | `ISO8859_1` | ✅ OK |
| Env/HTTP/XML/MIG_Host | `localhost` | ✅ OK |
| Env/HTTP/XML/MIG_Port | `8082` | ✅ OK |
| Env/Identities/BW/MIG_SourceNames | `TIL,BW` | ✅ OK |
| Env/Identities/BW/SOAP/MIG_FileType | `JKS` | ✅ OK |
| Env/Identities/BW/SOAP/MIG_Password | `#!WyysfGvEYl9YXjAcxmvCu3j&#x200B;DViyz0tktdDTOpSQBFZc=` | ✅ OK |
| Env/Identities/BW/SOAP/MIG_URL | `c:/cvsdir/TIL_SOURCE/thir&#x200B;d_party/SOAP/BW.jks` | ✅ OK |
| Env/Identities/ClientA/MIG_SourceNames | `ClientA` | ✅ OK |
| Env/Identities/ClientB/MIG_SourceNames | `ClientB` | ✅ OK |
| Env/JMS/AuditEvents/GLB_JMS_AuditEventsTopic | `AuditEvents` | ✅ OK |
| Env/JMS/Connections/ADBAdapter/GLB_QueueConnectionFactory | `MAPTILQueueConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/ADBAdapter/GLB_TopicConnectionFactory | `MAPTILTopicConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/ADBAdapter/MIG_JMSURL | `tcp://hscot07:8222,tcp://&#x200B;hscot07:8222` | ✅ OK |
| Env/JMS/Connections/ADBAdapter/MIG_Password | `#!/6wOgz2p586+3bvLN8Ud99V&#x200B;rXODUh1oh` | ✅ OK |
| Env/JMS/Connections/ADBAdapter/MIG_Username | `tiladb` | ✅ OK |
| Env/JMS/Connections/Audit/GLB_QueueConnectionFactory | `MAPTILQueueConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/Audit/GLB_TopicConnectionFactory | `MAPTILTopicConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/Audit/MIG_JMSURL | `tcp://tibtest5:8222,tcp:/&#x200B;/tibtest5:8222` | ✅ OK |
| Env/JMS/Connections/Audit/MIG_Password | `#!HbZcwADv+7V0RAvVXf/o6K1&#x200B;0Yohyxc03` | ✅ OK |
| Env/JMS/Connections/Audit/MIG_Username | `tilbw` | ✅ OK |
| Env/JMS/Connections/BW/GLB_QueueConnectionFactory | `MAPTILQueueConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/BW/GLB_TopicConnectionFactory | `MAPTILTopicConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/BW/MIG_JMSURL | `tcp://localhost:7222` | ✅ OK |
| Env/JMS/Connections/BW/MIG_Password | `#!vXwz9GthN01GlByDSwuIBRs&#x200B;dkmf5k1IE` | ✅ OK |
| Env/JMS/Connections/BW/MIG_Username | `tilbw` | ✅ OK |
| Env/JMS/Connections/ForwardJMSMessage/GLB_QueueConnectionFactory | `MAPTILQueueConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/ForwardJMSMessage/GLB_TopicConnectionFactory | `MAPTILTopicConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/ForwardJMSMessage/MIG_JMSURL | `tcp://auktltar.dc-dublin.&#x200B;de:7222,tcp://auktltar.dc&#x200B;-dublin.de:7222` | ✅ OK |
| Env/JMS/Connections/ForwardJMSMessage/MIG_Password | `#!/dnP3ncRwVUaSkb2giEF2/z&#x200B;V4JJTcsIQ` | ✅ OK |
| Env/JMS/Connections/ForwardJMSMessage/MIG_Username | `tilbw` | ✅ OK |
| Env/JMS/Connections/TeradataAdapter/GLB_QueueConnectionFactory | `MAPTILQueueConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/TeradataAdapter/GLB_TopicConnectionFactory | `MAPTILTopicConnectionFact&#x200B;ory` | ✅ OK |
| Env/JMS/Connections/TeradataAdapter/MIG_JMSURL | `tcp://hscot07:8222,tcp://&#x200B;hscot07:8222` | ✅ OK |
| Env/JMS/Connections/TeradataAdapter/MIG_Password | `#!0SLqzqbixCqnBRFFC+nzziA&#x200B;Wlxbut911MdCuuv65I/w=` | ✅ OK |
| Env/JMS/Connections/TeradataAdapter/MIG_Username | `tiladtera` | ✅ OK |
| Env/JMS/ErrorHandling/GLB_JMS_ExceptionNotifyTopic | `Exception.NOTIFY` | ✅ OK |
| Env/JMS/ErrorHandling/GLB_JMS_InvalidMessageQueue | `InvalidMessage` | ✅ OK |
| Env/JMS/ErrorHandling/GLB_JMS_ServiceExceptionQueue | `ServiceException` | ✅ OK |
| Env/JMS/ErrorHandling/JMS_TIBCO_COMPRESS | `false` | ✅ OK |
| Env/JMS/ErrorHandling/JMS_TIBCO_PRESERVE_UNDELIVERED | `false` | ✅ OK |
| Env/JMS/ErrorHandling/MIG_EnableExceptionQueues | `true` | ✅ OK |
| Env/JMS/ErrorHandling/MIG_Expiration | `0` | ✅ OK |
| Env/JMS/Invocation/GLB_MaxValidationLoops | `300` | ✅ OK |
| Env/JMS/Invocation/MIG_FailureLogLevel | `WARN` | ✅ OK |
| Env/JMS/Invocation/MIG_SuccessLogLevel | `INFO` | ✅ OK |
| Env/JMS/Invocation/MIG_Timeout | `30` | ✅ OK |
| Env/JMS/JNDI/MIG_Password | `#!UKCK6WA7J0ANEw19817uFNz&#x200B;YL+oVk6NR` | ✅ OK |
| Env/JMS/JNDI/MIG_URL | `tibjmsnaming://localhost:&#x200B;7222` | ✅ OK |
| Env/JMS/JNDI/MIG_Username | `tilbw` | ✅ OK |
| Env/JMS/JSON/GLB_JMSPropertiesCheckEnabled | `true` | ✅ OK |
| Env/JMS/JSON/GLB_JMSSenderCheckEnabled | `true` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix | `VOD.UK.DEV` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix_IF | `VOD.UK.DEV.TILIF` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix_Internal | `VOD.UK.DEV.TILINTERNAL` | ✅ OK |
| Env/JMS/MIG_ReplyToQueueByDefault | `true` | ✅ OK |
| Env/JMS/Properties/Publish/JMS_TIBCO_PRESERVE_UNDELIVERED | `true` | ✅ OK |
| Env/JMS/Properties/Publish/MIG_DeliveryMode | `PERSISTENT` | ✅ OK |
| Env/JMS/Properties/Publish/MIG_Expiration | `0` | ✅ OK |
| Env/JMS/SOAP/GLB_JMSPropertiesCheckEnabled | `true` | ✅ OK |
| Env/JMS/SOAP/GLB_JMSSenderCheckEnabled | `true` | ✅ OK |
| Env/JMS/SOAP/Headers/Header/GLB_CheckEnabled | `true` | ✅ OK |
| Env/JMS/SOAP/Headers/Header/MIG_DisabledOperations | `` | ✅ OK |
| Env/JMS/VFLE/GLB_DisableFilters | `false` | ✅ OK |
| Env/JMS/VFLE/GLB_JMS_Service_Element | `3` | ✅ OK |
| Env/JMS/VFLE/MIG_JMS_MessageCaptureTopicSpec | `MSGCPTR.DB` | ✅ OK |
| Env/LogRoles/MIG_EnableDebug | `false` | ✅ OK |
| Env/LogRoles/MIG_EnableErrorDebug | `false` | ✅ OK |
| Env/LogRoles/MIG_EnableInfo | `false` | ✅ OK |
| Env/LogRoles/MIG_TraceHTTPRequests | `true` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_JDBCDriver | `tibcosoftwareinc.jdbc.ora&#x200B;cle.OracleDriver` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_JDBCURL | `jdbc:tibcosoftwareinc:ora&#x200B;cle://hscot08:1528;SID=ED&#x200B;X4TST` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_LoginTimeout | `30` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_MaxConnections | `8` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_Password | `#!oMqc83zMxz+CXZ1uT+Jfk6N&#x200B;emUS5gtSUmVxk6oz1JpU=` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_Schema | `DEVBWCPT` | ✅ OK |
| Env/RDBMS/BusinessWorks/MIG_User | `DEVBWCPT` | ✅ OK |
| Env/RDBMS/Encryption/MIG_JDBCDriver | `tibcosoftwareinc.jdbc.ora&#x200B;cle.OracleDriver` | ✅ OK |
| Env/RDBMS/Encryption/MIG_JDBCURL | `jdbc:tibcosoftwareinc:ora&#x200B;cle://aukshocr.dc-dublin.&#x200B;de:33000;SID=TIBTST1` | ✅ OK |
| Env/RDBMS/Encryption/MIG_LoginTimeout | `30` | ✅ OK |
| Env/RDBMS/Encryption/MIG_MaxConnections | `8` | ✅ OK |
| Env/RDBMS/Encryption/MIG_MaxRows | `0` | ✅ OK |
| Env/RDBMS/Encryption/MIG_Password | `#!yd6oR3nORIsZtBZHdJ2q3XA&#x200B;xkXKIF8lfAWODwY5Lb24=` | ✅ OK |
| Env/RDBMS/Encryption/MIG_Schema | `c4keys_usr_db01` | ✅ OK |
| Env/RDBMS/Encryption/MIG_Timeout | `30` | ✅ OK |
| Env/RDBMS/Encryption/MIG_User | `c4keys_usr_db01` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_JDBCDriver | `tibcosoftwareinc.jdbc.ora&#x200B;cle.OracleDriver` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_JDBCURL | `jdbc:tibcosoftwareinc:ora&#x200B;cle://aukshocr.dc-dublin.&#x200B;de:33000;SID=TIBTST1` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_LoginTimeout | `30` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_MaxConnections | `8` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_MaxRows | `0` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_Password | `#!26DyWjgOeLORV8tFAGeDf/h&#x200B;buGWJrEqUT4WaN9ZbtyfOvMfQ&#x200B;cTt67A==` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_Timeout | `30` | ✅ OK |
| Env/RDBMS/ReferenceData/MIG_User | `MAP_OWN_DB01` | ✅ OK |
| Env/RDBMS/ReferenceData/Ping/MIG_RepeatMS | `30000` | ✅ OK |
| Env/RDBMS/VFLE/GLB_MaxRows | `100` | ✅ OK |
| Env/RDBMS/VFLE/MIG_JDBCDriver | `tibcosoftwareinc.jdbc.ora&#x200B;cle.OracleDriver` | ✅ OK |
| Env/RDBMS/VFLE/MIG_JDBCURL | `jdbc:tibcosoftwareinc:ora&#x200B;cle://hscot08:1528;SID=ED&#x200B;X4TST` | ✅ OK |
| Env/RDBMS/VFLE/MIG_LoginTimeout | `30` | ✅ OK |
| Env/RDBMS/VFLE/MIG_MaxConnections | `8` | ✅ OK |
| Env/RDBMS/VFLE/MIG_Password | `#!L53bHUYnI7K96lRWsWPLL6z&#x200B;7ukrPR/xs0IZcpTb3W74=` | ✅ OK |
| Env/RDBMS/VFLE/MIG_Retries | `2` | ✅ OK |
| Env/RDBMS/VFLE/MIG_RetrySleepInMs | `1000` | ✅ OK |
| Env/RDBMS/VFLE/MIG_User | `VFLE_DEV` | ✅ OK |
| Env/ReferenceData/MIG_ARP_DSPAgreementRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_ARP_DSPAgreementRefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_AccountCategoryRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_AccountTypesRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_ActivityReasonsRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_BANTrialRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_BundleAndProductIDsRefreshIntervalDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_BundleAndProductIDsRefreshStartTime | `2012 APRIL 26 06:31:00 GM&#x200B;T` | ✅ OK |
| Env/ReferenceData/MIG_CaseTextRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_ChannelRefreshIntervalDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_ChannelRefreshStartTime | `2012 APRIL 26 06:31:00 GM&#x200B;T` | ✅ OK |
| Env/ReferenceData/MIG_ContentPackRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_CountryVatCodeRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_DefaultRefreshDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_DestinationCodesRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_ExtrasPackValueRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_IMSI_SPIDsRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_IMSI_SPIDsRefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_NetworkNameRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_PBIDSPIDMapping_RefreshIntervalDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_PBIDSPIDMapping_RefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_Partner_SMS_TextsRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_Partner_SMS_TextsRefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_PublicHolidays_RefreshIntervalDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_PublicHolidays_RefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_ServiceProviderAuthRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_TIL_ARP_InformationRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_TIL_ARP_InformationRefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_TIL_IdTransformPrefixRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_TIL_IdTransformPrefixRefreshStartTime | `2015 MAY 12 06:00:00 GMT` | ✅ OK |
| Env/ReferenceData/MIG_TIL_Partner_InformationRefreshIntervalDays | `1` | ✅ OK |
| Env/ReferenceData/MIG_TIL_Partner_InformationRefreshStartTime | `2014 JANUARY 28 06:00:00 &#x200B;GMT` | ✅ OK |
| Env/ReferenceData/MIG_TariffRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_TariffType_International | `INTL` | ✅ OK |
| Env/ReferenceData/MIG_TeamIDRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_TeamIDTrialRefreshDays | `7` | ✅ OK |
| Env/ReferenceData/MIG_Transform_Identifier_serviceRefreshIntervalDays | `86400000` | ✅ OK |
| Env/ReferenceData/MIG_Transform_Identifier_serviceRefreshStartTime | `2015 MAY 12 06:00:00 GMT` | ✅ OK |
| Env/ReferenceData/MIG_VatCodeRefreshDays | `7` | ✅ OK |
| Env/Security/Obfuscation/MIG_ElementNames | `CVV2,Csc,CVV,CSC,CreateSe&#x200B;rviceRequest:Description,&#x200B;SecurityCode,SubmiteShopO&#x200B;rder:value,` | ✅ OK |
| Env/Security/Tokens/AllCodes/GLB_KeyRefreshIntervalDays | `1...` | ✅ OK |
| Env/Security/Tokens/AllCodes/GLB_KeyRefreshStartTime | `2009 AUG 31 06:31:00 GMT...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_CustomerPartyExpirationDuration | `1...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_CustomerPartyExpirationUnits | `hr...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_CustomerPartyTokenType | `CustomerParty...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_ExpirationDuration | `30...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_ExpirationUnits | `days...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_IntegrationPartnerName | `Vodafone...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_RequestType | `http://docs.oasis-open.org/ws-...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_TokenType | `Organisation...` | ✅ OK |
| Env/Security/Tokens/Defaults/GLB_Version | `2.0...` | ✅ OK |
| Env/Security/Tokens/Expiration/GLB_CheckEnabled | `true...` | ✅ OK |
| Env/Security/Tokens/GLB_CheckEnabled | `true...` | ✅ OK |
| Env/Security/Tokens/Signature/GLB_CacheID | `til.tokens...` | ✅ OK |
| Env/Security/Tokens/Signature/MIG_Keystore | `/opt/tibco/vodafone/certificat...` | ✅ OK |
| Env/Security/Tokens/Signature/MIG_KeystorePassword | `...` | ✅ OK |
| Env/Security/Tokens/Signature/MIG_PrivateKeyAlias | `bw...` | ✅ OK |
| Env/Security/Tokens/Signature/MIG_PublicKeyAlias | `bw...` | ✅ OK |
| Env/Security/Tokens/Signature/MIG_UsePartnerIdentity | `false...` | ✅ OK |
| Env/Security/Tokens/Validation/GLB_CheckEnabled | `true...` | ✅ OK |
| Env/Security/Tokens/Validation/GLB_RevokedVersions | `...` | ✅ OK |
| Env/Security/Tokens/Validation/MIG_Timeout | `30...` | ✅ OK |
| Env/TCP/MIG_Host | `localhost` | ✅ OK |
| Env/TCP/MIG_Port | `8110` | ✅ OK |
| Env/TCP/MIG_Timeout | `10` | ✅ OK |
| GLB_TILVersion | `TIL-Build24` | ✅ OK |
| HawkEnabled | `false` | ✅ OK |
| JmsProviderUrl | `tcp://localhost:7222` | ✅ OK |
| JmsSslProviderUrl | `ssl://localhost:7243` | ✅ OK |
| Processes/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/GLB_AuthSessionState | `1` | ✅ OK |
| Processes/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/GLB_CurrentLocation | `1` | ✅ OK |
| Processes/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/GLB_DataReference | `14,15` | ✅ OK |
| Processes/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/GLB_RequestedDomain | `0,1` | ✅ OK |
| Processes/CustomerManagement/CustomerProfileManagement/CustomerIdentityManagement/RetrieveHSSLocationDetails/GLB_RequestedNodes | `1,2,8` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/CRM6/Operation-NoReply/CRM6/MIG_MaxRetries | `3` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/CRM6/Operation-NoReply/CRM6/MIG_RetryDelayMS | `100` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/CRM6/Operation/CRM6/MIG_MaxRetries | `3` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/CRM6/Operation/CRM6/MIG_RetryDelayMS | `100` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/GMS/Sync/GMS/MIG_Timeout | `30` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Gemini/Read-Version3/MIG_Timeout | `300` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Gemini/Write-NoReply/MIG_Timeout | `300` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Gemini/Write-Version2/MIG_Timeout | `300` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-File/TriggerSystem/BatchFile/MIG_ErrorFolder | `c:/temp/Operation-File/er&#x200B;ror` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-File/TriggerSystem/BatchFile/MIG_Filename | `c:/temp/Operation-File/*.&#x200B;csv` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-File/TriggerSystem/BatchFile/MIG_PollingInterval | `30` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-File/TriggerSystem/BatchFile/MIG_SuccessFolder | `c:/temp/Operation-File/su&#x200B;ccess` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-File/TriggerSystem/BatchFile/MIG_WarningFolder | `c:/temp/Operation-File/wa&#x200B;rning` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTP/HTTPXML/MIG_Host | `localhost` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTP/HTTPXML/MIG_Port | `8081` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTP/TriggerSystem/HTTPServer/MIG_Host | `localhost` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTP/TriggerSystem/HTTPServer/MIG_Port | `9999` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTPSOAP/HTTPSOAP/MIG_Host | `localhost` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-HTTPSOAP/HTTPSOAP/MIG_Port | `8081` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-NoReply/Scheduled/JMSRequest/MIG_RepeatMS | `60000` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-NoReply/Scheduled/JMSRequest/MIG_Schedules | `08:00-18:00` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-TIMER/TIMER/MIG_RepeatMS | `0` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-TIMER/TIMER/MIG_StartUnixTime | `0` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_BatchSize | `10` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_ErrorCodes | `` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_MaxRetries | `10` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_NoReply | `true` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_RepeatMS | `60000` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_RetryDelayMS | `3600000` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Retry/JMSRequest/MIG_Timeout | `10` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Scheduled/JMSRequest/MIG_RepeatMS | `60000` | ✅ OK |
| Processes/GITA1/GITA2/GITA3/Operation-Update/Scheduled/JMSRequest/MIG_Schedules | `08:00-18:00` | ✅ OK |
| Processes/MIG_Timeout | `300` | ✅ OK |
| Processes/Retry/JMSRequest/MIG_ErrorCodes | `400-499` | ✅ OK |
| RemoteRvDaemon | `` | ✅ OK |
| RvDaemon | `tcp:7500` | ✅ OK |
| RvNetwork | `` | ✅ OK |
| RvService | `7500` | ✅ OK |
| RvaHost | `localhost` | ✅ OK |
| RvaPort | `7600` | ✅ OK |
| TIBHawkDaemon | `tcp:7474` | ✅ OK |
| TIBHawkNetwork | `` | ✅ OK |
| TIBHawkService | `7474` | ✅ OK |
| Testing/MIG_DefaultSleepMS | `0` | ✅ OK |
| Testing/StubModeFlag | `Sub` | ✅ OK |
| Testing/StubXMLRoot | `c:\cvsdir\TIL\BusinessSer&#x200B;vices\` | ✅ OK |
| Trace.Task.* | `false` | ✅ OK |
| EnableMemorySavingMode | `false` | ✅ OK |
| bw.engine.enableJobRecovery | `false` | ✅ OK |
| bw.engine.autoCheckpointRestart | `true` | ✅ OK |
| bw.engine.jobstats.enable | `false` | ✅ OK |
| log.file.encoding | `` | ✅ OK |
| bw.engine.emaEnabled | `false` | ✅ OK |
| bw.container.service | `` | ✅ OK |
| bw.container.service.rmi.port | `9995` | ✅ OK |
| bw.platform.services.retreiveresources.Enabled | `false` | ✅ OK |
| bw.platform.services.retreiveresources.Hostname | `localhost` | ✅ OK |
| bw.platform.services.retreiveresources.Httpport | `8010` | ✅ OK |
| bw.platform.services.retreiveresources.defaultEncoding | `ISO8859_1` | ✅ OK |
| bw.platform.services.retreiveresources.enableLookups | `false` | ✅ OK |
| bw.platform.services.retreiveresources.isSecure | `false` | ✅ OK |
| bw.platform.services.retreiveresources.identity | `/Identity_HTTPConnection.&#x200B;id` | ✅ OK |
| bw.log4j.configuration | `` | ✅ OK |
