# SMSAdapter-26_1_1 Architecture

## Process Inventory

## Visual Flow Diagrams


## Global Variables
| Name | Value | Status |
| :--- | :--- | :--- |
| DirLedger | `.` | ✅ OK |
| DirTrace | `.` | ✅ OK |
| Env/Adapter/SMS/GLB_EnquireFailCount | `10` | ✅ OK |
| Env/Adapter/SMS/GLB_EnquireInterval | `180` | ✅ OK |
| Env/Adapter/SMS/GLB_FileCount | `10` | ✅ OK |
| Env/Adapter/SMS/GLB_SendSMSFailCount | `3` | ✅ OK |
| Env/Adapter/SMS/GLB_SendSMSPubQueue | `.Response.SMSAdapter.Send&#x200B;SMS.1` | ✅ OK |
| Env/Adapter/SMS/GLB_SendSMSSubQueue | `.Request.SMSAdapter.SendS&#x200B;MS.1` | ✅ OK |
| Env/Adapter/SMS/MIG_ShortCodeMapper | `34444=50,33573=51` | ✅ OK |
| Env/Adapter/SMS/MIG_SourceFilter | `2006,1919` | ✅ OK |
| Env/Adapter/SMS/MIG_Threads | `2` | ✅ OK |
| Env/Adapter/SMS/MIG_UseQueue | `true` | ✅ OK |
| Env/Adapter/SMS/SMSC/MIG_Host | `PC4003176` | ✅ OK |
| Env/Adapter/SMS/SMSC/MIG_Password | `#!S3la4+hzNFIWjpgc6SAH0IW&#x200B;lq/7fxALnkHxKDSMzEss=` | ✅ OK |
| Env/Adapter/SMS/SMSC/MIG_Port | `2601` | ✅ OK |
| Env/Adapter/SMS/SMSC/MIG_Timeout | `20` | ✅ OK |
| Env/Adapter/SMS/SMSC/MIG_UserName | `1919` | ✅ OK |
| Env/GLB_BusinessServicesRoot | `c:\cvsdir\TIL_Wellington\&#x200B;BusinessServices\` | ✅ OK |
| Env/JMS/Connections/SMSAdapter/GLB_QueueConnectionFactory | `QueueConnectionFactory` | ✅ OK |
| Env/JMS/Connections/SMSAdapter/GLB_TopicConnectionFactory | `TopicConnectionFactory` | ✅ OK |
| Env/JMS/Connections/SMSAdapter/MIG_JMSURL | `tcp://hscot07:8222` | ✅ OK |
| Env/JMS/Connections/SMSAdapter/MIG_Password | `#!76ggxWqcTuG8zeOFIrN9aV1&#x200B;sERdBDtXN` | ✅ OK |
| Env/JMS/Connections/SMSAdapter/MIG_Username | `tilsms` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix | `VOD.UK.DEV` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix_IF | `VOD.UK.DEV.TILIF` | ✅ OK |
| Env/JMS/MIG_Jms_Dest_Prefix_Internal | `VOD.UK.DEV.TILINTERNAL` | ✅ OK |
| Env/JMS/MIG_ReplyToQueueByDefault | `true` | ✅ OK |
| Env/JMS/Properties/Publish/JMS_TIBCO_PRESERVE_UNDELIVERED | `true` | ✅ OK |
| Env/JMS/Properties/Publish/MIG_DeliveryMode | `PERSISTENT` | ✅ OK |
| Env/JMS/Properties/Publish/MIG_Expiration | `0` | ✅ OK |
| Env/LogRoles/MIG_EnableDebug | `false` | ✅ OK |
| Env/SMS/Default/GLB_SourceNPI | `9` | ✅ OK |
| Env/SMS/Default/GLB_SourceTON | `3` | ✅ OK |
| Env/SMS/GLB_KeyRefreshIntervalDays | `1...` | ✅ OK |
| Env/SMS/GLB_KeyRefreshStartTime | `2014 NOV 19 06:31:00 GMT...` | ✅ OK |
| Env/SMS/GLB_Timeout | `30` | ✅ OK |
| Env/SMS/Phone/GLB_SourceNPI | `1` | ✅ OK |
| Env/SMS/Phone/GLB_SourceTON | `1` | ✅ OK |
| Env/SMS/ShortCode/GLB_SourceNPI | `9` | ✅ OK |
| Env/SMS/ShortCode/GLB_SourceTON | `3` | ✅ OK |
| Env/SMS/Text/GLB_SourceNPI | `0` | ✅ OK |
| Env/SMS/Text/GLB_SourceTON | `5` | ✅ OK |
| GLB_TILVersion | `TIL-Build24` | ✅ OK |
| HawkEnabled | `true` | ✅ OK |
| JmsProviderUrl | `DO_NOT_USE` | ✅ OK |
| JmsSslProviderUrl | `DO_NOT_USE` | ✅ OK |
| RemoteRvDaemon | `` | ✅ OK |
| RvDaemon | `tcp:7500` | ✅ OK |
| RvNetwork | `` | ✅ OK |
| RvService | `7500` | ✅ OK |
| RvaHost | `localhost` | ✅ OK |
| RvaPort | `7600` | ✅ OK |
| TIBHawkDaemon | `tcp:7474` | ✅ OK |
| TIBHawkNetwork | `` | ✅ OK |
| TIBHawkService | `7474` | ✅ OK |
