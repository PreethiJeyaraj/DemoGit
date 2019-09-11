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
005200180713     FEDIPF5    UF A E             DISK
005300180713
005400180711      * Connection handle
005500180703     D HConn           S             10I 0
005600180703
005700180711      * Options
005800180703     D Options         S             10I 0
005900180703
006000180711      * Object handle
006100180703     D HObj            S             10I 0
006200180703
006300180711      * Completion codes
006400180703     D OpenCode        S             10I 0
006500180703     D CompletionCode  S             10I 0
006600180703
006700180711      * Reasons
006800180703     D Reason          S             10I 0
006900180703     D ConnReason      S             10I 0
007000180703
007100180711      * Buffer
007200180711     D Buffer          S          99999A   Inz('Initial')
007300180703
007400180711      * Buffer length
007500180703     D BufferLength    S             10I 0 Inz(%LEN(Buffer))
007600000000
007700180711      * Actual Message length received
007800180703     D MessageLength   S             10I 0
007900000000
008000180711      * XML-INTO Options
008100180703     D $Options        S            200A   varying
008200180703
008300180711      * Current Date
008400180713     D WWDATE          S               D   INZ(*SYS)
008500180703
008600180711      * Current Time
008700180713     D WWTIME          S               T   Inz(*SYS)
008800180703
008900180711      * Current TimeStamp
009000180713     D WWTIMESTAMP     S               Z   Inz(*SYS)
009100180703
009200180711      * Country Code
009300180704     D Country         S              2A
009400180704
009500180711      * Invoice Number
009600180704     D Id              S             22A
009700180704
009800180711      * Invoice Date
009900180710     D Invoice_Date    S               D   DATFMT(*MDY)
010000180704
010100180711      * Object ID
010200180705     D ObjId           S             16A
010300180705
010400180711      * Index of Object Description
010500180705     D n               S              3I 0
010600180705
010700180711      * Response from GCMS
010800180706     DRESPONSE_GCMS    S              1A
010900180706
011000180711      * WSCFEIMPR parm declaration
011100180704     DwAPPLID          S              5A
011200180704     DWSOPER           S             50A
011300180704     DErrNote          S            256A
011400180704     DRetCode          S              2A
011500180704     DWRETCODE         S              2A
011600180704     DWErrNote         S            256A
011700180705
011800180711      * Queue Manager
011900180705     D Qmgr            S             48A   Inz
012000180705
012100180711      * Queue Name
012200180705     D Queue           S             48A   Inz
012300180705
012400180711      * Program Library
012500180706     DPgmLib           S              8A
012600180706
012700180711      * IFS path Name
012800180705     D $New_File       S            100A   Inz
012900180705     D $File_Path      S            100A   Inz
013000180705     D $Arc_Dir        S            100A   Inz
013100180705     D fd              S             10I 0
013200180705
013300180711      * Correlation ID
013400180705     D GetCorID        S             80A   Inz
013500180705
013600180711      * Completion Code
013700180705     DCMPCOD           S             10I 0
013800180704
013900180711      * System Name
014000180706     DSYSNAME          S              8A
014100180706
014200180711      * Reason Code
014300180706     DREASONCODE       S             10A
014400180706
014500180711      * Reason Code
014600180706     DREASONCMP        S             10A   Inz('0000000000')
014700180711
014800180711      * Input Member Name
014900180711     DMBRNAME          S             10A
015000180711
015100180711      * Sender Identifier
015200180711     DSNDIND           S             30A
015300180711
015400180711      * Control Number
015500180711     DCTRNUM           S             10A
015600180706
015700180711      * MESSAGE VARIABLE
015800180711     DMSGVAR           S            256A
015900180711
016000180711      * Error Details to LOGIOERRS
016100180711     DERROR            S            136A
016200180711
016300180711      * Declare MQI structures needed
016400180711      * MQI named constants
016500180703     D/COPY CMQG
016600000000
016700180709      * Define ROBOT work fields
016800180709     DMSG_Q            S             10A   INZ(*BLANKS)
016900180709     DMSG_ID           S              7A   INZ(*BLANKS)
017000180709     DMSG_DTA          S            256A   INZ(*BLANKS)
017100180709     DMSG_TYP          S              1A   INZ('I')
017200180709
017300180711      * Object Descriptor
017400180703     D MQOD            DS                  Qualified
017500000000     D/COPY CMQODG
017600000000
017700180711      * Message Descriptor
017800180703     D MQMD            DS                  Qualified
017900000000     D/COPY CMQMDG
018000000000
018100180711      * Get message options
018200180703     D MQGMO           DS                  Qualified
018300000000     I/COPY CMQGMOG
018400000000
018500180622     D/copy *libl/qrpglesrc,IFSIO_H
018600180622
018700180711      * Get Correlation ID from XML Response
018800180703     D GetCorID_DS     DS                  Inz
018900180703     D Cor_Prefix                     4A
019000180703     D Buffer_CorID                  80A
019100180703
019200180711      * Get Status ID and Error details from XML Response
019300180703     D ApplicationStatus...
019400180703     D                 DS                  Qualified
019500180703     D StatusId                      10A
019600180703     D ErrorCode                     50A
019700180703     D ErrorDescription...
019800180703     D                               50A   Dim(50)
019900180703     D ErrorDataname                 50A
020000180711
020100180711      * Get Invoice Date from XML Response
020200180711     DDocumentDateTime...
020300180711     D                 S             10A
020400180703
020500180711      * Program Status Data Structure
020600180703     DPSDS            SDS
020700180705     DPGMNAME                  1     10A
020800180709     DPGMSTS                  11     15S 0
020900180709     DPGMMSGID                40     46A
021000180709     DPGMERRDTA               91    170A
021100180703     DPGMUSER                254    263A
021200180705
021300180705      * ERROR LOG data structure
021400180705     DERRORDS          DS                  INZ
021500180705     DMSGID                           7A
021600180705     DPROGRAMNAME                    10A
021700180705     DFILENAME                        8A
021800180705     DOPCODE                          6A
021900180705     DSTATUS                          5S 0
022000180705     DEXTMSG                        100A
022100180705
022200180705      * File data structure for file: EDIPF14
022300180705     DPF14DS           DS
022400180705     DPF14FIL            *FILE
022500180705     DPF14OPN                  9      9
022600180705     DPF14INP            *INP
022700180705     DPF14MOD            *MODE
022800180705     DPF14OUT            *OUT
022900180705     DPF14OPC            *OPCODE
023000180705     DPF14SIZ            *SIZE
023100180705     DPF14FST            *STATUS
023200180705     DPF14RCD            *RECORD
023300180705     DPF14RTN            *ROUTINE
023400180706
023500180706      * File data structure for file: MQOUTHP
023600180706     DMQHSDS           DS
023700180706     DMQHSFIL            *FILE
023800180706     DMQHSOPN                  9      9
023900180706     DMQHSINP            *INP
024000180706     DMQHSMOD            *MODE
024100180706     DMQHSOUT            *OUT
024200180706     DMQHSOPC            *OPCODE
024300180706     DMQHSSIZ            *SIZE
024400180706     DMQHSFST            *STATUS
024500180706     DMQHSRCD            *RECORD
024600180706     DMQHSRTN            *ROUTINE
024700180706
024800180711      * Prototype for WSCLIENT
024900180709     DWSCLIENT         PR                  ExtPgm('WSCLIENT')
025000180706     DwAPPLID                         5A
025100180706     DId                             22A
025200180706     DPgmLib                          8A
025300180706     DSYSNAME                         8A
025400180706     DWRETCODE                        2A
025500180706
025600180711      * Prototype for WSCFEIMPR
025700180709     DWSCFEIMPR        PR                  ExtPgm('WSCFEIMPR')
025800180706     DwAPPLID                         5A
025900180706     DWSOPER                         50A
026000180706     DId                             22A
026100180706     DObjId                          16A
026200180706     DPgmLib                          8A
026300180706     DSYSNAME                         8A
026400180706     DErrNote                       256A
026500180706     DRETCODE                         2A
026600180706
026700180711      * Prototype for SNDROBOT
026800180710     DSNDROBOT         PR                  ExtPgm('SNDROBOT')
026900180709     DMSG_Q                          10A
027000180709     DMSG_ID                          7A
027100180709     DMSG_DTA                       256A
027200180709     DMSG_TYP                         1A
027300180709
027400180711      * Prototype for LOGIOERRS
027500180711     DIOERRS           PR                  ExtProc('LOGIOERRS')
027600180711     DERROR                         136A
027700180705
027800180711      * Prototype for EDIMQRSPR1
027900180709     DMain             PR                  ExtPgm('EDIMQRSPR1')
028000180709     DPrmPgmLib                       8A
028100000000
028200180711      * Prototype Interface for EDIMQRSPR1
028300180709     DMain             PI
028400180709     DPrmPgmLib                       8A
028500180622
028600000000      /Free
028700000000
028800180706       //***************************************************************
028900180706       //   Mainline Processing                                        *
029000180702       //***************************************************************
029100180706
029200180711       //   Get queue manager and Queue from EDIPF14                   *
029300180711       PgmLib = PrmPgmLib;
029400180711       CHAIN ('DEVAS400': PgmLib: 'MQMANAGER') EDIPF14;
029500180711       IF %FOUND(EDIPF14);
029600180711          Qmgr = EDIXMLDATA;
029700180711       ENDIF;
029800180711
029900180702       //***************************************************************
030000180702       //   Connect to the queue manager                               *
030100180702       //***************************************************************
030200000000       MQCONN(Qmgr : HConn : CompletionCode : ConnReason);
030300000000
030400000000       // report reason and stop if it failed
030500000000       If CompletionCode = CCFAIL;
030600180712          Clear ErrorDS;
030700180712          PROGRAMNAME = PGMNAME;
030800180712          MSGID       = 'ICC6900';
030900180712          FILENAME    = *Blanks;
031000180712          OPCODE      = 'MQCONN';
031100180712          STATUS      = ConnReason;
031200180712          EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
031300180712                        'Unable to connect to to Queue Manager. ' +
031400180712                        'ReasonCode' + %Char(ConnReason);
031500180712          ERROR       = ERRORDS;
031600180712          IOERRS(ERROR);
031700180712          MSG_ID      = 'RBT8015';
031800180712          MSG_DTA     = 'EDIMQRSPR1: Unable to connect to Queue Manager. ' +
031900180712                        'ReasonCode' + %Char(ConnReason);
032000180712          EXSR SND_ROBOT;
032100180702
032200180702          *INLR = *ON;
032300180702          RETURN;
032400000000       EndIf;
032500000000
032600000000       //***************************************************************
032700000000       //   Open the named message queue for input (and fail if MQM    *
032800000000       //   is quiescing); exclusive or shared use of the queue is     *
032900000000       //   controlled by the queue definition here                    *
033000000000       //                                                              *
033100000000       //   Resulting queue handle is HObj                             *
033200000000       //***************************************************************
033300000000
033400180706       CHAIN ('DEVAS400': PgmLib: 'MQINNAME') EDIPF14;
033500180703       IF %FOUND(EDIPF14);
033600180703          Queue = EDIXMLDATA;
033700180703       ENDIF;
033800180703
033900000000       //***************************************************************
034000000000       //   Create object descriptor for source queue                  *
034100000000       //***************************************************************
034200000000       MQOD.ODON = Queue;
034300000000
034400000000       // options are input-as-queue-def and fail-if-quiescing
034500000000       Options = OOINPQ + OOFIQ;
034600000000
034700000000       MQOPEN(HConn : MQOD : Options : HObj : OpenCode : Reason);
034800000000
034900000000       // report reason, if any; stop if failed
035000000000
035100000000       If OpenCode = CCFAIL;
035200180712          Clear ErrorDS;
035300180712          PROGRAMNAME = PGMNAME;
035400180712          MSGID       = 'ICC6900';
035500180712          FILENAME    = *Blanks;
035600180712          OPCODE      = 'MQOPEN';
035700180712          STATUS      = Reason;
035800180712          EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
035900180712                        'Unable to open queue for get operation. ' +
036000180712                        'ReasonCode' + %Char(Reason);
036100180712          ERROR       = ERRORDS;
036200180712          IOERRS(ERROR);
036300180712          MSG_ID      = 'RBT8015';
036400180712          MSG_DTA     = 'EDIMQRSPR1: Unable to open queue for get operation ' +
036500180712                        'ReasonCode' + %Char(Reason);
036600180712          EXSR SND_ROBOT;
036700180702
036800180702          *INLR = *ON;
036900180702          RETURN;
037000000000       EndIf;
037100000000
037200180712       //***************************************************************
037300180702       //   Get IFS Path from EDIPF14 to save MQ XML response          *
037400180702       //***************************************************************
037500180702       CHAIN ('DEVAS400': PgmLib: 'EDIIFSOUT') EDIPF14;
037600180702       IF %FOUND(EDIPF14);
037700180703          $File_Path = EDIXMLDATA;
037800180702       ENDIF;
037900180702
038000180709
038100180709       //   Get IFS Path from EDIPF14 to save MQ XML response
038200180713         CHAIN ('DEVAS400': PgmLib: 'EDIIFSDIR') EDIPF14;
038300180709         IF %FOUND(EDIPF14);
038400180709            $Arc_Dir = EDIXMLDATA;
038500180709         ENDIF;
038600180709
038700000000       // initial loop condition is based on result of MQOPEN
038800000000       CompletionCode = OpenCode;
038900180622
039000180702       // option is to wait up to 15 seconds for next message
039100180702       MQGMO.GMOPT = GMWT;
039200180702       MQGMO.GMWI = 15000;
039300180702
039400180702       MQGMO.GMOPT += GMCONV;
039500180702
039600180703       // initial loop condition is based on result of MQOPEN
039700180703       CompletionCode = OpenCode;
039800180703
039900000000       // start of loop to read all the messages
040000180711       DoW CompletionCode <> CCFAIL and Buffer <> *BLANKS;
040100000000
040200000000         // MsgId and CorrelId are selectors that must be cleared
040300000000         // to get messages in sequence, and they are set each MQGET
040400000000         MQMD.MDMID = MINONE;
040500000000         MQMD.MDCID = CINONE;
040600000000
040700000000         // clear buffer because MQGET only fills to length of message
040800000000         Buffer = *BLANKS;
040900180702
041000180702       //***************************************************************
041100180702       //   Get messages from message queue                            *
041200180702       //***************************************************************
041300000000
041400000000         MQGET(HConn : HObj : MQMD : MQGMO :  BufferLength : %ADDR(Buffer) :
041500000000               MessageLength : CompletionCode : Reason);
041600000000
041700000000         // report reason, if any
041800000000         Select;
041900000000           When Reason = RCNONE;
042000000000
042100000000           When Reason = RC2033;
042200000000
042300000000           Other;
042400180712              Clear ErrorDS;
042500180712              PROGRAMNAME = PGMNAME;
042600180712              MSGID       = 'ICC6900';
042700180712              FILENAME    = *Blanks;
042800180712              OPCODE      = 'MQOPEN';
042900180712              STATUS      = Reason;
043000180712              EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
043100180712                            'Unable to perform MQGET operation. ' +
043200180712                            'ReasonCode' + %Char(Reason);
043300180712              ERROR       = ERRORDS;
043400180712              IOERRS(ERROR);
043500180712              MSG_ID      = 'RBT8015';
043600180712              MSG_DTA     = 'EDIMQRSPR1: Unable to perform MQGET operation. ' +
043700180712                            'ReasonCode' + %Char(Reason);
043800180712              EXSR SND_ROBOT;
043900180703
044000180621             *INLR = *ON;
044100180621             RETURN;
044200000000         EndSl;
044300180622
044400180703         If CompletionCode <> CCFAIL;
044500180622
044600180703            EXSR MovTmpEDI;
044700180703
044800180703            $Options  = 'case=any +
044900180703                      allowextra=yes +
045000180703                      allowmissing=yes +
045100180703                      ns=remove +
045200180703                      nsprefix=ns_ +
045300180703                      path=Envelope/Body/AcknowledgeInvoice/ApplicationArea/' +
045400180703                      'Application/ApplicationStatus';
045500180703            XML-INTO ApplicationStatus %XML(Buffer : $Options);
045600180703
045700180703            $Options  = 'case=any +
045800180703                         allowextra=yes +
045900180703                         allowmissing=yes +
046000180703                         ns=remove +
046100180703                         nsprefix=ns_ +
046200180703                         path=Envelope/Header/RelatesTo';
046300180703            XML-INTO GetCorID %XML(Buffer : $Options);
046400180703
046500180703            GetCorID_DS = GetCorID;
046600180703
046700180712            $Options  = 'case=any +
046800180712                         allowextra=yes +
046900180712                         allowmissing=yes +
047000180712                         ns=remove +
047100180712                         nsprefix=ns_ +
047200180712                         path=Envelope/Body/AcknowledgeInvoice/' +
047300180712                         'DataArea/Invoice/Header/Parties/SupplierParty' +
047400180712                         '/Addresses/PrimaryAddress/Country';
047500180712            XML-INTO Country %XML(Buffer : $Options);
047600180712
047700180712            $Options  = 'case=any +
047800180712                         allowextra=yes +
047900180712                         allowmissing=yes +
048000180712                         ns=remove +
048100180712                         nsprefix=ns_ +
048200180712                         path=Envelope/Body/AcknowledgeInvoice/' +
048300180712                         'DataArea/Invoice/Header/DocumentIds/' +
048400180712                         'SupplierDocumentId/Id';
048500180712            XML-INTO Id %XML(Buffer : $Options);
048600180712
048700180712            $Options  = 'case=any +
048800180712                         allowextra=yes +
048900180712                         allowmissing=yes +
049000180712                         ns=remove +
049100180712                         nsprefix=ns_ +
049200180712                         path=Envelope/Body/AcknowledgeInvoice/' +
049300180712                         'DataArea/Invoice/Header/DocumentDateTime';
049400180712            XML-INTO DocumentDateTime %XML(Buffer : $Options);
049500180712
049600180712            Invoice_Date = %Date(DocumentDateTime: *iso);
049700180712
049800180704            Select;
049900180704            When ApplicationStatus.StatusId = 'SUCCESS';
050000180704
050100180703            exec sql
050200180703               update invoice_control
050300180704               set mq_res_timestamp = :WWTIMESTAMP,
050400180704               gcms_response = 'S',
050500180704               last_update_id = :PGMUSER ,
050600180704               last_update_timestamp = :WWTIMESTAMP
050700180704               where mq_msg_id = :Buffer_CorID and
050800180704               country_code = :Country         and
050900180705               invoice_num = :Id               and
051000180705               invoice_date = :Invoice_Date    and
051100180704               mq_res_timestamp is null;
051200180709
051300180709            If SqlCode <> 0 and SqlCode <> 100;
051400180710               Clear ErrorDS;
051500180709               PROGRAMNAME = PGMNAME;
051600180709               MSGID       = 'ICC6700';
051700180709               FILENAME = 'INVOI00001';
051800180709               OPCODE   = 'Update';
051900180709               STATUS   = SQLCODE;
052000180709               EXTMSG='UPDATE- Error occurred for: '
052100180709                      +%trim(Id) + ' ' + %CHAR(Invoice_Date);
052200180711               ERROR = ERRORDS;
052300180711               IOERRS(ERROR);
052400180712               MSG_ID = 'RBT8015';
052500180712               MSG_DTA = 'EDIMQRSPR1: Error occurred while writing/updating' +
052600180712                         'BATCH_CONTROL file for invoice: ' +
052700180712                         %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
052800180709               EXSR SND_ROBOT;
052900180709            EndIf;
053000180704
053100180706            Other;
053200180704                 n = 1;
053300180705                 DoU ApplicationStatus.ErrorDescription(n) = *Blanks;
053400180704                     If %Scan('Duplicate Invoice'
053500180705                              :ApplicationStatus.ErrorDescription(n)) <> 0;
053600180705                        Response_GCMS = 'D';
053700180705                     Else;
053800180705                        Response_GCMS = 'E';
053900180704                     EndIf;
054000180704
054100180705                     WErrNote = %Trim(WErrNote) +
054200180705                                ApplicationStatus.ErrorDescription(n);
054300180704                     n= n+1;
054400180704                 EndDo;
054500180704
054600180704                 EXSR CrtCFEXML;
054700180704
054800180704                 exec sql
054900180704                 update invoice_control
055000180704                 set mq_res_timestamp = :WWTIMESTAMP ,
055100180704                 gcms_response = :Response_GCMS ,
055200180704                 last_update_id = :PGMUSER ,
055300180704                 last_update_timestamp = :WWTIMESTAMP
055400180704                 where mq_msg_id = :Buffer_CorID;
055500180709
055600180709                 If SqlCode <> 0 and SqlCode <> 100;
055700180710                    Clear ErrorDS;
055800180709                    PROGRAMNAME = PGMNAME;
055900180709                    MSGID       = 'ICC6700';
056000180709                    FILENAME = 'INVOI00001';
056100180709                    OPCODE   = 'Update';
056200180709                    STATUS   = SQLCODE;
056300180709                    EXTMSG='UPDATE- Error occurred for: '
056400180709                           +%trim(Id) + ' ' + %CHAR(Invoice_Date);
056500180711                    ERROR = ERRORDS;
056600180710                    IOERRS(ERRORDS);
056700180709                    MSG_ID = 'RBT8006';
056800180712                    MSG_DTA = 'EDIMQRSPR1: Error occurred while writing' +
056900180712                         '/updating BATCH_CONTROL file for invoice: ' +
057000180712                         %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
057100180709                    EXSR SND_ROBOT;
057200180709                 EndIf;
057300180706            EndSl;
057400180706
057500000000         // end DO-while loop; MQI failure causes loop to end
057600180706         EndIf;
057700180706       EndDo;
057800180704
057900180706       *INLR = *ON;
058000180706       RETURN;
058100180706
058200000000       //***************************************************************
058300000000       //                                                              *
058400000000       //   Close the source queue (if it was opened)                  *
058500000000       //                                                              *
058600000000       //***************************************************************
058700180706        If OpenCode <> CCFAIL;
058800180703          Options = CONONE;
058900180703          MQCLOSE(HConn : HObj : Options :  CompletionCode : Reason);
059000000000
059100180703         // report reason, if any, resulting from this call
059200180703          If Reason <> RCNONE;
059300180703
059400180712             Clear ErrorDS;
059500180712             PROGRAMNAME = PGMNAME;
059600180712             MSGID       = 'ICC6900';
059700180712             FILENAME = *Blanks;
059800180712             OPCODE   = 'MQCLOSE';
059900180712             STATUS   = Reason;
060000180712             EXTMSG='GCMS EDI RESPONSE ERROR: ' +
060100180712                    'Unable to close the Queue. ' +
060200180712                    'ReasonCode' + %Char(Reason);
060300180712             ERROR = ERRORDS;
060400180712             IOERRS(ERRORDS);
060500180712             MSG_ID = 'RBT8015';
060600180712             MSG_DTA     = 'EDIMQRSPR1: Unable to close the Queue. ' +
060700180712                           'ReasonCode' + %Char(Reason);
060800180712             EXSR SND_ROBOT;
060900180703          EndIf;
061000000000
061100000000         // end if (OpenCode not CCFAIL)
061200180706        EndIf;
061300000000
061400000000       //***************************************************************
061500000000       //                                                              *
061600000000       //  Disconnect from queue manager (if not previously connected) *
061700000000       //                                                              *
061800000000       //***************************************************************
061900180706        If ConnReason <> RC2002;
062000180703          MQDISC(HConn : CompletionCode : Reason);
062100000000
062200180703       // report reason and stop if it failed
062300180709          If CompletionCode = CCFAIL;
062400180712             Clear ErrorDS;
062500180712             PROGRAMNAME = PGMNAME;
062600180712             MSGID       = 'ICC6900';
062700180712             FILENAME = *Blanks;
062800180712             OPCODE   = 'MQDISC';
062900180712             STATUS   = Reason;
063000180712             EXTMSG='GCMS EDI RESPONSE ERROR: Unable to disconnect MQ. ' +
063100180712                    'ReasonCode' + %Char(Reason);
063200180712             ERROR = ERRORDS;
063300180712             IOERRS(ERRORDS);
063400180712             MSG_ID = 'RBT8015';
063500180712             MSG_DTA  = 'EDIMQRSPR1: Unable to disconnect MQ. ' +
063600180712                        'ReasonCode' + %Char(Reason);
063700180712             EXSR SND_ROBOT;
063800180709          EndIf;
063900180706        EndIf;
064000180703
064100180704       //***************************************************************
064200180704       //   Subroutine to write XML Response to IFS file               *
064300180704       //***************************************************************
064400180703       Begsr MovTmpEDI;
064500180709         fd  = open(%trim($file_path)
064600180709                  : O_WRONLY+O_CREAT+O_TRUNC
064700180709                  : S_IRGRP + S_IWGRP + S_IXGRP +
064800180709                    S_IRUSR + S_IWUSR + S_IXUSR+S_IROTH+S_IXOTH);
064900180709
065000180709         callp close(fd);
065100180709
065200180703         fd = open(%trim($file_path)
065300180703                  :O_WRONLY+O_TEXTDATA);
065400180703
065500180703       // Write xml buffer into IFS
065600180703         callp write(fd:%addr(Buffer): %len(%trim(Buffer)));
065700180703         callp close(fd);
065800180703
065900180703         $New_File = %trim($Arc_Dir) + 'EDIXMLRSP'+ %char(WWDATE) +
066000180703                           %char(WWTIME);
066100180703
066200180703       // Clear old XML log history
066300180703         fd  = open(%trim($New_File)
066400180703                   : O_WRONLY+O_CREAT+O_TRUNC
066500180703                   : S_IRGRP + S_IWGRP + S_IXGRP +
066600180706                   S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
066700180703                   : 819);
066800180703         callp close(fd);
066900180703
067000180703       // Create EDI xml history
067100180703         fd = open(%trim($New_File)
067200180703                   :O_WRONLY+O_TEXTDATA);
067300180703       // Write EDIXML buffer into IFS archive
067400180703         callp(e) write(fd:%addr(Buffer): %len(%trim(Buffer)));
067500180703         callp close(fd);
067600180703
067700180703       Endsr;
067800180704
067900180704       //***************************************************************
068000180704       //   Subroutine to write CM Error Worklist and Content Manager  *
068100180704       //***************************************************************
068200180704       Begsr CrtCFEXML;
068300180712
068400180712       //   Get Object ID & Control Num from Invoice Control File
068500180712       exec sql
068600180712          select CM_OBJECT_ID, CONTROL_NUM
068700180712          into :ObjId, :CTRNUM
068800180712          from Invoice_Control
068900180712          where mq_msg_id = :Buffer_CorID;
069000180712
069100180712
069200180712          If SqlCode <> 0 and SqlCode <> 100;
069300180712             Clear ErrorDS;
069400180712             PROGRAMNAME = PGMNAME;
069500180712             MSGID       = 'ICC6700';
069600180713             FILENAME = 'INVOI00001';
069700180713             OPCODE   = 'Select';
069800180712             STATUS   = SQLCODE;
069900180712             EXTMSG='INSERT- Error occurred for: '
070000180712                    +%trim(Id) + ' ' + %CHAR(Invoice_Date);
070100180712             ERROR = ERRORDS;
070200180712             IOERRS(ERRORDS);
070300180712             MSG_ID = 'RBT8006';
070400180712             MSG_DTA = 'EDIMQRSPR1: Error occurred while inserting ' +
070500180712                       'Error record into EDIPF5 for Invoice: ' +
070600180712                       %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
070700180712             EXSR SND_ROBOT;
070800180712          EndIf;
070900180712
071000180704      * PART1 -------------------------------------
071100180704          wAPPLID = 'CFE';
071200180710          If Country = 'US' and Response_GCMS = 'D';
071300180704          Else;
071400180704          // Put Object ID in CM Error Worklist
071500180704             WSOPER  = 'StartWorkflow';
071600180704             ErrNote = *Blanks;
071700180704             RETCODE = '00';
071800180706             SYSNAME = 'DEVAS400';
071900180711      // Generate xml for StartWorkflow
072000180706             WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
072100180710                       PgmLib: SYSNAME: ErrNote: RETCODE);
072200180704
072300180704             If RETCODE='00';
072400180704                WRETCODE = '00';
072500180710                WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
072600180706                         WRETCODE);
072700180711                If WRETCODE = '98';
072800180711                   MSGVAR = 'Error  : ' +
072900180711                            'Adding to worklist for ' +
073000180711                            'invoice number/Objectid: '  +
073100180711                             %TRIMR(Id)+' / '+ %TRIM(OBJID);
073200180711                   EXSR WRITEPF5;
073300180711                EndIf;
073400180704             Endif;
073500180704          Endif;
073600180704
073700180710      * PART2 -------------------------------------
073800180710          WSOPER  = 'AddNotelog';
073900180710          ErrNote = WErrNote;
074000180710          RETCODE = '00';
074100180710          SYSNAME = 'DEVAS400';
074200180710
074300180710      * Generate xml for AddNotelog
074400180710          WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
074500180710                    PgmLib: SYSNAME: ErrNote: RETCODE);
074600180710
074700180710          If RETCODE='00';
074800180710             WRETCODE = '00';
074900180710             WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
075000180710                      WRETCODE);
075100180711             If WRETCODE = '98';
075200180711                MSGVAR = 'Error  : ' +
075300180711                         'Adding to Notelog for ' +
075400180711                         'invoice number/Objectid: '  +
075500180711                         %TRIMR(Id)+' / '+ %TRIM(ObjId);
075600180711                EXSR WRITEPF5;
075700180711             EndIf;
075800180710          EndIf;
075900180704       ENDSR;
076000180704
076100180709      **********************************************************************
076200180709      * Subroutine to send ROBOT error messages
076300180709      **********************************************************************
076400180709       Begsr SND_ROBOT;
076500180709          SNDROBOT(MSG_Q: MSG_ID: MSG_DTA: MSG_TYP);
076600180709       Endsr;
076700180711
076800180711      ***********************************************************************
076900180711      * Write error messages
077000180711      ***********************************************************************
077100180711       Begsr WRITEPF5;
077200180711       //   Get Member Name and Sender Identifier from EDIPF6
077300180711          exec sql
077400180711             select E6MBRNAM, E6SNDIND
077500180711             into :MBRNAME, :SNDIND
077600180711             from EDIPF6
077700180713             where E6SEQNUM = :CTRNUM;
077800180711
077900180712          If SqlCode <> 0 and SqlCode <> 100;
078000180712             Clear ErrorDS;
078100180712             PROGRAMNAME = PGMNAME;
078200180712             MSGID       = 'ICC6700';
078300180712             FILENAME = 'EDIPF6';
078400180712             OPCODE   = 'Select';
078500180712             STATUS   = SQLCODE;
078600180712             EXTMSG='SELECT- Error occurred for: '
078700180712                    +%trim(Id) + ' ' + %CHAR(Invoice_Date);
078800180712             ERROR = ERRORDS;
078900180712             IOERRS(ERRORDS);
079000180712             MSG_ID = 'RBT8006';
079100180712             MSG_DTA = 'EDIMQRSPR1: Error occurred while fetching ' +
079200180712                       'Member Name and Sender Identifier for Invoice: ' +
079300180712                       %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
079400180712             EXSR SND_ROBOT;
079500180712          EndIf;
079600180712
079700180713        //exec sql
079800180713        //   insert into EDIPF5
079900180713        //   (E5MBRNAM,  E5SNDIND, E5CTRNUM, E5RUNDATE, E5RUNTIME,
080000180713        //    E5COUNTRY, E5INVNO,  E5INVTYP, E5MSGID,   E5MSGVAR)
080100180713        //   values(:MBRNAME, :SNDIND, :CTRNUM, :WWDATE, :WWTIME,
080200180713        //          :Country, :Id,     ' ',     ' ',     :MSGVAR);
080300180712
080400180713             E5MBRNAM  =  MBRNAME;
080500180713             E5SNDIND  =  SNDIND ;
080600180713             E5CTRNUM  =  CTRNUM ;
080700180713             E5RUNDATE =  WWDATE ;
080800180713             E5RUNTIME =  WWTIME ;
080900180713             E5COUNTRY =  Country;
081000180713             E5INVNO   =  Id     ;
081100180713             E5INVTYP  =  *Blanks;
081200180713             E5MSGID   =  *Blanks;
081300180713             E5MSGVAR  =  MSGVAR ;
081400180713             WRITE     EDIPF5R   ;
081500180713
081600180712          If SqlCode <> 0 and SqlCode <> 100;
081700180712             Clear ErrorDS;
081800180712             PROGRAMNAME = PGMNAME;
081900180712             MSGID       = 'ICC6700';
082000180712             FILENAME = 'EDIPF5';
082100180712             OPCODE   = 'Insert';
082200180712             STATUS   = SQLCODE;
082300180712             EXTMSG='INSERT- Error occurred for: '
082400180712                    +%trim(Id) + ' ' + %CHAR(Invoice_Date);
082500180712             ERROR = ERRORDS;
082600180712             IOERRS(ERRORDS);
082700180712             MSG_ID = 'RBT8006';
082800180712             MSG_DTA = 'EDIMQRSPR1: Error occurred while inserting ' +
082900180712                       'Error record into EDIPF5 for Invoice: ' +
083000180712                       %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
083100180712             EXSR SND_ROBOT;
083200180712          EndIf;
083300180711
083400180711       Endsr;
083500180711
083600180711      /End-Free
