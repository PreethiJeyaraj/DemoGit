000100180703     H
000200180703      ******************************************************************
000300180703      * Program name: EDIMQRSPR1                                       *
000400180702      *                                                                *
000500180703      * Module name:  EDIMQRSPR1                                       *
000600180702      *                                                                *
000700180702      * Description: Program to process EDI Response from MQ           *
000800180702      *                                                                *
000900180703      * Calling program: EDIMQRSPC1                                    *
001000180702      *                                                                *
001100180702      * Called programs: 1. LOGIOERRS - Std IGF error logging program  *
001200180702      * procedure/module                                               *
001300180702      *                  2. WSCFEIMPR - Generate xml for AddNotelog    *
001400180702      *                  3. WSCLIENT  - Invoke CFE webservice for      *
001500180702      * AddNotelog                                                     *
001600180702      *                                                                *
001700180702      *                                                                *
001800180702      * Files used: EDIPF5   - DETAIL ERROR FILE                       *
001900180702      *             EDIPF14  - MQ SERIES INFORMATION FILE              *
002000180702      *          INVOI00001  - INVOICE CONTROL FILE                    *
002100180705      *                                                                *
002200180702      * Special behevior:                                              *
002300180702      *                   Calls MQ to get MQ Message from GCMS         *
002400180702      *                                                                *
002500180702      * Compile as:  CRTRPGMOD MODULE(EDIMQRESPR)                      *
002600180702      *              SRCFILE(*CURLIB/QRPGLESRC)                        *
002700180702      *              BNDDIR(LIBHTTP/HTTPAPI)                           *
002800180702      *              COMMIT(*NONE)                                     *
002900180702      *              RPGPPOPT(*LVL1)                                   *
003000180702      *                                                                *
003100180702      * Messages: None                                                 *
003200180702      *                                                                *
003300180702      * Parameters: 1. PrmLibName - Library name  (Incoming)           *
003400180702      *                                                                *
003500180702      * Change history:                                                *
003600180702      *                                                                *
003700180702      * Change  Reason      Date     Pgmr   Description                *
003800180702      * flag                                                           *
003900180702      * -----   ----------  ------   ----   ------------------------   *
004000180702      * 1676    GIP1859663  07/2018  PXJ    Initial development      *
004100000000      ****************************************************************
004200000000      *                                                              *
004300000000      ****************************************************************
004400180703     H*DFTACTGRP(*NO) ACTGRP(*NEW)
004500180703      *
004600180711      * Log MQ Error  in EDIINVR11
004700180705     FMQOUTHP   UF A E             DISK    INFDS(MQHSDS)
004800180705
004900180711      * Info - EDI MQ Connection to GCMS , CTS Call
005000180705     FEDIPF14   IF   E           K DISK    INFDS(PF14DS)
005100180705
005200180711      * Connection handle
005300180703     D HConn           S             10I 0
005400180703
005500180711      * Options
005600180703     D Options         S             10I 0
005700180703
005800180711      * Object handle
005900180703     D HObj            S             10I 0
006000180703
006100180711      * Completion codes
006200180703     D OpenCode        S             10I 0
006300180703     D CompletionCode  S             10I 0
006400180703
006500180711      * Reasons
006600180703     D Reason          S             10I 0
006700180703     D ConnReason      S             10I 0
006800180703
006900180711      * Buffer
007000180711     D Buffer          S          99999A   Inz('Initial')
007100180703
007200180711      * Buffer length
007300180703     D BufferLength    S             10I 0 Inz(%LEN(Buffer))
007400000000
007500180711      * Actual Message length received
007600180703     D MessageLength   S             10I 0
007700000000
007800180711      * XML-INTO Options
007900180703     D $Options        S            200A   varying
008000180703
008100180711      * Current Date
008200180703     D WWDATE          S               D   DATFMT(*ISO)
008300180703
008400180711      * Current Time
008500180703     D WWTIME          S               T   TIMFMT(*HMS)
008600180703
008700180711      * Current TimeStamp
008800180703     D WWTIMESTAMP     S               Z   Inz(*sys)
008900180703
009000180711      * Country Code
009100180704     D Country         S              2A
009200180704
009300180711      * Invoice Number
009400180704     D Id              S             22A
009500180704
009600180711      * Invoice Date
009700180710     D Invoice_Date    S               D   DATFMT(*MDY)
009800180704
009900180711      * Object ID
010000180705     D ObjId           S             16A
010100180705
010200180711      * Index of Object Description
010300180705     D n               S              3I 0
010400180705
010500180711      * Response from GCMS
010600180706     DRESPONSE_GCMS    S              1A
010700180706
010800180711      * WSCFEIMPR parm declaration
010900180704     DwAPPLID          S              5A
011000180704     DWSOPER           S             50A
011100180704     DErrNote          S            256A
011200180704     DRetCode          S              2A
011300180704     DWRETCODE         S              2A
011400180704     DWErrNote         S            256A
011500180705
011600180711      * Queue Manager
011700180705     D Qmgr            S             48A   Inz
011800180705
011900180711      * Queue Name
012000180705     D Queue           S             48A   Inz
012100180705
012200180711      * Program Library
012300180706     DPgmLib           S              8A
012400180706
012500180711      * IFS path Name
012600180705     D $New_File       S            100A   Inz
012700180705     D $File_Path      S            100A   Inz
012800180705     D $Arc_Dir        S            100A   Inz
012900180705     D fd              S             10I 0
013000180705
013100180711      * Correlation ID
013200180705     D GetCorID        S             80A   Inz
013300180705
013400180711      * Completion Code
013500180705     DCMPCOD           S             10I 0
013600180704
013700180711      * System Name
013800180706     DSYSNAME          S              8A
013900180706
014000180711      * Reason Code
014100180706     DREASONCODE       S             10A
014200180706
014300180711      * Reason Code
014400180706     DREASONCMP        S             10A   Inz('0000000000')
014500180711
014600180711      * Input Member Name
014700180711     DMBRNAME          S             10A
014800180711
014900180711      * Sender Identifier
015000180711     DSNDIND           S             30A
015100180711
015200180711      * Control Number
015300180711     DCTRNUM           S             10A
015400180706
015500180711      * MESSAGE VARIABLE
015600180711     DMSGVAR           S            256A
015700180711
015800180711      * Error Details to LOGIOERRS
015900180711     DERROR            S            136A
016000180711
016100180711      * Declare MQI structures needed
016200180711      * MQI named constants
016300180703     D/COPY CMQG
016400000000
016500180709      * Define ROBOT work fields
016600180709     DMSG_Q            S             10A   INZ(*BLANKS)
016700180709     DMSG_ID           S              7A   INZ(*BLANKS)
016800180709     DMSG_DTA          S            256A   INZ(*BLANKS)
016900180709     DMSG_TYP          S              1A   INZ('I')
017000180709
017100180711      * Object Descriptor
017200180703     D MQOD            DS                  Qualified
017300000000     D/COPY CMQODG
017400000000
017500180711      * Message Descriptor
017600180703     D MQMD            DS                  Qualified
017700000000     D/COPY CMQMDG
017800000000
017900180711      * Get message options
018000180703     D MQGMO           DS                  Qualified
018100000000     I/COPY CMQGMOG
018200000000
018300180622     D/copy *libl/qrpglesrc,IFSIO_H
018400180622
018500180711      * Get Correlation ID from XML Response
018600180703     D GetCorID_DS     DS                  Inz
018700180703     D Cor_Prefix                     4A
018800180703     D Buffer_CorID                  80A
018900180703
019000180711      * Get Status ID and Error details from XML Response
019100180703     D ApplicationStatus...
019200180703     D                 DS                  Qualified
019300180703     D StatusId                      10A
019400180703     D ErrorCode                     50A
019500180703     D ErrorDescription...
019600180703     D                               50A   Dim(50)
019700180703     D ErrorDataname                 50A
019800180711
019900180711      * Get Invoice Date from XML Response
020000180711     DDocumentDateTime...
020100180711     D                 S             10A
020200180703
020300180711      * Program Status Data Structure
020400180703     DPSDS            SDS
020500180705     DPGMNAME                  1     10A
020600180709     DPGMSTS                  11     15S 0
020700180709     DPGMMSGID                40     46A
020800180709     DPGMERRDTA               91    170A
020900180703     DPGMUSER                254    263A
021000180705
021100180705      * ERROR LOG data structure
021200180705     DERRORDS          DS                  INZ
021300180705     DMSGID                           7A
021400180705     DPROGRAMNAME                    10A
021500180705     DFILENAME                        8A
021600180705     DOPCODE                          6A
021700180705     DSTATUS                          5S 0
021800180705     DEXTMSG                        100A
021900180705
022000180705      * File data structure for file: EDIPF14
022100180705     DPF14DS           DS
022200180705     DPF14FIL            *FILE
022300180705     DPF14OPN                  9      9
022400180705     DPF14INP            *INP
022500180705     DPF14MOD            *MODE
022600180705     DPF14OUT            *OUT
022700180705     DPF14OPC            *OPCODE
022800180705     DPF14SIZ            *SIZE
022900180705     DPF14FST            *STATUS
023000180705     DPF14RCD            *RECORD
023100180705     DPF14RTN            *ROUTINE
023200180706
023300180706      * File data structure for file: MQOUTHP
023400180706     DMQHSDS           DS
023500180706     DMQHSFIL            *FILE
023600180706     DMQHSOPN                  9      9
023700180706     DMQHSINP            *INP
023800180706     DMQHSMOD            *MODE
023900180706     DMQHSOUT            *OUT
024000180706     DMQHSOPC            *OPCODE
024100180706     DMQHSSIZ            *SIZE
024200180706     DMQHSFST            *STATUS
024300180706     DMQHSRCD            *RECORD
024400180706     DMQHSRTN            *ROUTINE
024500180706
024600180711      * Prototype for WSCLIENT
024700180709     DWSCLIENT         PR                  ExtPgm('WSCLIENT')
024800180706     DwAPPLID                         5A
024900180706     DId                             22A
025000180706     DPgmLib                          8A
025100180706     DSYSNAME                         8A
025200180706     DWRETCODE                        2A
025300180706
025400180711      * Prototype for WSCFEIMPR
025500180709     DWSCFEIMPR        PR                  ExtPgm('WSCFEIMPR')
025600180706     DwAPPLID                         5A
025700180706     DWSOPER                         50A
025800180706     DId                             22A
025900180706     DObjId                          16A
026000180706     DPgmLib                          8A
026100180706     DSYSNAME                         8A
026200180706     DErrNote                       256A
026300180706     DRETCODE                         2A
026400180706
026500180711      * Prototype for SNDROBOT
026600180710     DSNDROBOT         PR                  ExtPgm('SNDROBOT')
026700180709     DMSG_Q                          10A
026800180709     DMSG_ID                          7A
026900180709     DMSG_DTA                       256A
027000180709     DMSG_TYP                         1A
027100180709
027200180711      * Prototype for LOGIOERRS
027300180711     DIOERRS           PR                  ExtProc('LOGIOERRS')
027400180711     DERROR                         136A
027500180705
027600180711      * Prototype for EDIMQRSPR1
027700180709     DMain             PR                  ExtPgm('EDIMQRSPR1')
027800180709     DPrmPgmLib                       8A
027900000000
028000180711      * Prototype Interface for EDIMQRSPR1
028100180709     DMain             PI
028200180709     DPrmPgmLib                       8A
028300180622
028400000000      /Free
028500000000
028600180706       //***************************************************************
028700180706       //   Mainline Processing                                        *
028800180702       //***************************************************************
028900180706
029000180711       //   Get queue manager and Queue from EDIPF14                   *
029100180711       PgmLib = PrmPgmLib;
029200180711       CHAIN ('DEVAS400': PgmLib: 'MQMANAGER') EDIPF14;
029300180711       IF %FOUND(EDIPF14);
029400180711          Qmgr = EDIXMLDATA;
029500180711       ENDIF;
029600180711
029700180711       //   Get Object ID & Control Num from Invoice Control File
029800180711       exec sql
029900180711          select CM_OBJECT_ID, CONTROL_NUM
030000180711          into :ObjId, :CTRNUM
030100180711          from Invoice_Control
030200180711          where mq_msg_id = :Buffer_CorID;
030300180711
030400180702       //***************************************************************
030500180702       //   Connect to the queue manager                               *
030600180702       //***************************************************************
030700000000       MQCONN(Qmgr : HConn : CompletionCode : ConnReason);
030800000000
030900000000       // report reason and stop if it failed
031000000000       If CompletionCode = CCFAIL;
031100180711          //ReasonCode = %CHAR(Reason);
031200180711          //MSGVAR = 'GCMS EDI RESPONSE ERROR: ' +
031300180711          //         'Unable to connect to to Queue Manager. ' +
031400180711          //         'ReasonCode' + ReasonCode;
031500180711          //EXSR WRITEPF5;
031600180702
031700180702       // Log MQ Invoke history file
031800180702          EXSR LOGMQCALL;
031900180702
032000180702          *INLR = *ON;
032100180702          RETURN;
032200000000       EndIf;
032300000000
032400000000       //***************************************************************
032500000000       //   Open the named message queue for input (and fail if MQM    *
032600000000       //   is quiescing); exclusive or shared use of the queue is     *
032700000000       //   controlled by the queue definition here                    *
032800000000       //                                                              *
032900000000       //   Resulting queue handle is HObj                             *
033000000000       //***************************************************************
033100000000
033200180706       CHAIN ('DEVAS400': PgmLib: 'MQINNAME') EDIPF14;
033300180703       IF %FOUND(EDIPF14);
033400180703          Queue = EDIXMLDATA;
033500180703       ENDIF;
033600180703
033700000000       //***************************************************************
033800000000       //   Create object descriptor for source queue                  *
033900000000       //***************************************************************
034000000000       MQOD.ODON = Queue;
034100000000
034200000000       // options are input-as-queue-def and fail-if-quiescing
034300000000       Options = OOINPQ + OOFIQ;
034400000000
034500000000       MQOPEN(HConn : MQOD : Options : HObj : OpenCode : Reason);
034600000000
034700000000       // report reason, if any; stop if failed
034800000000
034900000000       If OpenCode = CCFAIL;
035000180711       // ReasonCode = %CHAR(Reason);
035100180711       // MSGVAR = 'GCMS EDI RESPONSE ERROR: ' +
035200180711       //          'Unable to open queue for input. ' +
035300180711       //          'ReasonCode' + ReasonCode;
035400180711       // EXSR WRITEPF5;
035500180702
035600180702       // Log MQ Invoke history file
035700180702          EXSR LOGMQCALL;
035800180702
035900180702          *INLR = *ON;
036000180702          RETURN;
036100000000       EndIf;
036200000000
036300180702       //***************************************************************
036400180702       //   Get IFS Path from EDIPF14 to save MQ XML response          *
036500180702       //***************************************************************
036600180702       CHAIN ('DEVAS400': PgmLib: 'EDIIFSOUT') EDIPF14;
036700180702       IF %FOUND(EDIPF14);
036800180703          $File_Path = EDIXMLDATA;
036900180702       ENDIF;
037000180702
037100180709
037200180709       //   Get IFS Path from EDIPF14 to save MQ XML response
037300180709         CHAIN ('DEVAS400': PgmLib: 'EDIARCDIR') EDIPF14;
037400180709         IF %FOUND(EDIPF14);
037500180709            $Arc_Dir = EDIXMLDATA;
037600180709         ENDIF;
037700180709
037800000000       // initial loop condition is based on result of MQOPEN
037900000000       CompletionCode = OpenCode;
038000180622
038100180702       // option is to wait up to 15 seconds for next message
038200180702       MQGMO.GMOPT = GMWT;
038300180702       MQGMO.GMWI = 15000;
038400180702
038500180702       MQGMO.GMOPT += GMCONV;
038600180702
038700180703       // initial loop condition is based on result of MQOPEN
038800180703       CompletionCode = OpenCode;
038900180703
039000000000       // start of loop to read all the messages
039100180711       DoW CompletionCode <> CCFAIL and Buffer <> *BLANKS;
039200000000
039300000000         // MsgId and CorrelId are selectors that must be cleared
039400000000         // to get messages in sequence, and they are set each MQGET
039500000000         MQMD.MDMID = MINONE;
039600000000         MQMD.MDCID = CINONE;
039700000000
039800000000         // clear buffer because MQGET only fills to length of message
039900000000         Buffer = *BLANKS;
040000180702
040100180702       //***************************************************************
040200180702       //   Get messages from message queue                            *
040300180702       //***************************************************************
040400000000
040500000000         MQGET(HConn : HObj : MQMD : MQGMO :  BufferLength : %ADDR(Buffer) :
040600000000               MessageLength : CompletionCode : Reason);
040700000000
040800000000         // report reason, if any
040900000000         Select;
041000000000           When Reason = RCNONE;
041100000000
041200000000           When Reason = RC2033;
041300000000
041400000000           Other;
041500180711         //   ReasonCode = %CHAR(Reason);
041600180711         //   MSGVAR = 'GCMS EDI RESPONSE ERROR: '+
041700180711         //            'Unable to perform MQGET operation. ' +
041800180711         //            'ReasonCode' + ReasonCode;
041900180711         //   EXSR WRITEPF5;
042000180703
042100180703              // Log MQ Invoke history file
042200180703              EXSR LOGMQCALL;
042300180703
042400180621             *INLR = *ON;
042500180621             RETURN;
042600000000         EndSl;
042700180622
042800180703         If CompletionCode <> CCFAIL;
042900180622
043000180703            EXSR MovTmpEDI;
043100180703
043200180703            $Options  = 'case=any +
043300180703                      allowextra=yes +
043400180703                      allowmissing=yes +
043500180703                      ns=remove +
043600180703                      nsprefix=ns_ +
043700180703                      path=Envelope/Body/AcknowledgeInvoice/ApplicationArea/' +
043800180703                      'Application/ApplicationStatus';
043900180703            XML-INTO ApplicationStatus %XML(Buffer : $Options);
044000180703
044100180703            $Options  = 'case=any +
044200180703                         allowextra=yes +
044300180703                         allowmissing=yes +
044400180703                         ns=remove +
044500180703                         nsprefix=ns_ +
044600180703                         path=Envelope/Header/RelatesTo';
044700180703            XML-INTO GetCorID %XML(Buffer : $Options);
044800180703
044900180703            GetCorID_DS = GetCorID;
045000180703
045100180704            Select;
045200180704            When ApplicationStatus.StatusId = 'SUCCESS';
045300180704
045400180704            $Options  = 'case=any +
045500180704                         allowextra=yes +
045600180704                         allowmissing=yes +
045700180704                         ns=remove +
045800180704                         nsprefix=ns_ +
045900180704                         path=Envelope/Body/AcknowledgeInvoice/' +
046000180704                         'DataArea/Invoice/Header/Parties/SupplierParty' +
046100180706                         '/Addresses/PrimaryAddress/Country';
046200180704            XML-INTO Country %XML(Buffer : $Options);
046300180704
046400180704            $Options  = 'case=any +
046500180704                         allowextra=yes +
046600180704                         allowmissing=yes +
046700180704                         ns=remove +
046800180704                         nsprefix=ns_ +
046900180704                         path=Envelope/Body/AcknowledgeInvoice/' +
047000180704                         'DataArea/Invoice/Header/DocumentIds/' +
047100180706                         'SupplierDocumentId/Id';
047200180704            XML-INTO Id %XML(Buffer : $Options);
047300180704
047400180704            $Options  = 'case=any +
047500180704                         allowextra=yes +
047600180704                         allowmissing=yes +
047700180704                         ns=remove +
047800180704                         nsprefix=ns_ +
047900180704                         path=Envelope/Body/AcknowledgeInvoice/' +
048000180706                         'DataArea/Invoice/Header/DocumentDateTime';
048100180704            XML-INTO DocumentDateTime %XML(Buffer : $Options);
048200180704
048300180710            Invoice_Date = %Date(DocumentDateTime: *iso);
048400180704
048500180703            exec sql
048600180703               update invoice_control
048700180704               set mq_res_timestamp = :WWTIMESTAMP,
048800180704               gcms_response = 'S',
048900180704               last_update_id = :PGMUSER ,
049000180704               last_update_timestamp = :WWTIMESTAMP
049100180704               where mq_msg_id = :Buffer_CorID and
049200180704               country_code = :Country         and
049300180705               invoice_num = :Id               and
049400180705               invoice_date = :Invoice_Date    and
049500180704               mq_res_timestamp is null;
049600180709
049700180709            If SqlCode <> 0 and SqlCode <> 100;
049800180710               Clear ErrorDS;
049900180709               PROGRAMNAME = PGMNAME;
050000180709               MSGID       = 'ICC6700';
050100180709               FILENAME = 'INVOI00001';
050200180709               OPCODE   = 'Update';
050300180709               STATUS   = SQLCODE;
050400180709               EXTMSG='UPDATE- Error occurred for: '
050500180709                      +%trim(Id) + ' ' + %CHAR(Invoice_Date);
050600180711               ERROR = ERRORDS;
050700180711               IOERRS(ERROR);
050800180709               MSG_ID = 'RBT8006';
050900180709               MSG_DTA = %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
051000180709               EXSR SND_ROBOT;
051100180709            EndIf;
051200180704
051300180706            Other;
051400180704                 n = 1;
051500180705                 DoU ApplicationStatus.ErrorDescription(n) = *Blanks;
051600180704                     If %Scan('Duplicate Invoice'
051700180705                              :ApplicationStatus.ErrorDescription(n)) <> 0;
051800180705                        Response_GCMS = 'D';
051900180705                     Else;
052000180705                        Response_GCMS = 'E';
052100180704                     EndIf;
052200180704
052300180705                     WErrNote = %Trim(WErrNote) +
052400180705                                ApplicationStatus.ErrorDescription(n);
052500180704                     n= n+1;
052600180704                 EndDo;
052700180704
052800180704                 EXSR CrtCFEXML;
052900180704
053000180704                 exec sql
053100180704                 update invoice_control
053200180704                 set mq_res_timestamp = :WWTIMESTAMP ,
053300180704                 gcms_response = :Response_GCMS ,
053400180704                 last_update_id = :PGMUSER ,
053500180704                 last_update_timestamp = :WWTIMESTAMP
053600180704                 where mq_msg_id = :Buffer_CorID;
053700180709
053800180709                 If SqlCode <> 0 and SqlCode <> 100;
053900180710                    Clear ErrorDS;
054000180709                    PROGRAMNAME = PGMNAME;
054100180709                    MSGID       = 'ICC6700';
054200180709                    FILENAME = 'INVOI00001';
054300180709                    OPCODE   = 'Update';
054400180709                    STATUS   = SQLCODE;
054500180709                    EXTMSG='UPDATE- Error occurred for: '
054600180709                           +%trim(Id) + ' ' + %CHAR(Invoice_Date);
054700180711                    ERROR = ERRORDS;
054800180710                    IOERRS(ERRORDS);
054900180709                    MSG_ID = 'RBT8006';
055000180709                    MSG_DTA = %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
055100180709                    EXSR SND_ROBOT;
055200180709                 EndIf;
055300180706            EndSl;
055400180706
055500000000         // end DO-while loop; MQI failure causes loop to end
055600180706         EndIf;
055700180706       EndDo;
055800180704
055900180706       *INLR = *ON;
056000180706       RETURN;
056100180706
056200000000       //***************************************************************
056300000000       //                                                              *
056400000000       //   Close the source queue (if it was opened)                  *
056500000000       //                                                              *
056600000000       //***************************************************************
056700180706        If OpenCode <> CCFAIL;
056800180703          Options = CONONE;
056900180703          MQCLOSE(HConn : HObj : Options :  CompletionCode : Reason);
057000000000
057100180703         // report reason, if any, resulting from this call
057200180703          If Reason <> RCNONE;
057300180703
057400180703         // "MQCLOSE ended with reason code ...."
057500180711         //  ReasonCode = %CHAR(Reason);
057600180711         //  MSGVAR = 'Unable to Close MQ. ' +
057700180711         //           'ReasonCode' + ReasonCode;
057800180711         //  EXSR WRITEPF5;
057900180711
058000180709           // Log MQ Invoke history file
058100180709             EXSR LOGMQCALL;
058200180703          EndIf;
058300000000
058400000000         // end if (OpenCode not CCFAIL)
058500180706        EndIf;
058600000000
058700000000       //***************************************************************
058800000000       //                                                              *
058900000000       //  Disconnect from queue manager (if not previously connected) *
059000000000       //                                                              *
059100000000       //***************************************************************
059200180706        If ConnReason <> RC2002;
059300180703          MQDISC(HConn : CompletionCode : Reason);
059400000000
059500180703       // report reason and stop if it failed
059600180709          If CompletionCode = CCFAIL;
059700180709       // "MQDISC ended with reason code ...."
059800180711       //    ReasonCode = %CHAR(Reason);
059900180711       //    MSGVAR = 'GCMS EDI RESPONSE ERROR: Unable to Disconnect MQ. ' +
060000180711       //             'ReasonCode' + ReasonCode;
060100180711       //    EXSR WRITEPF5;
060200180711
060300180709       // Log MQ Invoke history file
060400180709             EXSR LOGMQCALL;
060500180709
060600180709          EndIf;
060700180706        EndIf;
060800180703
060900180704       //***************************************************************
061000180704       //   Subroutine to write XML Response to IFS file               *
061100180704       //***************************************************************
061200180703       Begsr MovTmpEDI;
061300180709         fd  = open(%trim($file_path)
061400180709                  : O_WRONLY+O_CREAT+O_TRUNC
061500180709                  : S_IRGRP + S_IWGRP + S_IXGRP +
061600180709                    S_IRUSR + S_IWUSR + S_IXUSR+S_IROTH+S_IXOTH);
061700180709
061800180709         callp close(fd);
061900180709
062000180703         fd = open(%trim($file_path)
062100180703                  :O_WRONLY+O_TEXTDATA);
062200180703
062300180703       // Write xml buffer into IFS
062400180703         callp write(fd:%addr(Buffer): %len(%trim(Buffer)));
062500180703         callp close(fd);
062600180703
062700180703         $New_File = %trim($Arc_Dir) + 'EDIXMLRSP'+ %char(WWDATE) +
062800180703                           %char(WWTIME);
062900180703
063000180703       // Clear old XML log history
063100180703         fd  = open(%trim($New_File)
063200180703                   : O_WRONLY+O_CREAT+O_TRUNC
063300180703                   : S_IRGRP + S_IWGRP + S_IXGRP +
063400180706                   S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
063500180703                   : 819);
063600180703         callp close(fd);
063700180703
063800180703       // Create EDI xml history
063900180703         fd = open(%trim($New_File)
064000180703                   :O_WRONLY+O_TEXTDATA);
064100180703       // Write EDIXML buffer into IFS archive
064200180703         callp(e) write(fd:%addr(Buffer): %len(%trim(Buffer)));
064300180703         callp close(fd);
064400180703
064500180709         IF %ERROR;
064600180710            Clear ErrorDS;
064700180709            PROGRAMNAME = PGMNAME;
064800180709            MSGID       = PGMMSGID;
064900180709            FILENAME = 'EDIXMLOUT';
065000180709            OPCODE   = 'WRITE';
065100180709            STATUS   = PGMSTS;
065200180709            EXTMSG='Error while WRT object for: '
065300180709                   +%trim(Id) + '-'
065400180709                   + %trim(PGMERRDTA);
065500180711            ERROR = ERRORDS;
065600180710            IOERRS(ERRORDS);
065700180709            MSG_ID = 'RBT8013';
065800180709            MSG_DTA = %TRIM(Id) + '-'
065900180709                      + %trim(PGMERRDTA);
066000180709            EXSR SND_ROBOT;
066100180709         EndIf;
066200180703       Endsr;
066300180704
066400180704       //***************************************************************
066500180704       //   Subroutine to write CM Error Worklist and Content Manager  *
066600180704       //***************************************************************
066700180704       Begsr CrtCFEXML;
066800180704      * PART1 -------------------------------------
066900180704          wAPPLID = 'CFE';
067000180710          If Country = 'US' and Response_GCMS = 'D';
067100180704          Else;
067200180704          // Put Object ID in CM Error Worklist
067300180704             WSOPER  = 'StartWorkflow';
067400180704             ErrNote = *Blanks;
067500180704             RETCODE = '00';
067600180706             SYSNAME = 'DEVAS400';
067700180711      // Generate xml for StartWorkflow
067800180706             WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
067900180710                       PgmLib: SYSNAME: ErrNote: RETCODE);
068000180704
068100180704             If RETCODE='00';
068200180704                WRETCODE = '00';
068300180710                WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
068400180706                         WRETCODE);
068500180711                If WRETCODE = '98';
068600180711                   MSGVAR = 'Error  : ' +
068700180711                            'Adding to worklist for ' +
068800180711                            'invoice number/Objectid: '  +
068900180711                             %TRIMR(Id)+' / '+ %TRIM(OBJID);
069000180711                   EXSR WRITEPF5;
069100180711                EndIf;
069200180704             Endif;
069300180704          Endif;
069400180704
069500180710      * PART2 -------------------------------------
069600180710          WSOPER  = 'AddNotelog';
069700180710          ErrNote = WErrNote;
069800180710          RETCODE = '00';
069900180710          SYSNAME = 'DEVAS400';
070000180710
070100180710      * Generate xml for AddNotelog
070200180710          WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
070300180710                    PgmLib: SYSNAME: ErrNote: RETCODE);
070400180710
070500180710          If RETCODE='00';
070600180710             WRETCODE = '00';
070700180710             WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
070800180710                      WRETCODE);
070900180711             If WRETCODE = '98';
071000180711                MSGVAR = 'Error  : ' +
071100180711                         'Adding to Notelog for ' +
071200180711                         'invoice number/Objectid: '  +
071300180711                         %TRIMR(Id)+' / '+ %TRIM(ObjId);
071400180711                EXSR WRITEPF5;
071500180711             EndIf;
071600180710          EndIf;
071700180704       ENDSR;
071800180704
071900180705      **********************************************************************
072000180705      * Subroutine to log MQ History file
072100180705      **********************************************************************
072200180705       Begsr LOGMQCALL;
072300180705          WCTY     = Country;
072400180705          WINV#    = Id;
072500180705          WINVDATE = %date(DocumentDateTime: *iso);
072600180706          WRCode   = ReasonCMP;
072700180706          WCMPCODE   = ReasonCMP;
072800180705          WRUNDTE  = WWDATE;
072900180706          WRITE MQOUTHPR;
073000180705          If %Error;
073100180710             Clear ErrorDS;
073200180705             PROGRAMNAME = PGMNAME;
073300180705             MSGID       = 'ICC6700';
073400180705             FILENAME    = MQHSFIL;
073500180705             OPCODE      = MQHSOPC;
073600180705             STATUS      = MQHSFST;
073700180705             EXTMSG      ='Error occurred for: '+%trim(Id)
073800180705                          + ' ' + DocumentDateTime;
073900180711             ERROR = ERRORDS;
074000180710             IOERRS(ERRORDS);
074100180705          ENDIF;
074200180705       Endsr;
074300180705
074400180709      **********************************************************************
074500180709      * Subroutine to send ROBOT error messages
074600180709      **********************************************************************
074700180709       Begsr SND_ROBOT;
074800180709          SNDROBOT(MSG_Q: MSG_ID: MSG_DTA: MSG_TYP);
074900180709       Endsr;
075000180711
075100180711      ***********************************************************************
075200180711      * Write error messages
075300180711      ***********************************************************************
075400180711       Begsr WRITEPF5;
075500180711       //   Get Member Name and Sender Identifier from EDIPF6
075600180711          exec sql
075700180711             select E6MBRNAM, E6SNDIND
075800180711             into :MBRNAME, :SNDIND
075900180711             from EDIPF6
076000180711             where E6CTRNUM = :CTRNUM;
076100180711
076200180711          exec sql
076300180711             insert into EDIPF5
076400180711             (E5MBRNAM,  E5SNDIND, E5CTRNUM, E5RUNDATE, E5RUNTIME,
076500180711              E5COUNTRY, E5INVNO,  E5INVTYP, E5MSGID,   E5MSGVAR)
076600180711             values(:MBRNAME, :SNDIND, :CTRNUM, :WWDATE, :WWTIME,
076700180711                    :Country, :Id,     ' ',     ' ',     :MSGVAR);
076800180711
076900180711       Endsr;
077000180711
077100180711      ***********************************************************************
077200180711      * Write error messages
077300180711      ***********************************************************************
077400180711       Begsr INITSR;
077500180711       Endsr;
077600180711      /End-Free
