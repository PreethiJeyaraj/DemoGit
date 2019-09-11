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
010200180723     D ObjId           S             26A
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
012500180718     DPgmLib           S             10A   Inz
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
015400180713      * Sequence Number
015500180713     DSEQNUM           S             10I 0
015600180706
015700180713      * Control Number
015800180713     DCTRNUM           S             10A
015900180713
016000180711      * MESSAGE VARIABLE
016100180711     DMSGVAR           S            256A
016200180711
016300180711      * Error Details to LOGIOERRS
016400180711     DERROR            S            136A
016500180711
016600180718      * Command parameter to QCMDEXC
016700180718     Dcmd              S            200A
016800180718
016900180718      * MQ Retry Count
017000180718     DMQCNT            S              3I 0
017100180718
017200180711      * Declare MQI structures needed
017300180711      * MQI named constants
017400180703     D/COPY CMQG
017500000000
017600180709      * Define ROBOT work fields
017700180709     DMSG_Q            S             10A   INZ(*BLANKS)
017800180709     DMSG_ID           S              7A   INZ(*BLANKS)
017900180709     DMSG_DTA          S            256A   INZ(*BLANKS)
018000180709     DMSG_TYP          S              1A   INZ('I')
018100180709
018200180711      * Object Descriptor
018300180703     D MQOD            DS                  Qualified
018400000000     D/COPY CMQODG
018500000000
018600180711      * Message Descriptor
018700180703     D MQMD            DS                  Qualified
018800000000     D/COPY CMQMDG
018900000000
019000180711      * Get message options
019100180703     D MQGMO           DS                  Qualified
019200000000     I/COPY CMQGMOG
019300000000
019400180622     D/copy *libl/qrpglesrc,IFSIO_H
019500180622
019600180711      * Get Correlation ID from XML Response
019700180703     D GetCorID_DS     DS                  Inz
019800180703     D Cor_Prefix                     4A
019900180703     D Buffer_CorID                  80A
020000180703
020100180711      * Get Status ID and Error details from XML Response
020200180703     D ApplicationStatus...
020300180703     D                 DS                  Qualified
020400180703     D StatusId                      10A
020500180703     D ErrorCode                     50A
020600180703     D ErrorDescription...
020700180727     D                              256A   Dim(50)
020800180703     D ErrorDataname                 50A
020900180711
021000180711      * Get Invoice Date from XML Response
021100180711     DDocumentDateTime...
021200180711     D                 S             10A
021300180703
021400180711      * Program Status Data Structure
021500180703     DPSDS            SDS
021600180705     DPGMNAME                  1     10A
021700180709     DPGMSTS                  11     15S 0
021800180709     DPGMMSGID                40     46A
021900180709     DPGMERRDTA               91    170A
022000180703     DPGMUSER                254    263A
022100180705
022200180705      * ERROR LOG data structure
022300180705     DERRORDS          DS                  INZ
022400180705     DMSGID                           7A
022500180705     DPROGRAMNAME                    10A
022600180705     DFILENAME                        8A
022700180705     DOPCODE                          6A
022800180705     DSTATUS                          5S 0
022900180705     DEXTMSG                        100A
023000180705
023100180705      * File data structure for file: EDIPF14
023200180705     DPF14DS           DS
023300180705     DPF14FIL            *FILE
023400180705     DPF14OPN                  9      9
023500180705     DPF14INP            *INP
023600180705     DPF14MOD            *MODE
023700180705     DPF14OUT            *OUT
023800180705     DPF14OPC            *OPCODE
023900180705     DPF14SIZ            *SIZE
024000180705     DPF14FST            *STATUS
024100180705     DPF14RCD            *RECORD
024200180705     DPF14RTN            *ROUTINE
024300180706
024400180706      * File data structure for file: MQOUTHP
024500180706     DMQHSDS           DS
024600180706     DMQHSFIL            *FILE
024700180706     DMQHSOPN                  9      9
024800180706     DMQHSINP            *INP
024900180706     DMQHSMOD            *MODE
025000180706     DMQHSOUT            *OUT
025100180706     DMQHSOPC            *OPCODE
025200180706     DMQHSSIZ            *SIZE
025300180706     DMQHSFST            *STATUS
025400180706     DMQHSRCD            *RECORD
025500180706     DMQHSRTN            *ROUTINE
025600180706
025700180711      * Prototype for WSCLIENT
025800180709     DWSCLIENT         PR                  ExtPgm('WSCLIENT')
025900180706     DwAPPLID                         5A
026000180706     DId                             22A
026100180718     DPgmLib                         10A
026200180706     DSYSNAME                         8A
026300180706     DWRETCODE                        2A
026400180706
026500180711      * Prototype for WSCFEIMPR
026600180709     DWSCFEIMPR        PR                  ExtPgm('WSCFEIMPR')
026700180706     DwAPPLID                         5A
026800180706     DWSOPER                         50A
026900180706     DId                             22A
027000180723     DObjId                          26A
027100180718     DPgmLib                         10A
027200180706     DSYSNAME                         8A
027300180706     DErrNote                       256A
027400180706     DRETCODE                         2A
027500180706
027600180711      * Prototype for SNDROBOT
027700180710     DSNDROBOT         PR                  ExtPgm('SNDROBOT')
027800180709     DMSG_Q                          10A
027900180709     DMSG_ID                          7A
028000180709     DMSG_DTA                       256A
028100180709     DMSG_TYP                         1A
028200180709
028300180713      * Prototype for GETSYSNAME
028400180713     DGETSYSNAME       PR                  ExtPgm('GETSYSNAME')
028500180713     DSYSNAME                         8A
028600180713
028700180711      * Prototype for LOGIOERRS
028800180711     DIOERRS           PR                  ExtProc('LOGIOERRS')
028900180713     DERROR                         136A
029000180705
029100180718      * Prototype for QCMDEXC
029200180718     DQCMDEXC          PR                  ExtPgm('QCMDEXC')
029300180718     Dcommand                     32702a   const options(*varsize)
029400180718     Dlen                            15p 5 const
029500180718     Digc                             3a   const options(*nopass)
029600180718
029700180711      * Prototype for EDIMQRSPR1
029800180709     DMain             PR                  ExtPgm('EDIMQRSPR1')
029900180718     DPrmPgmLib                      10A
030000000000
030100180711      * Prototype Interface for EDIMQRSPR1
030200180709     DMain             PI
030300180718     DPrmPgmLib                      10A
030400180622
030500000000      /Free
030600000000
030700180706       //***************************************************************
030800180706       //   Mainline Processing                                        *
030900180702       //***************************************************************
031000180706
031100180719       Exec Sql
031200180719         set OPTION COMMIT=*NONE;
031300180719
031400180713       GETSYSNAME(SYSNAME);
031500180713
031600180711       //   Get queue manager and Queue from EDIPF14                   *
031700180711       PgmLib = PrmPgmLib;
031800180713       CHAIN (SYSNAME: PgmLib: 'MQMANAGER') EDIPF14;
031900180711       IF %FOUND(EDIPF14);
032000180711          Qmgr = EDIXMLDATA;
032100180711       ENDIF;
032200180711
032300180702       //***************************************************************
032400180702       //   Connect to the queue manager                               *
032500180702       //***************************************************************
032600180718       MQCNT = 1;
032700180718       CompletionCode = CCFAIL;
032800180718       DOW CompletionCode = CCFAIL and MQCNT <= 5;
032900180718           MQCONN(Qmgr : HConn : CompletionCode : ConnReason);
033000180718           If CompletionCode = CCFAIL;
033100180718              MQCNT = MQCNT + 1;
033200180718              CMD = *BLANKS;
033300180718              cmd = 'DLYJOB DLY(300)';
033400180718              QCMDEXC(cmd: %len(cmd));
033500180718           EndIf;
033600180718       ENDDO;
033700180718
033800000000       // report reason and stop if it failed
033900000000       If CompletionCode = CCFAIL;
034000180712          Clear ErrorDS;
034100180712          PROGRAMNAME = PGMNAME;
034200180712          MSGID       = 'ICC6900';
034300180712          FILENAME    = *Blanks;
034400180712          OPCODE      = 'MQCONN';
034500180712          STATUS      = ConnReason;
034600180712          EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
034700180712                        'Unable to connect to to Queue Manager. ' +
034800180720                        'ReasonCode ' + %Char(ConnReason);
034900180712          ERROR       = ERRORDS;
035000180712          IOERRS(ERROR);
035100180712          MSG_ID      = 'RBT8015';
035200180712          MSG_DTA     = 'EDIMQRSPR1: Unable to connect to Queue Manager. ' +
035300180720                        'ReasonCode ' + %Char(ConnReason);
035400180712          EXSR SND_ROBOT;
035500180702
035600180702          *INLR = *ON;
035700180702          RETURN;
035800000000       EndIf;
035900000000
036000000000       //***************************************************************
036100000000       //   Open the named message queue for input (and fail if MQM    *
036200000000       //   is quiescing); exclusive or shared use of the queue is     *
036300000000       //   controlled by the queue definition here                    *
036400000000       //                                                              *
036500000000       //   Resulting queue handle is HObj                             *
036600000000       //***************************************************************
036700000000
036800180713       CHAIN (SYSNAME: PgmLib: 'MQINNAME') EDIPF14;
036900180703       IF %FOUND(EDIPF14);
037000180703          Queue = EDIXMLDATA;
037100180703       ENDIF;
037200180703
037300000000       //***************************************************************
037400000000       //   Create object descriptor for source queue                  *
037500000000       //***************************************************************
037600000000       MQOD.ODON = Queue;
037700000000
037800000000       // options are input-as-queue-def and fail-if-quiescing
037900000000       Options = OOINPQ + OOFIQ;
038000000000
038100180718       MQCNT = 1;
038200180718       OpenCode = CCFAIL;
038300180718       DOW OpenCode = CCFAIL and MQCNT <= 5;
038400180718           MQOPEN(HConn : MQOD : Options : HObj : OpenCode : Reason);
038500000000
038600180718           If OpenCode = CCFAIL;
038700180718              MQCNT = MQCNT + 1;
038800180718              CMD = *BLANKS;
038900180718              CMD = 'DLYJOB DLY(300)';
039000180718              QCMDEXC(cmd: %len(cmd));
039100180718           EndIf;
039200180718       ENDDO;
039300000000       // report reason, if any; stop if failed
039400000000
039500000000       If OpenCode = CCFAIL;
039600180712          Clear ErrorDS;
039700180712          PROGRAMNAME = PGMNAME;
039800180712          MSGID       = 'ICC6900';
039900180712          FILENAME    = *Blanks;
040000180712          OPCODE      = 'MQOPEN';
040100180712          STATUS      = Reason;
040200180712          EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
040300180712                        'Unable to open queue for get operation. ' +
040400180720                        'ReasonCode ' + %Char(Reason);
040500180712          ERROR       = ERRORDS;
040600180712          IOERRS(ERROR);
040700180712          MSG_ID      = 'RBT8015';
040800180712          MSG_DTA     = 'EDIMQRSPR1: Unable to open queue for get operation ' +
040900180720                        'ReasonCode ' + %Char(Reason);
041000180712          EXSR SND_ROBOT;
041100180702
041200180702          *INLR = *ON;
041300180702          RETURN;
041400000000       EndIf;
041500000000
041600180712       //***************************************************************
041700180702       //   Get IFS Path from EDIPF14 to save MQ XML response          *
041800180702       //***************************************************************
041900180713       CHAIN (SYSNAME: PgmLib: 'EDIIFSOUT') EDIPF14;
042000180702       IF %FOUND(EDIPF14);
042100180703          $File_Path = EDIXMLDATA;
042200180702       ENDIF;
042300180702
042400180709
042500180709       //   Get IFS Path from EDIPF14 to save MQ XML response
042600180713         CHAIN (SYSNAME: PgmLib: 'EDIIFSDIR') EDIPF14;
042700180709         IF %FOUND(EDIPF14);
042800180709            $Arc_Dir = EDIXMLDATA;
042900180709         ENDIF;
043000180709
043100000000       // initial loop condition is based on result of MQOPEN
043200000000       CompletionCode = OpenCode;
043300180622
043400180702       // option is to wait up to 15 seconds for next message
043500180702       MQGMO.GMOPT = GMWT;
043600180702       MQGMO.GMWI = 15000;
043700180702
043800180702       MQGMO.GMOPT += GMCONV;
043900180702
044000180703       // initial loop condition is based on result of MQOPEN
044100180703       CompletionCode = OpenCode;
044200180703
044300000000       // start of loop to read all the messages
044400180711       DoW CompletionCode <> CCFAIL and Buffer <> *BLANKS;
044500000000
044600000000         // MsgId and CorrelId are selectors that must be cleared
044700000000         // to get messages in sequence, and they are set each MQGET
044800000000         MQMD.MDMID = MINONE;
044900000000         MQMD.MDCID = CINONE;
045000000000
045100000000         // clear buffer because MQGET only fills to length of message
045200000000         Buffer = *BLANKS;
045300180702
045400180702       //***************************************************************
045500180702       //   Get messages from message queue                            *
045600180702       //***************************************************************
045700000000
045800000000         MQGET(HConn : HObj : MQMD : MQGMO :  BufferLength : %ADDR(Buffer) :
045900000000               MessageLength : CompletionCode : Reason);
046000000000
046100000000         // report reason, if any
046200000000         Select;
046300000000           When Reason = RCNONE;
046400000000
046500000000           When Reason = RC2033;
046600000000
046700000000           Other;
046800180712              Clear ErrorDS;
046900180712              PROGRAMNAME = PGMNAME;
047000180712              MSGID       = 'ICC6900';
047100180712              FILENAME    = *Blanks;
047200180712              OPCODE      = 'MQOPEN';
047300180712              STATUS      = Reason;
047400180712              EXTMSG      = 'GCMS EDI RESPONSE ERROR: ' +
047500180712                            'Unable to perform MQGET operation. ' +
047600180720                            'ReasonCode ' + %Char(Reason);
047700180712              ERROR       = ERRORDS;
047800180712              IOERRS(ERROR);
047900180712              MSG_ID      = 'RBT8015';
048000180712              MSG_DTA     = 'EDIMQRSPR1: Unable to perform MQGET operation. ' +
048100180720                            'ReasonCode ' + %Char(Reason);
048200180712              EXSR SND_ROBOT;
048300180703
048400180621             *INLR = *ON;
048500180621             RETURN;
048600000000         EndSl;
048700180622
048800180731         If CompletionCode <> CCFAIL and MQMD.MDFMT = FMSTR;
048900180622
049000180703            EXSR MovTmpEDI;
049100180703
049200180703            $Options  = 'case=any +
049300180703                      allowextra=yes +
049400180703                      allowmissing=yes +
049500180703                      ns=remove +
049600180703                      nsprefix=ns_ +
049700180703                      path=Envelope/Body/AcknowledgeInvoice/ApplicationArea/' +
049800180703                      'Application/ApplicationStatus';
049900180703            XML-INTO ApplicationStatus %XML(Buffer : $Options);
050000180703
050100180703            $Options  = 'case=any +
050200180703                         allowextra=yes +
050300180703                         allowmissing=yes +
050400180703                         ns=remove +
050500180703                         nsprefix=ns_ +
050600180703                         path=Envelope/Header/RelatesTo';
050700180703            XML-INTO GetCorID %XML(Buffer : $Options);
050800180703
050900180703            GetCorID_DS = GetCorID;
051000180703
051100180712            $Options  = 'case=any +
051200180712                         allowextra=yes +
051300180712                         allowmissing=yes +
051400180712                         ns=remove +
051500180712                         nsprefix=ns_ +
051600180712                         path=Envelope/Body/AcknowledgeInvoice/' +
051700180712                         'DataArea/Invoice/Header/Parties/SupplierParty' +
051800180712                         '/Addresses/PrimaryAddress/Country';
051900180712            XML-INTO Country %XML(Buffer : $Options);
052000180712
052100180712            $Options  = 'case=any +
052200180712                         allowextra=yes +
052300180712                         allowmissing=yes +
052400180712                         ns=remove +
052500180712                         nsprefix=ns_ +
052600180712                         path=Envelope/Body/AcknowledgeInvoice/' +
052700180712                         'DataArea/Invoice/Header/DocumentIds/' +
052800180712                         'SupplierDocumentId/Id';
052900180712            XML-INTO Id %XML(Buffer : $Options);
053000180712
053100180712            $Options  = 'case=any +
053200180712                         allowextra=yes +
053300180712                         allowmissing=yes +
053400180712                         ns=remove +
053500180712                         nsprefix=ns_ +
053600180712                         path=Envelope/Body/AcknowledgeInvoice/' +
053700180712                         'DataArea/Invoice/Header/DocumentDateTime';
053800180712            XML-INTO DocumentDateTime %XML(Buffer : $Options);
053900180712
054000180712            Invoice_Date = %Date(DocumentDateTime: *iso);
054100180712
054200180704            Select;
054300180704            When ApplicationStatus.StatusId = 'SUCCESS';
054400180704
054500180703            exec sql
054600180703               update invoice_control
054700180704               set mq_res_timestamp = :WWTIMESTAMP,
054800180704               gcms_response = 'S',
054900180704               last_update_id = :PGMUSER ,
055000180704               last_update_timestamp = :WWTIMESTAMP
055100180704               where mq_msg_id = :Buffer_CorID and
055200180704               country_code = :Country         and
055300180705               invoice_num = :Id               and
055400180705               invoice_date = :Invoice_Date    and
055500180704               mq_res_timestamp is null;
055600180709
055700180709            If SqlCode <> 0 and SqlCode <> 100;
055800180710               Clear ErrorDS;
055900180709               PROGRAMNAME = PGMNAME;
056000180709               MSGID       = 'ICC6700';
056100180709               FILENAME = 'INVOI00001';
056200180709               OPCODE   = 'Update';
056300180709               STATUS   = SQLCODE;
056400180709               EXTMSG='UPDATE- Error occurred for: '
056500180709                      +%trim(Id) + ' ' + %CHAR(Invoice_Date);
056600180711               ERROR = ERRORDS;
056700180711               IOERRS(ERROR);
056800180712               MSG_ID = 'RBT8015';
056900180712               MSG_DTA = 'EDIMQRSPR1: Error occurred while writing/updating' +
057000180712                         'BATCH_CONTROL file for invoice: ' +
057100180712                         %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
057200180709               EXSR SND_ROBOT;
057300180709            EndIf;
057400180704
057500180706            Other;
057600180704                 n = 1;
057700180720                 WErrNote = *blanks;
057800180705                 DoU ApplicationStatus.ErrorDescription(n) = *Blanks;
057900180704                     If %Scan('Duplicate Invoice'
058000180705                              :ApplicationStatus.ErrorDescription(n)) <> 0;
058100180705                        Response_GCMS = 'D';
058200180705                     Else;
058300180705                        Response_GCMS = 'E';
058400180704                     EndIf;
058500180704
058600180727                     WErrNote = %Trim(WErrNote) + %Trim(
058700180727                                ApplicationStatus.ErrorDescription(n));
058800180704                     n= n+1;
058900180704                 EndDo;
059000180717
059100180717                 EXSR CrtCFEXML;
059200180718
059300180718                 exec sql
059400180718                 update invoice_control
059500180718                 set mq_res_timestamp = :WWTIMESTAMP ,
059600180718                 gcms_response = :Response_GCMS ,
059700180718                 last_update_id = :PGMUSER ,
059800180718                 last_update_timestamp = :WWTIMESTAMP
059900180718                 where mq_msg_id = :Buffer_CorID;
060000180718
060100180718                 If SqlCode <> 0 and SqlCode <> 100;
060200180718                    Clear ErrorDS;
060300180718                    PROGRAMNAME = PGMNAME;
060400180718                    MSGID       = 'ICC6700';
060500180718                    FILENAME = 'INVOI00001';
060600180718                    OPCODE   = 'Update';
060700180718                    STATUS   = SQLCODE;
060800180718                    EXTMSG='UPDATE- Error occurred for: '
060900180718                           +%trim(Id) + ' ' + %CHAR(Invoice_Date);
061000180718                    ERROR = ERRORDS;
061100180718                    IOERRS(ERRORDS);
061200180718                    MSG_ID = 'RBT8006';
061300180718                    MSG_DTA = 'EDIMQRSPR1: Error occurred while writing' +
061400180718                         '/updating BATCH_CONTROL file for invoice: ' +
061500180718                         %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
061600180718                    EXSR SND_ROBOT;
061700180718                 EndIf;
061800180706            EndSl;
061900180706
062000000000         // end DO-while loop; MQI failure causes loop to end
062100180706         EndIf;
062200180706       EndDo;
062300180704
062400180706       *INLR = *ON;
062500180706
062600000000       //***************************************************************
062700000000       //                                                              *
062800000000       //   Close the source queue (if it was opened)                  *
062900000000       //                                                              *
063000000000       //***************************************************************
063100180706        If OpenCode <> CCFAIL;
063200180703          Options = CONONE;
063300180703          MQCLOSE(HConn : HObj : Options :  CompletionCode : Reason);
063400000000
063500180703         // report reason, if any, resulting from this call
063600180703          If Reason <> RCNONE;
063700180703
063800180712             Clear ErrorDS;
063900180712             PROGRAMNAME = PGMNAME;
064000180712             MSGID       = 'ICC6900';
064100180712             FILENAME = *Blanks;
064200180712             OPCODE   = 'MQCLOSE';
064300180712             STATUS   = Reason;
064400180712             EXTMSG='GCMS EDI RESPONSE ERROR: ' +
064500180712                    'Unable to close the Queue. ' +
064600180720                    'ReasonCode ' + %Char(Reason);
064700180712             ERROR = ERRORDS;
064800180712             IOERRS(ERRORDS);
064900180712             MSG_ID = 'RBT8015';
065000180712             MSG_DTA     = 'EDIMQRSPR1: Unable to close the Queue. ' +
065100180720                           'ReasonCode ' + %Char(Reason);
065200180712             EXSR SND_ROBOT;
065300180703          EndIf;
065400000000
065500000000         // end if (OpenCode not CCFAIL)
065600180706        EndIf;
065700000000
065800000000       //***************************************************************
065900000000       //                                                              *
066000000000       //  Disconnect from queue manager (if not previously connected) *
066100000000       //                                                              *
066200000000       //***************************************************************
066300180706        If ConnReason <> RC2002;
066400180703          MQDISC(HConn : CompletionCode : Reason);
066500000000
066600180703       // report reason and stop if it failed
066700180709          If CompletionCode = CCFAIL;
066800180712             Clear ErrorDS;
066900180712             PROGRAMNAME = PGMNAME;
067000180712             MSGID       = 'ICC6900';
067100180712             FILENAME = *Blanks;
067200180712             OPCODE   = 'MQDISC';
067300180712             STATUS   = Reason;
067400180712             EXTMSG='GCMS EDI RESPONSE ERROR: Unable to disconnect MQ. ' +
067500180720                    'ReasonCode ' + %Char(Reason);
067600180712             ERROR = ERRORDS;
067700180712             IOERRS(ERRORDS);
067800180712             MSG_ID = 'RBT8015';
067900180712             MSG_DTA  = 'EDIMQRSPR1: Unable to disconnect MQ. ' +
068000180720                        'ReasonCode ' + %Char(Reason);
068100180712             EXSR SND_ROBOT;
068200180709          EndIf;
068300180706        EndIf;
068400180703
068500180704       //***************************************************************
068600180704       //   Subroutine to write XML Response to IFS file               *
068700180704       //***************************************************************
068800180703       Begsr MovTmpEDI;
068900180709         fd  = open(%trim($file_path)
069000180709                  : O_WRONLY+O_CREAT+O_TRUNC
069100180709                  : S_IRGRP + S_IWGRP + S_IXGRP +
069200180709                    S_IRUSR + S_IWUSR + S_IXUSR+S_IROTH+S_IXOTH);
069300180709
069400180709         callp close(fd);
069500180709
069600180703         fd = open(%trim($file_path)
069700180703                  :O_WRONLY+O_TEXTDATA);
069800180703
069900180703       // Write xml buffer into IFS
070000180703         callp write(fd:%addr(Buffer): %len(%trim(Buffer)));
070100180703         callp close(fd);
070200180703
070300180703         $New_File = %trim($Arc_Dir) + 'EDIXMLRSP'+ %char(WWDATE) +
070400180703                           %char(WWTIME);
070500180703
070600180703       // Clear old XML log history
070700180703         fd  = open(%trim($New_File)
070800180703                   : O_WRONLY+O_CREAT+O_TRUNC
070900180703                   : S_IRGRP + S_IWGRP + S_IXGRP +
071000180706                   S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
071100180703                   : 819);
071200180703         callp close(fd);
071300180703
071400180703       // Create EDI xml history
071500180703         fd = open(%trim($New_File)
071600180703                   :O_WRONLY+O_TEXTDATA);
071700180703       // Write EDIXML buffer into IFS archive
071800180703         callp(e) write(fd:%addr(Buffer): %len(%trim(Buffer)));
071900180703         callp close(fd);
072000180703
072100180703       Endsr;
072200180704
072300180704       //***************************************************************
072400180704       //   Subroutine to write CM Error Worklist and Content Manager  *
072500180704       //***************************************************************
072600180704       Begsr CrtCFEXML;
072700180712
072800180712       //   Get Object ID & Control Num from Invoice Control File
072900180712       exec sql
073000180712          select CM_OBJECT_ID, CONTROL_NUM
073100180713          into :ObjId, :SEQNUM
073200180712          from Invoice_Control
073300180712          where mq_msg_id = :Buffer_CorID;
073400180712
073500180712
073600180712          If SqlCode <> 0 and SqlCode <> 100;
073700180712             Clear ErrorDS;
073800180712             PROGRAMNAME = PGMNAME;
073900180712             MSGID       = 'ICC6700';
074000180713             FILENAME = 'INVOI00001';
074100180713             OPCODE   = 'Select';
074200180712             STATUS   = SQLCODE;
074300180712             EXTMSG='INSERT- Error occurred for: '
074400180712                    +%trim(Id) + ' ' + %CHAR(Invoice_Date);
074500180712             ERROR = ERRORDS;
074600180712             IOERRS(ERRORDS);
074700180712             MSG_ID = 'RBT8006';
074800180712             MSG_DTA = 'EDIMQRSPR1: Error occurred while inserting ' +
074900180712                       'Error record into EDIPF5 for Invoice: ' +
075000180712                       %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
075100180712             EXSR SND_ROBOT;
075200180712          EndIf;
075300180712
075400180704      * PART1 -------------------------------------
075500180704          wAPPLID = 'CFE';
075600180719          ErrNote = *Blanks;
075700180710          If Country = 'US' and Response_GCMS = 'D';
075800180704          Else;
075900180704          // Put Object ID in CM Error Worklist
076000180704             WSOPER  = 'StartWorkflow';
076100180704             RETCODE = '00';
076200180711      // Generate xml for StartWorkflow
076300180706             WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
076400180710                       PgmLib: SYSNAME: ErrNote: RETCODE);
076500180704
076600180704             If RETCODE='00';
076700180704                WRETCODE = '00';
076800180710                WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
076900180706                         WRETCODE);
077000180718                Select;
077100180718                When WRETCODE = '00';
077200180718                   Response_GCMS = 'W';
077300180718                When WRETCODE = '98';
077400180711                   MSGVAR = 'Error  : ' +
077500180711                            'Adding to worklist for ' +
077600180711                            'invoice number/Objectid: '  +
077700180711                             %TRIMR(Id)+' / '+ %TRIM(OBJID);
077800180711                   EXSR WRITEPF5;
077900180718                EndSl;
078000180704             Endif;
078100180704          Endif;
078200180704
078300180718          CMD = *BLANKS;
078400180718          cmd = 'DLYJOB DLY(2)';
078500180718          QCMDEXC(cmd: %len(cmd));
078600180718
078700180710      * PART2 -------------------------------------
078800180710          WSOPER  = 'AddNotelog';
078900180719          ErrNote = WErrNote;
079000180710          RETCODE = '00';
079100180710
079200180710      * Generate xml for AddNotelog
079300180710          WSCFEIMPR(wAPPLID: WSOPER: Id: ObjId:
079400180710                    PgmLib: SYSNAME: ErrNote: RETCODE);
079500180710
079600180710          If RETCODE='00';
079700180710             WRETCODE = '00';
079800180710             WSCLIENT(wAPPLID: Id: PgmLib: SYSNAME:
079900180710                      WRETCODE);
080000180711             If WRETCODE = '98';
080100180711                MSGVAR = 'Error  : ' +
080200180711                         'Adding to Notelog for ' +
080300180711                         'invoice number/Objectid: '  +
080400180711                         %TRIMR(Id)+' / '+ %TRIM(ObjId);
080500180711                EXSR WRITEPF5;
080600180711             EndIf;
080700180710          EndIf;
080800180704       ENDSR;
080900180704
081000180709      **********************************************************************
081100180709      * Subroutine to send ROBOT error messages
081200180709      **********************************************************************
081300180709       Begsr SND_ROBOT;
081400180709          SNDROBOT(MSG_Q: MSG_ID: MSG_DTA: MSG_TYP);
081500180709       Endsr;
081600180711
081700180711      ***********************************************************************
081800180711      * Write error messages
081900180711      ***********************************************************************
082000180711       Begsr WRITEPF5;
082100180711       //   Get Member Name and Sender Identifier from EDIPF6
082200180711          exec sql
082300180713             select E6MBRNAM, E6SNDIND, E6CTRNUM
082400180713             into :MBRNAME, :SNDIND, :CTRNUM
082500180711             from EDIPF6
082600180713             where E6SEQNUM = :SEQNUM;
082700180711
082800180712          If SqlCode <> 0 and SqlCode <> 100;
082900180712             Clear ErrorDS;
083000180712             PROGRAMNAME = PGMNAME;
083100180712             MSGID       = 'ICC6700';
083200180712             FILENAME = 'EDIPF6';
083300180712             OPCODE   = 'Select';
083400180712             STATUS   = SQLCODE;
083500180712             EXTMSG='SELECT- Error occurred for: '
083600180712                    +%trim(Id) + ' ' + %CHAR(Invoice_Date);
083700180712             ERROR = ERRORDS;
083800180712             IOERRS(ERRORDS);
083900180712             MSG_ID = 'RBT8006';
084000180712             MSG_DTA = 'EDIMQRSPR1: Error occurred while fetching ' +
084100180712                       'Member Name and Sender Identifier for Invoice: ' +
084200180712                       %TRIM(Id) + ' ' + %CHAR(Invoice_Date);
084300180712             EXSR SND_ROBOT;
084400180712          EndIf;
084500180712
084600180713             E5MBRNAM  =  MBRNAME;
084700180713             E5SNDIND  =  SNDIND ;
084800180713             E5CTRNUM  =  CTRNUM ;
084900180713             E5RUNDATE =  WWDATE ;
085000180713             E5RUNTIME =  WWTIME ;
085100180713             E5COUNTRY =  Country;
085200180713             E5INVNO   =  Id     ;
085300180713             E5INVTYP  =  *Blanks;
085400180713             E5MSGID   =  *Blanks;
085500180713             E5MSGVAR  =  MSGVAR ;
085600180713             WRITE     EDIPF5R   ;
085700180711       Endsr;
085800180711
085900180711      /End-Free
