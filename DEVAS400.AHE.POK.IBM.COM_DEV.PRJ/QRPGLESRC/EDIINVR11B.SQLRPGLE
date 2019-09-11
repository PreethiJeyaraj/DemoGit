000100160707      ******************************************************************
000200170831      * Program name: EDIINVR11                                        *
000300160707      *                                                                *
000400170831      * Module name:  EDIINVR11                                        *
000500160707      *                                                                *
000600171212      * Description: Program to create EDI XML for MQ to GCMS          *
000700160707      *                                                                *
000800160707      * Calling program: EDIINVC4                                      *
000900160707      *                                                                *
001000160707      * Called programs: 1. LOGIOERRS - Std IGF error logging program  *
001100160707      * procedure/module                                               *
001200160707      *                                                                *
001300160707      * Files used: EDIPF5   - DETAIL ERROR FILE                       *
001400160707      *             EDIPF7   - MQ SERIES INTERFACE                     *
001500170831      *             EDIPF7A  - MQ SERIES INTERFACE WRK FIL-NON UPFRONT *
001600170831      *             EDIPF7B  - MQ SERIES INTERFACE TAX WRK FIL-UPFRONT *
001700160707      *             EDIPF14  - MQ SERIES INFORMATION FILE              *
001800160708      *             BATCHCTL - BATCH CONTROL FILE                      *
001900160707      *                                                                *
002000160707      * Special behevior: Calls Webservice routine for tax calculation *
002100160707      *                   Calls MQ to send to GCMS                     *
002200160707      *                                                                *
002300161206      * Compile as:  CRTRPGMOD MODULE(EDIINVR11)                       *
002400161206      *              SRCFILE(*CURLIB/QRPGLESRC)                        *
002500171107      *              BNDDIR(LIBHTTP/HTTPAPI)                           *
002600171212      *              COMMIT(*NONE)                                     *
002700171212      *              RPGPPOPT(*LVL1)                                   *
002800171212      *                                                                *
002900160707      * Messages: None                                                 *
003000160707      *                                                                *
003100160707      * Parameters: 1. PrmMbrName - Member name  (Incoming)            *
003200160707      *             2. PrmLibName - Library name  (Incoming)           *
003300161227      *             2. PrmSysId   - System name  (Incoming)            *
003400160707      *                                                                *
003500160707      * Change history:                                                *
003600160707      *                                                                *
003700160707      * Change  Reason      Date     Pgmr   Description                *
003800160707      * flag                                                           *
003900160707      * -----   ----------  ------   ----   ------------------------   *
004000170831      * @1607  GIP1478503 08/2017 UXH    Initial develpment - Rewrite  *
004100170831      *                                  EDI MQ from Java to iseries - *
004200170831      *                                  Create  EDIXML for GCMS       *
004300171107      * @1622  GIP1753146 10/2017 UXH    [ELS Canada] EDI changes for  *
004400171107      *                                  CA                            *
004500171220      * @1607a Defect     12/2017 UXH    Duplicate record to EDIPF7A   *
004600180124      * @1607b Def1799943 01/2018 UXH    GCMS Webservice - Invoice amt *
004700180124      *                                  doesn't match Total detail    *
004800180124      *                                  Line Amounts                  *
004900180218      * @1607c Def1807218 02/2018 UXH    Assign I0 to 0 tax line item  *
005000180218      *                                  for US                        *
005100180222      * @1607d Def1799968 02/2018 UXH    Correct Invoice index,        *
005200180222      *                                  multiply Detail unit price    *
005300180222      *                                  with quantity to populate     *
005400180222      *                                  detail line amount            *
005500180226      * @1607e Defect     02/2018 UXH    Tax Spreading logic           *
005600180305      * @UXH   Bug        03/2018 UXH    Fixing existing bug noticed   *
005700180309      * @1607f Def1822796 03/2018 UXH    EDI Canada - Tax only invoice *
005800180309      * @1607g Def1822767 03/2018 UXH    EDI Canada Inv failed in MQ   *
005900180312      *                                  due to XML parsing issue ,    *
006000180312      *                                  Initialize MQ msg id          *
006100180323      * @1607h Def1828407 03/2018 UXH    US-non-upfront state with tax-*
006200180323      *                                  Invoice/Detail amt mismatch   *
006300180411      * @1647  GIP1829905 04/2018  UXH   Invoke CFE Webservice for "Add*
006400180411      *                                  Notelog" ,"Startworkflow" call*
006500180423      * @1652  GIP1840625 04/2018  UXH   EDI-US Tax Code Change        *
006600180626      * @1672  GIP1865468 06/2018  UXH   MES # should load GCMS
006700180710      * @1622a Def1870995 07/2018  UXH   EID CA failing as tax sent
006800180710      *                                  at Line item level
006900180718      * @1647a Defect     07/2018  UXH   Regression testing defect -
007000180718      *                                  Lisa confirmed multi soldto
007100180718      *                                  not sent in EDI files
007200180816      * @def1  Prodissue  08/2018  UXH   Spell mistake for currency as
007300180816      *                                  curreny
007400180917      * @1685  GIP1896660 09/2018  UXH   EDI - Increase buffer length to
007500180917      *                                  send complete xml through MQ
007600180926      * @1687  GIP1901252 09/2018  UXH   EDI-Receiver value too small to
007700180926      *                                  hold result
007800181004      * @1687a DEF1905132 10/2018  UXH   Invoices with taxes failing with
007900181004      *                                  incorrect tax spread
008000181017      * @1691  GIP1909673 10/2018  UXH   Invoice failed in MQ as supplier
008100181017      *                                  name sent with special character
008200190128      * @1712  GIP1938436 01/2019  UXH   GAPTS YE issue - Do not tax spread
008300190128      *                                  if tax not within tolerance
008400160707     *******************************************************************
008500160707      *
008600160707     *****************************************************************
008700160707      *            Definition Specification
008800160707     *****************************************************************
008900180225      * H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('LIBHTTP/HTTPAPI')
009000180225      *
009100170831     FEDIPF14   IF   E           K DISK    INFDS(PF14DS)
009200160315     FEDIPF7    IF   E             DISK    INFDS(PF7INFDS)
009300161107     FEDIFRTCTL IF   E           K DISK
009400160601     FBATCH00001UF   E           K DISK    RENAME(BATCH00001:BATCHCTL)
009500160315     F                                     INFDS(BATCHINFDS)
009600160316     FEDIPF5    UF A E             DISK
009700180304     FEDIPF7A   UF A E           K DISK    INFDS(PF7ADS)
009800160329     F                                     USROPN
009900180202     FEDIPF7B   UF A E           K DISK    INFDS(PF7BDS)
010000160630     F                                     USROPN
010100170611     FMQOUTHP   UF A E             DISK    INFDS(MQHSDS)
010200180303     FVATVARPF  IF   E           K DISK
010300171212      *
010400170611      * File data structure for file: MQOUTHP
010500170611     DMQHSDS           DS
010600170611     DMQHSFIL            *FILE
010700170611     DMQHSOPN                  9      9
010800170611     DMQHSINP            *INP
010900170611     DMQHSMOD            *MODE
011000170611     DMQHSOUT            *OUT
011100170611     DMQHSOPC            *OPCODE
011200170611     DMQHSSIZ            *SIZE
011300170611     DMQHSFST            *STATUS
011400170611     DMQHSRCD            *RECORD
011500170611     DMQHSRTN            *ROUTINE
011600170611      *
011700171206      * File data structure for file: EDIPF7A
011800171206     DPF7ADS           DS
011900171206     DPF7AFIL            *FILE
012000171206     DPF7AOPN                  9      9
012100171206     DPF7AINP            *INP
012200171206     DPF7AMOD            *MODE
012300171206     DPF7AOUT            *OUT
012400171206     DPF7AOPC            *OPCODE
012500171206     DPF7ASIZ            *SIZE
012600171206     DPF7AFST            *STATUS
012700171206     DPF7ARCD            *RECORD
012800171206     DPF7ARTN            *ROUTINE
012900171206      *
013000171206      * File data structure for file: EDIPF7B
013100171206     DPF7BDS           DS
013200171206     DPF7BFIL            *FILE
013300171206     DPF7BOPN                  9      9
013400171206     DPF7BINP            *INP
013500171206     DPF7BMOD            *MODE
013600171206     DPF7BOUT            *OUT
013700171206     DPF7BOPC            *OPCODE
013800171206     DPF7BSIZ            *SIZE
013900171206     DPF7BFST            *STATUS
014000171206     DPF7BRCD            *RECORD
014100171206     DPF7BRTN            *ROUTINE
014200171206      *
014300170831      * File data structure for file: EDIPF14
014400170831     DPF14DS           DS
014500170831     DPF14FIL            *FILE
014600170831     DPF14OPN                  9      9
014700170831     DPF14INP            *INP
014800170831     DPF14MOD            *MODE
014900170831     DPF14OUT            *OUT
015000170831     DPF14OPC            *OPCODE
015100170831     DPF14SIZ            *SIZE
015200170831     DPF14FST            *STATUS
015300170831     DPF14RCD            *RECORD
015400170831     DPF14RTN            *ROUTINE
015500170831      *
015600170112      *
015700061220      * FILE HEADER data structure
015800160311      *
015900120119     DDSFILEHDR        DS
016000120119     DFHDRCDID                 1     10
016100160314     DFHDFILLER1              11     17
016200120119     DFHDSEQNUM               18     23
016300061220      *
016400061220      * CONTROL data structure
016500160314      *
016600120119     DDSCONTROL        DS
016700120119     DCNTRCDID                 1     10
016800160311     DCNTFILLER1              11     17
016900120119     DCNTSNDIND               18     47
017000120119     DCNTCTRNUM               48     57
017100061220      *
017200160315      * HEADER data structure
017300120119      *
017400120119     DDSHEADER         DS
017500120119     DHDRRCDID                 1     10
017600160311     DHDRFILLER1              11     17
017700120119     DHDRINVDAT               18     25
017800120119     DHDRINVNO                26     47
017900120119     DHDRREFINV               48     69
018000120119     DHDRREFDAT               70     77
018100120119     DHDRPONUM                78     99
018200160330     DHDRDBCRINDIC           100    101
018300160316     DHDRTOTAMT              102    111
018400120119     DHDRTRMCOD              112    131
018500120119     DHDRTRMDSC              132    156
018600120119     DHDRBLLCUS              157    171
018700120119     DHDRBLLNAM              172    206
018800120119     DHDRBLLAD1              207    241
018900120119     DHDRBLLAD2              242    276
019000120119     DHDRBLLCTY              277    306
019100120119     DHDRBLLSTA              307    308
019200120119     DHDRBLLZIP              309    318
019300120119     DHDRSHPCUS              319    333
019400120119     DHDRSHPNAM              334    368
019500120119     DHDRSHPAD1              369    403
019600120119     DHDRSHPAD2              404    438
019700120119     DHDRSHPCTY              439    468
019800120119     DHDRSHPSTA              469    470
019900120119     DHDRSHPZIP              471    480
020000120119     DHDRSHPDAT              481    488
020100120119     DHDRINSTALL             489    496
020200160316     DHDRNUMITM              497    502
020300160330     DHDRFREIGHTCHARG        503    512
020400160330     DHDRMISCCHARG           513    522
020500120119     DHDRTAXES               523    532
020600120119     DHDRSPLCOD              533    539
020700120119     DHDROFFLTR              540    554
020800120119     DHDRSUPCOD              555    564
020900120119     DHDRCURCOD              565    567
021000160511     DHDRCNTRYCOD            568    572
021100160330     DHDREXCHRATE            573    582
021200160330     DHDRLEGALID             583    597
021300120119     DHDRVNDNAM              598    627
021400120119     DHDRDAT                 628    635
021500120119     DHDRTIM                 636    645
021600160328     DHDRECWTYP              646    647
021700160328     DHDRFILLER2             648    685
021800160328     DHDCPSNUM               686    700
021900160328     DHDPAYERNO              701    710
022000160328     DHDRFILLER3             711    809
022100160328     DHDROBJID               810    835
022200160328     DHDRINVTYPE             836    838
022300160329     DHDRVENNAME             839    878
022400160329     DHDRTAXCODE             879    880
022500160330     DHDRVENNUM              881    890
022600160329     DHDRCOMPCODE            891    894
022700160329     DHDRPOEX                895    898
022800160328     DHDRSRANUM              899    912
022900160330     DHDRCPSNUM              913    926
023000061220      *
023100061220      * COMMENT data structure
023200160311      *
023300120119     DDSCOMMENT        DS
023400120119     DCOMRCDID                 1     10
023500160311     DCOMFILLER1              11     17
023600120119     DCOMTXT                  18     77
023700120119     DCOMFILLER2              78    800
023800061220      *
023900160315      * DETAIL data structure
024000120119      *
024100120119     DDSDETAIL         DS
024200120119     DDETRCDID                 1     10
024300160311     DDETFILLER1              11     17
024400120119     DDETDTLLIN               18     23
024500160322     DDETQTY                  24     29  0
024600120119     DDETBOQTY                30     35
024700160322     DDETUNTPRC               36     45  2
024800160406     DDETITMDSC               46     55
024900160330     DDETPARTNUM              56     85
025000120119     DDETVNDPRT               86    105
025100120119     DDETMFGCOD              106    115
025200120119     DDETMFGDSC              116    145
025300120119     DDETPRTDSC              146    205
025400120119     DDETCARIND              206    207
025500120119     DDETCARCOD              208    211
025600120119     DDETCARDSC              212    246
025700120119     DDETCARREF              247    276
025800120119     DDETLINTAX              277    286
025900120119     DDETMCHTYP              287    290
026000120119     DDETMCHMOD              291    294
026100120119     DDETMES                 295    301
026200120119     DDETMESIND              302    302
026300120119     DDETEXTIND              303    307
026400120119     DDETCSTCTR              308    322
026500120119     DDETALLOW               323    332
026600120119     DDETCHARG               333    342
026700160324     DDETEQSRC               343    344
026800160330     DDETLINESEQ             345    351
026900160616     DDETFILLER2             352    878
027000160616     DDTLTAXCODE             879    880
027100061220      *
027200160315      * SERIAL data structure
027300120119      *
027400120119     DDSSERIAL         DS
027500120119     DSERRCDID                 1     10
027600160311     DSERFILLER1              11     17
027700120119     DSERSERNO                18     47
027800120119     DSERASSTAG               48     77
027900120119     DSERFILLER2              77    800
028000061220      *
028100061220      * FEATURE data structure
028200160314      *
028300120119     DDSFEATURE        DS
028400120119     DFEARCDID                 1     10
028500160311     DFEAFILLER1              11     17
028600120119     DFEALINNO                18     23
028700120119     DFEAQTY                  24     29
028800120119     DFEAUNTPRC               30     39
028900120119     DFEAPRTNO                40     59
029000120119     DFEAPRTDSC               60    119
029100120119     DFEAVNDPRT              120    139
029200120119     DFEAFILLER2             140    800
029300061220      *
029400061220      * TRAILER data structure
029500120119      *
029600120119     DDSTRAILER        DS
029700120119     DTRLRCDID                 1     10
029800160311     DTRLFILLER1              11     17
029900160316     DTRLNUMINV               18     22
030000120119     DTRLNUMRCD               23     27
030100160316     DTRLTOTAMT               28     42
030200120119     DTRLFILLER2              38    800
030300061220      *
030400061220      * FILE TRAILER data structure
030500160314      *
030600160311     DDSFILETRL        DS
030700120119     DFTRRCDID                 1     10
030800160311     DFTRFILLER1              11     17
030900120119     DFTRSEQNUM               18     23
031000120119     DFTRISANUM               24     28
031100120119     DFTRFILLER2              29    800
031200160315      *
031300160315      * Program status
031400160315      *
031500160315     DPSDS            SDS
031600160315     DPGMNAME                  1     10A
031700160315     DPGMSTS                  11     15S 0
031800160315     DPGMPRVSTS               16     20S 0
031900160315     DPGMSRCSTMT              21     28A
032000160315     DPGMROUTINE              29     36A
032100160315     DPGMPARMS                37     39S 0
032200160315     DPGMMSGID                40     46A
032300160315     DPGMMI#                  47     50A
032400160315     DPGMWORK                 51     80A
032500160315     DPGMLIB                  81     90A
032600160315     DPGMERRDTA               91    170A
032700160315     DPGMRPGMSG              171    174A
032800160315     DPGMLASTFILE            175    184A
032900160315     DPGMJOB                 244    253A
033000160315     DPGMUSER                254    263A
033100160315     DPGMJOBNUM              264    269S 0
033200160315     DPGMJOBDATE             270    275S 0
033300160315     DPGMRUNDATE             276    281S 0
033400160315     DPGMRUNTIME             282    287S 0
033500160315      *
033600160315      * BATCH feedback
033700160315      *
033800160315     DBATCHINFDS       DS
033900160315     DBATCHSTS           *STATUS
034000160315     DBATCHOPC           *OPCODE
034100160315     DBATCHROUTINE       *ROUTINE
034200160315     DBATCHINFFILE       *FILE
034300160315      *
034400160315      * PF7 feedback
034500160315      *
034600160315     DPF7INFDS         DS
034700160315     DPF7STS             *STATUS
034800160315     DPF7OPC             *OPCODE
034900160315     DPF7ROUTINE         *ROUTINE
035000160315     DPF7INFFILE         *FILE
035100160315      *
035200160315      * ERROR LOG data structure
035300160315      *
035400160315     DERRORDS          DS                  INZ
035500160315     DMSGID                           7A
035600160315     DPROGRAMNAME                    10A
035700160315     DFILENAME                        8A
035800160315     DOPCODE                          6A
035900160315     DSTATUS                          5S 0
036000160316     DEXTMSG                        100A
036100160322     DCMDLENGTH        S             15P 5
036200160322     DCMDTEXT          S            256A
036300061220      *
036400170611      * Define ROBOT work fields
036500170611     DMSG_Q            S             10A   INZ(*BLANKS)
036600170611     DMSG_ID           S              7A   INZ(*BLANKS)
036700170611     DMSG_DTA          S            256A   INZ(*BLANKS)
036800170611     DMSG_TYP          S              1A   INZ('I')
036900170611      *
037000160315      * Work fields
037100160314      *
037200160707     DPRMMBRNAME       S             10A
037300160826     DPRMLIBNAME       S             10A
037400161227     DPRMSYSID         S              8A
037500160311     DRECTYPE          S             10A
037600160311     DLASTCTL          S              9  0
037700160316     DPOS              S              2  0
037800160314     DINCOUNT          S             15A
037900171206     DINCOUNTU         S             15A
038000160314     DCNTLCOUNT        S             15A
038100160314     DTRLCOUNT         S              9  0 INZ(0)
038200160314     DHOLDDTL          S              9  0 INZ(0)
038300160316     DHEADERIND        S              1  0 INZ(0)
038400160314     DDTLCOUNT         S              9  0 INZ(0)
038500160526     DDTLCOUNTA        S              9  0 INZ(0)
038600160314     DFIRSTHDR         S              1  0 INZ(0)
038700160325     DPROCESSINV       S              9  0 INZ(0)
038800160314     DTOTINVCNT        S              9  0 INZ(0)
038900160316     DTOTINVAMT        S             15  2 INZ(0)
039000160316     DINTAMT           S             15  0 INZ(0)
039100160316     DDECAMT           S             13  2 INZ(0)
039200160512     DDECAMT4          S             11  4 INZ(0)
039300160311     DRECTYPE1         C                   CONST('FILEHDR   ')
039400160311     DRECTYPE2         C                   CONST('CONTROL   ')
039500160311     DRECTYPE3         C                   CONST('DHEADER   ')
039600160311     DRECTYPE4         C                   CONST('DCOMMENT  ')
039700160311     DRECTYPE5         C                   CONST('DDETAIL   ')
039800160311     DRECTYPE6         C                   CONST('DSERIALNO ')
039900160328     DRECTYPE7         C                   CONST('DFEATURE  ')
040000160311     DRECTYPE8         C                   CONST('TRAILER   ')
040100160311     DRECTYPE9         C                   CONST('FILETRL   ')
040200160316     DSYS_DATE         S               D   INZ(*SYS)
040300160316     DSYS_TIME         S               T
040400171212      *
040500170611     DWWDATE           S               D   DATFMT(*ISO)
040600170620     DWWTIME           S               T   TIMFMT(*HMS)
040700170614     DCHAR_DATE        S             10A
040800180222     DCHAR_DATE1       S             10A
040900170620     DHldSEQNUM        S                   Like(E7SEQNUM)
041000180222     DCounter          S              1  0 INZ(0)
041100170627      *
041200170627     D                 DS
041300170627     DhldMQ_MSG_ID             1     80A
041400170627     DtrmMQ_MSG_ID             1     48A
041500170627      *
041600170627     DhldMDMID         S                   Like(MDMID)
041700170621     DhldCREAT00001    S             30A
041800170711     Dp1CREAT00001     S             26Z
041900170711     Dp1MQ_RE00001     S             26Z
042000170711     Dp1LAST_00002     S             26Z
042100171212      *
042200160316     D                 DS
042300160316     DTIMSTP                   1     12S 0
042400160316     DSYSTIME                  1      6S 0
042500160316     DSYSDATE                  7     12S 0
042600160609     DINVOICEVALID     S              1A   DIM(10000)
042700160609     DINVOICETAX       S              1A   DIM(10000)
042800160609     DINVOICENDX       S              5S 0 INZ(0)
042900160526     DXMLDTLLINE       S              7  0 INZ(0)
043000160526     DXMLDTLCOUNT      S              7A
043100171206     DXMLDTLCOUNT1     S              7A
043200160526     DXMLDTLSEQ        S              7  0 INZ(0)
043300160322     DHOLDTIME         S             12A
043400160526     DHOLDFREIGHTCHG   S             10A   INZ('0000000000')
043500160526     DHOLDMISCCHG      S             10A   INZ('0000000000')
043600160526     DHOLDTAXES        S             10A   INZ('0000000000')
043700160526     DHOLDCHG          S              1A   INZ(' ')
043800160323     DSCAN_FIELD       S            100A
043900180309      * @1607g : Begin
044000180309     DSCAN_FIELD1      S            100A
044100180309      * @1607g : End
044200160324     DSCAN_AMP         S              1A   INZ('&')
044300160324     DREPLACE_AMP      S              5A   INZ('&amp;')
044400160324     DSCAN_GT          S              1A   INZ('>')
044500160324     DREPLACE_GT       S              4A   INZ('&gt;')
044600160324     DSCAN_LT          S              1A   INZ('<')
044700160324     DREPLACE_LT       S              4A   INZ('&lt;')
044800160324     DSCAN_QUOT        S              1A   INZ('"')
044900160324     DREPLACE_QUOT     S              6A   INZ('&quot;')
045000160324     DSCAN_APOS        S              1A   INZ('''')
045100160324     DREPLACE_APOS     S              6A   INZ('&apos;')
045200160323     DSCAN_POS         S             10I 0
045300160323     DSCAN_POS1        S             10I 0
045400160602     DKEYBOARD         C                   CONST(
045500160602     D                                           '1234567890-=  -
045600160602     D                                            qwertyuiop[]\ -
045700160602     D                                            asdfghjkl;    -
045800160602     D                                            zx cvbnm,./   -
045900160602     D                                            !@#$%^&*()_+  -
046000160602     D                                            QWERTYUIOP{}| -
046100160602     D                                            ASDFGHJKL:    -
046200160602     D                                            ZXCVBNM?'
046300160602     D                                            )
046400160328     DE7KEY1           S              7  0 INZ(0)
046500160328     DE7KEY2           S              7    INZ('0000000')
046600160328     DE7KEY3           S              7  0 INZ(0)
046700160328     DE7KEY4           S              7  0 INZ(0)
046800160510     DE7KEY5           S              2A   INZ('  ')
046900160408     DEDIXMLDTL        S            256A
047000160824     DCTSXMLDTL        S            750A
047100160411     DEDIXMLLEN        S              7  0 INZ(0)
047200160422     DQMNAME           S             48A
047300171212      *
047400170528     DTIMECNT          S              1S 0 INZ(0)
047500170619     DRCCPY            S              2A
047600170621     DFILNME           S             10A
047700170705     DLOGZ             S            200A
047800171212      *
047900170528     DHCONN            S             10I 0
048000170528     DCMPCOD           S             10I 0
048100170528     DREASON           S             10I 0
048200170528     DOBJDSC           S            360A
048300160422     DOPTS             S             10I 0
048400170528     DHOBJ             S             10I 0
048500170528     DMSGDSC           S            364A
048600170528     DPMO              S            176A
048700161115     DDIVBYZERO        S              1A
048800170528     DBUFLEN           S             10I 0
048900180917      * @1685 : Begin
049000180917     D*BUFFER           S        2000000A
049100171212      *
049200180917     D*BUFFER1          S        2000000A
049300180917     D*WrkXmlDtl        S        2000000A
049400180917     DBUFFER1          S        6000000A
049500180917     DWrkXmlDtl        S        6000000A
049600180917      * @1685 : End
049700171212      *
049800171212     DBUFFCTS          S          15000A
049900180917      * @1685 : Begin
050000180917     D*BUFFPTR          S               *   INZ(%ADDR(BUFFER))
050100180917     DBUFFPTR          S               *   INZ(%ADDR(BUFFER1))
050200180917      * @1685 : End
050300160422     DGMO              S            100A
050400160422     DDATLEN           S             10I 0
050500161227     DEDIXMLKEY0       S              8A
050600160422     DEDIXMLKEY1       S             10A
050700160422     DEDIXMLKEY2       S             10A
050800161107     DFREIGHTKEY1      S              2A
050900161107     DFREIGHTKEY2      S              3A
051000160510     DTOTAMTTYPE       S              2A
051100161206     DTAXPCT           S             10P 4
051200180314      * @uxh : Begin
051300180314      * HDRTAXES is always 10P 2 , indicates always 8 length before decimal
051400180314     D*TAXAMT           S             10P 4
051500180314     DTAXAMT           S             12P 4
051600180314      * @uxh : End
051700180926      * @1687 : Begin
051800180921     D*TAXAMT2          S             10I 0
051900180921     DTAXAMT2          S             10  0
052000180926      * @1687 : End
052100180314      * @uxh : Begin
052200180314     D*TAXACCUM         S             10P 4
052300180314     DTAXACCUM         S             12P 4
052400180314      * @uxh : End
052500160705     DTAXSTATE         S              3I 0
052600161227     DUPFRONTSTATES    S            256A
052700161227     DCHECKSTATE       S              3A
052800160617     DMQCNT            S             10I 0
052900160825     DCRLF             C                   CONST(X'0D25')
053000171107      *@1622: Begin
053100171030     DIBMCHK           S              2S 0
053200171030     DIBMIND           S              1A
053300171220     DwPROVINCE        S                   LIKE(HDRSHPSTA)
053400180228     DCAINVDATEC       S             10A
053500180228     DCAINVDATE        S               D   DATFMT(*ISO)
053600180303     D@@MQTAXCD        S              2A
053700180303     D@@MQTAXPCT       S              5S 5
053800180303     DHldVatVar        S              4S 2
053900180303     DVld_Tax_Tol      S              1A
054000180303     DCATAXSPD         S              1A
054100171107      *@1622: End
054200160422      *
054300160422      **  Declare MQI structures needed
054400160422      * MQI named constants
054500160422     DMQR              DS
054600170901     I/COPY QMQM/QRPGLESRC,CMQG
054700171212      *
054800160422      * Object Descriptor
054900160422     DMQOD             DS
055000170901     I/COPY QMQM/QRPGLESRC,CMQODG
055100171212      *
055200160422      * Message Descriptor
055300160422     DMQMD             DS
055400170901     I/COPY QMQM/QRPGLESRC,CMQMDG
055500171212      *
055600160422      * Get message options
055700160422     DMQGMO            DS
055800170901     I/COPY QMQM/QRPGLESRC,CMQGMOG
055900160422      *
056000160422      * Put message options
056100160422     DMQPMO            DS
056200170901     I/COPY QMQM/QRPGLESRC,CMQPMOG
056300160801      *
056400160801      * For HTPAPPI web service
056500160801      *
056600171107      /copy libhttp/qrpglesrc,httpapi_h
056700160825     Ddata             S           5000A
056800160825     DIFS              S            256A
056900160825     DURL              S            256A
057000160825     DACTION           S            256A
057100160825     Drc               S             10I 0
057200160825     Dlen              S             10I 0
057300160825     DTOLERANCE        C                   CONST('WithinTolerance="Y"')
057400160825
057500160316      *
057600171208     D/copy *libl/qrpglesrc,IFSIO_H
057700171212
057800171208     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
057900171208     D   command                  32702a   const options(*varsize)
058000171208     D   len                         15p 5 const
058100171208     D   igc                          3a   const options(*nopass)
058200180225
058300171208      * Variables to create IFS file to store EDI request xml
058400171208     D fd              S             10I 0
058500171208     D cmd             s            200A
058600171208     D $file_name      S             50
058700171208     D $file_dir       S            100A
058800171208     D $file_path      S            100A
058900180305     D $new_file       S             75A
059000171212      *
059100171212     D $file_dir1      S            100A
059200171212     D $file_path1     S            100A
059300180222     D $tmp_dir        S            100A
059400180222     D $arc_dir        S            100A
059500180225     D RCDLT           S              1S 0
059600171208      *
059700171212      * Work Variables used in XML Control
059800171212     DwXMLENV          S                   Like(EDIXMLDATA)
059900171212     DwSOAPADR         S                   Like(EDIXMLDATA)
060000171212     DWrkXMLCTL        S        1000000A
060100171212      *
060200171212      * Work Variables used in XML Detail
060300171212     DEDIXMLDTLU       S                   Like(EDIXMLDATA)
060400171212     DWrkXmlDtl1       S        1000000A
060500171212     DWrkXmlDtl2       S        1000000A
060600171212     DWrkXmlDtl3       S        1000000A
060700171212      *
060800171212      * Work Variables used for CTSXML
060900171212     DWrkCTSXML1       S           5000A
061000171212     DWrkCTSXML2       S           5000A
061100171212     DWrkCTSXML3       S           5000A
061200171212      *
061300180411      * @1647 : Begin
061400180411     ?* WSCFEIMPR parm declaration
061500180411     DwAPPLID          S              5A
061600180411     DWSOPER           S             50A
061700180411     DErrNote          S            256A
061800180411     DRetCode          S              2A
061900180411     DWRETCODE         S              2A
062000180411     DWErrNote         S            256A
062100180411      *
062200180411     ?* Declare constants for sending error to notelog
062300180411     DERRNOTE1         C                   Const('Tax Only Invoice -Division By-
062400180423     D                                      Zero')
062500180417     DERRNOTE2         C                   Const('Taxes on the invoice -
062600180417     D                                     are not within the state tax -
062700180417     D                                     tolerance values')
062800180417     DERRNOTE3         C                   Const('There should be no tax-
062900180417     D                                     es on IGF billed assets for -
063000180417     D                                     these states and should not -
063100180417     D                                     accept')
063200180411      * @1647 : End
063300160316      * Mainline
063400160316      *
063500160316     C     *ENTRY        PLIST
063600160707     C                   PARM                    PRMMBRNAME
063700160707     C                   PARM                    PRMLIBNAME
063800161227     C                   PARM                    PRMSYSID
063900180411      * @1647 : Begin
064000180411     C     ParmCFEXML    PLIST
064100180411     C                   PARM                    wAPPLID
064200180411     C                   PARM                    WSOPER
064300180411     C                   PARM                    HDRINVNO
064400180411     C                   PARM                    HDROBJID
064500180411     C                   PARM                    PRMLIBNAME
064600180411     C                   PARM                    PRMSYSID
064700180411     C                   PARM                    ErrNote
064800180411     C                   PARM                    RETCODE
064900180411      *
065000180411     C     ParmCFEWEB    PLIST
065100180411     C                   PARM                    wAPPLID
065200180411     C                   PARM                    HDRINVNO
065300180411     C                   PARM                    PRMLIBNAME
065400180411     C                   PARM                    PRMSYSID
065500180411     C                   PARM                    WRETCODE
065600180411      *
065700180411      * @1647 : End
065800160330      *
065900190129      * @1712 : Begin
066000190129     C                   MONITOR
066100190129      * @1712 : End
066200160316     C                   EXSR      INITSR
066300160330      *
066400160330      * Read invoice file
066500160330      *
066600160311     C                   READ      EDIPF7                                 90
066700061220     C     *IN90         DOUEQ     *ON
066800160311     C                   EVAL      RECTYPE = %SUBST(EDIRCD7:1:10)
066900160316     C                   EVAL      HEADERIND = 0
067000160330      *
067100160330      * Split out based on record type
067200160330      *
067300160311     C                   SELECT
067400160311     C                   WHEN      RECTYPE = RECTYPE1
067500160311     C                   EXSR      SRFILEHDR
067600160311     C                   WHEN      RECTYPE = RECTYPE2
067700160311     C                   EXSR      SRCONTROL
067800160311     C                   WHEN      RECTYPE = RECTYPE3
067900160311     C                   EXSR      SRHEADER
068000160311     C                   WHEN      RECTYPE = RECTYPE4
068100160311     C                   EXSR      SRCOMMENT
068200160311     C                   WHEN      RECTYPE = RECTYPE5
068300160311     C                   EXSR      SRDETAIL
068400160311     C                   WHEN      RECTYPE = RECTYPE6
068500160311     C                   EXSR      SRSERIALNO
068600160328     C                   WHEN      RECTYPE = RECTYPE7
068700160311     C                   EXSR      SRFEATURE
068800160311     C                   WHEN      RECTYPE = RECTYPE8
068900160311     C                   EXSR      SRTRAILER
069000160311     C                   WHEN      RECTYPE = RECTYPE9
069100160311     C                   EXSR      SRFILETRL
069200160311     C                   ENDSL
069300061220     C*
069400160311     C                   READ      EDIPF7                                 90
069500061220     C                   ENDDO
069600160315      *
069700160315      * Validate trailer record is present
069800160315      *
069900160315     C                   IF        TRLCOUNT <> 1
070000160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
070100160316     C                                        'Trailer record missing '
070200160316     C                   EXSR      WRITEPF5
070300160617     C                   EVAL      *INLR = *ON
070400160617     C                   RETURN
070500160825     C                   ENDIF
070600160330      *
070700160708
070800160707     C                   CLOSE     EDIPF7A
070900160707     C                   CLOSE     EDIPF7B
071000160707     C                   OPEN      EDIPF7A
071100160707     C                   OPEN      EDIPF7B
071200171212      *
071300180221     C                   EVAL      INVOICENDX = 0
071400171212     C                   EVAL      *IN90 = *OFF
071500171212      *
071600160708      *
071700160708      * Process main work file and create XML
071800160708      *
071900180304     C     *LOVAL        SETLL     EDIPF7A
072000160707     C                   READ      EDIPF7A                                90
072100160322     C     *IN90         DOUEQ     *ON
072200160329     C                   EVAL      RECTYPE = %SUBST(EDIRCD7S:1:10)
072300160330      *
072400160330      * Split out for XML based on record type
072500160330      *
072600160322     C                   SELECT
072700160322     C                   WHEN      RECTYPE = RECTYPE1
072800160322     C                   EXSR      XMLFILEHDR
072900160322     C                   WHEN      RECTYPE = RECTYPE2
073000160322     C                   EXSR      XMLCONTROL
073100160322     C                   WHEN      RECTYPE = RECTYPE3
073200160322     C                   EXSR      XMLHEADER
073300160322     C                   WHEN      RECTYPE = RECTYPE4
073400160322     C                   EXSR      XMLCOMMENT
073500160322     C                   WHEN      RECTYPE = RECTYPE5
073600171212     C                   EXSR      XMLDETAIL
073700160322     C                   WHEN      RECTYPE = RECTYPE6
073800160322     C                   EXSR      XMLSERIALNO
073900160328     C                   WHEN      RECTYPE = RECTYPE7
074000160322     C                   EXSR      XMLFEATURE
074100160322     C                   WHEN      RECTYPE = RECTYPE8
074200160322     C                   EXSR      XMLTRAILER
074300160322     C                   WHEN      RECTYPE = RECTYPE9
074400160322     C                   EXSR      XMLFILETRL
074500160322     C                   ENDSL
074600171212      *
074700160707     C                   READ      EDIPF7A                                90
074800160322     C                   ENDDO
074900160708      *
075000160708      * End of processing
075100160708      *
075200160330     C                   EXSR      ENDOFINV
075300160601     C                   EVAL      LAST_00001 = LASTCTL
075400160601     C                   EVAL      LAST_00002 = %TIMESTAMP()
075500160708      *
075600160708      * Update batch control file
075700160708      *
075800170901     C                   UPDATE    BATCHCTL                             71
075900170901     C                   IF        *IN71
076000170901     C                   CLEAR                   ERRORDS
076100170901     C                   EVAL      MSGID    = 'ICC6700'
076200170901     C                   EVAL      FILENAME = BATCHINFFILE
076300170901     C                   EVAL      OPCODE   = BATCHOPC
076400170901     C                   EVAL      STATUS   = BATCHSTS
076500170901     C                   EVAL      EXTMSG   = 'Update failed while ' +
076600170901     C                             'processing GCMS EDI update for ' +
076700170901     C                              PRMMBRNAME
076800170901     C                   EXSR      ERRLOG
076900170901     C                   ENDIF
077000170901      *
077100180222      * Move EDI invoice file from tmp to archive directory
077200180222      * Rename EDI invoice file with control num and current date
077300180222     C                   EXSR      MovTmpEDI
077400180222      *
077500190129      * @1712 : Begin
077600190129      * MONITORING FOR PROGRAM RELATED ERROR
077700190129      *
077800190129     C                   ON-ERROR  *PROGRAM
077900190129     C                   EVAL      FILENAME = *BLANKS
078000190129     C                   EVAL      STATUS = PGMSTS
078100190129     C                   EVAL      MSGID = 'EDI1005'
078200190129     C                   EVAL      EXTMSG = 'Program error occurred:'+
078300190129     C                                       %TRIMR(PRMMBRNAME)  +'-'+
078400190129     C                                       %TRIMR(HDRINVNO)
078500190129     C                   CALLB     'LOGIOERRS'
078600190129     C                   PARM                    ERRORDS
078700190129      *
078800190129     C                   EVAL      MSG_ID = 'RBT7200'
078900190129     C                   EVAL      MSG_DTA = 'GAPTS: ' +
079000190129     C                                       %TRIM(PGMNAME) + ' Error-' +
079100190129     C                                       %TRIM(HDRINVNO) + ':'
079200190129     C                                       + %trim(PGMERRDTA)
079300190129     C                   EXSR      SND_ROBOT
079400190129      *
079500190129      *
079600190129      * End of error monitoring
079700190129      *
079800190129     C                   ENDMON
079900190129      * @1712 : End
080000170831     C                   EVAL      *INLR = *ON
080100160315      *
080200180202      **********************************************************************
080300180202      * COPY  EDIPF7B  to EDIPF7A
080400180202      **********************************************************************
080500180202     C     CpyPF7BPF7A   BEGSR
080600180302      *
080700180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
080800180302     C                   EVAL      CATAXSPD ='Y'
080900180302     C                   ELSE
081000180302     C                   EVAL      CATAXSPD ='N'
081100180302     C                   ENDIF
081200180202      * Process tax work file for tax state and rewrite to main work file
081300180202      *
081400180302     C                   IF        TAXSTATE = 1 or CATAXSPD='Y'
081500190123      * @1712: Begin
081600190123      * Do not tax spread if tax not within tolerance for invoice
081700190128     C                   If        INVOICEVALID (INVOICENDX) <> '1'
081800190123      * @1712: End
081900180202     C                   DOU       TAXACCUM = 0
082000180202      *
082100180202     C                   SETOFF                                           90
082200180202     C     *LOVAL        SETLL     EDIPF7TR                             90
082300180202     C                   READ      EDIPF7B                                90
082400180202     C     *IN90         DOUEQ     *ON
082500180214      * @uxh : Begin
082600180214      * Check if record not serial record
082700180214     C                   IF        %SUBST(EDIRCD7T:1:10) <> RECTYPE6
082800180214      * @uxh : End
082900180202     C                   EXSR      PF7BTOPF7A1
083000180214      * @uxh : Begin
083100180214     C                   ENDIF
083200180214      * @uxh : End
083300180202     C                   READ      EDIPF7B                                90
083400180202     C                   ENDDO
083500180202      *
083600180202     C                   CLOSE     EDIPF7B
083700180202     C                   OPEN      EDIPF7B
083800180202     C                   ENDDO
083900180202      *
084000190123      * @1712: Begin
084100190123     C                   ENDIF
084200190123      * @1712: End
084300180202     C                   SETOFF                                           90
084400180202      *
084500180202     C     *LOVAL        SETLL     EDIPF7TR                             90
084600180202     C                   READ      EDIPF7B                                90
084700180202     C     *IN90         DOUEQ     *ON
084800180202     C                   EXSR      PF7BTOPF7A2
084900180202     C                   READ      EDIPF7B                                90
085000180202     C                   ENDDO
085100180202      *
085200180202     C                   CLOSE     EDIPF7B
085300180202     C                   EVAL      CMDTEXT = *BLANKS
085400180202     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7B'
085500180202     C                   CALL      'QCMDEXC'
085600180202     C                   PARM                    CMDTEXT
085700180202     C                   PARM                    CMDLENGTH
085800180202     C                   OPEN      EDIPF7B
085900180202      * End If TAXSTATE Not 1
086000180202     C                   ENDIF
086100180202      *
086200180304     C                   EVAL      CATAXSPD ='N'
086300180202      *
086400180202     C                   ENDSR
086500180202      **********************************************************************
086600170616      **********************************************************************
086700170616      * Subroutine to Write Invoice_Control
086800170616      **********************************************************************
086900170616     C     Wrt_INVOCTL   BEGSR
087000170616      *
087100170616     C                   EVAL      CHAR_DATE = %SUBST(HDRINVDAT:1:4)+'-'+
087200170616     C                                         %SUBST(HDRINVDAT:5:2)+'-'+
087300170616     C                                         %SUBST(HDRINVDAT:7:2)
087400170616     C     *ISO          MOVE      CHAR_DATE     WINVDATE
087500170616      *
087600170622     C                   EVAL      p1CREAT00001 = %TIMESTAMP()
087700170620
087800170622     C/EXEC SQL
087900170622     C+ INSERT INTO INVOI00001
088000170622     C+ (CONTR00001 , COUNT00001,  INVOI00001 ,
088100170622     C+ INVOI00002 , CM_OB00001,  CREATE_ID ,
088200170622     C+ CREAT00001 , LAST_00001 , LAST_00002 )
088300170622     C+ VALUES(:HldSEQNUM ,:HDRCNTRYCOD, :HDRINVNO,
088400170622     C+ :WINVDATE ,:HDROBJID , :PGMUSER ,
088500170622     C+ :p1CREAT00001 , :PGMUSER , :p1CREAT00001 )
088600170622     C/End-Exec
088700170623
088800170616      *
088900170622     C                   If        SqlCode <> 0 and SqlCode <> 100
089000170616     C                   CLEAR                   ERRORDS
089100171214     C                   EVAL      PROGRAMNAME = PGMNAME
089200171214     C                   EVAL      MSGID       = 'ICC6700'
089300170622     C                   EVAL      FILENAME = 'INVOI00001'
089400170622     C                   EVAL      OPCODE   = 'Insert'
089500170622     C                   EVAL      STATUS   = SQLCODE
089600170622     C                   EVAL      EXTMSG='INSERT- Error occurred for: '
089700170622     C                                    +%trim(HDRINVNO) + ' ' + CHAR_DATE
089800170616     C                   CALLB     'LOGIOERRS'
089900170616     C                   PARM                    ERRORDS
090000170616     C                   EVAL      MSG_ID = 'RBT8006'
090100170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
090200170616     C                   EXSR      SND_ROBOT
090300170616     C                   ENDIF
090400170616      *
090500170616     C                   ENDSR
090600170616      **********************************************************************
090700170616      * Subroutine to Update Invoice_Control
090800170616      **********************************************************************
090900170616     C     Upd_INVOCTL   BEGSR
091000170616      *
091100170621     C                   Movel     p1CREAT00001  hldCREAT00001
091200170627     C                   EVAL      p1MQ_RE00001 = %TIMESTAMP()
091300170627     C                   EVAL      p1LAST_00002 = %TIMESTAMP()
091400170622
091500170622     C/EXEC SQL
091600170622     C+ UPDATE INVOI00001
091700170711     C+ set MQ_MSG_ID    = lcase(:trmMQ_MSG_ID) ,
091800170623     C+     MQ_RE00001   = :p1MQ_RE00001 ,
091900170623     C+     LAST_00002   = :p1LAST_00002
092000170623     C+ where COUNT00001  = :HDRCNTRYCOD      and
092100170623     C+       INVOI00001  = :HDRINVNO         and
092200170623     C+       INVOI00002  = :WINVDATE         and
092300170623     C+       CONTR00001  = :HldSEQNUM        and
092400170623     C+       CREAT00001  = :p1CREAT00001
092500170622     C/End-Exec
092600170622
092700170616      * If a file error occurs, log and exit.
092800170622     C                   If        SqlCode <> 0 and SqlCode <> 100
092900170616     C                   CLEAR                   ERRORDS
093000171214     C                   EVAL      PROGRAMNAME = PGMNAME
093100171214     C                   EVAL      MSGID       = 'ICC6700'
093200170622     C                   EVAL      FILENAME = 'INVOI00001'
093300170622     C                   EVAL      OPCODE   = 'UPDATE'
093400170622     C                   EVAL      STATUS   = SqlCode
093500170622     C                   EVAL      EXTMSG='UPDATE - Error occurred for: '+
093600170622     C                                    %trim(HDRINVNO)  + ' ' + CHAR_DATE
093700170616     C                   CALLB     'LOGIOERRS'
093800170616     C                   PARM                    ERRORDS
093900170616     C                   EVAL      MSG_ID = 'RBT8006'
094000170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
094100170616     C                   EXSR      SND_ROBOT
094200170616     C                   Endif
094300170620      *
094400170616     C                   ENDSR
094500170614      **********************************************************************
094600170614      * Subroutine to log MQ History file
094700170614      **********************************************************************
094800170614     C     LOGMQCALL     BEGSR
094900170614      *
095000180303     C                   EVAL      WCTY    = HDRCNTRYCOD
095100170614     C                   EVAL      WINV#   = HDRINVNO
095200170614     C                   EVAL      CHAR_DATE = %SUBST(HDRINVDAT:1:4)+'-'+
095300170614     C                                         %SUBST(HDRINVDAT:5:2)+'-'+
095400170614     C                                         %SUBST(HDRINVDAT:7:2)
095500170614     C     *ISO          MOVE      CHAR_DATE     WINVDATE
095600170614     C                   MOVEL     REASON        WRCODE
095700170614     C                   MOVEL     CMPCOD        WCMPCODE
095800170614     C                   EVAL      WRUNDTE = WWDATE
095900170620     C                   EVAL      WRUNTME = %TIME()
096000170614     C                   WRITE     MQOUTHPR                             52
096100170614      * If a file error occurs, log and exit.
096200170614     C                   IF        *IN52 = *ON
096300170614     C                   CLEAR                   ERRORDS
096400171214     C                   EVAL      PROGRAMNAME = PGMNAME
096500171214     C                   EVAL      MSGID       = 'ICC6700'
096600170614     C                   EVAL      FILENAME = MQHSFIL
096700170614     C                   EVAL      OPCODE   = MQHSOPC
096800170614     C                   EVAL      STATUS   = MQHSFST
096900170614     C                   EVAL      EXTMSG='Error occurred for: '+%trim(HDRINVNO)
097000170614     C                                        + ' ' + CHAR_DATE
097100170614     C                   CALLB     'LOGIOERRS'
097200170614     C                   PARM                    ERRORDS
097300170614     C                   EVAL      MSG_ID = 'RBT8005'
097400170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
097500170614     C                   EXSR      SND_ROBOT
097600170614     C                   ENDIF
097700170614      *
097800170614     C                   ENDSR
097900160315      *
098000160315      * Error log
098100170611      **********************************************************************
098200170611      * Subroutine to send ROBOT error messages
098300170611      **********************************************************************
098400170611     C     SND_ROBOT     BEGSR
098500170611      *
098600170611     C                   CALL      'SNDROBOT'
098700170611     C                   PARM                    MSG_Q
098800170611     C                   PARM                    MSG_ID
098900170611     C                   PARM                    MSG_DTA
099000170611     C                   PARM                    MSG_TYP
099100170611      *
099200170611     C                   ENDSR
099300170611      **********************************************************************
099400171212      * Subroutine to log IO errors
099500171212      **********************************************************************
099600160315     C     ERRLOG        BEGSR
099700160315      *
099800160315      * Set program name.
099900160315     C                   EVAL      PROGRAMNAME = PGMNAME
100000160315      *
100100160315      * Call service program to log error.
100200161227     C                   CALLB     'LOGIOERRS'
100300160315     C                   PARM                    ERRORDS
100400160315      *
100500160315      * Exit program
100600160315     C                   EVAL      *INLR = *ON
100700160315     C                   RETURN
100800160315      *
100900160315     C                   ENDSR
101000180228      * @1622 : Begin
101100180228      **********************************************************************
101200180303      *Subroutine to update tax code for Canada based on default tax code
101300180228      **********************************************************************
101400180710     C     Upd_TaxCode   BEGSR
101500180228      *
101600180228     C                   Eval      CAINVDATEC =%subst(HDRINVDAT:1:4) + '-' +
101700180228     C                                         %subst(HDRINVDAT:2:2) + '-' +
101800180228     C                                         %subst(HDRINVDAT:7:2)
101900180228     C                   Move      CAINVDATEC    CAINVDATE
102000180228      *
102100180228     C                   Select
102200180228     C                   When      DETLINTAX <> '0000000000'
102300180710      * @1622a: Begin
102400180710     C                             And DECAMT <> *Zero
102500180710      * @1622a: End
102600180228      * tax > 0 default tax code
102700180228     C/Exec Sql
102800180228     C+ SELECT PT1LTAXCD
102900180303     C+ into :DTLTAXCODE
103000180228     C+ from PROVTAX1
103100180228     C+ Where PT1PROV    = :wPROVINCE  and
103200180228     C+       PT1DFTFLG  = '*'        and
103300180228     C+       PT1EFFFR  <= :CAINVDATE and
103400180228     C+       PT1EFFTO  >= :CAINVDATE
103500180228     C/End-Exec
103600180228     C                   If        SQLCODE <> 0
103700180303     C                   EVAL      DTLTAXCODE = *Blanks
103800180228     C                   EndIf
103900180228      *
104000180228     C                   Other
104100180228      * tax = 0 default tax code
104200180228     C/Exec Sql
104300180228     C+ SELECT PT1LTAXCD
104400180303     C+ into :DTLTAXCODE
104500180228     C+ from PROVTAX1
104600180228     C+ Where PT1PROV    = :wPROVINCE  and
104700180228     C+       PT1DFTZIND = '*'        and
104800180228     C+       PT1EFFFR  <= :CAINVDATE and
104900180228     C+       PT1EFFTO  >= :CAINVDATE
105000180228     C/End-Exec
105100180228     C                   If        SQLCODE <> 0
105200180303     C                   EVAL      DTLTAXCODE = 'I0'
105300180228     C                   EndIf
105400180228      *
105500180228     C                   Endsl
105600180303      *
105700180228     C                   ENDSR
105800180303      * @1622 : End
105900180303      **********************************************************************
106000180303      *Get tax% from PROVTAX1 for Canada based on default tax code
106100180303      **********************************************************************
106200180303     C     Get_TaxCode   BEGSR
106300180303      *
106400180303     C                   Eval      CAINVDATEC =%subst(HDRINVDAT:1:4) + '-' +
106500180303     C                                         %subst(HDRINVDAT:2:2) + '-' +
106600180303     C                                         %subst(HDRINVDAT:7:2)
106700180303     C                   Move      CAINVDATEC    CAINVDATE
106800180303      *
106900180303      * tax > 0 default tax code
107000180303     C/Exec Sql
107100180303     C+ SELECT PT1PCT
107200180303     C+ into :@@MQTAXPCT
107300180303     C+ from PROVTAX1
107400180303     C+ Where PT1PROV    = :HDRSHPSTA  and
107500180303     C+       PT1DFTFLG  = '*'        and
107600180303     C+       PT1EFFFR  <= :CAINVDATE and
107700180303     C+       PT1EFFTO  >= :CAINVDATE
107800180303     C/End-Exec
107900180303     C                   If        SQLCODE <> 0
108000180303     C                   EVAL      @@MQTAXPCT = *Zero
108100180303     C                   EndIf
108200180303      *
108300180303     C                   EVAL      WCTY = HDRCNTRYCOD
108400180303     C     WCTY          CHAIN     VATVARPF                           9599
108500180303     C                   IF        *In95 or *In99
108600180303     C                   Eval      HldVatVar = 0
108700180303     C                   ELSE
108800180303     C                   Move      VVALWVAR      HldVatVar
108900180303     C                   EndIf
109000180303      *
109100180303     C                   ENDSR
109200170616      **********************************************************************
109300170616      * Subroutine to define the key Lists used by this program
109400170616      **********************************************************************
109500170831     C     KeyLIST       BEGSR
109600171212      *
109700171212      * Key for EDIFRTCTL
109800170831     C     FREIGHTKEY    KLIST
109900170831     C                   KFLD                    FREIGHTKEY1
110000170831     C                   KFLD                    FREIGHTKEY2
110100171212
110200171212      * Key for EDIPF14
110300170831     C     EDIXMLKEY     KLIST
110400170831     C                   KFLD                    EDIXMLKEY0
110500170831     C                   KFLD                    EDIXMLKEY1
110600170831     C                   KFLD                    EDIXMLKEY2
110700170831      *
110800170616     C                   ENDSR
110900170622      **********************************************************************
111000160311      * FILE HEADER
111100171212      **********************************************************************
111200160311     C     SRFILEHDR     BEGSR
111300171212      *
111400170620     C                   EVAL      HldSEQNUM = E7SEQNUM
111500171212      *
111600160311     C                   EVAL      DSFILEHDR = EDIRCD7
111700160311     C                   EVAL      CONTR00001 = 'INVOICES'
111800170901     C     CONTR00001    CHAIN     BATCHCTL                           5052
111900170901      *
112000170901      * If *IN52 is on, log the  error.
112100170901     C                   IF        *IN52 = *ON
112200170901     C                   CLEAR                   ERRORDS
112300170901     C                   EVAL      FILENAME = BATCHINFFILE
112400170901     C                   EVAL      OPCODE = BATCHOPC
112500170901     C                   EVAL      STATUS = BATCHSTS
112600170901     C                   EVAL      EXTMSG =  'File error occurred while ' +
112700170901     C                             'processing GCMS EDI update for ' +
112800170901     C                              PRMMBRNAME
112900170901     C                   EXSR      ERRLOG
113000170901     C                   ENDIF
113100170901      *
113200170901      * Record found,
113300170901     C                   IF        *IN50 = *OFF
113400160314     C                   EVAL      LASTCTL = LAST_00001 + 1
113500160314      *
113600160314      * Validate batch control number
113700160314      *
113800160329     C                   IF        E7SEQNUM <> LASTCTL
113900160329     C                   EVAL      INCOUNT = %CHAR(E7SEQNUM)
114000160314     C                   EVAL      CNTLCOUNT = %CHAR(LASTCTL)
114100160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
114200160314     C                             'control number in file does not '   +
114300160314     C                             'match next number in sequence. '    +
114400160314     C                             'Control number in file: '           +
114500160314     C                             %TRIMR(INCOUNT)                      +
114600160314     C                             '; Next control number: '            +
114700160314     C                             %TRIMR(CNTLCOUNT)
114800160316     C                   EXSR      WRITEPF5
114900160314     C                   EVAL      *INLR = *ON
115000160314     C                   RETURN
115100160314     C                   ENDIF
115200170831      *
115300170831     C                   ENDIF
115400160708
115500160328     C                   EVAL      E7KEY1 = 0
115600160328     C                   EVAL      E7KEY2 = '0000000'
115700160328     C                   EVAL      E7KEY3 = 0
115800160328     C                   EVAL      E7KEY4 = 0
115900160510     C                   EVAL      E7KEY5 = '  '
116000160328     C                   EXSR      WRITEPF7
116100160526     C                   ENDSR
116200160311      *
116300171212      **********************************************************************
116400160311      * CONTROL
116500171212      **********************************************************************
116600160708      * Write miscellaneous charges as separate record
116700160708      *
116800160311     C     SRCONTROL     BEGSR
116900180305      * @1622: Begin
117000180305     C                   Eval      IBMIND = *Blanks
117100180305     C                   IF        HDRCNTRYCOD  = 'CA'
117200180305     C                   Eval      IBMIND = 'N'
117300180305     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
117400180305     C                   If        IBMCHK  <> 0
117500180305     C                   Eval      IBMIND = 'Y'
117600180305     C                   EndIf
117700180305     C                   ENDIF
117800180305      *
117900180305     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
118000180305     C                   EVAL      CATAXSPD ='Y'
118100180305     C                   ENDIF
118200180305      * @1622: End
118300180227      * Misc and freight charges is for all country
118400160526     C                   IF        HOLDMISCCHG > '0000000000'
118500160526     C                   EVAL      HOLDCHG = 'M'
118600160526     C                   EXSR      WRITECHARGES
118700160526     C                   ENDIF
118800160708      *
118900160708      * Write freight charges as separate record
119000160708      *
119100160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
119200160526     C                   EVAL      HOLDCHG = 'F'
119300160526     C                   EXSR      WRITECHARGES
119400160526     C                   ENDIF
119500160708      *
119600180228      *
119700160708      * Write taxes as separate record
119800160708      *
119900180213      * @uxh : Begin
120000180228      * New detail line tax record only for US and CA
120100180228     C                   Select
120200180228      *
120300180303     C                   When      HOLDTAXES<>'0000000000'
120400180303     C                             AND HDRCNTRYCOD  ='US'
120500180227     C                             AND TAXSTATE = 0
120600160526     C                   EVAL      HOLDCHG = 'T'
120700160526     C                   EXSR      WRITECHARGES
120800180228      *
120900180303     C                   When      HOLDTAXES <>'0000000000'
121000180303     C                             AND HDRCNTRYCOD  ='CA'
121100180228     C                             AND IBMIND  = 'N'
121200180228     C                   EVAL      HOLDCHG = 'T'
121300180228     C                   EXSR      WRITECHARGES
121400180228      *
121500180228     C                   Other
121600180221     C                   EVAL      HOLDTAXES = '0000000000'
121700180221      *
121800180228     C                   Endsl
121900180228      * @uxh : End
122000160708
122100180202     C                   EXSR      CpyPF7BPF7A
122200180202
122300160311     C                   EVAL      DSCONTROL = EDIRCD7
122400160609     C                   EVAL      E7KEY1 = E7KEY1 + 1
122500160328     C                   EVAL      E7KEY2 = '0000000'
122600160328     C                   EVAL      E7KEY3 = 0
122700160328     C                   EVAL      E7KEY4 = 0
122800160510     C                   EVAL      E7KEY5 = '  '
122900160328     C                   EXSR      WRITEPF7
123000180202      *
123100180202      *
123200160311     C                   ENDSR
123300171212      **********************************************************************
123400171212      * HEADER
123500171212      **********************************************************************
123600160311      *
123700160311     C     SRHEADER      BEGSR
123800160311     C                   EVAL      DSHEADER = EDIRCD7
123900160314     C                   EVAL      HDROBJID = E7OBJID
124000160328     C                   EVAL      HDRINVTYPE = E7INVTYP
124100160328     C                   EVAL      HDRSRANUM = E7SRA#
124200160329     C                   EVAL      HDRPOEX   = E7POEX
124300160330     C                   EVAL      HDRVENNUM  = E7SUPLR
124400160329     C                   EVAL      HDRVENNAME = E7NAME
124500160329     C                   EVAL      HDRCOMPCODE = E7CMPCODE
124600160314      *
124700171219     C                   EVAL      DIVBYZERO   = *Blanks
124800180302     C                   EVAL      TAXPCT      = *Zero
124900171219      *
125000180303      * @1622: Begin
125100180303     C                   Eval      IBMIND = *Blanks
125200180303     C                   IF        HDRCNTRYCOD = 'CA'
125300180303     C                   Eval      IBMIND = 'N'
125400180303     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
125500180303     C                   If        IBMCHK  <> 0
125600180303     C                   Eval      IBMIND = 'Y'
125700180303     C                   EndIf
125800180303     C                   ENDIF
125900180303      * @1622: End
126000160314      * Validate number of detail lines
126100160314      *
126200160314     C                   IF        FIRSTHDR = 0
126300160314     C                   EVAL      FIRSTHDR = 1
126400160314     C                   ELSE
126500160526     C                   IF        HOLDDTL <> DTLCOUNTA
126600160316     C                   EVAL      HEADERIND = 1
126700160526     C                   EVAL      INCOUNT = %CHAR(DTLCOUNTA)
126800160314     C                   EVAL      CNTLCOUNT = %CHAR(HOLDDTL)
126900160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
127000160316     C                             'Number of detail lines does not '   +
127100160314     C                             'match number of detail lines in '   +
127200160314     C                             'invoice header.  Number of lines '  +
127300160314     C                             'in header: '                        +
127400160314     C                             %TRIMR(CNTLCOUNT)                    +
127500160314     C                             '; Number of lines in file: '        +
127600160314     C                             %TRIMR(INCOUNT)
127700160316     C                   EXSR      WRITEPF5
127800160314     C                   EVAL      *INLR = *ON
127900160314     C                   RETURN
128000160314     C                   ENDIF
128100160314     C                   ENDIF
128200160314      *
128300160314      * Validate that content manager object id is in invoice header
128400160314      *
128500160314     C                   IF        HDROBJID = *BLANKS
128600160316     C                   EVAL      HEADERIND = 1
128700160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
128800160314     C                             'CM object id does not exist in '    +
128900160314     C                             'invoice header.  Invoice number: '  +
129000160314     C                             %TRIMR(HDRINVNO)
129100160316     C                   EXSR      WRITEPF5
129200160314     C                   EVAL      *INLR = *ON
129300160314     C                   RETURN
129400160314     C                   ENDIF
129500161108      *
129600161108      * set freight charges to 0 if blank
129700161108      *
129800161108     C                   IF        %LEN(%TRIMR(HDRFREIGHTCHARG)) = 0
129900161108     C                   EVAL      HDRFREIGHTCHARG = '0000000000'
130000161108     C                   ENDIF
130100160606      *
130200160606      * Validate that there are detail lines
130300160606      *
130400160606     C                   EVAL      INVOICENDX = INVOICENDX + 1
130500160606     C                   IF        HDRNUMITM = '000000'
130600161108     C                   IF        HDRFREIGHTCHARG = '0000000000'
130700160606     C                   EVAL      HEADERIND = 1
130800160606     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
130900160606     C                             'There are no detail lines for '     +
131000160606     C                             'invoice number: '  +
131100160606     C                             %TRIMR(HDRINVNO)
131200160606     C                   EXSR      WRITEPF5
131300160606     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
131400161108     C                   ENDIF
131500160606     C                   ENDIF
131600160316      *
131700160316      * Validate that header total amount is numeric
131800160316      *
131900160316     C                   EVAL      POS =%CHECK('0123456789':HDRTOTAMT)
132000160316     C                   IF        POS > 0
132100160316     C                   EVAL      HEADERIND = 1
132200160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
132300160316     C                             'Total amount is not numeric in '    +
132400160316     C                             'invoice header.  Invoice number: '  +
132500160316     C                             %TRIMR(HDRINVNO)
132600160316     C                   EXSR      WRITEPF5
132700160316     C                   EVAL      *INLR = *ON
132800160316     C                   RETURN
132900160316     C                   ENDIF
133000160708      *
133100160708      * Validate that number if items is numeric
133200160708      *
133300160316     C                   EVAL      POS =%CHECK('0123456789':HDRNUMITM)
133400160316     C                   IF        POS > 0
133500160316     C                   EVAL      HEADERIND = 1
133600160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
133700160316     C                             'Item count is not numeric in '    +
133800160316     C                             'invoice header.  Invoice number: '  +
133900160316     C                             %TRIMR(HDRINVNO)
134000160316     C                   EXSR      WRITEPF5
134100160316     C                   EVAL      *INLR = *ON
134200160316     C                   RETURN
134300160316     C                   ENDIF
134400160708      *
134500160708      * set miscellaneous charges to 0 if blank
134600160708      *
134700160616     C                   IF        %LEN(%TRIMR(HDRMISCCHARG)) = 0
134800160616     C                   EVAL      HDRMISCCHARG = '0000000000'
134900160616     C                   ENDIF
135000160708      *
135100160708      * save freight charges is greater than 0
135200160708      *
135300160526     C                   IF        HDRFREIGHTCHARG > '0000000000'
135400160526     C                   EVAL      HOLDFREIGHTCHG = HDRFREIGHTCHARG
135500160526     C                   ENDIF
135600160708      *
135700160708      * save miscellaneous charges is greater than 0
135800160708      *
135900160526     C                   IF        HDRMISCCHARG > '0000000000'
136000160526     C                   EVAL      HOLDMISCCHG = HDRMISCCHARG
136100160526     C                   ENDIF
136200160708      *
136300180302      *
136400160708      * calculate tax percentage if taxes is greater than 0
136500160708      *
136600160526     C                   IF        HDRTAXES > '0000000000'
136700160526     C                   EVAL      HOLDTAXES = HDRTAXES
136800161115     C                   IF        (%INT(HDRTOTAMT)-
136900161115     C                              %INT(HDRTAXES)) = 0
137000161115     C                   EVAL      DIVBYZERO = 'Y'
137100161115     C                   ELSE
137200161115     C                   EVAL      DIVBYZERO = 'N'
137300180227      * @UXH : Begin
137400180227     C***                EVAL      TAXPCT = %DECH((%INT(HDRTAXES)/
137500180227     C***                                         (%INT(HDRTOTAMT)-
137600180227     C***                                          %INT(HDRMISCCHARG)-
137700180227     C***                                          %INT(HDRTAXES)))*100:7:4)
137800180227     C                   EVAL      TAXPCT = %DECH((%INT(HDRTAXES)/
137900180227     C                                            (%INT(HDRTOTAMT)-
138000180227     C                                             %INT(HDRTAXES)))*100:7:4)
138100180227      * @UXH : End
138200161115     C                   ENDIF
138300160526     C                   ENDIF
138400160708      *
138500160708      * for upfront states create XML for webservice call to CTS
138600160708      *
138700161227     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
138800161227     C                   EVAL      SCAN_POS =
138900161227     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
139000180303     C                   IF        (SCAN_POS > 0 and HDRCNTRYCOD ='US' )
139100180303     C                             or (IBMIND='Y')
139200171206     C                   Select
139300180303     C                   When      DIVBYZERO = 'N' and HDRCNTRYCOD ='CA'
139400180302     C                   EVAL      TAXSTATE = 0
139500180302     C                   EVAL      TAXACCUM = %INT(HDRTAXES)/100
139600180302     C                   EXSR      CATOLSR
139700180302      *
139800180303     C                   When      DIVBYZERO = 'N' and HDRCNTRYCOD ='US'
139900160705     C                   EVAL      TAXSTATE = 1
140000160706     C                   EVAL      TAXACCUM = %INT(HDRTAXES)/100
140100170621     C                   EXSR      CTSXMLSR
140200180302      *
140300171206     C                   When      DIVBYZERO = 'Y'
140400161115     C                   EVAL      HEADERIND = 1
140500180309      * @1607f : Begin
140600180309     C***                EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
140700180309     C***                          'Upfront state division by zero for ' +
140800180309     C***                          'invoice number: '  +
140900180309     C***                          %TRIMR(HDRINVNO)
141000180417     C                   EVAL      E5MSGVAR = 'Warning :' +
141100180417     C                             ERRNOTE1 + 'for invoice number: '  +
141200180309     C                             %TRIMR(HDRINVNO)
141300180309      * @1607f : End
141400161115     C                   EXSR      WRITEPF5
141500180411      * @1647 : Begin
141600180417     C                   EVAL      WErrNote = ERRNOTE1
141700180411     C                   EXSR      CrtCFEXML
141800180411      * @1647 : End
141900161115     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
142000180209      * @UXH : Begin
142100180209     C                   EVAL      HOLDMISCCHG = '0000000000'
142200180209     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
142300180209     C                   EVAL      HOLDTAXES      = '0000000000'
142400180209      * @UXH : End
142500171206     C                   Other
142600171206     C                   EVAL      TAXSTATE = 0
142700180202     C                   EVAL      TAXACCUM = 0
142800171206     C                   Endsl
142900171206      *
143000160705     C                   ELSE
143100160705     C                   EVAL      TAXSTATE = 0
143200180202     C                   EVAL      TAXACCUM = 0
143300160627     C                   ENDIF
143400180417
143500180417      * @1647 : Begin
143600180417      * Do not send US Nonupfront with tax having multisoldto
143700180417      * address to GCMS , send it to notelog
143800180417      *
143900180718      * @1647a: Begin
144000180718      * IGF confirmed multisoldto  not sent in EDI files so
144100180718      * comment logic earlier given by Miguel
144200180718     C***                If        HDRCNTRYCOD ='US' AND TAXSTATE=0
144300180718     C***                          AND HDRTAXES > '0000000000'
144400180417      *
144500180718     C***                Select
144600180718     C***                When      HDRSHPAD1 <> *Blanks AND HDRSHPAD2 <>*Blanks
144700180718     C***                EVAL      HEADERIND = 1
144800180718     C***                EVAL      E5MSGVAR = 'Warning :' +
144900180718     C***                          ERRNOTE3
145000180718     C***                EXSR      WRITEPF5
145100180718     C***                EVAL      WErrNote = ErrNote3
145200180718     C***                EXSR      CrtCFEXML
145300180718      *
145400180718     C***                EVAL      INVOICEVALID (INVOICENDX) = '1'
145500180718      *
145600180718     C***                EVAL      HOLDMISCCHG = '0000000000'
145700180718     C***                EVAL      HOLDFREIGHTCHG = '0000000000'
145800180718     C***                EVAL      HOLDTAXES      = '0000000000'
145900180718     C***                Endsl
146000180417      *
146100180718     C***                Endif
146200180718      * @1647a: End
146300180417      * @1647 : End
146400180417
146500160316     C                   EVAL      HOLDDTL = %DEC(HDRNUMITM:6:0)
146600180129     C                   EVAL      DTLCOUNT = 0
146700160526     C                   EVAL      DTLCOUNTA = 0
146800160314     C                   EVAL      TOTINVCNT = TOTINVCNT + 1
146900160316     C                   EVAL      INTAMT = %INT(HDRTOTAMT)
147000160316     C                   EVAL      DECAMT = INTAMT / 100
147100160316     C                   EVAL      TOTINVAMT = TOTINVAMT + DECAMT
147200160328     C                   EVAL      E7KEY1 = E7KEY1
147300160328     C                   EVAL      E7KEY2 = E7KEY2
147400160328     C                   EVAL      E7KEY3 = E7KEY3
147500160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
147600160510     C                   EVAL      E7KEY5 = E7KEY5
147700160328     C                   EXSR      WRITEPF7
147800161206     C
147900180213      * @uxh : Begin
148000180213     C***                IF        TAXSTATE = 1
148100180213      * Misc and freight charges is for all country
148200180227     C*                  IF        HOLDMISCCHG > '0000000000'
148300180227     C*                  EVAL      HOLDCHG = 'M'
148400180227     C*                  EXSR      WRITECHARGES
148500180227     C*                  ENDIF
148600180213      * @uxh : End
148700180227     C*                  IF        HOLDFREIGHTCHG > '0000000000'
148800180227     C*                  EVAL      HOLDCHG = 'F'
148900180227     C*                  EXSR      WRITECHARGES
149000180227     C*                  ENDIF
149100180124      * @1607b : Begin
149200180124      * Write taxes as separate record
149300180124      *
149400180227     C*                  IF        HOLDTAXES>'0000000000'
149500180227     C*                            AND (HDRCNTRYCOD='US' or HDRCNTRYCOD='CA')
149600180227     C*                            AND TAXSTATE = 0
149700180227     C*                  IF        INVOICETAX (INVOICENDX) = '0'
149800180227     C*                  EVAL      HOLDCHG = 'T'
149900180227     C*                  EXSR      WRITECHARGES
150000180227     C*                  ENDIF
150100180227     C*                  ELSE
150200180227     C*                  EVAL      HOLDTAXES='0000000000'
150300180227     C*                  ENDIF
150400180124      * @1607b : End
150500180213      * @uxh : Begin
150600180213     C***                ENDIF
150700180213      * @uxh : End
150800160311     C                   ENDSR
150900160311      *
151000180411      * @1647 : Begin
151100180411      **********************************************************************
151200180411     ?* Build XML for Start Workflow , Addnotelog parts
151300180411     ?* and invoke CFE Persist document Webservice
151400180411      *********************************************************************
151500180411     C     CrtCFEXML     BEGSR
151600180411      *
151700180411     ?* PART1 -------------------------------------
151800180411     C                   EVAL      wAPPLID = 'CFE'
151900180411     C                   EVAL      WSOPER  = 'StartWorkflow'
152000180411     C                   EVAL      ErrNote = *Blanks
152100180411     C                   EVAL      RETCODE = '00'
152200180411      *
152300180411     ?* Generate xml for StartWorkflow
152400180411     C                   CALL      'WSCFEIMPR'   ParmCFEXML
152500180411      *
152600180411     C                   If        RETCODE='00'
152700180411     C                   EVAL      WRETCODE = '00'
152800180411     ?* Invoke CFE webservice for StartWorkflow
152900180411     C                   CALL      'WSCLIENT'    ParmCFEWEB
153000180411      *
153100180411     C                   Select
153200180411     C                   When      WRETCODE = '98'
153300180411     C                   EVAL      E5MSGVAR = 'Error  : ' +
153400180411     C                             'Adding to worklist for ' +
153500180411     C                             'invoice number/Objectid: '  +
153600180411     C                             %TRIMR(HDRINVNO)+' / '+ %TRIM(HDROBJID)
153700180411     C                   EXSR      WRITEPF5
153800180411     C                   Endsl
153900180411      *
154000180411     C                   Endif
154100180411      *
154200180411     ?* PART2 -------------------------------------
154300180411     C                   EVAL      WSOPER  = 'AddNotelog'
154400180411     C                   EVAL      ErrNote = WErrNote
154500180411     C                   EVAL      RETCODE = '00'
154600180411      *
154700180411     ?* Generate xml for AddNotelog
154800180411     C                   CALL      'WSCFEIMPR'   ParmCFEXML
154900180411      *
155000180411     C                   If        RETCODE='00'
155100180411     C                   EVAL      WRETCODE = '00'
155200180411     ?* Invoke CFE webservice for AddNotelog
155300180411     C                   CALL      'WSCLIENT'    ParmCFEWEB
155400180411      *
155500180411     C                   Select
155600180411     C                   When      WRETCODE = '98'
155700180411     C                   EVAL      E5MSGVAR = 'Error  : ' +
155800180411     C                             'Adding to Notelog for ' +
155900180411     C                             'invoice number/Objectid: '  +
156000180411     C                             %TRIMR(HDRINVNO)+' / '+ %TRIM(HDROBJID)
156100180411     C                   EXSR      WRITEPF5
156200180411     C                   Endsl
156300180411      *
156400180411     C                   Endif
156500180411      *
156600180411     C                   ENDSR
156700180411      * @1647 : End
156800171212      *******************************************************************
156900160311      * COMMENT
157000171212      *******************************************************************
157100160311      *
157200160311     C     SRCOMMENT     BEGSR
157300160311     C                   EVAL      DSCOMMENT = EDIRCD7
157400160328     C                   EVAL      E7KEY1 = E7KEY1
157500160328     C                   EVAL      E7KEY2 = E7KEY2
157600160328     C                   EVAL      E7KEY3 = E7KEY3
157700160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
157800160510     C                   EVAL      E7KEY5 = E7KEY5
157900160328     C                   EXSR      WRITEPF7
158000160311     C                   ENDSR
158100160311      *
158200171212      *******************************************************************
158300160311      * DETAIL
158400171212      *******************************************************************
158500160311      *
158600160311     C     SRDETAIL      BEGSR
158700180228      * @1622: Begin
158800180302     C                   Eval      IBMIND = *Blanks
158900180303     C                   IF        HDRCNTRYCOD  = 'CA'
159000180228     C                   Eval      IBMIND = 'N'
159100180228     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
159200180228     C                   If        IBMCHK  <> 0
159300180228     C                   Eval      IBMIND = 'Y'
159400180228     C                   EndIf
159500180228     C                   ENDIF
159600180302      *
159700180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
159800180302     C                   EVAL      CATAXSPD ='Y'
159900180302     C                   ENDIF
160000180228      * @1622: End
160100160311     C                   EVAL      DSDETAIL = EDIRCD7
160200160330     C                   EVAL      DTLTAXCODE = E7VATCOD
160300171220      * @1607a: Begin
160400171114     C***                IF        DETLINESEQ = '0000001'
160500180129     C                   EVAL      DTLCOUNT = DTLCOUNT + 1
160600171114     C***                ENDIF
160700171220      * @1607a: End
160800160708
160900160526     C                   EVAL      DTLCOUNTA = DTLCOUNTA + 1
161000160328     C                   EVAL      E7KEY1 = E7KEY1
161100160328     C                   EVAL      E7KEY2 = DETLINESEQ
161200180129     C                   EVAL      E7KEY3 = DTLCOUNT
161300160328     C                   EVAL      E7KEY4 = 0
161400160708
161500160510     C                   IF        %LEN(%TRIMR(DETMCHTYP)) > 0
161600160511     C                   IF        %LEN(%TRIMR(DETMCHMOD)) > 0
161700160510     C                   EVAL      E7KEY5 = 'TM'
161800160511     C                   ENDIF
161900160510     C                   ELSE
162000160510     C                   IF        DETCHARG > '0000000000'
162100160510     C                   EVAL      E7KEY5 = 'OC'
162200160510     C                   ELSE
162300160510     C                   EVAL      E7KEY5 = 'P '
162400160510     C                   ENDIF
162500160510     C                   ENDIF
162600160708      *
162700160708      * for upfront states calculate detail line tax amount
162800160708      *
162900171107     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
163000171107     C                   EVAL      SCAN_POS =
163100171107     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
163200180228      *
163300180303     C                   IF        (HDRCNTRYCOD ='US' and SCAN_POS > 0)
163400180303     C                             or (HDRCNTRYCOD ='CA' and CATAXSPD ='Y')
163500180226      * @1607e : Begin
163600180226     C***                EVAL      TAXAMT = %DECH((DETUNTPRC *
163700180226     C***                                         TAXPCT)/100:10:4)
163800180226     C                   EVAL      TAXAMT = %DECH((DETUNTPRC *
163900180226     C                                            TAXPCT)/100:10:2)
164000180226      * @1607e : End
164100180926      * @1687 : Begin
164200180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
164300180924     C                   EVAL      TAXAMT2 = TAXAMT * 100
164400180926      * @1687 : End
164500160706     C                   EVAL      TAXACCUM = TAXACCUM - TAXAMT
164600160616     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
164700160616     C                   EVAL      EDIRCD7 = DSDETAIL
164800180423      * @1652 : Begin
164900180423     C***                EVAL      E7VATCOD = 'I2'
165000180423     C                   EVAL      E7VATCOD = 'I1'
165100180423      * @1652 : End
165200160616     C                   ENDIF
165300160708
165400180323      * @1607h : Begin
165500180323      * for non upfront states
165600180323     C                   Select
165700180710     C                   When      (HDRCNTRYCOD = 'US' and TAXSTATE = 0) OR
165800180710      * @1622a: Begin
165900180710     C                             (HDRCNTRYCOD = 'CA' and CATAXSPD = 'N')
166000180710      * @1622a: End
166100180323     C                   Other
166200180323      * @1607h : End
166300160609     C                   IF        DETLINTAX > '0000000000'
166400160609     C                   EVAL      INVOICETAX(INVOICENDX) = '1'
166500160609     C                   ENDIF
166600180323      * @1607h : Begin
166700180323     C                   Endsl
166800180323      * @1607h : End
166900160328     C                   EXSR      WRITEPF7
167000160311     C                   ENDSR
167100160311      *
167200171212      ******************************************************************
167300160311      * SERIAL
167400171212      ******************************************************************
167500160311      *
167600160311     C     SRSERIALNO    BEGSR
167700160311     C                   EVAL      DSSERIAL  = EDIRCD7
167800160328     C                   EVAL      E7KEY1 = E7KEY1
167900160328     C                   EVAL      E7KEY2 = E7KEY2
168000160328     C                   EVAL      E7KEY3 = E7KEY3
168100160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
168200160510     C                   EVAL      E7KEY5 = E7KEY5
168300180302      *
168400180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
168500180302     C                   EVAL      CATAXSPD ='Y'
168600180302     C                   ENDIF
168700180302      *
168800160328     C                   EXSR      WRITEPF7
168900160311     C                   ENDSR
169000160311      *
169100171212      ******************************************************************
169200160311      * FEATURE
169300171212      ******************************************************************
169400160311      *
169500160311     C     SRFEATURE     BEGSR
169600160311     C                   EVAL      DSFEATURE = EDIRCD7
169700160328     C                   EVAL      E7KEY1 = E7KEY1
169800160328     C                   EVAL      E7KEY2 = E7KEY2
169900160328     C                   EVAL      E7KEY3 = E7KEY3
170000160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
170100160510     C                   EVAL      E7KEY5 = E7KEY5
170200160328     C                   EXSR      WRITEPF7
170300160311     C                   ENDSR
170400160311      *
170500171212      ******************************************************************
170600160311      * TRAILER
170700171212      ******************************************************************
170800160311      *
170900160311     C     SRTRAILER     BEGSR
171000160311     C                   EVAL      DSTRAILER = EDIRCD7
171100160314      *
171200160314      * Validate number of detail lines
171300160314      *
171400160526     C                   IF        HOLDDTL <> DTLCOUNTA
171500160316     C                   EVAL      HEADERIND = 1
171600160526     C                   EVAL      INCOUNT = %CHAR(DTLCOUNTA)
171700160314     C                   EVAL      CNTLCOUNT = %CHAR(HOLDDTL)
171800160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
171900160314     C                             'Number of detail lines does not '   +
172000160314     C                             'match number of detail lines in '   +
172100160314     C                             'invoice header.  Number of lines '  +
172200160314     C                             'in header: '                        +
172300160314     C                             %TRIMR(CNTLCOUNT)                    +
172400160314     C                             '; Number of lines in file: '        +
172500160314     C                             %TRIMR(INCOUNT)
172600160316     C                   EXSR      WRITEPF5
172700160314     C                   EVAL      *INLR = *ON
172800160314     C                   RETURN
172900160314     C                   ENDIF
173000160314      *
173100160314      * Validate number of invoices
173200160314      *
173300160316     C                   EVAL      POS =%CHECK('0123456789':TRLNUMINV)
173400160316     C                   IF        POS > 0
173500160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
173600160316     C                             'Invoice count is not numeric in ' +
173700160316     C                             'trailer'
173800160316     C                   EXSR      WRITEPF5
173900160316     C                   EVAL      *INLR = *ON
174000160316     C                   RETURN
174100160316     C                   ENDIF
174200160708
174300160316     C                   IF        TOTINVCNT <> %DEC(TRLNUMINV:5:0)
174400160316     C                   EVAL      INCOUNT = %CHAR(TOTINVCNT)
174500160316     C                   EVAL      CNTLCOUNT = TRLNUMINV
174600160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
174700160314     C                             'Number of invoices does not match ' +
174800160314     C                             'number of invoices in trailer.  '   +
174900160314     C                             'Number of invoices counted: '       +
175000160314     C                             %TRIMR(INCOUNT)                      +
175100160314     C                             '; Number of invoices in trailer: '  +
175200160314     C                             %TRIMR(CNTLCOUNT)
175300160316     C                   EXSR      WRITEPF5
175400160314     C                   EVAL      *INLR = *ON
175500160314     C                   RETURN
175600160314     C                   ENDIF
175700160314      *
175800160314      * Validate invoice amount hash total
175900160314      *
176000160316     C                   EVAL      POS =%CHECK('0123456789':TRLTOTAMT)
176100160316     C                   IF        POS > 0
176200160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
176300160316     C                             'Total amount is not numeric in ' +
176400160316     C                             'trailer'
176500160316     C                   EXSR      WRITEPF5
176600160316     C                   EVAL      *INLR = *ON
176700160316     C                   RETURN
176800160316     C                   ENDIF
176900160708
177000160316     C                   EVAL      INTAMT = %INT(TRLTOTAMT)
177100160316     C                   EVAL      DECAMT = INTAMT / 100
177200160316     C                   IF        TOTINVAMT <> DECAMT
177300160316     C                   EVAL      INCOUNT = %CHAR(TOTINVAMT)
177400160316     C                   EVAL      CNTLCOUNT = TRLTOTAMT
177500160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
177600160314     C                             'Calculated invoice amount does not '+
177700160314     C                             'match total invoice amount in '     +
177800160314     C                             'invoice trailer.  Calculated '      +
177900160314     C                             'invoice amount: '                   +
178000160314     C                             %TRIMR(INCOUNT)                      +
178100160314     C                             '; Total invoice amount in trailer: '+
178200160314     C                             %TRIMR(CNTLCOUNT)
178300160316     C                   EXSR      WRITEPF5
178400160314     C                   EVAL      *INLR = *ON
178500160314     C                   RETURN
178600160314     C                   ENDIF
178700160708
178800180305      * @1622: Begin
178900180305     C                   Eval      IBMIND = *Blanks
179000180305     C                   IF        HDRCNTRYCOD  = 'CA'
179100180305     C                   Eval      IBMIND = 'N'
179200180305     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
179300180305     C                   If        IBMCHK  <> 0
179400180305     C                   Eval      IBMIND = 'Y'
179500180305     C                   EndIf
179600180305     C                   ENDIF
179700180305      *
179800180305     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
179900180305     C                   EVAL      CATAXSPD ='Y'
180000180305     C                   ENDIF
180100180305      * @1622: End
180200180305
180300160526     C                   IF        HOLDMISCCHG > '0000000000'
180400160526     C                   EVAL      HOLDCHG = 'M'
180500160526     C                   EXSR      WRITECHARGES
180600160526     C                   ENDIF
180700160708
180800160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
180900160526     C                   EVAL      HOLDCHG = 'F'
181000160526     C                   EXSR      WRITECHARGES
181100160526     C                   ENDIF
181200160708
181300180228
181400180228      * Write taxes as separate record
181500180228      *
181600180228      * @uxh : Begin
181700180228      * New detail line tax record only for US and CA
181800180228     C                   Select
181900180228      *
182000180303     C                   When      HOLDTAXES <>'0000000000'
182100180303     C                             AND HDRCNTRYCOD  ='US'
182200180228     C                             AND TAXSTATE = 0
182300180228     C                   EVAL      HOLDCHG = 'T'
182400180228     C                   EXSR      WRITECHARGES
182500180228      *
182600180303     C                   When      HOLDTAXES <>'0000000000'
182700180303     C                             AND HDRCNTRYCOD  ='CA'
182800180228     C                             AND IBMIND  = 'N'
182900180228     C                   EVAL      HOLDCHG = 'T'
183000180228     C                   EXSR      WRITECHARGES
183100180228      *
183200180228     C                   Other
183300180228     C                   EVAL      HOLDTAXES = '0000000000'
183400180228      *
183500180228     C                   Endsl
183600180228      * @uxh : End
183700160708
183800180202     C                   EXSR      CpyPF7BPF7A
183900180202
184000160328     C                   EVAL      E7KEY1 = 9999998
184100160328     C                   EVAL      E7KEY2 = '0000000'
184200160328     C                   EVAL      E7KEY3 = 0
184300160328     C                   EVAL      E7KEY4 = 0
184400160510     C                   EVAL      E7KEY5 = '  '
184500160328     C                   EXSR      WRITEPF7
184600160311     C                   ENDSR
184700160311      *
184800171212      ********************************************************************
184900160311      * FILE TRAILER
185000171212      ********************************************************************
185100160311      *
185200160311     C     SRFILETRL     BEGSR
185300160311     C                   EVAL      DSFILETRL = EDIRCD7
185400160314     C                   EVAL      TRLCOUNT = 1
185500160328     C                   EVAL      E7KEY1 = 9999999
185600160328     C                   EVAL      E7KEY2 = '0000000'
185700160328     C                   EVAL      E7KEY3 = 0
185800160328     C                   EVAL      E7KEY4 = 0
185900160510     C                   EVAL      E7KEY5 = '  '
186000160328     C                   EXSR      WRITEPF7
186100160311     C                   ENDSR
186200160526      *
186300171212      ********************************************************************
186400160526      * WRITE FREIGHT/MISC/TAXES
186500171212      ********************************************************************
186600160526      *
186700160526     C     WRITECHARGES  BEGSR
186800171212      *
186900160526     C                   CLEAR                   DSDETAIL
187000180129     C                   EVAL      DTLCOUNT = DTLCOUNT + 1
187100160526     C                   EVAL      E7KEY1 = E7KEY1
187200160526     C                   EVAL      E7KEY2 = '0000001'
187300180129     C                   EVAL      E7KEY3 = DTLCOUNT
187400160526     C                   EVAL      E7KEY4 = 0
187500160526     C                   EVAL      DETQTY = 1
187600160708
187700160526     C                   IF        HOLDCHG = 'M'
187800160526     C                   IF        HOLDMISCCHG > '0000000000'
187900161104     C                   EVAL      E7KEY5 = 'P '
188000161104     C                   EVAL      DETPARTNUM = 'MISC'
188100180213      * @UXH : Begin
188200180213     C                   EVAL      DETEQSRC = *Blanks
188300180213      * @UXH : End
188400160526     C                   EVAL      DETPRTDSC = 'misc charge'
188500160526     C                   EVAL      INTAMT = %INT(HOLDMISCCHG)
188600160526     C                   EVAL      DECAMT = INTAMT / 100
188700180206     C                   EVAL      DETUNTPRC = DECAMT
188800160526     C                   EVAL      HOLDMISCCHG = '0000000000'
188900160526     C                   ENDIF
189000160526     C                   ENDIF
189100160708
189200160526     C                   IF        HOLDCHG = 'F'
189300160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
189400180213      *
189500180213     C                   Select
189600180213      *
189700180213     C                   WHEN      %TRIM(HDRINVTYPE) = 'IBM'
189800180213     C                   EVAL      DETMCHTYP = '9OT9'
189900180213     C                   EVAL      DETMCHMOD = 'IBM'
190000180213     C                   EVAL      DETEQSRC =  'IB'
190100180213      *
190200180213     C                   WHEN      %TRIM(HDRINVTYPE) = 'VEN'
190300180213     C                   EVAL      DETEQSRC =  'BP'
190400170831      *
190500180213     C                   EVAL      FREIGHTKEY1 = %TRIM(HDRCNTRYCOD)
190600161107     C                   EVAL      FREIGHTKEY2 = HDRINVTYPE
190700161107     C     FREIGHTKEY    CHAIN     EDIFRTCTL
190800170831     C                   IF        %FOUND
190900161107     C                   EVAL      DETMCHTYP = EDIFMACTYP
191000161107     C                   EVAL      DETMCHMOD = EDIFMODEL
191100170831     C                   ENDIF
191200180213      *
191300180213     C                   ENDSL
191400180213      *
191500161107     C                   EVAL      E7KEY5 = 'TM'
191600160526     C                   EVAL      DETPRTDSC = 'shipping charge'
191700160526     C                   EVAL      INTAMT = %INT(HOLDFREIGHTCHG)
191800160526     C                   EVAL      DECAMT = INTAMT / 100
191900160526     C                   EVAL      DETUNTPRC = DECAMT
192000160526     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
192100160526     C                   ENDIF
192200160526     C                   ENDIF
192300160708
192400160526     C                   IF        HOLDCHG = 'T'
192500171107      * @1622: Begin
192600171025     C                   Select
192700180206      * @uxh : Begin
192800180206     C***                When      HOLDTAXES>'0000000000' and HDRCNTRYCOD<>'CA'
192900180303     C                   When      HOLDTAXES<>'0000000000'
193000180303     C                             and HDRCNTRYCOD = 'US'
193100180303     C                             and TAXSTATE = 0
193200180206      * @uxh : End
193300171107      * @1622: End
193400161104     C                   EVAL      E7KEY5 = 'TM'
193500160526     C                   EVAL      DETMCHTYP = '9TX8'
193600160526     C                   EVAL      DETMCHMOD = 'TAX'
193700160526     C                   EVAL      INTAMT = %INT(HOLDTAXES)
193800180206     C                   EVAL      DECAMT = INTAMT / 100
193900180206      * @uxh : Begin
194000180213     C                   EVAL      DETUNTPRC = DECAMT
194100180209     C*                  MOVE      DECAMT        DETLINTAX
194200180206      *
194300180206     C                   IF        HDRINVTYPE = 'IBM'
194400180206     C                   EVAL      DETEQSRC = 'IB'
194500180228     C                   ELSEIF    HDRINVTYPE = 'VEN'
194600180206     C                   EVAL      DETEQSRC = 'BP'
194700180206     C                   ELSE
194800180206     C                   EVAL      DETEQSRC = '  '
194900180206     C                   ENDIF
195000180206      * @uxh : End
195100160526     C                   EVAL      HOLDTAXES = '0000000000'
195200171107      * @1622: Begin
195300180303     C                   When      HOLDTAXES<>'0000000000'
195400180303     C                             and HDRCNTRYCOD = 'CA'
195500171025     C                   EVAL      E7KEY5 = 'TM'
195600171101     C                   IF        IBMIND = 'N'
195700171025     C                   EVAL      DETMCHTYP = '9TX8'
195800171025     C                   EVAL      DETMCHMOD = 'HST'
195900171101     C                   ENDIF
196000171025     C                   EVAL      INTAMT = %INT(HOLDTAXES)
196100171025     C                   EVAL      DECAMT = INTAMT / 100
196200180206      * @uxh : Begin
196300180209     C                   EVAL      DETUNTPRC = DECAMT
196400180209     C**                 MOVE      DECAMT        DETLINTAX
196500180206      * @uxh : End
196600180228     C                   IF        HDRINVTYPE = 'IBM'
196700180228     C                   EVAL      DETEQSRC = 'IB'
196800180228     C                   ELSEIF    HDRINVTYPE = 'VEN'
196900180228     C                   EVAL      DETEQSRC = 'BP'
197000180228     C                   ELSE
197100180228     C                   EVAL      DETEQSRC = '  '
197200180228     C                   ENDIF
197300171025     C                   EVAL      HOLDTAXES = '0000000000'
197400180220      * @1607d : Begin
197500180220     C                   Other
197600180220     C                   EVAL      HOLDTAXES = '0000000000'
197700180220      * @1607d : End
197800171025     C                   ENDSL
197900171107      * @1622: End
198000160526     C                   ENDIF
198100160708
198200180206      * @UXH : Begin
198300180206     C***                IF        %TRIMR(HDRCNTRYCOD) = 'US'
198400180206     C***                IF        HDRINVTYPE = 'IBM'
198500180206     C***                EVAL      DETEQSRC = 'IB'
198600180206     C***                ELSE
198700180206     C***                IF        HDRINVTYPE = 'VEN'
198800180206     C***                EVAL      DETEQSRC = 'BP'
198900180206     C***                ELSE
199000180206     C***                EVAL      DETEQSRC = '  '
199100180206     C***                ENDIF
199200180206     C***                ENDIF
199300180206     C***                ENDIF
199400180206      * @UXH : End
199500161103
199600160526     C                   EVAL      DETRCDID = RECTYPE5
199700180302     C                   IF        TAXSTATE = 0 and CATAXSPD<>'Y'
199800160526     C                   EVAL      E7SKEY1 = E7KEY1
199900160526     C                   EVAL      E7SKEY2 = E7KEY2
200000160526     C                   EVAL      E7SKEY3 = E7KEY3
200100160526     C                   EVAL      E7SKEY4 = E7KEY4
200200160526     C                   EVAL      E7SKEY5 = E7KEY5
200300160526     C                   EVAL      EDIRCD7S = DSDETAIL
200400171206     C                   WRITE     EDIPF7SR                             70
200500171206     C                   EXSR      ErrPF7A
200600161206     C                   ELSE
200700180226      * @1607e : Begin
200800180226     C***                EVAL      TAXAMT = %DECH((DETUNTPRC *
200900180226     C***                                         TAXPCT)/100:10:4)
201000180226     C                   EVAL      TAXAMT = %DECH((DETUNTPRC *
201100180226     C                                            TAXPCT)/100:10:2)
201200180226      * @1607e : End
201300180926      * @1687 : Begin
201400180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
201500180924     C                   EVAL      TAXAMT2 = TAXAMT * 100
201600180926      * @1687 : End
201700161206     C                   EVAL      TAXACCUM = TAXACCUM - TAXAMT
201800161206     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
201900180423      * @1652 : Begin
202000180423     C***                EVAL      E7VATCOD = 'I2'
202100180423     C                   EVAL      E7VATCOD = 'I1'
202200180423      * @1652 : End
202300161206     C                   EVAL      E7TKEY1 = E7KEY1
202400161206     C                   EVAL      E7TKEY2 = E7KEY2
202500161206     C                   EVAL      E7TKEY3 = E7KEY3
202600161206     C                   EVAL      E7TKEY4 = E7KEY4
202700161206     C                   EVAL      E7TKEY5 = E7KEY5
202800161206     C                   EVAL      EDIRCD7T = DSDETAIL
202900171213     C                   WRITE     EDIPF7TR                             70
203000171213     C                   EXSR      ErrPF7B
203100161206     C                   ENDIF
203200160526     C                   ENDSR
203300171206      *************************************************************
203400171206      * EDIPF7A error logging on write
203500171206      *************************************************************
203600171206     C     ErrPF7A       Begsr
203700171206      *
203800171206     C                   IF        *IN70
203900171206     C                   CLEAR                   ERRORDS
204000171206     C                   EVAL      MSGID    = 'ICC6700'
204100171206     C                   EVAL      FILENAME = PF7AFIL
204200171206     C                   EVAL      OPCODE   = PF7AOPC
204300171206     C                   EVAL      STATUS   = PF7AFST
204400171206     C                   EVAL      EXTMSG   = 'Write failed while ' +
204500171206     C                             'processing GCMS EDI for ' +
204600171206     C                              PRMMBRNAME
204700171206     C                   EXSR      ERRLOG
204800171206     C                   ENDIF
204900171206      *
205000171206     C                   Endsr
205100171213      *************************************************************
205200171213      * EDIPF7B error logging on write
205300171213      *************************************************************
205400171213     C     ErrPF7B       Begsr
205500171213      *
205600171213     C                   IF        *IN70
205700171213     C                   CLEAR                   ERRORDS
205800171213     C                   EVAL      MSGID    = 'ICC6700'
205900171213     C                   EVAL      FILENAME = PF7BFIL
206000171213     C                   EVAL      OPCODE   = PF7BOPC
206100171213     C                   EVAL      STATUS   = PF7BFST
206200171213     C                   EVAL      EXTMSG   = 'Write failed while ' +
206300171213     C                             'processing GCMS EDI for ' +
206400171213     C                              PRMMBRNAME
206500171213     C                   EXSR      ERRLOG
206600171213     C                   ENDIF
206700171213      *
206800171213     C                   Endsr
206900171206      *************************************************************
207000160322      * FILE HEADER
207100171212      *************************************************************
207200160322      *
207300160322     C     XMLFILEHDR    BEGSR
207400160329     C                   EVAL      DSFILEHDR = EDIRCD7S
207500160322     C                   ENDSR
207600171212      *************************************************************
207700160322      * CONTROL
207800171212      *************************************************************
207900160322      *
208000160322     C     XMLCONTROL    BEGSR
208100160325     C                   IF        PROCESSINV <> 0
208200160330     C                   EXSR      ENDOFINV
208300180917      * @1685 : Begin
208400180917     C***                EVAL      BUFFER = ' '
208500180917      * @1685 : End
208600171206     C                   EVAL      BUFFER1= *Blanks
208700160325     C                   ENDIF
208800160708
208900161116     C                   EVAL      INVOICENDX = INVOICENDX + 1
209000160325     C                   EVAL      PROCESSINV = PROCESSINV + 1
209100160411     C                   EVAL      DSCONTROL = EDIRCD7S
209200160620     C                   EVAL      EDIXMLLEN = 0
209300171212     C                   EVAL      wrkXMLCTL  = *Blanks
209400171212     ?* Time ***
209500171212     C                   TIME                    TIMSTP
209600171212     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
209700171212      *
209800171212      *
209900171208       /free
210000171212     ?* Clear old xml - EDI
210100171212     ?* O_CREAT indicates create file if not exist
210200171208            fd  = open(%trim($file_path)
210300171208                       : O_WRONLY+O_CREAT+O_TRUNC
210400171208                       : S_IRGRP + S_IWGRP + S_IXGRP +
210500180309                          S_IRUSR + S_IWUSR + S_IXUSR+S_IROTH+S_IXOTH);
210600171208
210700171208            callp close(fd);
210800171212     ?* Compose new xml  - EDI
210900171208            fd = open(%trim($file_path)
211000171208                      :O_WRONLY+O_TEXTDATA);
211100171208       /end-free
211200171208      *
211300171212     C                   EVAL      WrkXMLCTL = '<?xml version="1.0" '  +
211400171212     C                                         'encoding="UTF-8"?>'    +
211500171212      *
211600171212     C                                         '<soapenv:Envelope '           +
211700160331     C                                         'xmlns:xsl="http://www.w3.org' +
211800160331     C                                         '/2001/XMLSchema-instance" '   +
211900160331     C                                         'xmlns:xsd="http://www.w3.org/'+
212000160331     C                                         '2001/XMLSchema" xmlns:soapenv'+
212100160331     C                                         '="http://schemas.xmlsoap.org' +
212200171212     C                                         '/soap/envelope/">'            +
212300171212      *
212400171212     C                                         '<soapenv:Header>'             +
212500190429      *
212600190429     C                                         '<wsse:Security '              +
212700190430     C                                         'xmlns:wsu="http://docs.oasis' +
212800190429     C                                         '-open.org/wss/2004/01/oasis-' +
212900190429     C                                         '200401-wss-wssecurity-utility'+
213000190429     C                                         '-1.0.xsd">'                   +
213100171212      *
213200171212     C                                         '<wsa:To soapenv:mustUnderstand'+
213300160331     C                                         '="0" '                        +
213400160331     C                                         'xmlns:wsa="http://schemas.xml'+
213500160331     C                                         'soap.org/ws/2004/03/'         +
213600160331     C                                         'addressing">jms:/queue?destin'+
213700160331     C                                         'ation=jms/IGFHUB/IGFHUBeBizW' +
213800170531     C                                         'SRequest&amp;amp;connectionFa'+
213900160331     C                                         'ctory=jms/IGFHUB/SOAPJMSFacto'+
214000171212     C                                         'ry</wsa:To>'                  +
214100171212      *
214200171212     C                                         '<wsa:Action '                 +
214300160331     C                                         'xmlns:wsa="http://schemas.xml'+
214400160331     C                                         'soap.org/ws/2004/03/'         +
214500160331     C                                         'addressing" soapenv:mustUnde' +
214600160331     C                                         'rstand="0">jms:/targetService'+
214700171212     C                                         '=ProcessInvoice</wsa:Action>' +
214800171212      *
214900171212     C                                         '<wsa:ReplyTo '                +
215000160331     C                                         'xmlns:wsa="http://schemas.xml'+
215100160331     C                                         'soap.org/ws/2004/03/'         +
215200160331     C                                         'addressing" soapenv:mustUnde' +
215300171212     C                                         'rstand="0">'                  +
215400171212      *
215500171212     C                                         '<wsa:Address '                +
215600160331     C                                         'xmlns:wsa="http://schemas.xml'+
215700160331     C                                         'soap.org/ws/2004/03/'         +
215800160331     C                                         'addressing">jms:/queue?destin'+
215900161227     C                                         'ation=jms/'                   +
216000171212     C                                         %TRIMR(WSOAPADR)               +
216100171212     C                                         '</wsa:Address>'               +
216200171212      *
216300171212     C                                         '</wsa:ReplyTo>'               +
216400171212      *
216500171212     C                                         '<wsa:MessageId '              +
216600160331     C                                         'xmlns:wsa="http://schemas.xml'+
216700160331     C                                         'soap.org/ws/2004/03/'         +
216800160331     C                                         'addressing" soapenv:mustUnde' +
216900171212     C                                         'rstand="0"> </wsa:MessageId>' +
217000171212      *
217100171212     C                                         '<Application soapenv:mustUnde'+
217200160331     C                                         'rstand="0" xmlns="">GAPTS'    +
217300171212     C                                         '</Application>'               +
217400171212      *
217500171212     C                                         '<Environment soapenv:mustUnde'+
217600161227     C                                         'rstand="0" xmlns="">'         +
217700171212     C                                         %TRIMR(wXMLENV)                +
217800171212     C                                         '</Environment>'               +
217900171212      *
218000171212     C                                         '<Format soapenv:mustUnderstan'+
218100160331     C                                         'd="0" xmlns="">ProcessInvoice'+
218200171212     C                                         '</Format>'                    +
218300171212      *
218400171212     C                                         '<ServiceParameter soapenv:mus'+
218500171212     C                                         'tUnderstand="0" xmlns=""/>'   +
218600171212      *
218700171212     C                                         '<RefId soapenv:mustUnderstan' +
218800160509     C                                         'd="0" xmlns="">'              +
218900160509     C                                         HOLDTIME                       +
219000171212     C                                         '</RefId>'                     +
219100171212      *
219200171212     C                                         '</soapenv:Header>'            +
219300171212      *
219400171212     C                                         '<soapenv:Body>'               +
219500171212      *
219600171212     C                                         '<ProcessInvoice'               +
219700160325     C                                         ' xmlns="http://www.ibm.com/'   +
219800160325     C                                         'xmlns/ims/1.3/ProcessInvoice'  +
219900160325     C                                         '_2012-12-20" xmlns:ns2="'      +
220000160325     C                                         'http://www.openapplications'   +
220100160325     C                                         '.org/oagis/8.2/ProcessInvoice' +
220200171212     C                                         '_2012-12-20" revision="1.0">'  +
220300171212      *
220400171212     C                                         '<ApplicationArea>'             +
220500171212      *
220600171212     C                                         '<ns2:Sender>'                  +
220700171212      *
220800171212     C                                         '<ns2:Component>'      +
220900160325     C                                         'GAPTS'                +
221000171212     C                                         '</ns2:Component>'     +
221100171212      *
221200171212     C                                         '</ns2:Sender>'        +
221300171212      *
221400171212     C                                         '<ns2:CreationDateTime>'  +
221500160325     C                                         '1970-01-01T00:00:00.000-05:00' +
221600171212     C                                         '</ns2:CreationDateTime>'  +
221700171212      *
221800171212     C                                         '<ns2:BODId>'        +
221900160325     C                                         'GAPTS-'             +
222000160413     C                                         HOLDTIME             +
222100171212     C                                         '</ns2:BODId>'       +
222200171212      *
222300171212     C                                         '<Application/>'     +
222400171212      *
222500171212     C                                         '</ApplicationArea>' +
222600171212      *
222700171212     C                                         '<DataArea>'         +
222800171212      *
222900171212     C                                         '<ns2:Process/>'     +
223000171212      *
223100171212     C                                         '<Invoice>'
223200171212      *
223300171212      *
223400171212     ?* Append buffer
223500171212     C                   IF        INVOICEVALID (INVOICENDX) = '0'
223600171212     C                   EVAL      BUFFER1 = %Trimr(BUFFER1)      +
223700171212     C                                       %Trimr(WrkXMLCTL)
223800171212     C                   ENDIF
223900171212      *
224000160322     C                   ENDSR
224100171212      *****************************************************************
224200171212     ?* End of invoice
224300171212      *****************************************************************
224400160330     C     ENDOFINV      BEGSR
224500171212      *
224600171212     C                   EVAL      EDIXMLDTL = '</Invoice>' +
224700171212      *
224800171212     C                                         '</DataArea>'  +
224900171212      *
225000171212     C                                         '</ProcessInvoice>'  +
225100171212      *
225200171212     C                                         '</soapenv:Body>' +
225300171212      *
225400171212     C                                         '</soapenv:Envelope>'
225500171212     C                   EXSR      WRITEXML
225600171212      *
225700161116     C                   IF        INVOICEVALID (INVOICENDX) = '0'
225800170111     C                   EXSR      MQSR
225900161116     C                   ENDIF
226000171212      *
226100160330     C                   ENDSR
226200171212      *****************************************************************
226300171212     ?* HEADER
226400171212      * ****************************************************************
226500160322      *
226600160322     C     XMLHEADER     BEGSR
226700160708
226800180917      * @1652 : Begin
226900180917     C                   EVAL      Wrkxmldtl1 = *Blanks
227000180917      * @1652 : End
227100160322     C                   EVAL      XMLDTLLINE = 0
227200160329     C                   EVAL      DSHEADER = EDIRCD7S
227300190129      * @1712 : Begin
227400190129      * Do not create XML for invalid invoices
227500190129     C                   IF        INVOICEVALID (INVOICENDX) = '1'
227600190129     C                   LEAVESR
227700190129     C                   ENDIF
227800190129      * @1712 : End
227900180303      * @1622: Begin
228000180303     C                   Eval      IBMIND = *Blanks
228100180303     C                   IF        HDRCNTRYCOD  = 'CA'
228200180303     C                   EVAL      wPROVINCE = HDRSHPSTA
228300180303     C                   Eval      IBMIND = 'N'
228400180303     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
228500180303     C                   If        IBMCHK  <> 0
228600180303     C                   Eval      IBMIND = 'Y'
228700180303     C                   EndIf
228800180303     C                   ELSE
228900180303     C                   EVAL      wPROVINCE = *Blanks
229000180303     C                   ENDIF
229100180303      * @1622: End
229200180303     C                   IF        %LEN(%TRIMR(HDRFREIGHTCHARG))= 0
229300180303     C                   EVAL      HDRFREIGHTCHARG = '0000000000'
229400180303     C                   ENDIF
229500180303
229600180303     C                   IF        %LEN(%TRIMR(HDRMISCCHARG))= 0
229700180303     C                   EVAL      HDRMISCCHARG = '0000000000'
229800180303     C                   ENDIF
229900180303
230000180303     C                   IF        %LEN(%TRIMR(HDRTAXES))= 0
230100180303     C                   EVAL      HDRTAXES = '0000000000'
230200180303     C                   ENDIF
230300180303      *
230400160329     C                   EVAL      HDROBJID = E7SOBJID
230500160329     C                   EVAL      HDRINVTYPE = E7SINVTYP
230600160329     C                   EVAL      HDRSRANUM = E7SSRA#
230700160329     C                   EVAL      HDRPOEX   = E7SPOEX
230800160330     C                   EVAL      HDRVENNUM = E7SSUPLR
230900160329     C                   EVAL      HDRVENNAME = E7SNAME
231000160329     C                   EVAL      HDRCOMPCODE = E7SCMPCODE
231100160325     C                   EVAL      EDIXMLDTL = '<Header>'
231200160325     C                   EXSR      WRITEXML
231300160325     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
231400160325     C                   EXSR      WRITEXML
231500160325     C                   EVAL      EDIXMLDTL = '<ns2:SupplierDocumentId>'
231600160325     C                   EXSR      WRITEXML
231700160325     C                   EVAL      EDIXMLDTL = '<ns2:Id type="E" '         +
231800160505     C                                         'IdOrigin="IBM/Invoice">'   +
231900160328     C                                         %TRIMR(HDRINVNO)            +
232000160325     C                                         '</ns2:Id>'
232100160325     C                   EXSR      WRITEXML
232200160325     C                   EVAL      EDIXMLDTL = '</ns2:SupplierDocumentId>'
232300160325     C                   EXSR      WRITEXML
232400160325     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
232500160325     C                   EXSR      WRITEXML
232600160325     C                   EVAL      EDIXMLDTL = '<LastModificationDateTime>'+
232700160325     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
232800160325     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
232900160325     C                                         %SUBST(HDRINVDAT:7:2)       +
233000160325     C                                         'T00:00:01.000Z'            +
233100160325     C                                         '</LastModificationDateTime>'
233200160325     C                   EXSR      WRITEXML
233300160328     C                   EVAL      EDIXMLDTL = '<DocumentDateTime>'+
233400160328     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
233500160328     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
233600160328     C                                         %SUBST(HDRINVDAT:7:2)       +
233700160328     C                                         'T00:00:01.000Z'            +
233800160328     C                                         '</DocumentDateTime>'
233900160328     C                   EXSR      WRITEXML
234000160707     C                   READ      EDIPF7A
234100160329     C                   DOW       %SUBST(EDIRCD7S:1:10) = RECTYPE4
234200160329     C                   EVAL      DSCOMMENT = EDIRCD7S
234300160328     C                   EVAL      SCAN_FIELD = COMTXT
234400160328     C                   EXSR      REPLACECHAR
234500160328     C                   TIME                    TIMSTP
234600160328     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
234700160328     C                   EVAL      EDIXMLDTL = '<Note entryDateTime="'     +
234800160328     C                                         %CHAR(SYS_DATE) + 'T'       +
234900160328     C                                         %SUBST(HOLDTIME:1:2) + ':'  +
235000160328     C                                         %SUBST(HOLDTIME:3:2) + ':'  +
235100160328     C                                         %SUBST(HOLDTIME:5:2)        +
235200160328     C                                         '.000-04:00">'              +
235300160328     C                                         %TRIMR(SCAN_FIELD)          +
235400160328     C                                         '</Note>'
235500160328     C                   EXSR      WRITEXML
235600160707     C                   READ      EDIPF7A
235700160328     C                   ENDDO
235800160708
235900160707     C                   READP     EDIPF7A
236000160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentReferences>'
236100160328     C                   EXSR      WRITEXML
236200160328     C                   EVAL      EDIXMLDTL = '<ns2:InvoiceDocumentReference>'
236300160328     C                   EXSR      WRITEXML
236400160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
236500160328     C                   EXSR      WRITEXML
236600160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
236700160328     C                   EXSR      WRITEXML
236800170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="GCPS"/>'
236900160328     C                   EXSR      WRITEXML
237000160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
237100160328     C                   EXSR      WRITEXML
237200160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
237300160328     C                   EXSR      WRITEXML
237400170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin='    +
237500160328     C                                         '"ContentManager">'    +
237600160328     C                                         %TRIMR(HDROBJID)       +
237700170605     C                                         '</ns2:Id>'
237800160328     C                   EXSR      WRITEXML
237900160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
238000160328     C                   EXSR      WRITEXML
238100160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
238200160328     C                   EXSR      WRITEXML
238300170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="GIL">'  +
238400160527     C                                         %TRIMR(HDRREFINV)          +
238500170605     C                                         '</ns2:Id>'
238600160328     C                   EXSR      WRITEXML
238700160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
238800160328     C                   EXSR      WRITEXML
238900160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
239000160328     C                   EXSR      WRITEXML
239100160601     C                   IF        %LEN(%TRIMR(HDRDAT)) > 0
239200160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentDate>'   +
239300160328     C                                         %SUBST(HDRDAT:1:4) + '-' +
239400160328     C                                         %SUBST(HDRDAT:5:2) + '-' +
239500160328     C                                         %SUBST(HDRDAT:7:2)     +
239600170517     C                                         'T00:00:01.000Z'       +
239700160328     C                                         '</ns2:DocumentDate>'
239800160601     C                   ELSE
239900160601     C                   EVAL      EDIXMLDTL = '<ns2:DocumentDate>'        +
240000160601     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
240100160601     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
240200160601     C                                         %SUBST(HDRINVDAT:7:2)       +
240300170517     C                                         'T00:00:01.000Z'            +
240400160601     C                                         '</ns2:DocumentDate>'
240500160601     C                   ENDIF
240600160708
240700160328     C                   EXSR      WRITEXML
240800160328     C                   EVAL      EDIXMLDTL = '</ns2:InvoiceDocumentReference>'
240900160328     C                   EXSR      WRITEXML
241000160328     C                   EVAL      EDIXMLDTL = '<ns2:FinancialOffering' +
241100160328     C                                          'LetterDocumentReference>'
241200160328     C                   EXSR      WRITEXML
241300160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
241400160328     C                   EXSR      WRITEXML
241500160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
241600160328     C                   EXSR      WRITEXML
241700170602     C                   EVAL      EDIXMLDTL = '<ns2:Id>'             +
241800160328     C                                         %TRIMR(HDROFFLTR)      +
241900170602     C                                         '</ns2:Id>'
242000160328     C                   EXSR      WRITEXML
242100160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
242200160328     C                   EXSR      WRITEXML
242300160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
242400160328     C                   EXSR      WRITEXML
242500160328     C                   EVAL      EDIXMLDTL = '</ns2:FinancialOffering' +
242600160328     C                                          'LetterDocumentReference>'
242700160328     C                   EXSR      WRITEXML
242800160328     C                   EVAL      EDIXMLDTL = '<ns2:ContractDocumentReference>'
242900160328     C                   EXSR      WRITEXML
243000160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
243100160328     C                   EXSR      WRITEXML
243200160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
243300160328     C                   EXSR      WRITEXML
243400170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="IBM">'  +
243500160328     C                                         %TRIMR(HDRSRANUM)          +
243600170605     C                                         '</ns2:Id>'
243700160328     C                   EXSR      WRITEXML
243800160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
243900160328     C                   EXSR      WRITEXML
244000160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
244100160328     C                   EXSR      WRITEXML
244200160328     C                   EVAL      EDIXMLDTL ='</ns2:ContractDocumentReference>'
244300160328     C                   EXSR      WRITEXML
244400170621     C                   EVAL      EDIXMLDTL = '</ns2:DocumentReferences>'
244500160328     C                   EXSR      WRITEXML
244600160328     C                   EVAL      EDIXMLDTL = '<ns2:OrderStatus>'
244700160328     C                   EXSR      WRITEXML
244800160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>Invoice_' +
244900160328     C                                         'header-Invoice_status'     +
245000160328     C                                         '</ns2:Description>'
245100160328     C                   EXSR      WRITEXML
245200160328     C                   EVAL      EDIXMLDTL = '<ns2:AcknowledgementDetail>'
245300160328     C                   EXSR      WRITEXML
245400160509     C                   EVAL      EDIXMLDTL = '<ns2:Code>N</ns2:Code>'
245500160328     C                   EXSR      WRITEXML
245600160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>invoice_' +
245700160328     C                                         'header-coa_with_invoice_indc' +
245800160328     C                                         '</ns2:Description>'
245900160328     C                   EXSR      WRITEXML
246000160328     C                   EVAL      EDIXMLDTL = '</ns2:AcknowledgementDetail>'
246100160328     C                   EXSR      WRITEXML
246200160328     C                   EVAL      EDIXMLDTL = '<ns2:AcknowledgementDetail>'
246300160328     C                   EXSR      WRITEXML
246400160509     C                   EVAL      EDIXMLDTL = '<ns2:Code>N</ns2:Code>'
246500160328     C                   EXSR      WRITEXML
246600160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>invoice_' +
246700160328     C                                         'header-exception_ind'      +
246800160328     C                                         '</ns2:Description>'
246900160328     C                   EXSR      WRITEXML
247000160328     C                   EVAL      EDIXMLDTL = '</ns2:AcknowledgementDetail>'
247100160328     C                   EXSR      WRITEXML
247200160328     C                   EVAL      EDIXMLDTL = '</ns2:OrderStatus>'
247300160328     C                   EXSR      WRITEXML
247400160329     C                   EVAL      EDIXMLDTL = '<Priority>'                +
247500160505     C                                         'Standard'                  +
247600160329     C                                         '</Priority>'
247700160329     C                   EXSR      WRITEXML
247800160610     C                   IF        INVOICETAX(INVOICENDX) = '1'
247900160610     C                   EVAL      INTAMT = %INT(HDRTOTAMT) -
248000160610     C                                      %INT(HDRTAXES)
248100160610     C                   ELSE
248200160610     C                   EVAL      INTAMT = %INT(HDRTOTAMT)
248300160610     C                   ENDIF
248400160708
248500160329     C                   EVAL      DECAMT = INTAMT / 100
248600160329     C                   EVAL      INCOUNT = %CHAR(DECAMT)
248700160510     C                   IF        HDRDBCRINDIC = 'DR'
248800160510     C                   EVAL      TOTAMTTYPE = 'DB'
248900160510     C                   ELSE
249000160510     C                   EVAL      TOTAMTTYPE = 'CR'
249100160510     C                   ENDIF
249200160708
249300160525     C                   IF        DECAMT < 1
249400160329     C                   EVAL      EDIXMLDTL = '<TotalAmount type="'       +
249500160510     C                                         TOTAMTTYPE                  +
249600160329     C                                         '" currency ="'             +
249700160512     C                                         %TRIMR(HDRCURCOD)           +
249800160525     C                                         '" basis="TotalAmount">0'   +
249900160329     C                                         %TRIMR(INCOUNT)             +
250000160329     C                                         '</TotalAmount>'
250100160525     C                   ELSE
250200160525     C                   EVAL      EDIXMLDTL = '<TotalAmount type="'       +
250300160525     C                                         TOTAMTTYPE                  +
250400160525     C                                         '" currency ="'             +
250500160525     C                                         %TRIMR(HDRCURCOD)           +
250600160525     C                                         '" basis="TotalAmount">'    +
250700160525     C                                         %TRIMR(INCOUNT)             +
250800160525     C                                         '</TotalAmount>'
250900160525     C                   ENDIF
251000160708
251100160329     C                   EXSR      WRITEXML
251200160329     C                   EVAL      EDIXMLDTL = '<TotalAmount currency="'   +
251300160512     C                                         %TRIMR(HDRCURCOD)           +
251400160329     C                                         '" basis="AvailableUnit'    +
251500160329     C                                         'Amount"/>'
251600160329     C                   EXSR      WRITEXML
251700160329     C                   EVAL      EDIXMLDTL = '<ns2:Parties>'
251800160329     C                   EXSR      WRITEXML
251900160329     C                   EVAL      EDIXMLDTL = '<ns2:SupplierParty>'
252000160329     C                   EXSR      WRITEXML
252100170605     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
252200160329     C                   EXSR      WRITEXML
252300170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="Supplier"/>'
252400160329     C                   EXSR      WRITEXML
252500170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="POEX">'  +
252600160329     C                                         %TRIMR(HDRPOEX)     +
252700170605     C                                         '</ns2:Id>'
252800160329     C                   EXSR      WRITEXML
252900170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="SAP">'  +
253000160330     C                                         %TRIMR(HDRVENNUM)   +
253100170605     C                                         '</ns2:Id>'
253200160329     C                   EXSR      WRITEXML
253300170605     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
253400160329     C                   EXSR      WRITEXML
253500181018      * @1691 : Begin
253600181018     C***                EVAL      EDIXMLDTL = '<ns2:Name>'               +
253700181018     C***                                      %TRIMR(HDRVENNAME)         +
253800181018     C***                                      '</ns2:Name>'
253900181018     C                   EVAL      SCAN_FIELD = HDRVENNAME
254000181018     C                   EXSR      REPLACECHAR
254100181018     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
254200181018     C                                         %TRIMR(SCAN_FIELD)         +
254300181018     C                                         '</ns2:Name>'
254400181018      * @1691 : End
254500160329     C                   EXSR      WRITEXML
254600160601     C                   EVAL      EDIXMLDTL = '<ns2:TaxId IdOrigin="VAT">' +
254700160601     C                                         %TRIMR(HDRLEGALID)           +
254800160601     C                                         '</ns2:TaxId>'
254900160329     C                   EXSR      WRITEXML
255000160524     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
255100160524     C                   EXSR      WRITEXML
255200160524     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
255300160524     C                   EXSR      WRITEXML
255400160524     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
255500160524     C                                         %TRIMR(HDRCNTRYCOD) +
255600160524     C                                         '</ns2:Country>'
255700160524     C                   EXSR      WRITEXML
255800160524     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
255900160524     C                   EXSR      WRITEXML
256000160524     C                   EVAL      EDIXMLDTL = '<ns2:SecondaryAddress>'
256100160524     C                   EXSR      WRITEXML
256200160524     C                   EVAL      EDIXMLDTL = '<ns2:Country>'
256300160524     C                   EXSR      WRITEXML
256400160524     C                   EVAL      EDIXMLDTL = '</ns2:Country>'
256500160524     C                   EXSR      WRITEXML
256600160524     C                   EVAL      EDIXMLDTL = '</ns2:SecondaryAddress>'
256700160524     C                   EXSR      WRITEXML
256800160524     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
256900160524     C                   EXSR      WRITEXML
257000160329     C                   EVAL      EDIXMLDTL = '</ns2:SupplierParty>'
257100160329     C                   EXSR      WRITEXML
257200160329     C                   EVAL      EDIXMLDTL = '<ns2:EmployeeParty>'
257300160329     C                   EXSR      WRITEXML
257400160329     C                   EVAL      EDIXMLDTL = '<ns2:Contacts>'
257500160329     C                   EXSR      WRITEXML
257600160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
257700160329     C                   EXSR      WRITEXML
257800160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
257900160329     C                                         'BSP'                       +
258000160329     C                                         '</ns2:JobTitle>'
258100160329     C                   EXSR      WRITEXML
258200170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
258300160329     C                                        'sequence="1"/>'
258400160329     C                   EXSR      WRITEXML
258500160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
258600160329     C                   EXSR      WRITEXML
258700160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
258800160329     C                   EXSR      WRITEXML
258900160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
259000160329     C                                         'Indexer-Creator'           +
259100160329     C                                         '</ns2:JobTitle>'
259200160329     C                   EXSR      WRITEXML
259300170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
259400160329     C                                        'sequence="1">'        +
259500160329     C                                        'GAPTS'                +
259600170602     C                                        '</ns2:EMailAddress>'
259700160329     C                   EXSR      WRITEXML
259800160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
259900160329     C                   EXSR      WRITEXML
260000160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
260100160329     C                   EXSR      WRITEXML
260200160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
260300160329     C                                         'Indexer-Modified'          +
260400160329     C                                         '</ns2:JobTitle>'
260500160329     C                   EXSR      WRITEXML
260600170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
260700160329     C                                        'sequence="1"/>'
260800160329     C                   EXSR      WRITEXML
260900160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
261000160329     C                   EXSR      WRITEXML
261100160329     C                   EVAL      EDIXMLDTL = '</ns2:Contacts>'
261200160329     C                   EXSR      WRITEXML
261300160329     C                   EVAL      EDIXMLDTL = '<ns2:SplitPayInfo/>'
261400160329     C                   EXSR      WRITEXML
261500160329     C                   EVAL      EDIXMLDTL = '</ns2:EmployeeParty>'
261600160329     C                   EXSR      WRITEXML
261700160329     C                   EVAL      EDIXMLDTL = '<ns2:ShipToParty>'
261800160329     C                   EXSR      WRITEXML
261900160329     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
262000160329     C                   EXSR      WRITEXML
262100160524     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="IBM">'   +
262200160329     C                                         %TRIMR(HDRCOMPCODE)         +
262300160329     C                                         '</ns2:Id>'
262400160329     C                   EXSR      WRITEXML
262500160329     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
262600160329     C                   EXSR      WRITEXML
262700160329     C                   EVAL      EDIXMLDTL = '<ns2:Business>'
262800160329     C                   EXSR      WRITEXML
262900160329     C                   EVAL      EDIXMLDTL = '<ns2:RelatedUnit>'
263000160329     C                   EXSR      WRITEXML
263100160329     C                   EVAL      EDIXMLDTL = '<ns2:Relationship>'        +
263200160510     C                                         'CostCenter'                +
263300160329     C                                         '</ns2:Relationship>'
263400160329     C                   EXSR      WRITEXML
263500160329     C                   EVAL      EDIXMLDTL = '<ns2:Unit>'
263600160329     C                   EXSR      WRITEXML
263700160329     C                   EVAL      EDIXMLDTL = '<ns2:Id/>'
263800160329     C                   EXSR      WRITEXML
263900160329     C                   EVAL      EDIXMLDTL = '</ns2:Unit>'
264000160329     C                   EXSR      WRITEXML
264100160329     C                   EVAL      EDIXMLDTL = '</ns2:RelatedUnit>'
264200160329     C                   EXSR      WRITEXML
264300160329     C                   EVAL      EDIXMLDTL = '</ns2:Business>'
264400160329     C                   EXSR      WRITEXML
264500160329     C                   EVAL      EDIXMLDTL = '</ns2:ShipToParty>'
264600160329     C                   EXSR      WRITEXML
264700160330     C                   EVAL      EDIXMLDTL = '<ns2:RemitToParty>'
264800160330     C                   EXSR      WRITEXML
264900160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
265000160330     C                   EXSR      WRITEXML
265100160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'        +
265200160330     C                                         'GIL'                       +
265300160330     C                                         '"/>'
265400160330     C                   EXSR      WRITEXML
265500160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
265600160330     C                   EXSR      WRITEXML
265700160330     C                   EVAL      EDIXMLDTL = '</ns2:RemitToParty>'
265800160330     C                   EXSR      WRITEXML
265900160330     C                   EVAL      EDIXMLDTL = '<ns2:BillToParty>'
266000160330     C                   EXSR      WRITEXML
266100160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
266200160330     C                   EXSR      WRITEXML
266300160331      *
266400160331      * Remove first 2 zeroes for DRDA invoices
266500160331      *
266600160331     C                   IF        %LEN(%TRIMR(HDRBLLCUS)) = 8 AND
266700160331     C                             %SUBST(HDRBLLCUS:1:2) = '00'
266800160331     C                   EVAL      EDIXMLDTL = '<ns2:Id>'                 +
266900160331     C                                         %SUBST(HDRBLLCUS:3:6)      +
267000160331     C                                         '</ns2:Id>'
267100160331     C                   ELSE
267200160330     C                   EVAL      EDIXMLDTL = '<ns2:Id>'                 +
267300160330     C                                         %TRIMR(HDRBLLCUS)          +
267400160330     C                                         '</ns2:Id>'
267500160331     C                   ENDIF
267600160708
267700160331     C                   EXSR      WRITEXML
267800160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
267900160330     C                   EXSR      WRITEXML
268000160330     C                   EVAL      SCAN_FIELD = HDRBLLNAM
268100160330     C                   EXSR      REPLACECHAR
268200160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
268300160330     C                                         %TRIMR(SCAN_FIELD)         +
268400160330     C                                         '</ns2:Name>'
268500160330     C                   EXSR      WRITEXML
268600160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
268700160330     C                   EXSR      WRITEXML
268800160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
268900160330     C                   EXSR      WRITEXML
269000160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
269100160330     C                   EXSR      WRITEXML
269200160510     C                   IF        %LEN(%TRIMR(HDRBLLAD1)) > 0
269300160330     C                   EVAL      SCAN_FIELD = HDRBLLAD1
269400160330     C                   EXSR      REPLACECHAR
269500160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
269600160330     C                                         %TRIMR(SCAN_FIELD)         +
269700160330     C                                         '</ns2:Line>'
269800160330     C                   EXSR      WRITEXML
269900160510     C                   ENDIF
270000160708
270100160510     C                   IF        %LEN(%TRIMR(HDRBLLAD2)) > 0
270200160330     C                   EVAL      SCAN_FIELD = HDRBLLAD2
270300160330     C                   EXSR      REPLACECHAR
270400160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
270500160330     C                                         %TRIMR(SCAN_FIELD)         +
270600160330     C                                         '</ns2:Line>'
270700160330     C                   EXSR      WRITEXML
270800160510     C                   ENDIF
270900160708
271000160510     C                   IF        %LEN(%TRIMR(HDRBLLCTY)) > 0
271100160330     C                   EVAL      SCAN_FIELD = HDRBLLCTY
271200160330     C                   EXSR      REPLACECHAR
271300160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
271400160330     C                                         %TRIMR(SCAN_FIELD)         +
271500160330     C                                         '</ns2:Line>'
271600160330     C                   EXSR      WRITEXML
271700160510     C                   ENDIF
271800160708
271900160510     C                   IF        %LEN(%TRIMR(HDRBLLSTA)) > 0
272000160330     C                   EVAL      SCAN_FIELD = HDRBLLSTA
272100160330     C                   EXSR      REPLACECHAR
272200160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
272300160330     C                                         %TRIMR(SCAN_FIELD)         +
272400160330     C                                         '</ns2:Line>'
272500160330     C                   EXSR      WRITEXML
272600160510     C                   ENDIF
272700160708
272800160510     C                   IF        %LEN(%TRIMR(HDRBLLZIP)) > 0
272900160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
273000160330     C                                         %TRIMR(HDRBLLZIP)          +
273100160330     C                                         '</ns2:Line>'
273200160330     C                   EXSR      WRITEXML
273300160510     C                   ENDIF
273400160708
273500160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
273600160330     C                   EXSR      WRITEXML
273700160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
273800160512     C                                         %TRIMR(HDRCNTRYCOD) +
273900160330     C                                         '</ns2:Country>'
274000160330     C                   EXSR      WRITEXML
274100160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
274200160330     C                   EXSR      WRITEXML
274300160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
274400160330     C                   EXSR      WRITEXML
274500160330     C                   EVAL      EDIXMLDTL = '</ns2:BillToParty>'
274600160330     C                   EXSR      WRITEXML
274700160330     C                   EVAL      EDIXMLDTL = '<ns2:ShipToParty>'
274800160330     C                   EXSR      WRITEXML
274900160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
275000160330     C                   EXSR      WRITEXML
275100160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'       +
275200160330     C                                         'IBM/ShipTo"'              +
275300160330     C                                         '/>'
275400160330     C                   EXSR      WRITEXML
275500160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
275600160330     C                   EXSR      WRITEXML
275700160330     C                   EVAL      SCAN_FIELD = HDRSHPNAM
275800160330     C                   EXSR      REPLACECHAR
275900160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
276000160330     C                                         %TRIMR(SCAN_FIELD)         +
276100160330     C                                         '</ns2:Name>'
276200160330     C                   EXSR      WRITEXML
276300160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
276400160330     C                   EXSR      WRITEXML
276500160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
276600160330     C                   EXSR      WRITEXML
276700160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
276800160330     C                   EXSR      WRITEXML
276900160512     C                   IF        %LEN(%TRIMR(HDRSHPAD1)) > 0
277000160330     C                   EVAL      SCAN_FIELD = HDRSHPAD1
277100160330     C                   EXSR      REPLACECHAR
277200160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
277300160330     C                                         %TRIMR(SCAN_FIELD)         +
277400160330     C                                         '</ns2:Line>'
277500160330     C                   EXSR      WRITEXML
277600160512     C                   ENDIF
277700160708
277800160512     C                   IF        %LEN(%TRIMR(HDRSHPAD2)) > 0
277900160330     C                   EVAL      SCAN_FIELD = HDRSHPAD2
278000160330     C                   EXSR      REPLACECHAR
278100160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
278200160330     C                                         %TRIMR(SCAN_FIELD)         +
278300160330     C                                         '</ns2:Line>'
278400160330     C                   EXSR      WRITEXML
278500160512     C                   ENDIF
278600160708
278700160512     C                   IF        %LEN(%TRIMR(HDRSHPCTY)) > 0
278800160330     C                   EVAL      SCAN_FIELD = HDRSHPCTY
278900160330     C                   EXSR      REPLACECHAR
279000160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
279100160330     C                                         %TRIMR(SCAN_FIELD)         +
279200160330     C                                         '</ns2:Line>'
279300160330     C                   EXSR      WRITEXML
279400160512     C                   ENDIF
279500160708
279600160512     C                   IF        %LEN(%TRIMR(HDRSHPSTA)) > 0
279700160330     C                   EVAL      SCAN_FIELD = HDRSHPSTA
279800160330     C                   EXSR      REPLACECHAR
279900160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
280000160330     C                                         %TRIMR(SCAN_FIELD)         +
280100160330     C                                         '</ns2:Line>'
280200160330     C                   EXSR      WRITEXML
280300160512     C                   ENDIF
280400160708
280500160512     C                   IF        %LEN(%TRIMR(HDRSHPZIP)) > 0
280600160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
280700160330     C                                         %TRIMR(HDRSHPZIP)          +
280800160330     C                                         '</ns2:Line>'
280900160330     C                   EXSR      WRITEXML
281000160512     C                   ENDIF
281100160708
281200160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
281300160330     C                   EXSR      WRITEXML
281400160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
281500160512     C                                         %TRIMR(HDRCNTRYCOD) +
281600160330     C                                         '</ns2:Country>'
281700160330     C                   EXSR      WRITEXML
281800160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
281900160330     C                   EXSR      WRITEXML
282000160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
282100160330     C                   EXSR      WRITEXML
282200160330     C                   EVAL      EDIXMLDTL = '</ns2:ShipToParty>'
282300160330     C                   EXSR      WRITEXML
282400160330     C                   EVAL      EDIXMLDTL = '<ns2:SoldToParty>'
282500160330     C                   EXSR      WRITEXML
282600160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
282700160330     C                   EXSR      WRITEXML
282800160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'       +
282900160330     C                                         'IBM/SoldTo"'              +
283000160330     C                                         '/>'
283100160330     C                   EXSR      WRITEXML
283200160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
283300160330     C                   EXSR      WRITEXML
283400160330     C                   EVAL      SCAN_FIELD = HDRSHPNAM
283500160330     C                   EXSR      REPLACECHAR
283600160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
283700160330     C                                         %TRIMR(SCAN_FIELD)         +
283800160330     C                                         '</ns2:Name>'
283900160330     C                   EXSR      WRITEXML
284000160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
284100160330     C                   EXSR      WRITEXML
284200160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
284300160330     C                   EXSR      WRITEXML
284400160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
284500160330     C                   EXSR      WRITEXML
284600160512     C                   IF        %LEN(%TRIMR(HDRSHPAD1)) > 0
284700160330     C                   EVAL      SCAN_FIELD = HDRSHPAD1
284800160330     C                   EXSR      REPLACECHAR
284900160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
285000160330     C                                         %TRIMR(SCAN_FIELD)         +
285100160330     C                                         '</ns2:Line>'
285200160330     C                   EXSR      WRITEXML
285300160512     C                   ENDIF
285400160708
285500160512     C                   IF        %LEN(%TRIMR(HDRSHPAD2)) > 0
285600160330     C                   EVAL      SCAN_FIELD = HDRSHPAD2
285700160330     C                   EXSR      REPLACECHAR
285800160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
285900160330     C                                         %TRIMR(SCAN_FIELD)         +
286000160330     C                                         '</ns2:Line>'
286100160330     C                   EXSR      WRITEXML
286200160512     C                   ENDIF
286300160708
286400160512     C                   IF        %LEN(%TRIMR(HDRSHPCTY)) > 0
286500160330     C                   EVAL      SCAN_FIELD = HDRSHPCTY
286600160330     C                   EXSR      REPLACECHAR
286700160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
286800160330     C                                         %TRIMR(SCAN_FIELD)         +
286900160330     C                                         '</ns2:Line>'
287000160330     C                   EXSR      WRITEXML
287100160512     C                   ENDIF
287200160708
287300160512     C                   IF        %LEN(%TRIMR(HDRSHPSTA)) > 0
287400160330     C                   EVAL      SCAN_FIELD = HDRSHPSTA
287500160330     C                   EXSR      REPLACECHAR
287600160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
287700160330     C                                         %TRIMR(SCAN_FIELD)         +
287800160330     C                                         '</ns2:Line>'
287900160330     C                   EXSR      WRITEXML
288000160512     C                   ENDIF
288100160708
288200160512     C                   IF        %LEN(%TRIMR(HDRSHPZIP)) > 0
288300160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
288400160330     C                                         %TRIMR(HDRSHPZIP)          +
288500160330     C                                         '</ns2:Line>'
288600160330     C                   EXSR      WRITEXML
288700160525     C                   ENDIF
288800160708
288900160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
289000160330     C                   EXSR      WRITEXML
289100160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
289200160512     C                                         %TRIMR(HDRCNTRYCOD) +
289300160330     C                                         '</ns2:Country>'
289400160330     C                   EXSR      WRITEXML
289500160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
289600160330     C                   EXSR      WRITEXML
289700160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
289800160330     C                   EXSR      WRITEXML
289900160330     C                   EVAL      EDIXMLDTL = '<ns2:TotalTax/>'
290000160330     C                   EXSR      WRITEXML
290100160330     C                   EVAL      EDIXMLDTL = '</ns2:SoldToParty>'
290200160330     C                   EXSR      WRITEXML
290300160329     C                   EVAL      EDIXMLDTL = '</ns2:Parties>'
290400160329     C                   EXSR      WRITEXML
290500160601     C                   EVAL      EDIXMLDTL = '<Type>'           +
290600160601     C                                         %TRIMR(HDRINVTYPE) +
290700160601     C                                         '</Type>'
290800160330     C                   EXSR      WRITEXML
290900160513     C                   EVAL      EDIXMLDTL = '<Reason code="'         +
291000160513     C                                         'Variance_Reason">'      +
291100160513     C                                         '</Reason>'
291200160330     C                   EXSR      WRITEXML
291300180816      * @def1: Begin
291400180816     C***                EVAL      EDIXMLDTL = '<CurrenyConversion>'
291500180816     C                   EVAL      EDIXMLDTL = '<CurrencyConversion>'
291600180816      * @def1: End
291700160330     C                   EXSR      WRITEXML
291800160512     C                   EVAL      EDIXMLDTL = '<ns2:Actual currency="'    +
291900160512     C                                         %TRIMR(HDRCURCOD)           +
292000160512     C                                         '">0</ns2:Actual>'
292100160330     C                   EXSR      WRITEXML
292200160512     C                   EVAL      INTAMT = %INT(HDREXCHRATE)
292300160512     C                   EVAL      DECAMT4 = INTAMT / 10000
292400160512     C                   EVAL      INCOUNT = %CHAR(DECAMT4)
292500160525     C                   IF        DECAMT4 < 1
292600160512     C                   EVAL      EDIXMLDTL = '<ns2:Converted currency="' +
292700160512     C                                         %TRIMR(HDRCURCOD)           +
292800160525     C                                         '" conversionFactor="0'     +
292900160512     C                                         %TRIMR(INCOUNT)             +
293000160512     C                                         '"/>'
293100160525     C                   ELSE
293200160525     C                   EVAL      EDIXMLDTL = '<ns2:Converted currency="' +
293300160525     C                                         %TRIMR(HDRCURCOD)           +
293400160525     C                                         '" conversionFactor="'      +
293500160525     C                                         %TRIMR(INCOUNT)             +
293600160525     C                                         '"/>'
293700160525     C                   ENDIF
293800160708
293900160330     C                   EXSR      WRITEXML
294000180209      * @uxh : Begin
294100180209      * Set total tax amount in header to 0 for non upfront
294200180209      *
294300180209     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
294400180209     C                   EVAL      SCAN_POS =
294500180209     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
294600180209     C                   IF        SCAN_POS > 0
294700180209     C                   Eval      TAXSTATE = 1
294800180209     C                   ELSE
294900180209     C                   Eval      TAXSTATE = 0
295000180209     C                   ENDIF
295100180209      *
295200180228      * @1622 : Begin
295300180228     C                   Select
295400180303     C                   WHEN      HDRCNTRYCOD = 'US' and TAXSTATE = 0
295500180209     C                             and  HDRTAXES <> '0000000000'
295600180209     C                   Eval      DECAMT = *Zero
295700180228      *
295800180303     C                   WHEN      HDRCNTRYCOD  = 'CA' and IBMIND ='N'
295900180228     C                             and  HDRTAXES <> '0000000000'
296000180228     C                   Eval      DECAMT = *Zero
296100180228     C                   Other
296200180228      *
296300160610     C                   EVAL      INTAMT = %INT(HDRTAXES)
296400160610     C                   EVAL      DECAMT = INTAMT / 100
296500180228      *
296600180228     C                   Endsl
296700180228      * @1622: End
296800160512     C                   EVAL      INCOUNT = %CHAR(DECAMT)
296900180816      * @def1: Begin
297000180816     C***                EVAL      EDIXMLDTL = '</CurrenyConversion>'
297100180816     C                   EVAL      EDIXMLDTL = '</CurrencyConversion>'
297200180816      * @def1: End
297300160330     C                   EXSR      WRITEXML
297400160524     C                   IF        DECAMT < 1
297500160512     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
297600160512     C                                         %TRIMR(HDRCURCOD)           +
297700160524     C                                         '" basis="TotalTax">0'      +
297800160512     C                                         %TRIMR(INCOUNT)             +
297900160512     C                                         '</TotalTax>'
298000160524     C                   ELSE
298100160524     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
298200160524     C                                         %TRIMR(HDRCURCOD)           +
298300160524     C                                         '" basis="TotalTax">'       +
298400160524     C                                         %TRIMR(INCOUNT)             +
298500160524     C                                         '</TotalTax>'
298600160524     C                   ENDIF
298700160708
298800160330     C                   EXSR      WRITEXML
298900160512     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
299000160512     C                                         %TRIMR(HDRCURCOD)           +
299100160512     C                                         '" basis="AvailableTax"/>'
299200160330     C                   EXSR      WRITEXML
299300160330     C                   EVAL      EDIXMLDTL = '<InterfaceData>'
299400160330     C                   EXSR      WRITEXML
299500160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
299600160512     C                                         'SourceIndc">'             +
299700160512     C                                         %TRIMR(%SUBST(CNTSNDIND:1:3))+
299800160330     C                                         '</InterfaceProperty>'
299900160330     C                   EXSR      WRITEXML
300000160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
300100160602     C                                         'CPS NUMBER">'              +
300200160602     C                                         %TRIMR(HDCPSNUM)            +
300300160602     C                                         '</InterfaceProperty>'
300400160330     C                   EXSR      WRITEXML
300500160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
300600160512     C                                         'AutoCreateCoaIndc">N'      +
300700160330     C                                         '</InterfaceProperty>'
300800160330     C                   EXSR      WRITEXML
300900171220      * @1622: Begin
301000171220     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
301100171220     C                                         'ProvinceCode">'            +
301200171220     C                                         %TRIMR(wPROVINCE)           +
301300171220     C                                         '</InterfaceProperty>'
301400171220     C                   EXSR      WRITEXML
301500171220      * @1622: End
301600160330     C                   EVAL      EDIXMLDTL = '</InterfaceData>'
301700160330     C                   EXSR      WRITEXML
301800160325     C                   EVAL      EDIXMLDTL = '</Header>'
301900160325     C                   EXSR      WRITEXML
302000180917      * @1685 : Begin
302100180917     C                   IF        INVOICEVALID (INVOICENDX) = '0'
302200180917     C                   EVAL      BUFFER1= %TRIMR(BUFFER1) + %TRIMR(Wrkxmldtl1)
302300180917     C                   ENDIF
302400180917      * @1685 : End
302500160322     C                   ENDSR
302600171212      *******************************************************************
302700171212     ?* COMMENT
302800171212      *******************************************************************
302900160322      *
303000160322     C     XMLCOMMENT    BEGSR
303100160329     C                   EVAL      DSCOMMENT = EDIRCD7S
303200160322     C                   ENDSR
303300160322      *
303400171212      *******************************************************************
303500171212     ?* DETAIL
303600171212      *******************************************************************
303700160322      *
303800171212     C     XMLDETAIL     BEGSR
303900190128      * @1712 : Begin
304000190128      * Do not create XML for invalid invoices
304100190130     C                   IF        INVOICEVALID (INVOICENDX) = '1'
304200190130     C                   LEAVESR
304300190130     C                   ENDIF
304400190128      * @1712 : End
304500171206      * Set values for all variables
304600171206     C                   EVAL      WrkXmlDtl1= *Blanks
304700171206     C                   EVAL      WrkXmlDtl2= *Blanks
304800171206     C                   EVAL      WrkXmlDtl3= *Blanks
304900171206     C                   EVAL      DSDETAIL = EDIRCD7S
305000171206     C                   EVAL      DTLTAXCODE = E7SVATCOD
305100171206     C                   EVAL      XMLDTLLINE = XMLDTLLINE + 1
305200171206     C                   EVAL      XMLDTLCOUNT = %EDITC(E7SKEY3:'X')
305300171206     C                   EVAL      XMLDTLSEQ = %DEC(E7SKEY2:6:0)
305400171206     C                   EVAL      XMLDTLCOUNT1= %EDITC(XMLDTLSEQ:'X')
305500180309      * @1607g : Begin
305600180309     C                   EVAL      SCAN_FIELD = DETPARTNUM
305700180309     C                   EXSR      REPLACECHAR
305800180309     C                   EVAL      SCAN_FIELD1= SCAN_FIELD
305900180309      * @1607g : End
306000171206     C                   EVAL      SCAN_FIELD = DETPRTDSC
306100171206     C                   EXSR      REPLACECHAR
306200171206      *
306300171212     ?* Set  WrkXmlDtl1
306400171206     C                   EVAL      WrkXmlDtl1= '<Line>' +
306500171206     C                                         '<LineNumber>'             +
306600171206     C                                         %SUBST(XMLDTLCOUNT:2:6)    +
306700171206     C                                         '</LineNumber>'            +
306800171206     C                                         '<LineSeq>'                +
306900171206     C                                         %SUBST(XMLDTLCOUNT1:2:6)   +
307000171206     C                                         '</LineSeq>'               +
307100171206     C                                         '<OrderItem>'              +
307200171206     C                                         '<ns2:ItemIds>'            +
307300171206     C                                         '<ns2:ItemId>'             +
307400171206     C                                        '<ns2:Id IdOrigin="Vendor">'+
307500180309     C                                         %TRIMR(SCAN_FIELD1)        +
307600171206     C                                         '</ns2:Id>'                +
307700171206     C                                         '<ns2:Id IdOrigin='        +
307800171206     C                                         '"IBM/MachineType">'       +
307900171206     C                                         %TRIMR(DETMCHTYP)          +
308000171206     C                                         '</ns2:Id>'                +
308100171206     C                                         '<ns2:Id IdOrigin='        +
308200171206     C                                         '"IBM/Model">'             +
308300171206     C                                         %TRIMR(DETMCHMOD)          +
308400171206     C                                         '</ns2:Id>'                +
308500171206     C                                         '</ns2:ItemId>'            +
308600171206     C                                         '</ns2:ItemIds>'           +
308700171206     C                                         '<ItemCategoryId '         +
308800171206     C                                         'type="ItemType">'         +
308900171206     C                                         %TRIMR(E7SKEY5)            +
309000171206     C                                         '</ItemCategoryId>'        +
309100171206     C                                         '<ItemCategoryId '         +
309200171206     C                                         'type="ProductCategory">'  +
309300171206     C                                         %TRIMR(' ')                +
309400171206     C                                         '</ItemCategoryId>'        +
309500171206     C                                         '<ItemCategoryId '         +
309600171206     C                                         'type="ProductClass">'     +
309700171206     C                                         %TRIMR(' ')                +
309800171206     C                                         '</ItemCategoryId>'        +
309900171206     C                                         '<Description>'            +
310000171206     C                                         %TRIMR(SCAN_FIELD)         +
310100171206     C                                         '</Description>'
310200171212     ?* End  WrkXmlDtl1
310300171206     C                   READ      EDIPF7A                                90
310400171206     C                   IF        %SUBST(EDIRCD7S:1:10) <> RECTYPE6
310500171206     C                   CLEAR                   DSSERIAL
310600171206     C                   READP     EDIPF7A
310700171206     C                   ELSE
310800171206     C                   EVAL      DSSERIAL  = EDIRCD7S
310900171206     C                   ENDIF
311000171206      * UpgradeorMES
311100171206     C                   IF        %LEN(%TRIMR(DETMES)) > 0
311200171206     C                   EVAL      DETMES = 'MES'
311300171206     C                   ELSE
311400171206     C                   EVAL      DETMES = 'Upgrade'
311500171206     C                   ENDIF
311600171206      * Equipment source
311700171206     C                   IF        %LEN(%TRIMR(DETEQSRC)) = 0
311800171206     C                   IF        %LEN(%TRIMR(HDRINVTYPE)) > 0
311900171206     C                   IF        HDRINVTYPE = 'IBM'
312000171206     C                   EVAL      DETEQSRC = 'IB'
312100171206     C                   ELSE
312200171206     C                   IF        HDRINVTYPE = 'VEN'
312300171206     C                   EVAL      DETEQSRC = 'BP'
312400171206     C                   ELSE
312500171206     C                   EVAL      DETEQSRC = '  '
312600171206     C                   ENDIF
312700171206     C                   ENDIF
312800171206     C                   ENDIF
312900171206     C                   ENDIF
313000171206
313100180218      * @1607C : Begin
313200180218     C***                IF        DETMCHTYP = '9OT9'
313300180218     C***                EVAL      DETEQSRC = '  '
313400180218     C***                EVAL      DTLTAXCODE = '  '
313500180218     C***                ENDIF
313600171206
313700180218     C***                IF        DETMCHTYP = '9TX8'
313800180218     C***                EVAL      DETEQSRC = '  '
313900180218     C***                EVAL      DTLTAXCODE = 'I2'
314000180218     C***                ENDIF
314100180218      * @1607C : End
314200171206
314300180222      * @1607d : Begin
314400180222     C***                EVAL      INCOUNTU= %CHAR(DETUNTPRC)
314500180222     C                   EVAL      INCOUNTU= %CHAR(DETUNTPRC * DETQTY)
314600180222      * @1607d : End
314700171206
314800171206     C                   IF        DETUNTPRC < 1
314900171206     C                   EVAL      EDIXMLDTLU= '<ns2:Amount currency="'    +
315000171206     C                                         HDRCURCOD                   +
315100171206     C                                         '" basis="ListPrice">0'     +
315200171206     C                                         %TRIMR(INCOUNTU)            +
315300171206     C                                         '</ns2:Amount>'
315400171206     C                   ELSE
315500171206     C                   EVAL      EDIXMLDTLU= '<ns2:Amount currency="'    +
315600171206     C                                         HDRCURCOD                   +
315700171206     C                                         '" basis="ListPrice">'      +
315800171206     C                                         %TRIMR(INCOUNTU)            +
315900171206     C                                         '</ns2:Amount>'
316000171206     C                   ENDIF
316100171206
316200171206     C                   IF        %LEN(%TRIMR(DETITMDSC)) = 0
316300171206     C                   EVAL      DETITMDSC = '0000000000'
316400171206     C                   ENDIF
316500171206
316600171206     C                   IF        %LEN(%TRIMR(DETLINTAX)) = 0
316700171206     C                   EVAL      DETLINTAX = '0000000000'
316800171206     C                   ENDIF
316900171206
317000171206     C                   EVAL      INTAMT = %INT(DETITMDSC)
317100171206     C                   EVAL      DECAMT = INTAMT / 100
317200171206     C                   EVAL      INCOUNT = %CHAR(DECAMT)
317300171206
317400171206     C                   IF        DECAMT < 1
317500171206     C                   EVAL      EDIXMLDTL = '<ns2:Amount currency="'    +
317600171206     C                                         HDRCURCOD                   +
317700171206     C                                         '" basis="DiscountAmount">0'+
317800171206     C                                         %TRIMR(INCOUNT)             +
317900171206     C                                         '</ns2:Amount>'
318000171206     C                   ELSE
318100171206     C                   EVAL      EDIXMLDTL = '<ns2:Amount currency="'    +
318200171206     C                                         HDRCURCOD                   +
318300171206     C                                         '" basis="DiscountAmount">' +
318400171206     C                                         %TRIMR(INCOUNT)             +
318500171206     C                                         '</ns2:Amount>'
318600171206     C                   ENDIF
318700171206
318800171206     C                   TIME                    TIMSTP
318900171206     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
319000171206
319100171212     ?* Set WrkXmlDtl2
319200171206     C                   EVAL      WrkXmlDtl2= '<AssetId>'  +
319300171206     C                                         '<SerialNumber>'            +
319400171206     C                                         %TRIMR(SERSERNO)            +
319500171206     C                                         '</SerialNumber>'           +
319600171206     C                                         '<Id IdOrigin="Supplier">'  +
319700171206     C                                         %TRIMR(' ')                 +
319800171206     C                                         '</Id>'                     +
319900171206     C                                         '</AssetId>'                +
320000171206     C                                         '<UpgradeOrMES>'            +
320100171206     C                                         %TRIMR(DETMES)              +
320200171206     C                                         '</UpgradeOrMES>'           +
320300171206     C                                         '<EquipmentSource>'         +
320400171206     C                                         %TRIMR(DETEQSRC)            +
320500171206     C                                         '</EquipmentSource>'        +
320600171206     C                                         '</OrderItem>'              +
320700171206     C                                         '<UnitPrice>'               +
320800171206     C                                         %TRIMR(EDIXMLDTLU)          +
320900171206     C                                         '<ns2:PerQuantity uom="">'  +
321000171206     C                                         '1'                         +
321100171206     C                                         '</ns2:PerQuantity>'        +
321200171206     C                                         '</UnitPrice>'              +
321300171206     C                                         '<UnitPrice>'               +
321400171206     C                                         %TRIMR(EDIXMLDTL)           +
321500171206     C                                         '<ns2:PerQuantity uom="">'  +
321600171206     C                                         '1'                         +
321700171206     C                                         '</ns2:PerQuantity>'        +
321800171206     C                                         '</UnitPrice>'              +
321900171206      *
322000171206     C                                         '<ns2:OrderStatus>'         +
322100171206     C                                         '<ns2:AcknowledgementDetail>'+
322200171206     C                                         '<ns2:Change>'              +
322300171206     C                                         '<ns2:ChangeDate>'          +
322400171206     C                                         %CHAR(SYS_DATE) + 'T'       +
322500171206     C                                         %SUBST(HOLDTIME:1:2) + ':'  +
322600171206     C                                         %SUBST(HOLDTIME:3:2) + ':'  +
322700171206     C                                         %SUBST(HOLDTIME:5:2)        +
322800171206     C                                         '.000-04:00'                +
322900171206     C                                         '</ns2:ChangeDate>'         +
323000171206     C                                         '</ns2:Change>'             +
323100171206     C                                         '</ns2:AcknowledgementDetail>' +
323200171206     C                                         '</ns2:OrderStatus>'
323300171212     ?* End WrkXmlDtl2
323400171206      *
323500180710      * @1622a: Begin
323600180710     C                   Eval      DECAMT = *Zero
323700180710      * @1622a: End
323800171206     C                   EVAL      INTAMT = %INT(DETLINTAX)
323900180209      * @UXH : Begin
324000180209     C***                IF        INVOICETAX(INVOICENDX) = '1'
324100180209     C                   IF        INTAMT > 0
324200180209      * @UXH : End
324300171206     C                   Select
324400180305     C                   WHEN      TAXSTATE = 1  or IBMIND ='Y'
324500180926      * @1687 : Begin
324600180924     C***                EVAL(H)   DECAMT  = INTAMT / 10000
324700180924     C                   EVAL(H)   DECAMT  = INTAMT / 100
324800180926      * @1687 : End
324900171206     C                   Other
325000171206     C                   EVAL(H)   DECAMT  = INTAMT / 100
325100171206     C                   Endsl
325200180209      * @UXH : Begin
325300180209     C                   Endif
325400180209      * @UXH : End
325500171212      *
325600180218      * For non-upfront state, Set total tax amount in header to 0
325700180303     C                   If        HDRCNTRYCOD = 'US' and TAXSTATE = 0
325800180209     C                             and  HDRTAXES <> '0000000000'
325900180209     C                   Eval      DECAMT = *Zero
326000180423      * @1652 : Begin
326100180423     C**                 Eval      DTLTAXCODE = 'I0'
326200180423     C                   Eval      DTLTAXCODE = 'U1'
326300180423      * @1652 : End
326400180209     C                   Endif
326500180228      * @1622 : Begin
326600180228      * For Canada, Set total tax amount in header to 0
326700180303     C                   If        HDRCNTRYCOD = 'CA' and IBMIND ='N'
326800180228     C                             and  HDRTAXES <> '0000000000'
326900180228     C                   Eval      DECAMT = *Zero
327000180228     C                   Endif
327100180228      *
327200180314      * @1607c : Begin
327300180314      * For US upfront state with tax, Set tax code to I0 for zero tax line
327400180314     C                   If        HDRCNTRYCOD = 'US' and TAXSTATE = 1
327500180314     C                             and  HDRTAXES <> '0000000000'
327600180314     C                             and  DETLINTAX = '0000000000'
327700180423      * @1652 : Begin
327800180423     C**                 Eval      DTLTAXCODE = 'I0'
327900180423     C                   Eval      DTLTAXCODE = 'U1'
328000180423      * @1652 : End
328100180314     C                   Endif
328200180314      * @1607c : End
328300180314      *
328400180303     C                   If        HDRCNTRYCOD  = 'CA'
328500180303     C                   Exsr      Upd_TaxCode
328600180228     C                   Endif
328700180228      * @1622 : End
328800180209      * @uxh : End
328900171206     C                   EVAL      INCOUNT = %CHAR(DECAMT)
329000171206     C                   IF        DECAMT  < 1
329100171212      *
329200171206     C                   EVAL      EDIXMLDTL = '<ns2:TaxAmount '        +
329300171206     C                                         'currency="'             +
329400171206     C                                         HDRCURCOD                +
329500171206     C                                         '" basis="unit_tax">0'   +
329600171206     C                                         %TRIMR(INCOUNT)          +
329700171206     C                                         '</ns2:TaxAmount>'
329800171206     C                   ELSE
329900171206     C                   EVAL      EDIXMLDTL = '<ns2:TaxAmount '        +
330000171206     C                                         'currency="'             +
330100171206     C                                         HDRCURCOD                +
330200171206     C                                         '" basis="unit_tax">'    +
330300171206     C                                         %TRIMR(INCOUNT)          +
330400171206     C                                         '</ns2:TaxAmount>'
330500171206     C                   ENDIF
330600171206
330700171206     C                   IF        DETMCHTYP = '9OT9'
330800171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
330900171206     C                                         '</ns2:Id>'
331000171206     C                   ELSE
331100171206     C                   IF        DETMCHTYP = '9TX8'
331200171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
331300171206     C                                         '</ns2:Id>'
331400171206     C                   ELSE
331500171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
331600171206     C                                         %TRIMR(HDRPONUM)               +
331700171206     C                                         '</ns2:Id>'
331800171206     C                   ENDIF
331900171206     C                   ENDIF
332000171206     C                   EVAL      INCOUNTU= %CHAR(DETQTY)
332100171206
332200171206      *
332300171212     ?* Set WrkXmlDtl3
332400171206     C                   EVAL      WrkXmlDtl3  =
332500171206     C                                         '<ns2:Tax>'              +
332600171206     C                                         %TRIMR(EDIXMLDTL)        +
332700171206     C                                         '<ns2:TaxCode>'          +
332800171206     C                                         %TRIMR(DTLTAXCODE)       +
332900171206     C                                         '</ns2:TaxCode>'         +
333000171206     C                                         '</ns2:Tax>'             +
333100171206     C                                         '<ns2:DocumentReferences>'  +
333200171206     C                                         '<ns2:InvoiceDocumentReference>'+
333300171206     C                                         '<ns2:Status>'             +
333400171206     C                                         '<ns2:Code>'               +
333500171206     C                                         'false'                    +
333600171206     C                                         '</ns2:Code>'              +
333700171206     C                                         '</ns2:Status>'            +
333800171206     C                                  '</ns2:InvoiceDocumentReference>' +
333900171206     C                             '<ns2:PurchaseOrderDocumentReference>' +
334000171206     C                                         '<ns2:DocumentIds>'        +
334100171206     C                                         '<ns2:SupplierDocumentId>' +
334200171206     C                                         %TRIMR(EDIXMLDTLU)         +
334300171206     C                                         '</ns2:SupplierDocumentId>'+
334400171206     C                                         '<ns2:SupplierDocumentId>' +
334500171206     C                                         '<ns2:Id IdOrigin="IBM/MES">'  +
334600180626      * @1672 : Begin
334700180626     C***                                      %TRIMR(' ')                    +
334800180626     C                                         %TRIMR(SERASSTAG)              +
334900180626      * @1672 : End
335000171206     C                                         '</ns2:Id>'                +
335100171206     C                                         '</ns2:SupplierDocumentId>'+
335200171206     C                                         '</ns2:DocumentIds>'       +
335300171206     C                                         '</ns2:PurchaseOrder' +
335400171206     C                                         'DocumentReference>'  +
335500171206     C                                         '</ns2:DocumentReferences>' +
335600171206     C                                         '<ns2:PartyId>'             +
335700171206     C                                         '<ns2:Id/>'                 +
335800171206     C                                         '</ns2:PartyId>'            +
335900171206     C                                         '<ItemQuantity uom="">'+
336000171206     C                                         %TRIMR(INCOUNTU)        +
336100171206     C                                         '</ItemQuantity>'       +
336200171206     C                                         '<LeaseTerms>'          +
336300171206     C                                         '<PeriodTime/>'         +
336400171206     C                                         '</LeaseTerms>'         +
336500171206     C                                         '</Line>'
336600171212     ?* End WrkXmlDtl3
336700171206      *
336800171206     C                   IF        INVOICEVALID (INVOICENDX) = '0'
336900171206     C                   EVAL      BUFFER1 = %Trimr(BUFFER1)      +
337000171206     C                                       %Trimr(WrkXmlDtl1)   +
337100171206     C                                       %Trimr(WrkXmlDtl2)   +
337200171206     C                                       %Trimr(WrkXmlDtl3)
337300171206     C                   ENDIF
337400171206      *
337500171206     C                   ENDSR
337600171212      **********************************************************
337700171212     ?* Serial
337800171212      **********************************************************
337900160322      *
338000160322     C     XMLSERIALNO   BEGSR
338100160329     C                   EVAL      DSSERIAL  = EDIRCD7S
338200160322     C                   ENDSR
338300171212      **********************************************************
338400171212     ?* FEATURE
338500171212      *********************************************************
338600160322      *
338700160322     C     XMLFEATURE    BEGSR
338800160329     C                   EVAL      DSFEATURE = EDIRCD7S
338900160322     C                   ENDSR
339000160322      *
339100171212      *********************************************************
339200171212     ?* TRAILER
339300171212      *********************************************************
339400160322      *
339500160322     C     XMLTRAILER    BEGSR
339600160329     C                   EVAL      DSTRAILER = EDIRCD7S
339700160322     C                   ENDSR
339800160322      *
339900171212      *********************************************************
340000171212     ?* FILE TRAILER
340100171212      *********************************************************
340200160322      *
340300160322     C     XMLFILETRL    BEGSR
340400160329     C                   EVAL      DSFILETRL = EDIRCD7S
340500160322     C                   ENDSR
340600171212      *
340700171212      *********************************************************
340800171212     ?* Write error messages
340900171212      *********************************************************
341000160316      *
341100160316     C     WRITEPF5      BEGSR
341200160707     C                   EVAL      E5MBRNAM = PRMMBRNAME
341300160316     C                   EVAL      E5RUNDATE = SYS_DATE
341400160316     C                   EVAL      E5RUNTIME = SYS_TIME
341500161227     C                   EVAL      E5COUNTRY = HDRCNTRYCOD
341600160708
341700160316     C                   IF        HEADERIND = 1
341800160316     C                   EVAL      E5SNDIND = CNTSNDIND
341900160316     C                   EVAL      E5CTRNUM = CNTCTRNUM
342000160316     C                   EVAL      E5INVNO = HDRINVNO
342100160316     C                   ELSE
342200160316     C                   EVAL      E5SNDIND = *BLANKS
342300160316     C                   EVAL      E5CTRNUM = *BLANKS
342400160316     C                   EVAL      E5INVNO = *BLANKS
342500160316     C                   ENDIF
342600160708
342700160316     C                   EVAL      E5INVTYP = *BLANKS
342800160316     C                   EVAL      E5MSGID = *BLANKS
342900160316     C                   WRITE     EDIPF5R
343000160316     C                   ENDSR
343100160325      *
343200171212      *********************************************************
343300171212     ?* Write XML
343400171212      *********************************************************
343500160325      *
343600160325     C     WRITEXML      BEGSR
343700180917      * @1685 : Begin
343800180917      * Load wrkxmldtl1  for XMLHEADER
343900180917     C                   Select
344000180917     C                   When      RECTYPE = RECTYPE3
344100180917     C                   IF        INVOICEVALID (INVOICENDX) = '0'
344200180917     C                   EVAL      WrkXmlDtl1 = %TRIMR(WrkXmlDtl1) +
344300180917     C                                           %TRIMR(EDIXMLDTL)
344400180917     C                   ENDIF
344500180917     C                   Other
344600180917      * @1685 : End
344700160606     C                   IF        INVOICEVALID (INVOICENDX) = '0'
344800171206     C                   EVAL      BUFFER1= %TRIMR(BUFFER1) + %TRIMR(EDIXMLDTL)
344900160606     C                   ENDIF
345000180917      * @1685 : Begin
345100180917     C                   ENDSL
345200180917      * @1685 : End
345300160325     C                   ENDSR
345400160627      *
345500180302      *********************************************************
345600180302     ?* TOLRANCE CHECK - CANADA
345700180302      *********************************************************
345800180302     C     CATOLSR       BEGSR
345900180302      *
346000180303     C                   EVAL      Vld_Tax_Tol     ='N'
346100180303     C                   Exsr      Get_TaxCode
346200180303      * Calculated tax amt based on province TAX%
346300180303     C                   EVAL      TAXAMT= %DECH((
346400180303     C                                  (%INT(HDRTOTAMT)-  %INT(HDRTAXES))
346500180303     C                                      *  @@MQTAXPCT)/100:10:2)
346600180303      * Check if tax amount within tolerance or not
346700180303     C                   IF        %INT(HDRTAXES)/100 <= (TAXAMT+HldVatVar)
346800180303     C                             and  %INT(HDRTAXES)/100 >= (TAXAMT-HldVatVar)
346900180303     C                   EVAL      Vld_Tax_Tol     ='Y'
347000180303     C                   ENDIF
347100180303     C
347200180303     C                   IF        Vld_Tax_Tol ='N'
347300180302     C                   EVAL      HEADERIND = 1
347400180417     C                   EVAL      E5MSGVAR = 'Warning: ' + Errnote2 +
347500180417     C                             'for invoice number: '  +
347600180302     C                             %TRIMR(HDRINVNO)
347700180302     C                   EXSR      WRITEPF5
347800180411      * @1647 : Begin
347900180411     C                   EVAL      WErrNote = ErrNote2
348000180411     C                   EXSR      CrtCFEXML
348100180411      * @1647 : End
348200180302     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
348300180302      * @UXH : Begin
348400180302     C                   EVAL      HOLDMISCCHG = '0000000000'
348500180302     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
348600180302     C                   EVAL      HOLDTAXES      = '0000000000'
348700180303     C                   ENDIF
348800180303      *
348900180302     C                   ENDSR
349000171212      *********************************************************
349100171212     ?* Create XML for CTS
349200171212      *********************************************************
349300170621     C     CTSXMLSR      BEGSR
349400171212      *
349500160825     C                   CLEAR                   BUFFCTS
349600171212     C                   EVAL      WrkCTSXML1 = *Blanks
349700171212     C                   EVAL      WrkCTSXML2 = *Blanks
349800171212     C                   EVAL      WrkCTSXML3 = *Blanks
349900171212     ?* Set  wrkCTSXML1
350000171212     C                   EVAL      wrkCTSXML1 = '<soapenv:Envelope '          +
350100160627     C                                         'xmlns:soapenv'                +
350200160627     C                                         '="http://schemas.xmlsoap.org' +
350300171212     C                                         '/soap/envelope/">'            +
350400171212      *
350500171212     C                                         '<soapenv:Body>'               +
350600171212      *
350700171212     C                                         '<ns7:GetTaxserviceRequest'    +
350800171212     C                                         ' xmlns:ns12='                 +
350900171212     C                                         '"http://w3.ibm.com/xmlns/igf' +
351000171212     C                                         '/gcps/cts/upfront"'           +
351100160627     C                                         ' xmlns:ns11='                 +
351200160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
351300160627     C                                         '/gcps/cts/taxAmount/response"'+
351400160627     C                                         ' xmlns:ns10='                 +
351500160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
351600160627     C                                         '/gcps/cts/taxAmount/request"' +
351700160627     C                                         ' xmlns:ns9='                  +
351800160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
351900160627     C                                         '/gcps/cts/qmc"'               +
352000160627     C                                         ' xmlns:ns8='                  +
352100160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
352200160627     C                                         '/gcps/cts/taxes/response"'    +
352300160627     C                                         ' xmlns:ns7='                  +
352400160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
352500160627     C                                         '/gcps/cts/taxes/request"'     +
352600160627     C                                         ' xmlns:ns6='                  +
352700160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
352800160627     C                                         '/gcps/cts/custinfo"'          +
352900160627     C                                         ' xmlns:ns5='                  +
353000160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
353100160627     C                                         '/gcps/cts/commonTypes"'       +
353200160627     C                                         ' xmlns:ns4='                  +
353300160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
353400160627     C                                         '/gcps/common/faults"'         +
353500160627     C                                         ' xmlns:ns3='                  +
353600160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
353700160627     C                                         '/gcps/common/errors"'         +
353800160627     C                                         ' xmlns:ns2='                  +
353900160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
354000171212     C                                         '/gcps/common/addressing">'    +
354100171212      *
354200171212     C                                         '<CommonTaxHeader>'            +
354300171212      *
354400171212     C                                         '<ApplicationName>GAPTS'       +
354500171212     C                                         '</ApplicationName>'           +
354600171212      *
354700171212     C                                         '<ApplicationId>GAPTS'         +
354800171212     C                                         '</ApplicationId>'             +
354900171212      *
355000171212     C                                         '<ClientLoggingId>GAPTS'       +
355100171212     C                                         '</ClientLoggingId>'           +
355200171212      *
355300171212     C                                         '<CtsRequestId>GAPTS'          +
355400171212     C                                         '</CtsRequestId>'              +
355500171212      *
355600171212     C                                         '</CommonTaxHeader>'           +
355700171212      *
355800171212     C                                         '<Contract>'                   +
355900171212      *
356000171212     C                                         '<CountryCode>896'  +
356100171212     C                                         '</CountryCode>'     +
356200171212      *
356300171212     C                                         '<SubsidairyCode>01'   +
356400171212     C                                         '</SubsidairyCode>'    +
356500171212      *
356600171212     C                                         '<CurrencyCode>USD'   +
356700171212     C                                         '</CurrencyCode>'     +
356800171212      *
356900171212     C                                         '<ContractNumber>'   +
357000171212     C                                         %TRIMR(HDRINVNO)     +
357100171212     C                                         '</ContractNumber>'  +
357200171212      *
357300171212     C                                         '<ContractDate>'   +
357400160819     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
357500160819     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
357600160819     C                                         %SUBST(HDRINVDAT:7:2)       +
357700160819     C                                         '-04:00'                    +
357800171212     C                                         '</ContractDate>'       +
357900171212      *
358000171212     C                                         '<Line ID="1">'         +
358100171212      *
358200171212     C                                         '<ContractLineNumber>0'   +
358300171212     C                                         '</ContractLineNumber>'   +
358400171212      *
358500171212     C                                         '<Financed>Y'             +
358600171212     C                                         '</Financed>'             +
358700171212      *
358800171212     C                                         '<TransactionType>NLSE'   +
358900171212     C                                         '</TransactionType>'      +
359000171212      *
359100171212     C                                         '<FinanceType>FMV'       +
359200171212     C                                         '</FinanceType>'         +
359300171212      *
359400171212     C                                         '<OriginalFinanceType>FMV' +
359500171212     C                                         '</OriginalFinanceType>'   +
359600171212      *
359700171212     C                                         '<UpfrontIndicator>N' +
359800171212     C                                         '</UpfrontIndicator>'   +
359900171212      *
360000171212     C                                         '<InvoiceLineNumber>1' +
360100171212     C                                         '</InvoiceLineNumber>' +
360200171212      *
360300171212     C                                         '<InvoiceDate>'   +
360400160627     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
360500160627     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
360600160627     C                                         %SUBST(HDRINVDAT:7:2)       +
360700160627     C                                         '-04:00'                    +
360800171212     C                                         '</InvoiceDate>'            +
360900171212      *
361000171212     C                                         '<Quantity>1' +
361100171212     C                                         '</Quantity>'
361200171212     ?* End  wrkCTSXML1
361300171212      ****
361400180226      * as per Java code , need to subtract freight as well
361500160627     C                   EVAL      INTAMT = %INT(HDRTOTAMT)-
361600160627     C                                      %INT(HDRMISCCHARG)-
361700180226     C                                      %INT(HDRFREIGHTCHARG) -
361800160627     C                                      %INT(HDRTAXES)
361900160627     C                   EVAL      DECAMT = INTAMT / 100
362000160627     C                   EVAL      INCOUNT = %CHAR(DECAMT)
362100160708
362200160627     C                   IF        DECAMT < 1
362300160627     C                   EVAL      CTSXMLDTL = '<NetPurchasePrice>0'     +
362400160627     C                                         %TRIMR(INCOUNT)           +
362500160627     C                                         '</NetPurchasePrice>'
362600160627     C                   ELSE
362700160627     C                   EVAL      CTSXMLDTL = '<NetPurchasePrice>'      +
362800160627     C                                         %TRIMR(INCOUNT)           +
362900160627     C                                         '</NetPurchasePrice>'
363000160627     C                   ENDIF
363100171212     ?* Set  wrkCTSXML2
363200171212     C                   EVAL      wrkCTSXML2 = %TRIMR(CTSXMLDTL) +
363300160824
363400171212     C                                         '<SumOfPayments>0'        +
363500160627     C                                         '</SumOfPayments>'
363600171212     ?* End  wrkCTSXML2
363700171212      *
363800160627     C                   EVAL      INTAMT = %INT(HDRTAXES)
363900160627     C                   EVAL      DECAMT = INTAMT / 100
364000160627     C                   EVAL      INCOUNT = %CHAR(DECAMT)
364100160708
364200160627     C                   IF        DECAMT < 1
364300160627     C                   EVAL      CTSXMLDTL = '<TaxesPaid>0'            +
364400160627     C                                         %TRIMR(INCOUNT)           +
364500160627     C                                         '</TaxesPaid>'
364600160627     C                   ELSE
364700160627     C                   EVAL      CTSXMLDTL = '<TaxesPaid>'             +
364800160627     C                                         %TRIMR(INCOUNT)           +
364900160627     C                                         '</TaxesPaid>'
365000160627     C                   ENDIF
365100171212     ?* Set  wrkCTSXML3
365200171212     C                   EVAL      wrkCTSXML3 = %TRIMR(CTSXMLDTL) +
365300171212      *
365400171212     C                                         '<GenericMaterialCode>'   +
365500160627     C                                         '74E 16'        +
365600171212     C                                         '</GenericMaterialCode>'  +
365700171212      *
365800171212     C                                         '<ShipTo>'                +
365900171212      *
366000171212     C                                         '<CountryAbbreviation>'   +
366100160627     C                                         'US'        +
366200171212     C                                         '</CountryAbbreviation>'  +
366300171212      *
366400171212     C                                         '<StateCode>'       +
366500160627     C                                         %TRIMR(HDRSHPSTA)   +
366600171212     C                                         '</StateCode>'      +
366700171212      *
366800171212     C                                         '</ShipTo>'         +
366900171212      *
367000171212     C                                         '</Line>'           +
367100171212      *
367200171212     C                                         '</Contract>'        +
367300171212      *
367400171212     C                                         '</ns7:GetTaxserviceRequest>' +
367500171212      *
367600171212     C                                         '</soapenv:Body>'   +
367700171212      *
367800171212     C                                         '</soapenv:Envelope>'
367900171212     ?* End wrkCTSXML3
368000171212      *
368100171212     C                   EXSR      CTSWRITE
368200171212       /free
368300171212     ?* Clear old XML Input - CTS
368400171212            fd  = open(%trim($file_path1)
368500171212                       : O_WRONLY+O_CREAT+O_TRUNC
368600171212                       : S_IRGRP + S_IWGRP + S_IXGRP +
368700180308                          S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
368800171212                       : 819);
368900171212
369000171212            callp close(fd);
369100171212     ?* Compose new XML  -  CTS
369200171212            fd = open(%trim($file_path1)
369300171212                      :O_WRONLY+O_TEXTDATA);
369400171212     ?* Write CTSXML buffer into IFS
369500171212            callp write(fd:%addr(buffcts): %len(%trim(buffcts)));
369600171212            callp close(fd);
369700171212     ?* Create CTSXML history
369800171212            // Append date,timestamp for every file to be unique
369900171212            WWTIME    = %TIME();
370000171212            $new_file = 'CTSXMLIN'+ %char(WWDATE) + %char(WWTIME);
370100171212            cmd = 'CPY OBJ(''' + %trim($file_path1) + ''') +
370200171212                 TOOBJ(''' + %trim($file_dir1)+ %trim($new_file)+ ''')';
370300180227            callp(e) QCMDEXC(cmd: %len(cmd));
370400180227       /end-free
370500171212
370600180227      * Log error if copy object CTSXMLIN failed
370700180227     C                   IF        %ERROR
370800180227     C                   CLEAR                   ERRORDS
370900180227     C                   EVAL      PROGRAMNAME = PGMNAME
371000180227     C                   EVAL      MSGID       = PGMMSGID
371100180227     C                   EVAL      FILENAME = 'CTSXMLIN'
371200180227     C                   EVAL      OPCODE   = 'QCMD'
371300180227     C                   EVAL      STATUS   = PGMSTS
371400180227     C                   EVAL      EXTMSG='Error while CPY object for: '
371500180228     C                                    +%trim(HDRINVNO) + ':'
371600180227     C                                    + %trim(PGMERRDTA)
371700180227     C                   CALLB     'LOGIOERRS'
371800180227     C                   PARM                    ERRORDS
371900180227     C                   EVAL      MSG_ID = 'RBT7200'
372000180228     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ':'
372100180227     C                                       + %trim(PGMERRDTA)
372200180227     C                   EXSR      SND_ROBOT
372300180227     C
372400180227      *
372500180227     C                   ENDIF
372600180227
372700171212      *
372800171212      *     Now invoke CTS Webservice and
372900171212      *     check return to see if WithinTolerance="Y" is found
373000171212      *
373100171212     ?* Clear old CTSXML Output
373200180227       /free
373300171212            fd  = open(%trim(IFS)
373400171212                       : O_WRONLY+O_CREAT+O_TRUNC +O_CCSID
373500171212                       : S_IRGRP + S_IWGRP + S_IXGRP +
373600180308                          S_IRUSR + S_IWUSR + S_IXUSR +S_IROTH+ S_IXOTH
373700171212                       : 819);
373800171212
373900171212            callp close(fd);
374000171212
374100171212     ?* CTS Webservice call
374200171212
374300160825                         rc =      http_url_post(
374400160825                                   %trim(URL)
374500160825                                   : %addr(BUFFCTS)
374600160825                                   : %len(%trim(BUFFCTS))
374700160825                                   : %trim(IFS)
374800160802                                   : HTTP_TIMEOUT
374900160802                                   : HTTP_USERAGENT
375000160802                                   : 'text/xml'
375100160825                                   : %trim(URL)+%trim(ACTION));
375200171212                         fd = open(%TRIM(IFS): O_RDONLY + O_TEXTDATA);
375300160826                         len = read(fd:%addr(data):%size(data));
375400180814     ?* @def : Begin
375500180814            callp close(fd);
375600180814     ?* @def : End
375700160823              /end-free
375800160825     C                   EVAL      SCAN_POS =
375900160825     C                             %SCAN(TOLERANCE:DATA:1)
376000171212     ?* check return to see if WithinTolerance="Y" is found
376100171212      *
376200160825     C                   IF        SCAN_POS = 0
376300160825     C                   EVAL      HEADERIND = 1
376400180312     C                   EVAL      E5MSGVAR = 'Warning: ' +
376500160825     C                             'Taxes are not within tolerance for ' +
376600160825     C                             'invoice number: '  +
376700160825     C                             %TRIMR(HDRINVNO)
376800160825     C                   EXSR      WRITEPF5
376900180411      * @1647 : Begin
377000180411     C                   EVAL      WErrNote = ErrNote2
377100180411     C                   EXSR      CrtCFEXML
377200180411      * @1647 : End
377300160825     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
377400180209      * @UXH : Begin
377500180209     C                   EVAL      HOLDMISCCHG = '0000000000'
377600180209     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
377700180209     C                   EVAL      HOLDTAXES      = '0000000000'
377800180209      * @UXH : End
377900180411     C                   Endif
378000171212     ?* Create CTSXMLRES history
378100171212       /free
378200171212            // Append date,timestamp for every file to be unique
378300171212            WWTIME    = %TIME();
378400171212            $new_file = 'CTSXMLRES'+ %char(WWDATE) + %char(WWTIME);
378500171212            cmd = 'CPY OBJ(''' + %trim(IFS) + ''') +
378600171212                 TOOBJ(''' + %trim($file_dir1)+ %trim($new_file)+ ''')';
378700180227            callp(e) QCMDEXC(cmd: %len(cmd));
378800171212
378900171212       /end-free
379000170705      *
379100180227      * Log error if copy object CTSXMLRES failed
379200180227     C                   IF        %ERROR
379300180227     C                   CLEAR                   ERRORDS
379400180227     C                   EVAL      PROGRAMNAME = PGMNAME
379500180227     C                   EVAL      MSGID       = PGMMSGID
379600180227     C                   EVAL      FILENAME = 'CTSXMLRES'
379700180227     C                   EVAL      OPCODE   = 'QCMD'
379800180227     C                   EVAL      STATUS   = PGMSTS
379900180227     C                   EVAL      EXTMSG='Error while CPY object for: '
380000180227     C                                    +%trim(PRMMBRNAME) + '#'
380100180227     C                                    + %trim(PGMERRDTA)
380200180227     C                   CALLB     'LOGIOERRS'
380300180227     C                   PARM                    ERRORDS
380400180227     C                   EVAL      MSG_ID = 'RBT7200'
380500180227     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + '#'
380600180227     C                                       + %trim(PGMERRDTA)
380700180227     C                   EXSR      SND_ROBOT
380800180227     C
380900180227      *
381000180227     C                   ENDIF
381100171212      *
381200170705      * end of subroutine for CTSXML
381300160823     C                   ENDSR
381400171212      **********************************************************
381500171212     ?* Load CTS Buffer
381600171212      **********************************************************
381700160824     C     CTSWRITE      BEGSR
381800171212      *
381900171212     C                   EVAL      BUFFCTS = %Trimr(WrkCTSXML1)    +
382000171212     C                                       %Trimr(WrkCTSXML2)    +
382100171212     C                                       %Trimr(WrkCTSXML3)
382200171212      *
382300160824     C                   ENDSR
382400171212      **********************************************************
382500171212     ?* Write EDIPF7A and EDIPF7B
382600171212      **********************************************************
382700160801     C     WRITEPF7      BEGSR
382800160801
382900180214      * @uxh : Begin
383000180214     C**                 IF        TAXSTATE = 0 OR
383100180214     C**                           RECTYPE <> 'DDETAIL'
383200180228     C                   IF        ((TAXSTATE =0) OR (RECTYPE<>'DDETAIL'
383300180228     C                             and RECTYPE<>'DSERIALNO'))
383400180302     C                             AND (CATAXSPD<>'Y')
383500180214      * @uxh : End
383600160328     C                   EVAL      E7SKEY1 = E7KEY1
383700160328     C                   EVAL      E7SKEY2 = E7KEY2
383800160328     C                   EVAL      E7SKEY3 = E7KEY3
383900160328     C                   EVAL      E7SKEY4 = E7KEY4
384000160510     C                   EVAL      E7SKEY5 = E7KEY5
384100160328     C                   EVAL      EDIRCD7S = EDIRCD7
384200160328     C                   EVAL      E7SSEQNUM = E7SEQNUM
384300160328     C                   EVAL      E7SOBJID = E7OBJID
384400160328     C                   EVAL      E7SINVTYP = E7INVTYP
384500160328     C                   EVAL      E7SNAME = E7NAME
384600160328     C                   EVAL      E7SVATCOD = E7VATCOD
384700160328     C                   EVAL      E7SSUPLR = E7SUPLR
384800160328     C                   EVAL      E7SCMPCODE = E7CMPCODE
384900160328     C                   EVAL      E7SPOEX = E7POEX
385000160328     C                   EVAL      E7SSRA# = E7SRA#
385100160328     C                   EVAL      E7SCPSNUM = E7CPSNUM
385200160328     C                   EVAL      E7SPAYRID = E7PAYRID
385300171213     C                   WRITE     EDIPF7SR                             70
385400171213     C                   EXSR      ErrPF7A
385500160705     C                   ELSE
385600160705     C                   EVAL      E7TKEY1 = E7KEY1
385700160705     C                   EVAL      E7TKEY2 = E7KEY2
385800160705     C                   EVAL      E7TKEY3 = E7KEY3
385900160705     C                   EVAL      E7TKEY4 = E7KEY4
386000160705     C                   EVAL      E7TKEY5 = E7KEY5
386100160705     C                   EVAL      EDIRCD7T = EDIRCD7
386200160705     C                   EVAL      E7TSEQNUM = E7SEQNUM
386300160705     C                   EVAL      E7TOBJID = E7OBJID
386400160705     C                   EVAL      E7TINVTYP = E7INVTYP
386500160705     C                   EVAL      E7TNAME = E7NAME
386600160705     C                   EVAL      E7TVATCOD = E7VATCOD
386700160705     C                   EVAL      E7TSUPLR = E7SUPLR
386800160705     C                   EVAL      E7TCMPCODE = E7CMPCODE
386900160705     C                   EVAL      E7TPOEX = E7POEX
387000160705     C                   EVAL      E7TSRA# = E7SRA#
387100160705     C                   EVAL      E7TCPSNUM = E7CPSNUM
387200160705     C                   EVAL      E7TPAYRID = E7PAYRID
387300171213     C                   WRITE     EDIPF7TR                             70
387400171213     C                   EXSR      ErrPF7B
387500160705     C                   ENDIF
387600160708
387700180302     C                   EVAL      CATAXSPD  = 'N'
387800180302
387900160328     C                   ENDSR
388000171212      **********************************************************
388100171213     ?* Update EDIPF7B after Tax Spread
388200171212      **********************************************************
388300161206     C     PF7BTOPF7A1   BEGSR
388400161206     C                   EVAL      DSDETAIL = EDIRCD7T
388500160706     C                   IF        TAXACCUM <> 0 AND
388600160706     C                             DETLINTAX > '0000000000'
388700160706     C                   EVAL      INTAMT = %INT(DETLINTAX)
388800160706     C                   IF        TAXACCUM > 0
388900180226      * @1607e : Begin
389000180226     C***                EVAL      INTAMT = INTAMT + 1
389100180226     C***                EVAL      TAXACCUM = TAXACCUM - .0001
389200181004      * @1687a : Begin
389300181004     C***                EVAL      INTAMT = INTAMT + 100
389400181004     C                   EVAL      INTAMT = INTAMT + 1
389500181004      * @1687a : End
389600180226     C                   EVAL      TAXACCUM = TAXACCUM - .01
389700180226      * @1607e : End
389800160706     C                   ELSE
389900180226      * @1607e : Begin
390000180226     C***                EVAL      INTAMT = INTAMT - 1
390100180226     C***                EVAL      TAXACCUM = TAXACCUM + .0001
390200181004      * @1687a : Begin
390300181004     C***                EVAL      INTAMT = INTAMT - 100
390400181004     C                   EVAL      INTAMT = INTAMT - 1
390500181004      * @1687a : End
390600180226     C                   EVAL      TAXACCUM = TAXACCUM + .01
390700180226      * @1607e : End
390800160706     C                   ENDIF
390900161206     C                   EVAL      TAXAMT = %DECH((INTAMT)/10000:10:4)
391000180926      * @1687 : Begin
391100180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
391200181004      * @1687a : Begin
391300181004     C***                EVAL      TAXAMT2 = TAXAMT * 100
391400181004     C                   EVAL      TAXAMT2 = TAXAMT * 10000
391500181004      * @1687a : End
391600180926      * @1687 : End
391700160706     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
391800160706     C                   ENDIF
391900161206     C                   EVAL      EDIRCD7T = DSDETAIL
392000171213     C                   UPDATE    EDIPF7TR                             70
392100171213     C                   EXSR      ErrPF7B
392200160706     C                   ENDSR
392300161206
392400171212      **********************************************************
392500171212     ?* Write from EDIPF7B (Non Upfront) to EDIPF7A (Upfront)
392600171212      **********************************************************
392700161206     C     PF7BTOPF7A2   BEGSR
392800171212      *
392900161206     C                   EVAL      E7SKEY1 = E7TKEY1
393000161206     C                   EVAL      E7SKEY2 = E7TKEY2
393100161206     C                   EVAL      E7SKEY3 = E7TKEY3
393200161206     C                   EVAL      E7SKEY4 = E7TKEY4
393300161206     C                   EVAL      E7SKEY5 = E7TKEY5
393400161206     C                   EVAL      E7SSEQNUM = E7TSEQNUM
393500161206     C                   EVAL      E7SOBJID = E7TOBJID
393600161206     C                   EVAL      E7SINVTYP = E7TINVTYP
393700161206     C                   EVAL      E7SNAME = E7TNAME
393800161206     C                   EVAL      E7SVATCOD = E7TVATCOD
393900161206     C                   EVAL      E7SSUPLR = E7TSUPLR
394000161206     C                   EVAL      E7SCMPCODE = E7TCMPCODE
394100161206     C                   EVAL      E7SPOEX = E7TPOEX
394200161206     C                   EVAL      E7SSRA# = E7TSRA#
394300161206     C                   EVAL      E7SCPSNUM = E7TCPSNUM
394400161206     C                   EVAL      E7SPAYRID = E7TPAYRID
394500161206     C                   EVAL      EDIRCD7S = EDIRCD7T
394600161206     C                   WRITE     EDIPF7SR
394700171213     C                   EXSR      ErrPF7A
394800171212      *
394900161206     C                   ENDSR
395000171212      **********************************************************
395100171212     ?* Replace & > < ' " for XML as &amp; &gt; &lt; &apos; &quot
395200171212      **********************************************************
395300160323     C     REPLACECHAR   BEGSR
395400171212      *
395500160324     C                   EXSR      REPLACEAMP
395600160324     C                   EXSR      REPLACEGT
395700160324     C                   EXSR      REPLACELT
395800160324     C                   EXSR      REPLACEQUOT
395900160324     C                   EXSR      REPLACEAPOS
396000160602     C                   EXSR      REPLACEJUNK
396100160324     C                   ENDSR
396200171212      *
396300171212      **********************************************************
396400160324     C     REPLACEAMP    BEGSR
396500171212      **********************************************************
396600160323     C                   EVAL      SCAN_POS = 1
396700160323     C                   EVAL      SCAN_POS1 = 1
396800160323     C                   DOU       SCAN_POS <= 0
396900160323     C                   EVAL      SCAN_POS =
397000160324     C                             %SCAN(%TRIM(SCAN_AMP)
397100160323     C                             :SCAN_FIELD:SCAN_POS1)
397200160708
397300160323     C                   IF        (SCAN_POS = 0)
397400160323     C                   LEAVE
397500160323     C                   ENDIF
397600160708
397700160323     C                   EVAL      SCAN_POS1 = SCAN_POS + 4
397800160323     C                   EVAL      SCAN_FIELD =
397900160324     C                             %REPLACE(%TRIM(REPLACE_AMP)
398000160323     C                             :SCAN_FIELD
398100160323     C                             :SCAN_POS
398200160324     C                             :%LEN(%TRIM(SCAN_AMP)))
398300160708
398400160323     C                   IF        (SCAN_POS
398500160324     C                              + %LEN(%TRIM(REPLACE_AMP)) >
398600160323     C                             %LEN(SCAN_FIELD))
398700160323     C                   LEAVE
398800160323     C                   ENDIF
398900160708
399000160323     C                   ENDDO
399100160323     C                   ENDSR
399200171212      **********************************************************
399300171212     C     REPLACEGT     BEGSR
399400171212      **********************************************************
399500171212      *
399600160324     C                   EVAL      SCAN_POS = 1
399700160324     C                   EVAL      SCAN_POS1 = 1
399800160324     C                   DOU       SCAN_POS <= 0
399900160324     C                   EVAL      SCAN_POS =
400000160324     C                             %SCAN(%TRIM(SCAN_GT)
400100160324     C                             :SCAN_FIELD:SCAN_POS1)
400200160708
400300160324     C                   IF        (SCAN_POS = 0)
400400160324     C                   LEAVE
400500160324     C                   ENDIF
400600160708
400700160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 3
400800160324     C                   EVAL      SCAN_FIELD =
400900160324     C                             %REPLACE(%TRIM(REPLACE_GT)
401000160324     C                             :SCAN_FIELD
401100160324     C                             :SCAN_POS
401200160324     C                             :%LEN(%TRIM(SCAN_GT)))
401300160708
401400160324     C                   IF        (SCAN_POS
401500160324     C                              + %LEN(%TRIM(REPLACE_GT)) >
401600160324     C                             %LEN(SCAN_FIELD))
401700160324     C                   LEAVE
401800160324     C                   ENDIF
401900160708
402000160324     C                   ENDDO
402100160324     C                   ENDSR
402200171212      **********************************************************
402300171212     C     REPLACELT     BEGSR
402400171212      **********************************************************
402500171212      *
402600160324     C                   EVAL      SCAN_POS = 1
402700160324     C                   EVAL      SCAN_POS1 = 1
402800160324     C                   DOU       SCAN_POS <= 0
402900160324     C                   EVAL      SCAN_POS =
403000160324     C                             %SCAN(%TRIM(SCAN_LT)
403100160324     C                             :SCAN_FIELD:SCAN_POS1)
403200160708
403300160324     C                   IF        (SCAN_POS = 0)
403400160324     C                   LEAVE
403500160324     C                   ENDIF
403600160708
403700160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 3
403800160324     C                   EVAL      SCAN_FIELD =
403900160324     C                             %REPLACE(%TRIM(REPLACE_LT)
404000160324     C                             :SCAN_FIELD
404100160324     C                             :SCAN_POS
404200160324     C                             :%LEN(%TRIM(SCAN_LT)))
404300160708
404400160324     C                   IF        (SCAN_POS
404500160324     C                              + %LEN(%TRIM(REPLACE_LT)) >
404600160324     C                             %LEN(SCAN_FIELD))
404700160324     C                   LEAVE
404800160324     C                   ENDIF
404900160708
405000160324     C                   ENDDO
405100160324     C                   ENDSR
405200171212      **********************************************************
405300171212     C     REPLACEQUOT   BEGSR
405400171212      **********************************************************
405500171212      *
405600160324     C                   EVAL      SCAN_POS = 1
405700160324     C                   EVAL      SCAN_POS1 = 1
405800160324     C                   DOU       SCAN_POS <= 0
405900160324     C                   EVAL      SCAN_POS =
406000160324     C                             %SCAN(%TRIM(SCAN_QUOT)
406100160324     C                             :SCAN_FIELD:SCAN_POS1)
406200160708
406300160324     C                   IF        (SCAN_POS = 0)
406400160324     C                   LEAVE
406500160324     C                   ENDIF
406600160708
406700160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 5
406800160324     C                   EVAL      SCAN_FIELD =
406900160324     C                             %REPLACE(%TRIM(REPLACE_QUOT)
407000160324     C                             :SCAN_FIELD
407100160324     C                             :SCAN_POS
407200160324     C                             :%LEN(%TRIM(SCAN_QUOT)))
407300160708
407400160324     C                   IF        (SCAN_POS
407500160324     C                              + %LEN(%TRIM(REPLACE_QUOT)) >
407600160324     C                             %LEN(SCAN_FIELD))
407700160324     C                   LEAVE
407800160324     C                   ENDIF
407900160708
408000160324     C                   ENDDO
408100160324     C                   ENDSR
408200171212      **********************************************************
408300171212     C     REPLACEAPOS   BEGSR
408400171212      **********************************************************
408500171212      *
408600160324     C                   EVAL      SCAN_POS = 1
408700160324     C                   EVAL      SCAN_POS1 = 1
408800160324     C                   DOU       SCAN_POS <= 0
408900160324     C                   EVAL      SCAN_POS =
409000160324     C                             %SCAN(%TRIM(SCAN_APOS)
409100160324     C                             :SCAN_FIELD:SCAN_POS1)
409200160708
409300160324     C                   IF        (SCAN_POS = 0)
409400160324     C                   LEAVE
409500160324     C                   ENDIF
409600160708
409700160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 5
409800160324     C                   EVAL      SCAN_FIELD =
409900160324     C                             %REPLACE(%TRIM(REPLACE_APOS)
410000160324     C                             :SCAN_FIELD
410100160324     C                             :SCAN_POS
410200160324     C                             :%LEN(%TRIM(SCAN_APOS)))
410300160708
410400160324     C                   IF        (SCAN_POS
410500160324     C                              + %LEN(%TRIM(REPLACE_APOS)) >
410600160324     C                             %LEN(SCAN_FIELD))
410700160324     C                   LEAVE
410800160324     C                   ENDIF
410900160708
411000160324     C                   ENDDO
411100160324     C                   ENDSR
411200171212      **********************************************************
411300171212     C     REPLACEJUNK   BEGSR
411400171212      **********************************************************
411500171212      *
411600160602     C                   EVAL      SCAN_POS = 1
411700160602     C                   DOU       SCAN_POS <= 0
411800160602     C                   EVAL      SCAN_POS =
411900160602     C                             %CHECK(KEYBOARD : SCAN_FIELD)
412000160708
412100160602     C                   IF        (SCAN_POS = 0)
412200160602     C                   LEAVE
412300160602     C                   ENDIF
412400160708
412500160602     C                   EVAL      SCAN_FIELD =
412600160602     C                             %REPLACE('?'
412700160602     C                             :SCAN_FIELD
412800160602     C                             :SCAN_POS
412900160602     C                             :1)
413000160602     C                   ENDDO
413100160602     C                   ENDSR
413200160323      *
413300171212     ?* Initialize
413400170831      *********************************************************************
413500160316     C     INITSR        BEGSR
413600170831      *********************************************************************
413700160316     C                   TIME                    TIMSTP
413800160316     C     *HMS          MOVE      SYSTIME       SYS_TIME
413900171212      *
414000170628      * Set program name.
414100170628     C                   EVAL      PROGRAMNAME = PGMNAME
414200170628      *
414300170615     C                   EVAL      WWDATE     = SYS_DATE
414400170620     C                   EVAL      WWTIME     = SYS_TIME
414500170620      *
414600170831      * Clear workfiles, initialize, and open
414700170831      *
414800180220     C                   EVAL      INVOICENDX = 1
414900170831
415000170831     C                   DOU       INVOICENDX > 10000
415100170831     C                   EVAL      INVOICEVALID(INVOICENDX) = '0'
415200170831     C                   EVAL      INVOICETAX(INVOICENDX) = '0'
415300170831     C                   EVAL      INVOICENDX = INVOICENDX + 1
415400170831     C                   ENDDO
415500170831
415600180220      * @1607d : Begin
415700180220     C***                EVAL      INVOICENDX = 1
415800180220     C                   EVAL      INVOICENDX = 0
415900180220      * @1607d : End
416000171212      *
416100170831     C                   EVAL      CMDLENGTH = 256
416200170831     C                   EVAL      CMDTEXT = *BLANKS
416300170831     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7A'
416400170831     C                   CALL      'QCMDEXC'
416500170831     C                   PARM                    CMDTEXT
416600170831     C                   PARM                    CMDLENGTH
416700170831
416800170831     C                   EVAL      CMDTEXT = *BLANKS
416900170831     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7B'
417000170831     C                   CALL      'QCMDEXC'
417100170831     C                   PARM                    CMDTEXT
417200170831     C                   PARM                    CMDLENGTH
417300170831
417400180917      * @1685 : Begin
417500180917     C***                EVAL      BUFFER = ' '
417600180917      * @1685 : End
417700171212      *
417800171206     C                   EVAL      BUFFER1= *Blanks
417900171212      *
418000170831     C                   OPEN      EDIPF7A
418100170831     C                   OPEN      EDIPF7B
418200180222      *
418300171212     ?* Chain EDIPF14 to load all work variables
418400170831     C                   EVAL      EDIXMLKEY0 = '*ANY'
418500170831     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
418600170831     C                   EVAL      EDIXMLKEY2 = 'UPFRONT'
418700170831      *
418800170831     C     EDIXMLKEY     CHAIN     EDIPF14
418900170831     C                   IF        %FOUND
419000170831     C                   EVAL      UPFRONTSTATES = EDIXMLDATA
419100170831     C                   ENDIF
419200170831      *
419300171212     ?* Set xml save Path for EDIXML
419400171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
419500171208     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
419600171208     C                   EVAL      EDIXMLKEY2 = 'EDIIFSIN'
419700171208      *
419800171208     C     EDIXMLKEY     CHAIN     EDIPF14
419900171208     C                   IF        %FOUND
420000171208     C                   EVAL      $file_path         = EDIXMLDATA
420100171208     C                   ENDIF
420200171208      *
420300171208     C                   EVAL      EDIXMLKEY0 = PRMSYSID
420400171208     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
420500171208     C                   EVAL      EDIXMLKEY2 = 'EDIIFSDIR'
420600171208      *
420700171208     C     EDIXMLKEY     CHAIN     EDIPF14
420800171208     C                   IF        %FOUND
420900171208     C                   EVAL      $file_dir          = EDIXMLDATA
421000171208     C                   ENDIF
421100171208      *
421200171212     ?* Set xml save Path for CTSXML
421300171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
421400171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
421500171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSIN'
421600171212      *
421700171212     C     EDIXMLKEY     CHAIN     EDIPF14
421800171212     C                   IF        %FOUND
421900171212     C                   EVAL      $file_path1        = EDIXMLDATA
422000171212     C                   ENDIF
422100171212      *
422200171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
422300171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
422400171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSDIR'
422500171212      *
422600171212     C     EDIXMLKEY     CHAIN     EDIPF14
422700171212     C                   IF        %FOUND
422800171212     C                   EVAL      $file_dir1         = EDIXMLDATA
422900171212     C                   ENDIF
423000180222     ?* Set archive save Path for EDI file in tmp
423100180222     C                   EVAL      EDIXMLKEY0 = PRMSYSID
423200180222     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
423300180222     C                   EVAL      EDIXMLKEY2 = 'EDITMPDIR'
423400180222      *
423500180222     C     EDIXMLKEY     CHAIN     EDIPF14
423600180222     C                   IF        %FOUND
423700180222     C                   EVAL      $tmp_dir           = EDIXMLDATA
423800180222     C                   ENDIF
423900180222      *
424000180222     C                   EVAL      EDIXMLKEY0 = PRMSYSID
424100180222     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
424200180222     C                   EVAL      EDIXMLKEY2 = 'EDIARCDIR'
424300180222      *
424400180222     C     EDIXMLKEY     CHAIN     EDIPF14
424500180222     C                   IF        %FOUND
424600180222     C                   EVAL      $arc_dir           = EDIXMLDATA
424700180222     C                   ENDIF
424800171212     ?* XMLCONTROL work variables
424900171212     ?* SOAPADDR ********
425000171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
425100171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
425200171212     C                   EVAL      EDIXMLKEY2 = 'SOAPADDR'
425300171212     C     EDIXMLKEY     CHAIN     EDIPF14
425400171212      *
425500171212     C                   IF        NOT %FOUND
425600171212     C                   EVAL      MSG_ID = 'RBT8011'
425700171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
425800171212     C                   EXSR      SND_ROBOT
425900171212     C                   CLEAR                   ERRORDS
426000171212     C                   EVAL      FILENAME = PF14FIL
426100171212     C                   EVAL      OPCODE = PF14OPC
426200171212     C                   EVAL      STATUS = PF14FST
426300171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
426400171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
426500171212     C                                      ' ' + EDIXMLKEY2
426600171212     C                   EXSR      ERRLOG
426700171212     C                   ELSE
426800171212     C                   EVAL      wSOAPADR = EDIXMLDATA
426900171212     C                   ENDIF
427000171212     ?* XMLENV *******
427100171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
427200171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
427300171212     C                   EVAL      EDIXMLKEY2 = 'XMLENV'
427400171212      *
427500171212     C     EDIXMLKEY     CHAIN     EDIPF14
427600171212      *
427700171212     C                   IF        NOT %FOUND
427800171212     C                   EVAL      MSG_ID = 'RBT8011'
427900171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
428000171212     C                   EXSR      SND_ROBOT
428100171212     C                   CLEAR                   ERRORDS
428200171212     C                   EVAL      FILENAME = PF14FIL
428300171212     C                   EVAL      OPCODE = PF14OPC
428400171212     C                   EVAL      STATUS = PF14FST
428500171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
428600171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
428700171212     C                                      ' ' + EDIXMLKEY2
428800171212     C                   EXSR      ERRLOG
428900171212     C                   ELSE
429000171212     C                   EVAL      wXMLENV = EDIXMLDATA
429100171212     C                   ENDIF
429200171212     ?********
429300171212     ?* CTS Webservice work variables
429400171212     ?* CTSURL ***************************
429500171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
429600171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
429700171212     C                   EVAL      EDIXMLKEY2 = 'CTSURL'
429800171212     C     EDIXMLKEY     CHAIN     EDIPF14
429900171212      *
430000171212     C                   IF        NOT %FOUND
430100171212     C                   EVAL      MSG_ID = 'RBT8011'
430200171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
430300171212     C                   EXSR      SND_ROBOT
430400171212     C                   CLEAR                   ERRORDS
430500171212     C                   EVAL      FILENAME = PF14FIL
430600171212     C                   EVAL      OPCODE = PF14OPC
430700171212     C                   EVAL      STATUS = PF14FST
430800171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
430900171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
431000171212     C                                      ' ' + EDIXMLKEY2
431100171212     C                   EXSR      ERRLOG
431200171212     C                   ENDIF
431300171212      *
431400171212     C                   EVAL      URL = EDIXMLDATA
431500171212     ?* CTSACTION *************
431600171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
431700171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
431800171212     C                   EVAL      EDIXMLKEY2 = 'CTSACTION'
431900171212     C     EDIXMLKEY     CHAIN     EDIPF14
432000171212      *
432100171212     C                   IF        NOT %FOUND
432200171212     C                   EVAL      MSG_ID = 'RBT8011'
432300171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
432400171212     C                   EXSR      SND_ROBOT
432500171212     C                   CLEAR                   ERRORDS
432600171212     C                   EVAL      FILENAME = PF14FIL
432700171212     C                   EVAL      OPCODE = PF14OPC
432800171212     C                   EVAL      STATUS = PF14FST
432900171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
433000171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
433100171212     C                                      ' ' + EDIXMLKEY2
433200171212     C                   EXSR      ERRLOG
433300171212     C                   ENDIF
433400171212      *
433500171212     C                   EVAL      ACTION = EDIXMLDATA
433600171212     ?* CTSIFSOUT *************
433700171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
433800171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
433900171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSOUT'
434000171212     C     EDIXMLKEY     CHAIN     EDIPF14
434100171212      *
434200171212     C                   IF        NOT %FOUND
434300171212     C                   EVAL      MSG_ID = 'RBT8011'
434400171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
434500171212     C                   EXSR      SND_ROBOT
434600171212     C                   CLEAR                   ERRORDS
434700171212     C                   EVAL      FILENAME = PF14FIL
434800171212     C                   EVAL      OPCODE = PF14OPC
434900171212     C                   EVAL      STATUS = PF14FST
435000171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
435100171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
435200171212     C                                      ' ' + EDIXMLKEY2
435300171212     C                   EXSR      ERRLOG
435400171212     C                   ENDIF
435500171212      *
435600171212     C                   EVAL      IFS = EDIXMLDATA
435700171212     ?*************************
435800171212      *
435900160316     C                   ENDSR
436000180222      *********************************************************************
436100180222     ?* Move EDI Invoice file from tmp to archive directory
436200180222      *********************************************************************
436300180222     C     MovTmpEDI     BEGSR
436400180222      *
436500180222     C                   MOVE      WWDATE        CHAR_DATE
436600180222     C                   EVAL      CHAR_DATE1= %SUBST(CHAR_DATE:1:4)+
436700180222     C                                         %SUBST(CHAR_DATE:6:2)+
436800180222     C                                         %SUBST(CHAR_DATE:9:2)
436900180222      *
437000180222       /free
437100180222            // Rename EDI invoice file with control num and current date
437200180222
437300180222            $new_file = %trim(PRMMBRNAME) + '.' + %triml(%CHAR(HldSEQNUM))
437400180222                        +'.' + %trim(CHAR_DATE1);
437500180222            $tmp_dir  = %trim($tmp_dir) + %trim(PRMMBRNAME);
437600180222
437700180222            cmd = 'CPY OBJ(''' + %trim($tmp_dir) + ''') +
437800180223                   TOOBJ(''' + %trim($arc_dir)+ %trim($new_file)+ ''') +
437900180223                   REPLACE(*YES)';
438000180222            callp(e) QCMDEXC(cmd: %len(cmd));
438100180224
438200180224            if not%error;
438300180225            rcdlt = unlink(%TRIM($tmp_dir));
438400180224            endif;
438500180222       /end-free
438600180225      * Log error if copy object EDI file failed
438700180222     C                   IF        %ERROR
438800180222     C                   CLEAR                   ERRORDS
438900180222     C                   EVAL      PROGRAMNAME = PGMNAME
439000180222     C                   EVAL      MSGID       = PGMMSGID
439100180222     C                   EVAL      FILENAME = 'MOVTMPEDI'
439200180222     C                   EVAL      OPCODE   = 'QCMD'
439300180222     C                   EVAL      STATUS   = PGMSTS
439400180222     C                   EVAL      EXTMSG='Error while CPY object for: '
439500180222     C                                    +%trim(PRMMBRNAME) + '-'
439600180222     C                                    + %trim(PGMERRDTA)
439700180222     C                   CALLB     'LOGIOERRS'
439800180222     C                   PARM                    ERRORDS
439900180222     C                   EVAL      MSG_ID = 'RBT7200'
440000180222     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + '-'
440100180222     C                                       + %trim(PGMERRDTA)
440200180222     C                   EXSR      SND_ROBOT
440300180222     C
440400180222      *
440500180222     C                   ENDIF
440600180225      * Log error if unlink failed
440700180225     C                   IF        RCDLT < 0
440800180225     C                   CLEAR                   ERRORDS
440900180225     C                   EVAL      PROGRAMNAME = PGMNAME
441000180225     C                   EVAL      MSGID       = 'ICC6700'
441100180225     C                   EVAL      FILENAME = 'DLTTMPEDI'
441200180225     C                   EVAL      OPCODE   = 'UNLINK'
441300180225     C                   EVAL      STATUS   = PGMSTS
441400180225     C                   EVAL      EXTMSG='Error while unlink for: '
441500180225     C                                    +%trim(PRMMBRNAME)
441600180225     C                   CALLB     'LOGIOERRS'
441700180225     C                   PARM                    ERRORDS
441800180225     C                   EVAL      MSG_ID = 'RBT7200'
441900180225     C                   EVAL      MSG_DTA = 'Error unlink for: '
442000180225     C                                       +%trim(PRMMBRNAME)
442100180225     C                   EXSR      SND_ROBOT
442200180225     C
442300180225      *
442400180225     C                   ENDIF
442500180225      *
442600180222     C                   ENDSR
442700180222      *********************************************************************
442800180222     ?* Archive EDI xml
442900180222      *********************************************************************
443000180222     C     CpyObjEDI     BEGSR
443100180222      *
443200180222       /free
443300180222            // Append date,timestamp for every file to be unique
443400180222            WWTIME    = %TIME();
443500180222
443600180222            $new_file = 'EDIXMLIN'+ %char(WWDATE) + %char(WWTIME);
443700180222
443800180222            cmd = 'CPY OBJ(''' + %trim($file_path) + ''') +
443900180222                   TOOBJ(''' + %trim($file_dir)+ %trim($new_file)+ ''')';
444000180222            callp(e) QCMDEXC(cmd: %len(cmd));
444100180222
444200180222            if not%error;
444300180222            counter = 6;
444400180222            endif;
444500180222
444600180222       /end-free
444700180222      *
444800180222     C                   ENDSR
444900170831      *********************************************************************
445000171212     ?* MQ Process
445100170831      *********************************************************************
445200170111     C     MQSR          BEGSR
445300171212      *
445400180305       /free
445500171208     ?* Write xml buffer into IFS
445600171208            callp write(fd:%addr(buffer1): %len(%trim(buffer1)));
445700171208            callp close(fd);
445800171208     ?* Create EDI xml history
445900180305         // Exsr CpyObjEDI;
446000180222
446100180222     ?* if EDIXMLIN object in use
446200180305         // if %error and PGMMSGID = 'CPFA09E';
446300180305         // counter = 0;
446400180305         // Dou counter>5;
446500180305         // cmd =  'DLYJOB DLY(1)';
446600180305         // callp QCMDEXC(cmd: %len(cmd));
446700180305         // Exsr CpyObjEDI;
446800180305         // counter = counter + 1;
446900180305         // Enddo;
447000180305         // Endif;
447100171214       /end-free
447200180222      *
447300180305     C*                  IF        %ERROR
447400180305     C*                  CLEAR                   ERRORDS
447500180305     C*                  EVAL      PROGRAMNAME = PGMNAME
447600180305     C*                  EVAL      MSGID       = PGMMSGID
447700180305     C*                  EVAL      FILENAME = 'EDIXMLIN'
447800180305     C*                  EVAL      OPCODE   = 'QCMD'
447900180305     C*                  EVAL      STATUS   = PGMSTS
448000180305     C*                  EVAL      EXTMSG='Error while CPY object for: '
448100180305     C*                                   +%trim(HDRINVNO) + '-'
448200180305     C*                                   + %trim(PGMERRDTA)
448300180305     C*                  CALLB     'LOGIOERRS'
448400180305     C*                  PARM                    ERRORDS
448500180305     C*                  EVAL      MSG_ID = 'RBT8013'
448600180305     C*                  EVAL      MSG_DTA = %TRIM(HDRINVNO) + '-'
448700180305     C*                                      + %trim(PGMERRDTA)
448800180305     C*                  EXSR      SND_ROBOT
448900180305     C*
449000180222      *
449100180305     C*                  ENDIF
449200180305       /free
449300180305            // Append date,timestamp for every file to be unique
449400180305            WWTIME    = %TIME();
449500180305
449600180305            $new_file = %trim($file_dir) + 'EDIXMLIN'+ %char(WWDATE) +
449700180305                              %char(WWTIME);
449800180305     ?* Clear old XML log history
449900180305            fd  = open(%trim($new_file)
450000180305                       : O_WRONLY+O_CREAT+O_TRUNC
450100180305                       : S_IRGRP + S_IWGRP + S_IXGRP +
450200180308                          S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
450300180305                       : 819);
450400180305
450500180305            callp close(fd);
450600180305     ?* Create EDI xml history
450700180305            fd = open(%trim($new_file)
450800180305                      :O_WRONLY+O_TEXTDATA);
450900180305     ?* Write EDIXML buffer into IFS archive
451000180305            callp(e) write(fd:%addr(buffer1): %len(%trim(buffer1)));
451100180305            callp close(fd);
451200180305       /end-free
451300171213
451400180305     C                   IF        %ERROR
451500180305     C                   CLEAR                   ERRORDS
451600180305     C                   EVAL      PROGRAMNAME = PGMNAME
451700180305     C                   EVAL      MSGID       = PGMMSGID
451800180305     C                   EVAL      FILENAME = 'EDIXMLIN'
451900180305     C                   EVAL      OPCODE   = 'WRITE'
452000180305     C                   EVAL      STATUS   = PGMSTS
452100180305     C                   EVAL      EXTMSG='Error while WRT object for: '
452200180305     C                                    +%trim(HDRINVNO) + '-'
452300180305     C                                    + %trim(PGMERRDTA)
452400180305     C                   CALLB     'LOGIOERRS'
452500180305     C                   PARM                    ERRORDS
452600180305     C                   EVAL      MSG_ID = 'RBT8013'
452700180305     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + '-'
452800180305     C                                       + %trim(PGMERRDTA)
452900180305     C                   EXSR      SND_ROBOT
453000180305      *
453100180305     C                   ENDIF
453200180305
453300171212      *
453400171212     ?* Get Queue manager name
453500161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
453600160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
453700160422     C                   EVAL      EDIXMLKEY2 = 'MQMANAGER'
453800160707     C     EDIXMLKEY     CHAIN     EDIPF14
453900170831      *
454000170831     C                   IF        NOT %FOUND
454100170831     C                   EVAL      MSG_ID = 'RBT8011'
454200170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
454300170831     C                   EXSR      SND_ROBOT
454400170831     C                   CLEAR                   ERRORDS
454500170831     C                   EVAL      FILENAME = PF14FIL
454600170831     C                   EVAL      OPCODE = PF14OPC
454700170831     C                   EVAL      STATUS = PF14FST
454800170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
454900170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
455000170831     C                                      ' ' + EDIXMLKEY2
455100170831     C                   EXSR      ERRLOG
455200170831     C                   ENDIF
455300170831      *
455400160422      * Queue manager name
455500160422     C                   EVAL      QMNAME     = EDIXMLDATA
455600160422     C                   EVAL      ODMN       = EDIXMLDATA
455700171212      *
455800171212     ?* Get Output queue name
455900161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
456000160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
456100160422     C                   EVAL      EDIXMLKEY2 = 'MQOUTNAME'
456200160707     C     EDIXMLKEY     CHAIN     EDIPF14
456300170831      *
456400170831     C                   IF        NOT %FOUND
456500170831     C                   EVAL      MSG_ID = 'RBT8011'
456600170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
456700170831     C                   EXSR      SND_ROBOT
456800170831     C                   CLEAR                   ERRORDS
456900170831     C                   EVAL      FILENAME = PF14FIL
457000170831     C                   EVAL      OPCODE = PF14OPC
457100170831     C                   EVAL      STATUS = PF14FST
457200170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
457300170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
457400170831     C                                      ' ' + EDIXMLKEY2
457500170831     C                   EXSR      ERRLOG
457600170831     C                   ENDIF
457700170831      *
457800160422      * Output queue
457900160422     C                   EVAL      ODON       = EDIXMLDATA
458000171212     ?* Connect MQ
458100160617     C                   EVAL      MQCNT = 1
458200160617     C                   EVAL      CMPCOD = 1
458300160617     C                   DOU       CMPCOD = 0 OR
458400160617     C                             MQCNT > 5
458500170528      /free
458600170528       MQCONN(QMNAME : HConn : CMPCOD         : Reason);
458700170528      /end-free
458800160708
458900160617     C                   IF        CMPCOD = 0
459000160617     C                   EVAL      MQCNT = 6
459100160617     C                   ELSE
459200160617     C                   EVAL      MQCNT = MQCNT + 1
459300160617     C                   EVAL      CMDLENGTH = 256
459400160617     C                   EVAL      CMDTEXT = *BLANKS
459500160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
459600160617     C                   CALL      'QCMDEXC'
459700160617     C                   PARM                    CMDTEXT
459800160617     C                   PARM                    CMDLENGTH
459900160617     C                   ENDIF
460000160708
460100160617     C                   ENDDO
460200160708
460300160617     C                   IF        CMPCOD <> 0
460400160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
460500160617     C                             'cannot connect to MQ'
460600160617     C                   EXSR      WRITEPF5
460700171212      *
460800171212     ?* Log MQ Invoke history file
460900170615     C                   EVAL      WCNAME  = 'MQCONN'
461000170615     C                   EXSR      LOGMQCALL
461100171212      *
461200160617     C                   EVAL      *INLR = *ON
461300160617     C                   RETURN
461400160617     C                   ENDIF
461500160422      *
461600171212     ?* Open queue to put messages
461700170528     C                   EVAL      OPTS = OOOUT + OOFIQ
461800171212      *
461900160422     C                   EVAL      OBJDSC= MQOD
462000160617     C                   EVAL      MQCNT = 1
462100160617     C                   EVAL      CMPCOD = 1
462200160617     C                   DOU       CMPCOD = 0 OR
462300160617     C                             MQCNT > 5
462400170528      /free
462500170528       MQOPEN(HConn : MQOD : Opts    : HObj : CMPCOD   : Reason);
462600170528      /end-free
462700160708
462800160617     C                   IF        CMPCOD = 0
462900160617     C                   EVAL      MQCNT = 6
463000160617     C                   ELSE
463100160617     C                   EVAL      MQCNT = MQCNT + 1
463200160617     C                   EVAL      CMDLENGTH = 256
463300160617     C                   EVAL      CMDTEXT = *BLANKS
463400160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
463500160617     C                   CALL      'QCMDEXC'
463600160617     C                   PARM                    CMDTEXT
463700160617     C                   PARM                    CMDLENGTH
463800160617     C                   ENDIF
463900160708
464000160617     C                   ENDDO
464100160617     C                   IF        CMPCOD <> 0
464200160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
464300160617     C                             'cannot open MQ'
464400160617     C                   EXSR      WRITEPF5
464500171212      *
464600171212     ?* Log MQ Invoke history file
464700170615     C                   EVAL      WCNAME  = 'MQOPEN'
464800170615     C                   EXSR      LOGMQCALL
464900171212      *
465000160617     C                   EVAL      *INLR = *ON
465100160617     C                   RETURN
465200160617     C                   ENDIF
465300160422      *
465400171212     ?* Put
465500171212     ?* Positive and Negative action notification reports
465600160422     C                   EVAL      MDREP = RONAN + ROPAN
465700160422      * Report message
465800171212      *
465900170518     C                   MOVEL     FMSTR         MDFMT
466000171212      *
466100161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
466200160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
466300160422     C                   EVAL      EDIXMLKEY2 = 'MQCCSID'
466400160707     C     EDIXMLKEY     CHAIN     EDIPF14
466500170831      *
466600170831     C                   IF        NOT %FOUND
466700170831     C                   EVAL      MSG_ID = 'RBT8011'
466800170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
466900170831     C                   EXSR      SND_ROBOT
467000170831     C                   CLEAR                   ERRORDS
467100170831     C                   EVAL      FILENAME = PF14FIL
467200170831     C                   EVAL      OPCODE = PF14OPC
467300170831     C                   EVAL      STATUS = PF14FST
467400170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
467500170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
467600170831     C                                      ' ' + EDIXMLKEY2
467700170831     C                   EXSR      ERRLOG
467800170831     C                   ENDIF
467900170831      *
468000171212     ?* MQPRIORITY
468100160422     C                   EVAL      MDCSI = %INT(%TRIMR(EDIXMLDATA))
468200161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
468300160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
468400160422     C                   EVAL      EDIXMLKEY2 = 'MQPRIORITY'
468500160707     C     EDIXMLKEY     CHAIN     EDIPF14
468600170831      *
468700170831     C                   IF        NOT %FOUND
468800170831     C                   EVAL      MSG_ID = 'RBT8011'
468900170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
469000170831     C                   EXSR      SND_ROBOT
469100170831     C                   CLEAR                   ERRORDS
469200170831     C                   EVAL      FILENAME = PF14FIL
469300170831     C                   EVAL      OPCODE = PF14OPC
469400170831     C                   EVAL      STATUS = PF14FST
469500170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
469600170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
469700170831     C                                      ' ' + EDIXMLKEY2
469800170831     C                   EXSR      ERRLOG
469900170831     C                   ENDIF
470000170831      *
470100160422      * Priority
470200160422     C                   EVAL      MDPRI = %INT(%TRIMR(EDIXMLDATA))
470300171212      *
470400161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
470500160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
470600160422     C                   EVAL      EDIXMLKEY2 = 'MQINNAME'
470700160707     C     EDIXMLKEY     CHAIN     EDIPF14
470800170831      *
470900170831     C                   IF        NOT %FOUND
471000170831     C                   EVAL      MSG_ID = 'RBT8011'
471100170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
471200170831     C                   EXSR      SND_ROBOT
471300170831     C                   CLEAR                   ERRORDS
471400170831     C                   EVAL      FILENAME = PF14FIL
471500170831     C                   EVAL      OPCODE = PF14OPC
471600170831     C                   EVAL      STATUS = PF14FST
471700170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
471800170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
471900170831     C                                      ' ' + EDIXMLKEY2
472000170831     C                   EXSR      ERRLOG
472100170831     C                   ENDIF
472200170831      *
472300171212     ?* Input queue
472400180312      * @1607g : Begin
472500180312      * Clear message id so that new msg id sent by MQ for every invoice
472600180309     C                   EVAL      MDMID      = MINONE
472700180312      * @1607g : End
472800160422     C                   EVAL      MDRQ       = EDIXMLDATA
472900160422     C                   EVAL      MSGDSC     = MQMD
473000160422     C                   EVAL      PMO        = MQPMO
473100160617     C                   EVAL      MQCNT = 1
473200160617     C                   EVAL      CMPCOD = 1
473300171212      *
473400171212     ?* Write Invoice_Control  before MQPUT
473500170616     C                   EXSR      Wrt_INVOCTL
473600171212      *
473700180917      * @1685 : Begin
473800180917     C***                EVAL      BUFFER = %TRIMR(BUFFER1)
473900180917     C***                EVAL      BUFLEN    = %LEN(%TRIMR(Buffer))
474000180917     C                   EVAL      BUFFER1= %TRIMR(BUFFER1)
474100180917     C                   EVAL      BUFLEN    = %LEN(%TRIMR(Buffer1))
474200180917      * @1685 : End
474300171212      *
474400160617     C                   DOU       CMPCOD = 0 OR
474500160617     C                             MQCNT > 5
474600170526      *
474700170528      /free
474800180917        // @1685 : Begin
474900180917        //    MQPUT(HConn : HObj : MQMD  : MQPMO :  Buflen :%ADDR(BUFFER)  :
475000180917        //       Cmpcod         : Reason);
475100180917              MQPUT(HConn : HObj : MQMD  : MQPMO :  Buflen :%ADDR(BUFFER1):
475200180917                 Cmpcod         : Reason);
475300180917        // @1685 : End
475400170528      /end-free
475500160708
475600160617     C                   IF        CMPCOD = 0
475700160617     C                   EVAL      MQCNT = 6
475800171212      *
475900171212     ?* Convert Character to Hexadecimal Message id
476000170627     C                   CALL      'CVTCHARHEX'
476100170627     C                   PARM                    MDMID
476200170627     C                   PARM                    hldMQ_MSG_ID
476300170627      *
476400170616     C                   EXSR      Upd_INVOCTL
476500171212      *
476600160617     C                   ELSE
476700160617     C                   EVAL      MQCNT = MQCNT + 1
476800160617     C                   EVAL      CMDLENGTH = 256
476900160617     C                   EVAL      CMDTEXT = *BLANKS
477000160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
477100160617     C                   CALL      'QCMDEXC'
477200160617     C                   PARM                    CMDTEXT
477300160617     C                   PARM                    CMDLENGTH
477400160617     C                   ENDIF
477500160708
477600160617     C                   ENDDO
477700171212      *
477800171212     ?* Log MQ Invoke history file
477900170615     C                   EVAL      WCNAME  = 'MQPUT'
478000170615     C                   EXSR      LOGMQCALL
478100171212      *
478200160617     C                   IF        CMPCOD <> 0
478300160617     C                   EVAL      HEADERIND = 1
478400160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
478500160617     C                             'cannot put to MQ for invoice number: '+
478600160617     C                             %TRIMR(HDRINVNO)
478700160617     C                   EXSR      WRITEPF5
478800160617     C                   RETURN
478900160617     C                   ENDIF
479000160422      *
479100171212     ?* Disconnect MQ
479200170528      /free
479300170528         MQDISC(HConn : CMPCOD         : Reason);
479400170528      /end-free
479500170528     C                   ENDSR
