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
008400190412      * @1692  GIP1792298 11/2018  UXH   Changes for CCSID 500 to
008500190412      *                                  1208 unicode
008600190422      * @1756  GIP1973249 04/2019  KES   Need VATVARPF to expand to allow
008700190422      *                                  4 digits and 2 decimals.
008800160707     *******************************************************************
008900160707      *
009000160707     *****************************************************************
009100160707      *            Definition Specification
009200160707     *****************************************************************
009300180225      * H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('LIBHTTP/HTTPAPI')
009400180225      *
009500170831     FEDIPF14   IF   E           K DISK    INFDS(PF14DS)
009600160315     FEDIPF7    IF   E             DISK    INFDS(PF7INFDS)
009700161107     FEDIFRTCTL IF   E           K DISK
009800160601     FBATCH00001UF   E           K DISK    RENAME(BATCH00001:BATCHCTL)
009900160315     F                                     INFDS(BATCHINFDS)
010000160316     FEDIPF5    UF A E             DISK
010100180304     FEDIPF7A   UF A E           K DISK    INFDS(PF7ADS)
010200160329     F                                     USROPN
010300180202     FEDIPF7B   UF A E           K DISK    INFDS(PF7BDS)
010400160630     F                                     USROPN
010500170611     FMQOUTHP   UF A E             DISK    INFDS(MQHSDS)
010600180303     FVATVARPF  IF   E           K DISK
010700171212      *
010800170611      * File data structure for file: MQOUTHP
010900170611     DMQHSDS           DS
011000170611     DMQHSFIL            *FILE
011100170611     DMQHSOPN                  9      9
011200170611     DMQHSINP            *INP
011300170611     DMQHSMOD            *MODE
011400170611     DMQHSOUT            *OUT
011500170611     DMQHSOPC            *OPCODE
011600170611     DMQHSSIZ            *SIZE
011700170611     DMQHSFST            *STATUS
011800170611     DMQHSRCD            *RECORD
011900170611     DMQHSRTN            *ROUTINE
012000170611      *
012100171206      * File data structure for file: EDIPF7A
012200171206     DPF7ADS           DS
012300171206     DPF7AFIL            *FILE
012400171206     DPF7AOPN                  9      9
012500171206     DPF7AINP            *INP
012600171206     DPF7AMOD            *MODE
012700171206     DPF7AOUT            *OUT
012800171206     DPF7AOPC            *OPCODE
012900171206     DPF7ASIZ            *SIZE
013000171206     DPF7AFST            *STATUS
013100171206     DPF7ARCD            *RECORD
013200171206     DPF7ARTN            *ROUTINE
013300171206      *
013400171206      * File data structure for file: EDIPF7B
013500171206     DPF7BDS           DS
013600171206     DPF7BFIL            *FILE
013700171206     DPF7BOPN                  9      9
013800171206     DPF7BINP            *INP
013900171206     DPF7BMOD            *MODE
014000171206     DPF7BOUT            *OUT
014100171206     DPF7BOPC            *OPCODE
014200171206     DPF7BSIZ            *SIZE
014300171206     DPF7BFST            *STATUS
014400171206     DPF7BRCD            *RECORD
014500171206     DPF7BRTN            *ROUTINE
014600171206      *
014700170831      * File data structure for file: EDIPF14
014800170831     DPF14DS           DS
014900170831     DPF14FIL            *FILE
015000170831     DPF14OPN                  9      9
015100170831     DPF14INP            *INP
015200170831     DPF14MOD            *MODE
015300170831     DPF14OUT            *OUT
015400170831     DPF14OPC            *OPCODE
015500170831     DPF14SIZ            *SIZE
015600170831     DPF14FST            *STATUS
015700170831     DPF14RCD            *RECORD
015800170831     DPF14RTN            *ROUTINE
015900170831      *
016000170112      *
016100061220      * FILE HEADER data structure
016200160311      *
016300120119     DDSFILEHDR        DS
016400120119     DFHDRCDID                 1     10
016500160314     DFHDFILLER1              11     17
016600120119     DFHDSEQNUM               18     23
016700061220      *
016800061220      * CONTROL data structure
016900160314      *
017000120119     DDSCONTROL        DS
017100120119     DCNTRCDID                 1     10
017200160311     DCNTFILLER1              11     17
017300120119     DCNTSNDIND               18     47
017400120119     DCNTCTRNUM               48     57
017500061220      *
017600160315      * HEADER data structure
017700120119      *
017800120119     DDSHEADER         DS
017900120119     DHDRRCDID                 1     10
018000160311     DHDRFILLER1              11     17
018100120119     DHDRINVDAT               18     25
018200120119     DHDRINVNO                26     47
018300120119     DHDRREFINV               48     69
018400120119     DHDRREFDAT               70     77
018500120119     DHDRPONUM                78     99
018600160330     DHDRDBCRINDIC           100    101
018700160316     DHDRTOTAMT              102    111
018800120119     DHDRTRMCOD              112    131
018900120119     DHDRTRMDSC              132    156
019000120119     DHDRBLLCUS              157    171
019100120119     DHDRBLLNAM              172    206
019200120119     DHDRBLLAD1              207    241
019300120119     DHDRBLLAD2              242    276
019400120119     DHDRBLLCTY              277    306
019500120119     DHDRBLLSTA              307    308
019600120119     DHDRBLLZIP              309    318
019700120119     DHDRSHPCUS              319    333
019800120119     DHDRSHPNAM              334    368
019900120119     DHDRSHPAD1              369    403
020000120119     DHDRSHPAD2              404    438
020100120119     DHDRSHPCTY              439    468
020200120119     DHDRSHPSTA              469    470
020300120119     DHDRSHPZIP              471    480
020400120119     DHDRSHPDAT              481    488
020500120119     DHDRINSTALL             489    496
020600160316     DHDRNUMITM              497    502
020700160330     DHDRFREIGHTCHARG        503    512
020800160330     DHDRMISCCHARG           513    522
020900120119     DHDRTAXES               523    532
021000120119     DHDRSPLCOD              533    539
021100120119     DHDROFFLTR              540    554
021200120119     DHDRSUPCOD              555    564
021300120119     DHDRCURCOD              565    567
021400160511     DHDRCNTRYCOD            568    572
021500160330     DHDREXCHRATE            573    582
021600160330     DHDRLEGALID             583    597
021700120119     DHDRVNDNAM              598    627
021800120119     DHDRDAT                 628    635
021900120119     DHDRTIM                 636    645
022000160328     DHDRECWTYP              646    647
022100160328     DHDRFILLER2             648    685
022200160328     DHDCPSNUM               686    700
022300160328     DHDPAYERNO              701    710
022400160328     DHDRFILLER3             711    809
022500160328     DHDROBJID               810    835
022600160328     DHDRINVTYPE             836    838
022700160329     DHDRVENNAME             839    878
022800160329     DHDRTAXCODE             879    880
022900160330     DHDRVENNUM              881    890
023000160329     DHDRCOMPCODE            891    894
023100160329     DHDRPOEX                895    898
023200160328     DHDRSRANUM              899    912
023300160330     DHDRCPSNUM              913    926
023400061220      *
023500061220      * COMMENT data structure
023600160311      *
023700120119     DDSCOMMENT        DS
023800120119     DCOMRCDID                 1     10
023900160311     DCOMFILLER1              11     17
024000120119     DCOMTXT                  18     77
024100120119     DCOMFILLER2              78    800
024200061220      *
024300160315      * DETAIL data structure
024400120119      *
024500120119     DDSDETAIL         DS
024600120119     DDETRCDID                 1     10
024700160311     DDETFILLER1              11     17
024800120119     DDETDTLLIN               18     23
024900160322     DDETQTY                  24     29  0
025000120119     DDETBOQTY                30     35
025100160322     DDETUNTPRC               36     45  2
025200160406     DDETITMDSC               46     55
025300160330     DDETPARTNUM              56     85
025400120119     DDETVNDPRT               86    105
025500120119     DDETMFGCOD              106    115
025600120119     DDETMFGDSC              116    145
025700120119     DDETPRTDSC              146    205
025800120119     DDETCARIND              206    207
025900120119     DDETCARCOD              208    211
026000120119     DDETCARDSC              212    246
026100120119     DDETCARREF              247    276
026200120119     DDETLINTAX              277    286
026300120119     DDETMCHTYP              287    290
026400120119     DDETMCHMOD              291    294
026500120119     DDETMES                 295    301
026600120119     DDETMESIND              302    302
026700120119     DDETEXTIND              303    307
026800120119     DDETCSTCTR              308    322
026900120119     DDETALLOW               323    332
027000120119     DDETCHARG               333    342
027100160324     DDETEQSRC               343    344
027200160330     DDETLINESEQ             345    351
027300190412     DDETFILLER2             352    878
027400160616     DDTLTAXCODE             879    880
027500061220      *
027600160315      * SERIAL data structure
027700120119      *
027800120119     DDSSERIAL         DS
027900120119     DSERRCDID                 1     10
028000160311     DSERFILLER1              11     17
028100120119     DSERSERNO                18     47
028200120119     DSERASSTAG               48     77
028300120119     DSERFILLER2              77    800
028400061220      *
028500061220      * FEATURE data structure
028600160314      *
028700120119     DDSFEATURE        DS
028800120119     DFEARCDID                 1     10
028900160311     DFEAFILLER1              11     17
029000120119     DFEALINNO                18     23
029100120119     DFEAQTY                  24     29
029200120119     DFEAUNTPRC               30     39
029300120119     DFEAPRTNO                40     59
029400120119     DFEAPRTDSC               60    119
029500120119     DFEAVNDPRT              120    139
029600120119     DFEAFILLER2             140    800
029700061220      *
029800061220      * TRAILER data structure
029900120119      *
030000120119     DDSTRAILER        DS
030100120119     DTRLRCDID                 1     10
030200160311     DTRLFILLER1              11     17
030300160316     DTRLNUMINV               18     22
030400120119     DTRLNUMRCD               23     27
030500160316     DTRLTOTAMT               28     42
030600120119     DTRLFILLER2              38    800
030700061220      *
030800061220      * FILE TRAILER data structure
030900160314      *
031000160311     DDSFILETRL        DS
031100120119     DFTRRCDID                 1     10
031200160311     DFTRFILLER1              11     17
031300120119     DFTRSEQNUM               18     23
031400120119     DFTRISANUM               24     28
031500120119     DFTRFILLER2              29    800
031600160315      *
031700160315      * Program status
031800160315      *
031900160315     DPSDS            SDS
032000160315     DPGMNAME                  1     10A
032100160315     DPGMSTS                  11     15S 0
032200160315     DPGMPRVSTS               16     20S 0
032300160315     DPGMSRCSTMT              21     28A
032400160315     DPGMROUTINE              29     36A
032500160315     DPGMPARMS                37     39S 0
032600160315     DPGMMSGID                40     46A
032700160315     DPGMMI#                  47     50A
032800160315     DPGMWORK                 51     80A
032900160315     DPGMLIB                  81     90A
033000160315     DPGMERRDTA               91    170A
033100160315     DPGMRPGMSG              171    174A
033200160315     DPGMLASTFILE            175    184A
033300160315     DPGMJOB                 244    253A
033400160315     DPGMUSER                254    263A
033500160315     DPGMJOBNUM              264    269S 0
033600160315     DPGMJOBDATE             270    275S 0
033700160315     DPGMRUNDATE             276    281S 0
033800160315     DPGMRUNTIME             282    287S 0
033900160315      *
034000160315      * BATCH feedback
034100160315      *
034200160315     DBATCHINFDS       DS
034300160315     DBATCHSTS           *STATUS
034400160315     DBATCHOPC           *OPCODE
034500160315     DBATCHROUTINE       *ROUTINE
034600160315     DBATCHINFFILE       *FILE
034700160315      *
034800160315      * PF7 feedback
034900160315      *
035000160315     DPF7INFDS         DS
035100160315     DPF7STS             *STATUS
035200160315     DPF7OPC             *OPCODE
035300160315     DPF7ROUTINE         *ROUTINE
035400160315     DPF7INFFILE         *FILE
035500160315      *
035600160315      * ERROR LOG data structure
035700160315      *
035800160315     DERRORDS          DS                  INZ
035900160315     DMSGID                           7A
036000160315     DPROGRAMNAME                    10A
036100160315     DFILENAME                        8A
036200160315     DOPCODE                          6A
036300160315     DSTATUS                          5S 0
036400160316     DEXTMSG                        100A
036500160322     DCMDLENGTH        S             15P 5
036600160322     DCMDTEXT          S            256A
036700061220      *
036800170611      * Define ROBOT work fields
036900170611     DMSG_Q            S             10A   INZ(*BLANKS)
037000170611     DMSG_ID           S              7A   INZ(*BLANKS)
037100170611     DMSG_DTA          S            256A   INZ(*BLANKS)
037200170611     DMSG_TYP          S              1A   INZ('I')
037300170611      *
037400160315      * Work fields
037500160314      *
037600160707     DPRMMBRNAME       S             10A
037700160826     DPRMLIBNAME       S             10A
037800161227     DPRMSYSID         S              8A
037900160311     DRECTYPE          S             10A
038000160311     DLASTCTL          S              9  0
038100160316     DPOS              S              2  0
038200160314     DINCOUNT          S             15A
038300171206     DINCOUNTU         S             15A
038400160314     DCNTLCOUNT        S             15A
038500160314     DTRLCOUNT         S              9  0 INZ(0)
038600160314     DHOLDDTL          S              9  0 INZ(0)
038700160316     DHEADERIND        S              1  0 INZ(0)
038800160314     DDTLCOUNT         S              9  0 INZ(0)
038900160526     DDTLCOUNTA        S              9  0 INZ(0)
039000160314     DFIRSTHDR         S              1  0 INZ(0)
039100160325     DPROCESSINV       S              9  0 INZ(0)
039200160314     DTOTINVCNT        S              9  0 INZ(0)
039300160316     DTOTINVAMT        S             15  2 INZ(0)
039400160316     DINTAMT           S             15  0 INZ(0)
039500160316     DDECAMT           S             13  2 INZ(0)
039600160512     DDECAMT4          S             11  4 INZ(0)
039700160311     DRECTYPE1         C                   CONST('FILEHDR   ')
039800160311     DRECTYPE2         C                   CONST('CONTROL   ')
039900160311     DRECTYPE3         C                   CONST('DHEADER   ')
040000160311     DRECTYPE4         C                   CONST('DCOMMENT  ')
040100160311     DRECTYPE5         C                   CONST('DDETAIL   ')
040200160311     DRECTYPE6         C                   CONST('DSERIALNO ')
040300160328     DRECTYPE7         C                   CONST('DFEATURE  ')
040400160311     DRECTYPE8         C                   CONST('TRAILER   ')
040500160311     DRECTYPE9         C                   CONST('FILETRL   ')
040600160316     DSYS_DATE         S               D   INZ(*SYS)
040700160316     DSYS_TIME         S               T
040800171212      *
040900170611     DWWDATE           S               D   DATFMT(*ISO)
041000170620     DWWTIME           S               T   TIMFMT(*HMS)
041100170614     DCHAR_DATE        S             10A
041200180222     DCHAR_DATE1       S             10A
041300170620     DHldSEQNUM        S                   Like(E7SEQNUM)
041400180222     DCounter          S              1  0 INZ(0)
041500170627      *
041600170627     D                 DS
041700170627     DhldMQ_MSG_ID             1     80A
041800170627     DtrmMQ_MSG_ID             1     48A
041900170627      *
042000170627     DhldMDMID         S                   Like(MDMID)
042100170621     DhldCREAT00001    S             30A
042200170711     Dp1CREAT00001     S             26Z
042300170711     Dp1MQ_RE00001     S             26Z
042400170711     Dp1LAST_00002     S             26Z
042500171212      *
042600160316     D                 DS
042700160316     DTIMSTP                   1     12S 0
042800160316     DSYSTIME                  1      6S 0
042900160316     DSYSDATE                  7     12S 0
043000160609     DINVOICEVALID     S              1A   DIM(10000)
043100160609     DINVOICETAX       S              1A   DIM(10000)
043200160609     DINVOICENDX       S              5S 0 INZ(0)
043300160526     DXMLDTLLINE       S              7  0 INZ(0)
043400160526     DXMLDTLCOUNT      S              7A
043500171206     DXMLDTLCOUNT1     S              7A
043600160526     DXMLDTLSEQ        S              7  0 INZ(0)
043700160322     DHOLDTIME         S             12A
043800160526     DHOLDFREIGHTCHG   S             10A   INZ('0000000000')
043900160526     DHOLDMISCCHG      S             10A   INZ('0000000000')
044000160526     DHOLDTAXES        S             10A   INZ('0000000000')
044100160526     DHOLDCHG          S              1A   INZ(' ')
044200160323     DSCAN_FIELD       S            100A
044300180309      * @1607g : Begin
044400180309     DSCAN_FIELD1      S            100A
044500180309      * @1607g : End
044600160324     DSCAN_AMP         S              1A   INZ('&')
044700160324     DREPLACE_AMP      S              5A   INZ('&amp;')
044800160324     DSCAN_GT          S              1A   INZ('>')
044900160324     DREPLACE_GT       S              4A   INZ('&gt;')
045000160324     DSCAN_LT          S              1A   INZ('<')
045100160324     DREPLACE_LT       S              4A   INZ('&lt;')
045200160324     DSCAN_QUOT        S              1A   INZ('"')
045300160324     DREPLACE_QUOT     S              6A   INZ('&quot;')
045400160324     DSCAN_APOS        S              1A   INZ('''')
045500160324     DREPLACE_APOS     S              6A   INZ('&apos;')
045600160323     DSCAN_POS         S             10I 0
045700160323     DSCAN_POS1        S             10I 0
045800160602     DKEYBOARD         C                   CONST(
045900160602     D                                           '1234567890-=  -
046000160602     D                                            qwertyuiop[]\ -
046100160602     D                                            asdfghjkl;    -
046200160602     D                                            zx cvbnm,./   -
046300160602     D                                            !@#$%^&*()_+  -
046400160602     D                                            QWERTYUIOP{}| -
046500160602     D                                            ASDFGHJKL:    -
046600160602     D                                            ZXCVBNM?'
046700160602     D                                            )
046800160328     DE7KEY1           S              7  0 INZ(0)
046900160328     DE7KEY2           S              7    INZ('0000000')
047000160328     DE7KEY3           S              7  0 INZ(0)
047100160328     DE7KEY4           S              7  0 INZ(0)
047200160510     DE7KEY5           S              2A   INZ('  ')
047300160408     DEDIXMLDTL        S            256A
047400160824     DCTSXMLDTL        S            750A
047500160411     DEDIXMLLEN        S              7  0 INZ(0)
047600160422     DQMNAME           S             48A
047700171212      *
047800170528     DTIMECNT          S              1S 0 INZ(0)
047900170619     DRCCPY            S              2A
048000170621     DFILNME           S             10A
048100170705     DLOGZ             S            200A
048200171212      *
048300170528     DHCONN            S             10I 0
048400170528     DCMPCOD           S             10I 0
048500170528     DREASON           S             10I 0
048600170528     DOBJDSC           S            360A
048700160422     DOPTS             S             10I 0
048800170528     DHOBJ             S             10I 0
048900190225      * 1692  : Begin
049000190225     DHMsg             S             20I 0
049100190225      * 1692  : End
049200170528     DMSGDSC           S            364A
049300170528     DPMO              S            176A
049400161115     DDIVBYZERO        S              1A
049500170528     DBUFLEN           S             10I 0
049600180917      * @1685 : Begin
049700180917     D*BUFFER           S        2000000A
049800171212      *
049900180917     D*BUFFER1          S        2000000A
050000180917     D*WrkXmlDtl        S        2000000A
050100180917     DBUFFER1          S        6000000A
050200180917     DWrkXmlDtl        S        6000000A
050300180917      * @1685 : End
050400171212      *
050500171212     DBUFFCTS          S          15000A
050600180917      * @1685 : Begin
050700180917     D*BUFFPTR          S               *   INZ(%ADDR(BUFFER))
050800180917     DBUFFPTR          S               *   INZ(%ADDR(BUFFER1))
050900180917      * @1685 : End
051000190225      * @1692  : Begin
051100190225            dcl-s  UTF8DATA       char(6000000) ccsid(1208);
051200190225            dcl-s  BUFFER2        char(6000000) ccsid(1208);
051300190225     DBUFFPTR1         S               *   INZ(%ADDR(BUFFER2))
051400190225     Dbuflen1          S             10I 0
051500190225      * @1692  : End
051600160422     DGMO              S            100A
051700160422     DDATLEN           S             10I 0
051800161227     DEDIXMLKEY0       S              8A
051900160422     DEDIXMLKEY1       S             10A
052000160422     DEDIXMLKEY2       S             10A
052100161107     DFREIGHTKEY1      S              2A
052200161107     DFREIGHTKEY2      S              3A
052300160510     DTOTAMTTYPE       S              2A
052400161206     DTAXPCT           S             10P 4
052500180314      * @uxh : Begin
052600180314      * HDRTAXES is always 10P 2 , indicates always 8 length before decimal
052700180314     D*TAXAMT           S             10P 4
052800180314     DTAXAMT           S             12P 4
052900180314      * @uxh : End
053000180926      * @1687 : Begin
053100180921     D*TAXAMT2          S             10I 0
053200180921     DTAXAMT2          S             10  0
053300180926      * @1687 : End
053400180314      * @uxh : Begin
053500180314     D*TAXACCUM         S             10P 4
053600180314     DTAXACCUM         S             12P 4
053700180314      * @uxh : End
053800160705     DTAXSTATE         S              3I 0
053900161227     DUPFRONTSTATES    S            256A
054000161227     DCHECKSTATE       S              3A
054100160617     DMQCNT            S             10I 0
054200160825     DCRLF             C                   CONST(X'0D25')
054300171107      *@1622: Begin
054400171030     DIBMCHK           S              2S 0
054500171030     DIBMIND           S              1A
054600171220     DwPROVINCE        S                   LIKE(HDRSHPSTA)
054700180228     DCAINVDATEC       S             10A
054800180228     DCAINVDATE        S               D   DATFMT(*ISO)
054900180303     D@@MQTAXCD        S              2A
055000180303     D@@MQTAXPCT       S              5S 5
055100190422     D*@1756: BEGIN
055200190422     D*HldVatVar        S              4S 2
055300190422     DHldVatVar        S              6S 2
055400190422     D*@1756: END
055500180303     DVld_Tax_Tol      S              1A
055600180303     DCATAXSPD         S              1A
055700171107      *@1622: End
055800160422      *
055900160422      **  Declare MQI structures needed
056000160422      * MQI named constants
056100160422     DMQR              DS
056200170901     I/COPY QMQM/QRPGLESRC,CMQG
056300171212      *
056400160422      * Object Descriptor
056500160422     DMQOD             DS
056600170901     I/COPY QMQM/QRPGLESRC,CMQODG
056700171212      *
056800160422      * Message Descriptor
056900160422     DMQMD             DS
057000170901     I/COPY QMQM/QRPGLESRC,CMQMDG
057100171212      *
057200160422      * Get message options
057300160422     DMQGMO            DS
057400170901     I/COPY QMQM/QRPGLESRC,CMQGMOG
057500160422      *
057600160422      * Put message options
057700190225      * @1692  : Begin
057800190225     D*MQPMO            DS
057900190225     DMQPMO            DS                  Qualified
058000170901     I/COPY QMQM/QRPGLESRC,CMQPMOG
058100190225      * Create Message Handle
058200190225     D MQCMHO          DS                  Qualified
058300190225     I/COPY QMQM/QRPGLESRC,CMQCMHOG
058400190225      * Delete Message Handle
058500190225     D MQDMHO          DS                  Qualified
058600190225     I/COPY QMQM/QRPGLESRC,CMQDMHOG
058700190225      * Set Message Properties
058800190225     DMQSMPO           DS
058900190225     I/COPY QMQM/QRPGLESRC,CMQSMPOG
059000190225      *
059100190225      * Property descriptor -to define attributes of properties
059200190225     DMQPD             DS
059300190225     I/COPY QMQM/QRPGLESRC,CMQPDG
059400190225      *
059500190225     D PropName        DS                  Qualified
059600190225     D/COPY CMQCHRVG
059700190225      *
059800190225     D PropertyName    S             40A   Varying
059900190225     D PropertyValue   S             40A   Varying
060000190225      * @1692  : End
060100160801      *
060200160801      * For HTPAPPI web service
060300160801      *
060400171107      /copy libhttp/qrpglesrc,httpapi_h
060500160825     Ddata             S           5000A
060600160825     DIFS              S            256A
060700160825     DURL              S            256A
060800160825     DACTION           S            256A
060900160825     Drc               S             10I 0
061000160825     Dlen              S             10I 0
061100160825     DTOLERANCE        C                   CONST('WithinTolerance="Y"')
061200160825
061300160316      *
061400171208     D/copy *libl/qrpglesrc,IFSIO_H
061500171212
061600171208     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
061700171208     D   command                  32702a   const options(*varsize)
061800171208     D   len                         15p 5 const
061900171208     D   igc                          3a   const options(*nopass)
062000180225
062100171208      * Variables to create IFS file to store EDI request xml
062200171208     D fd              S             10I 0
062300171208     D cmd             s            200A
062400171208     D $file_name      S             50
062500171208     D $file_dir       S            100A
062600171208     D $file_path      S            100A
062700180305     D $new_file       S             75A
062800171212      *
062900171212     D $file_dir1      S            100A
063000171212     D $file_path1     S            100A
063100180222     D $tmp_dir        S            100A
063200180222     D $arc_dir        S            100A
063300180225     D RCDLT           S              1S 0
063400171208      *
063500171212      * Work Variables used in XML Control
063600171212     DwXMLENV          S                   Like(EDIXMLDATA)
063700171212     DwSOAPADR         S                   Like(EDIXMLDATA)
063800171212     DWrkXMLCTL        S        1000000A
063900171212      *
064000171212      * Work Variables used in XML Detail
064100171212     DEDIXMLDTLU       S                   Like(EDIXMLDATA)
064200171212     DWrkXmlDtl1       S        1000000A
064300171212     DWrkXmlDtl2       S        1000000A
064400171212     DWrkXmlDtl3       S        1000000A
064500171212      *
064600171212      * Work Variables used for CTSXML
064700171212     DWrkCTSXML1       S           5000A
064800171212     DWrkCTSXML2       S           5000A
064900171212     DWrkCTSXML3       S           5000A
065000171212      *
065100180411      * @1647 : Begin
065200180411     ?* WSCFEIMPR parm declaration
065300180411     DwAPPLID          S              5A
065400180411     DWSOPER           S             50A
065500180411     DErrNote          S            256A
065600180411     DRetCode          S              2A
065700180411     DWRETCODE         S              2A
065800180411     DWErrNote         S            256A
065900180411      *
066000180411     ?* Declare constants for sending error to notelog
066100180411     DERRNOTE1         C                   Const('Tax Only Invoice -Division By-
066200180423     D                                      Zero')
066300180417     DERRNOTE2         C                   Const('Taxes on the invoice -
066400180417     D                                     are not within the state tax -
066500180417     D                                     tolerance values')
066600180417     DERRNOTE3         C                   Const('There should be no tax-
066700180417     D                                     es on IGF billed assets for -
066800180417     D                                     these states and should not -
066900180417     D                                     accept')
067000180411      * @1647 : End
067100160316      * Mainline
067200160316      *
067300160316     C     *ENTRY        PLIST
067400160707     C                   PARM                    PRMMBRNAME
067500160707     C                   PARM                    PRMLIBNAME
067600161227     C                   PARM                    PRMSYSID
067700180411      * @1647 : Begin
067800180411     C     ParmCFEXML    PLIST
067900180411     C                   PARM                    wAPPLID
068000180411     C                   PARM                    WSOPER
068100180411     C                   PARM                    HDRINVNO
068200180411     C                   PARM                    HDROBJID
068300180411     C                   PARM                    PRMLIBNAME
068400180411     C                   PARM                    PRMSYSID
068500180411     C                   PARM                    ErrNote
068600180411     C                   PARM                    RETCODE
068700180411      *
068800180411     C     ParmCFEWEB    PLIST
068900180411     C                   PARM                    wAPPLID
069000180411     C                   PARM                    HDRINVNO
069100180411     C                   PARM                    PRMLIBNAME
069200180411     C                   PARM                    PRMSYSID
069300180411     C                   PARM                    WRETCODE
069400180411      *
069500180411      * @1647 : End
069600160330      *
069700190129      * @1712 : Begin
069800190129     C                   MONITOR
069900190129      * @1712 : End
070000160316     C                   EXSR      INITSR
070100160330      *
070200160330      * Read invoice file
070300160330      *
070400160311     C                   READ      EDIPF7                                 90
070500061220     C     *IN90         DOUEQ     *ON
070600160311     C                   EVAL      RECTYPE = %SUBST(EDIRCD7:1:10)
070700160316     C                   EVAL      HEADERIND = 0
070800160330      *
070900160330      * Split out based on record type
071000160330      *
071100160311     C                   SELECT
071200160311     C                   WHEN      RECTYPE = RECTYPE1
071300160311     C                   EXSR      SRFILEHDR
071400160311     C                   WHEN      RECTYPE = RECTYPE2
071500160311     C                   EXSR      SRCONTROL
071600160311     C                   WHEN      RECTYPE = RECTYPE3
071700160311     C                   EXSR      SRHEADER
071800160311     C                   WHEN      RECTYPE = RECTYPE4
071900160311     C                   EXSR      SRCOMMENT
072000160311     C                   WHEN      RECTYPE = RECTYPE5
072100160311     C                   EXSR      SRDETAIL
072200160311     C                   WHEN      RECTYPE = RECTYPE6
072300160311     C                   EXSR      SRSERIALNO
072400160328     C                   WHEN      RECTYPE = RECTYPE7
072500160311     C                   EXSR      SRFEATURE
072600160311     C                   WHEN      RECTYPE = RECTYPE8
072700160311     C                   EXSR      SRTRAILER
072800160311     C                   WHEN      RECTYPE = RECTYPE9
072900160311     C                   EXSR      SRFILETRL
073000160311     C                   ENDSL
073100061220     C*
073200160311     C                   READ      EDIPF7                                 90
073300061220     C                   ENDDO
073400160315      *
073500160315      * Validate trailer record is present
073600160315      *
073700160315     C                   IF        TRLCOUNT <> 1
073800160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
073900160316     C                                        'Trailer record missing '
074000160316     C                   EXSR      WRITEPF5
074100160617     C                   EVAL      *INLR = *ON
074200160617     C                   RETURN
074300160825     C                   ENDIF
074400160330      *
074500160708
074600160707     C                   CLOSE     EDIPF7A
074700160707     C                   CLOSE     EDIPF7B
074800160707     C                   OPEN      EDIPF7A
074900160707     C                   OPEN      EDIPF7B
075000171212      *
075100180221     C                   EVAL      INVOICENDX = 0
075200171212     C                   EVAL      *IN90 = *OFF
075300171212      *
075400160708      *
075500160708      * Process main work file and create XML
075600160708      *
075700180304     C     *LOVAL        SETLL     EDIPF7A
075800160707     C                   READ      EDIPF7A                                90
075900160322     C     *IN90         DOUEQ     *ON
076000160329     C                   EVAL      RECTYPE = %SUBST(EDIRCD7S:1:10)
076100160330      *
076200160330      * Split out for XML based on record type
076300160330      *
076400160322     C                   SELECT
076500160322     C                   WHEN      RECTYPE = RECTYPE1
076600160322     C                   EXSR      XMLFILEHDR
076700160322     C                   WHEN      RECTYPE = RECTYPE2
076800160322     C                   EXSR      XMLCONTROL
076900160322     C                   WHEN      RECTYPE = RECTYPE3
077000160322     C                   EXSR      XMLHEADER
077100160322     C                   WHEN      RECTYPE = RECTYPE4
077200160322     C                   EXSR      XMLCOMMENT
077300160322     C                   WHEN      RECTYPE = RECTYPE5
077400171212     C                   EXSR      XMLDETAIL
077500160322     C                   WHEN      RECTYPE = RECTYPE6
077600160322     C                   EXSR      XMLSERIALNO
077700160328     C                   WHEN      RECTYPE = RECTYPE7
077800160322     C                   EXSR      XMLFEATURE
077900160322     C                   WHEN      RECTYPE = RECTYPE8
078000160322     C                   EXSR      XMLTRAILER
078100160322     C                   WHEN      RECTYPE = RECTYPE9
078200160322     C                   EXSR      XMLFILETRL
078300160322     C                   ENDSL
078400171212      *
078500160707     C                   READ      EDIPF7A                                90
078600160322     C                   ENDDO
078700160708      *
078800160708      * End of processing
078900160708      *
079000160330     C                   EXSR      ENDOFINV
079100160601     C                   EVAL      LAST_00001 = LASTCTL
079200160601     C                   EVAL      LAST_00002 = %TIMESTAMP()
079300160708      *
079400160708      * Update batch control file
079500160708      *
079600170901     C                   UPDATE    BATCHCTL                             71
079700170901     C                   IF        *IN71
079800170901     C                   CLEAR                   ERRORDS
079900170901     C                   EVAL      MSGID    = 'ICC6700'
080000170901     C                   EVAL      FILENAME = BATCHINFFILE
080100170901     C                   EVAL      OPCODE   = BATCHOPC
080200170901     C                   EVAL      STATUS   = BATCHSTS
080300170901     C                   EVAL      EXTMSG   = 'Update failed while ' +
080400170901     C                             'processing GCMS EDI update for ' +
080500170901     C                              PRMMBRNAME
080600170901     C                   EXSR      ERRLOG
080700170901     C                   ENDIF
080800170901      *
080900180222      * Move EDI invoice file from tmp to archive directory
081000180222      * Rename EDI invoice file with control num and current date
081100180222     C                   EXSR      MovTmpEDI
081200180222      *
081300190129      * @1712 : Begin
081400190129      * MONITORING FOR PROGRAM RELATED ERROR
081500190129      *
081600190129     C                   ON-ERROR  *PROGRAM
081700190129     C                   EVAL      FILENAME = *BLANKS
081800190129     C                   EVAL      STATUS = PGMSTS
081900190129     C                   EVAL      MSGID = 'EDI1005'
082000190129     C                   EVAL      EXTMSG = 'Program error occurred:'+
082100190129     C                                       %TRIMR(PRMMBRNAME)  +'-'+
082200190129     C                                       %TRIMR(HDRINVNO)
082300190129     C                   CALLB     'LOGIOERRS'
082400190129     C                   PARM                    ERRORDS
082500190129      *
082600190129     C                   EVAL      MSG_ID = 'RBT7200'
082700190129     C                   EVAL      MSG_DTA = 'GAPTS: ' +
082800190129     C                                       %TRIM(PGMNAME) + ' Error-' +
082900190129     C                                       %TRIM(HDRINVNO) + ':'
083000190129     C                                       + %trim(PGMERRDTA)
083100190129     C                   EXSR      SND_ROBOT
083200190129      *
083300190129      *
083400190129      * End of error monitoring
083500190129      *
083600190129     C                   ENDMON
083700190129      * @1712 : End
083800170831     C                   EVAL      *INLR = *ON
083900160315      *
084000180202      **********************************************************************
084100180202      * COPY  EDIPF7B  to EDIPF7A
084200180202      **********************************************************************
084300180202     C     CpyPF7BPF7A   BEGSR
084400180302      *
084500180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
084600180302     C                   EVAL      CATAXSPD ='Y'
084700180302     C                   ELSE
084800180302     C                   EVAL      CATAXSPD ='N'
084900180302     C                   ENDIF
085000180202      * Process tax work file for tax state and rewrite to main work file
085100180202      *
085200180302     C                   IF        TAXSTATE = 1 or CATAXSPD='Y'
085300190123      * @1712: Begin
085400190123      * Do not tax spread if tax not within tolerance for invoice
085500190128     C                   If        INVOICEVALID (INVOICENDX) <> '1'
085600190123      * @1712: End
085700180202     C                   DOU       TAXACCUM = 0
085800180202      *
085900180202     C                   SETOFF                                           90
086000180202     C     *LOVAL        SETLL     EDIPF7TR                             90
086100180202     C                   READ      EDIPF7B                                90
086200180202     C     *IN90         DOUEQ     *ON
086300180214      * @uxh : Begin
086400180214      * Check if record not serial record
086500180214     C                   IF        %SUBST(EDIRCD7T:1:10) <> RECTYPE6
086600180214      * @uxh : End
086700180202     C                   EXSR      PF7BTOPF7A1
086800180214      * @uxh : Begin
086900180214     C                   ENDIF
087000180214      * @uxh : End
087100180202     C                   READ      EDIPF7B                                90
087200180202     C                   ENDDO
087300180202      *
087400180202     C                   CLOSE     EDIPF7B
087500180202     C                   OPEN      EDIPF7B
087600180202     C                   ENDDO
087700180202      *
087800190123      * @1712: Begin
087900190123     C                   ENDIF
088000190123      * @1712: End
088100180202     C                   SETOFF                                           90
088200180202      *
088300180202     C     *LOVAL        SETLL     EDIPF7TR                             90
088400180202     C                   READ      EDIPF7B                                90
088500180202     C     *IN90         DOUEQ     *ON
088600180202     C                   EXSR      PF7BTOPF7A2
088700180202     C                   READ      EDIPF7B                                90
088800180202     C                   ENDDO
088900180202      *
089000180202     C                   CLOSE     EDIPF7B
089100180202     C                   EVAL      CMDTEXT = *BLANKS
089200180202     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7B'
089300180202     C                   CALL      'QCMDEXC'
089400180202     C                   PARM                    CMDTEXT
089500180202     C                   PARM                    CMDLENGTH
089600180202     C                   OPEN      EDIPF7B
089700180202      * End If TAXSTATE Not 1
089800180202     C                   ENDIF
089900180202      *
090000180304     C                   EVAL      CATAXSPD ='N'
090100180202      *
090200180202     C                   ENDSR
090300180202      **********************************************************************
090400170616      **********************************************************************
090500170616      * Subroutine to Write Invoice_Control
090600170616      **********************************************************************
090700170616     C     Wrt_INVOCTL   BEGSR
090800170616      *
090900170616     C                   EVAL      CHAR_DATE = %SUBST(HDRINVDAT:1:4)+'-'+
091000170616     C                                         %SUBST(HDRINVDAT:5:2)+'-'+
091100170616     C                                         %SUBST(HDRINVDAT:7:2)
091200170616     C     *ISO          MOVE      CHAR_DATE     WINVDATE
091300170616      *
091400170622     C                   EVAL      p1CREAT00001 = %TIMESTAMP()
091500170620
091600170622     C/EXEC SQL
091700170622     C+ INSERT INTO INVOI00001
091800170622     C+ (CONTR00001 , COUNT00001,  INVOI00001 ,
091900170622     C+ INVOI00002 , CM_OB00001,  CREATE_ID ,
092000170622     C+ CREAT00001 , LAST_00001 , LAST_00002 )
092100170622     C+ VALUES(:HldSEQNUM ,:HDRCNTRYCOD, :HDRINVNO,
092200170622     C+ :WINVDATE ,:HDROBJID , :PGMUSER ,
092300170622     C+ :p1CREAT00001 , :PGMUSER , :p1CREAT00001 )
092400170622     C/End-Exec
092500170623
092600170616      *
092700170622     C                   If        SqlCode <> 0 and SqlCode <> 100
092800170616     C                   CLEAR                   ERRORDS
092900171214     C                   EVAL      PROGRAMNAME = PGMNAME
093000171214     C                   EVAL      MSGID       = 'ICC6700'
093100170622     C                   EVAL      FILENAME = 'INVOI00001'
093200170622     C                   EVAL      OPCODE   = 'Insert'
093300170622     C                   EVAL      STATUS   = SQLCODE
093400170622     C                   EVAL      EXTMSG='INSERT- Error occurred for: '
093500170622     C                                    +%trim(HDRINVNO) + ' ' + CHAR_DATE
093600170616     C                   CALLB     'LOGIOERRS'
093700170616     C                   PARM                    ERRORDS
093800170616     C                   EVAL      MSG_ID = 'RBT8006'
093900170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
094000170616     C                   EXSR      SND_ROBOT
094100170616     C                   ENDIF
094200170616      *
094300170616     C                   ENDSR
094400170616      **********************************************************************
094500170616      * Subroutine to Update Invoice_Control
094600170616      **********************************************************************
094700170616     C     Upd_INVOCTL   BEGSR
094800170616      *
094900170621     C                   Movel     p1CREAT00001  hldCREAT00001
095000170627     C                   EVAL      p1MQ_RE00001 = %TIMESTAMP()
095100170627     C                   EVAL      p1LAST_00002 = %TIMESTAMP()
095200170622
095300170622     C/EXEC SQL
095400170622     C+ UPDATE INVOI00001
095500170711     C+ set MQ_MSG_ID    = lcase(:trmMQ_MSG_ID) ,
095600170623     C+     MQ_RE00001   = :p1MQ_RE00001 ,
095700170623     C+     LAST_00002   = :p1LAST_00002
095800170623     C+ where COUNT00001  = :HDRCNTRYCOD      and
095900170623     C+       INVOI00001  = :HDRINVNO         and
096000170623     C+       INVOI00002  = :WINVDATE         and
096100170623     C+       CONTR00001  = :HldSEQNUM        and
096200170623     C+       CREAT00001  = :p1CREAT00001
096300170622     C/End-Exec
096400170622
096500170616      * If a file error occurs, log and exit.
096600170622     C                   If        SqlCode <> 0 and SqlCode <> 100
096700170616     C                   CLEAR                   ERRORDS
096800171214     C                   EVAL      PROGRAMNAME = PGMNAME
096900171214     C                   EVAL      MSGID       = 'ICC6700'
097000170622     C                   EVAL      FILENAME = 'INVOI00001'
097100170622     C                   EVAL      OPCODE   = 'UPDATE'
097200170622     C                   EVAL      STATUS   = SqlCode
097300170622     C                   EVAL      EXTMSG='UPDATE - Error occurred for: '+
097400170622     C                                    %trim(HDRINVNO)  + ' ' + CHAR_DATE
097500170616     C                   CALLB     'LOGIOERRS'
097600170616     C                   PARM                    ERRORDS
097700170616     C                   EVAL      MSG_ID = 'RBT8006'
097800170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
097900170616     C                   EXSR      SND_ROBOT
098000170616     C                   Endif
098100170620      *
098200170616     C                   ENDSR
098300170614      **********************************************************************
098400170614      * Subroutine to log MQ History file
098500170614      **********************************************************************
098600170614     C     LOGMQCALL     BEGSR
098700170614      *
098800180303     C                   EVAL      WCTY    = HDRCNTRYCOD
098900170614     C                   EVAL      WINV#   = HDRINVNO
099000170614     C                   EVAL      CHAR_DATE = %SUBST(HDRINVDAT:1:4)+'-'+
099100170614     C                                         %SUBST(HDRINVDAT:5:2)+'-'+
099200170614     C                                         %SUBST(HDRINVDAT:7:2)
099300170614     C     *ISO          MOVE      CHAR_DATE     WINVDATE
099400170614     C                   MOVEL     REASON        WRCODE
099500170614     C                   MOVEL     CMPCOD        WCMPCODE
099600170614     C                   EVAL      WRUNDTE = WWDATE
099700170620     C                   EVAL      WRUNTME = %TIME()
099800170614     C                   WRITE     MQOUTHPR                             52
099900170614      * If a file error occurs, log and exit.
100000170614     C                   IF        *IN52 = *ON
100100170614     C                   CLEAR                   ERRORDS
100200171214     C                   EVAL      PROGRAMNAME = PGMNAME
100300171214     C                   EVAL      MSGID       = 'ICC6700'
100400170614     C                   EVAL      FILENAME = MQHSFIL
100500170614     C                   EVAL      OPCODE   = MQHSOPC
100600170614     C                   EVAL      STATUS   = MQHSFST
100700170614     C                   EVAL      EXTMSG='Error occurred for: '+%trim(HDRINVNO)
100800170614     C                                        + ' ' + CHAR_DATE
100900170614     C                   CALLB     'LOGIOERRS'
101000170614     C                   PARM                    ERRORDS
101100170614     C                   EVAL      MSG_ID = 'RBT8005'
101200170620     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ' ' + CHAR_DATE
101300170614     C                   EXSR      SND_ROBOT
101400170614     C                   ENDIF
101500170614      *
101600170614     C                   ENDSR
101700160315      *
101800160315      * Error log
101900170611      **********************************************************************
102000170611      * Subroutine to send ROBOT error messages
102100170611      **********************************************************************
102200170611     C     SND_ROBOT     BEGSR
102300170611      *
102400170611     C                   CALL      'SNDROBOT'
102500170611     C                   PARM                    MSG_Q
102600170611     C                   PARM                    MSG_ID
102700170611     C                   PARM                    MSG_DTA
102800170611     C                   PARM                    MSG_TYP
102900170611      *
103000170611     C                   ENDSR
103100170611      **********************************************************************
103200171212      * Subroutine to log IO errors
103300171212      **********************************************************************
103400160315     C     ERRLOG        BEGSR
103500160315      *
103600160315      * Set program name.
103700160315     C                   EVAL      PROGRAMNAME = PGMNAME
103800160315      *
103900160315      * Call service program to log error.
104000161227     C                   CALLB     'LOGIOERRS'
104100160315     C                   PARM                    ERRORDS
104200160315      *
104300160315      * Exit program
104400160315     C                   EVAL      *INLR = *ON
104500160315     C                   RETURN
104600160315      *
104700160315     C                   ENDSR
104800180228      * @1622 : Begin
104900180228      **********************************************************************
105000180303      *Subroutine to update tax code for Canada based on default tax code
105100180228      **********************************************************************
105200180710     C     Upd_TaxCode   BEGSR
105300180228      *
105400180228     C                   Eval      CAINVDATEC =%subst(HDRINVDAT:1:4) + '-' +
105500180228     C                                         %subst(HDRINVDAT:2:2) + '-' +
105600180228     C                                         %subst(HDRINVDAT:7:2)
105700180228     C                   Move      CAINVDATEC    CAINVDATE
105800180228      *
105900180228     C                   Select
106000180228     C                   When      DETLINTAX <> '0000000000'
106100180710      * @1622a: Begin
106200180710     C                             And DECAMT <> *Zero
106300180710      * @1622a: End
106400180228      * tax > 0 default tax code
106500180228     C/Exec Sql
106600180228     C+ SELECT PT1LTAXCD
106700180303     C+ into :DTLTAXCODE
106800180228     C+ from PROVTAX1
106900180228     C+ Where PT1PROV    = :wPROVINCE  and
107000180228     C+       PT1DFTFLG  = '*'        and
107100180228     C+       PT1EFFFR  <= :CAINVDATE and
107200180228     C+       PT1EFFTO  >= :CAINVDATE
107300180228     C/End-Exec
107400180228     C                   If        SQLCODE <> 0
107500180303     C                   EVAL      DTLTAXCODE = *Blanks
107600180228     C                   EndIf
107700180228      *
107800180228     C                   Other
107900180228      * tax = 0 default tax code
108000180228     C/Exec Sql
108100180228     C+ SELECT PT1LTAXCD
108200180303     C+ into :DTLTAXCODE
108300180228     C+ from PROVTAX1
108400180228     C+ Where PT1PROV    = :wPROVINCE  and
108500180228     C+       PT1DFTZIND = '*'        and
108600180228     C+       PT1EFFFR  <= :CAINVDATE and
108700180228     C+       PT1EFFTO  >= :CAINVDATE
108800180228     C/End-Exec
108900180228     C                   If        SQLCODE <> 0
109000180303     C                   EVAL      DTLTAXCODE = 'I0'
109100180228     C                   EndIf
109200180228      *
109300180228     C                   Endsl
109400180303      *
109500180228     C                   ENDSR
109600180303      * @1622 : End
109700180303      **********************************************************************
109800180303      *Get tax% from PROVTAX1 for Canada based on default tax code
109900180303      **********************************************************************
110000180303     C     Get_TaxCode   BEGSR
110100180303      *
110200180303     C                   Eval      CAINVDATEC =%subst(HDRINVDAT:1:4) + '-' +
110300180303     C                                         %subst(HDRINVDAT:2:2) + '-' +
110400180303     C                                         %subst(HDRINVDAT:7:2)
110500180303     C                   Move      CAINVDATEC    CAINVDATE
110600180303      *
110700180303      * tax > 0 default tax code
110800180303     C/Exec Sql
110900180303     C+ SELECT PT1PCT
111000180303     C+ into :@@MQTAXPCT
111100180303     C+ from PROVTAX1
111200180303     C+ Where PT1PROV    = :HDRSHPSTA  and
111300180303     C+       PT1DFTFLG  = '*'        and
111400180303     C+       PT1EFFFR  <= :CAINVDATE and
111500180303     C+       PT1EFFTO  >= :CAINVDATE
111600180303     C/End-Exec
111700180303     C                   If        SQLCODE <> 0
111800180303     C                   EVAL      @@MQTAXPCT = *Zero
111900180303     C                   EndIf
112000180303      *
112100180303     C                   EVAL      WCTY = HDRCNTRYCOD
112200180303     C     WCTY          CHAIN     VATVARPF                           9599
112300180303     C                   IF        *In95 or *In99
112400180303     C                   Eval      HldVatVar = 0
112500180303     C                   ELSE
112600180303     C                   Move      VVALWVAR      HldVatVar
112700180303     C                   EndIf
112800180303      *
112900180303     C                   ENDSR
113000170616      **********************************************************************
113100170616      * Subroutine to define the key Lists used by this program
113200170616      **********************************************************************
113300170831     C     KeyLIST       BEGSR
113400171212      *
113500171212      * Key for EDIFRTCTL
113600170831     C     FREIGHTKEY    KLIST
113700170831     C                   KFLD                    FREIGHTKEY1
113800170831     C                   KFLD                    FREIGHTKEY2
113900171212
114000171212      * Key for EDIPF14
114100170831     C     EDIXMLKEY     KLIST
114200170831     C                   KFLD                    EDIXMLKEY0
114300170831     C                   KFLD                    EDIXMLKEY1
114400170831     C                   KFLD                    EDIXMLKEY2
114500170831      *
114600170616     C                   ENDSR
114700170622      **********************************************************************
114800160311      * FILE HEADER
114900171212      **********************************************************************
115000160311     C     SRFILEHDR     BEGSR
115100171212      *
115200170620     C                   EVAL      HldSEQNUM = E7SEQNUM
115300171212      *
115400160311     C                   EVAL      DSFILEHDR = EDIRCD7
115500160311     C                   EVAL      CONTR00001 = 'INVOICES'
115600170901     C     CONTR00001    CHAIN     BATCHCTL                           5052
115700170901      *
115800170901      * If *IN52 is on, log the  error.
115900170901     C                   IF        *IN52 = *ON
116000170901     C                   CLEAR                   ERRORDS
116100170901     C                   EVAL      FILENAME = BATCHINFFILE
116200170901     C                   EVAL      OPCODE = BATCHOPC
116300170901     C                   EVAL      STATUS = BATCHSTS
116400170901     C                   EVAL      EXTMSG =  'File error occurred while ' +
116500170901     C                             'processing GCMS EDI update for ' +
116600170901     C                              PRMMBRNAME
116700170901     C                   EXSR      ERRLOG
116800170901     C                   ENDIF
116900170901      *
117000170901      * Record found,
117100170901     C                   IF        *IN50 = *OFF
117200160314     C                   EVAL      LASTCTL = LAST_00001 + 1
117300160314      *
117400160314      * Validate batch control number
117500160314      *
117600160329     C                   IF        E7SEQNUM <> LASTCTL
117700160329     C                   EVAL      INCOUNT = %CHAR(E7SEQNUM)
117800160314     C                   EVAL      CNTLCOUNT = %CHAR(LASTCTL)
117900160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
118000160314     C                             'control number in file does not '   +
118100160314     C                             'match next number in sequence. '    +
118200160314     C                             'Control number in file: '           +
118300160314     C                             %TRIMR(INCOUNT)                      +
118400160314     C                             '; Next control number: '            +
118500160314     C                             %TRIMR(CNTLCOUNT)
118600160316     C                   EXSR      WRITEPF5
118700160314     C                   EVAL      *INLR = *ON
118800160314     C                   RETURN
118900160314     C                   ENDIF
119000170831      *
119100170831     C                   ENDIF
119200160708
119300160328     C                   EVAL      E7KEY1 = 0
119400160328     C                   EVAL      E7KEY2 = '0000000'
119500160328     C                   EVAL      E7KEY3 = 0
119600160328     C                   EVAL      E7KEY4 = 0
119700160510     C                   EVAL      E7KEY5 = '  '
119800160328     C                   EXSR      WRITEPF7
119900160526     C                   ENDSR
120000160311      *
120100171212      **********************************************************************
120200160311      * CONTROL
120300171212      **********************************************************************
120400160708      * Write miscellaneous charges as separate record
120500160708      *
120600160311     C     SRCONTROL     BEGSR
120700180305      * @1622: Begin
120800180305     C                   Eval      IBMIND = *Blanks
120900180305     C                   IF        HDRCNTRYCOD  = 'CA'
121000180305     C                   Eval      IBMIND = 'N'
121100180305     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
121200180305     C                   If        IBMCHK  <> 0
121300180305     C                   Eval      IBMIND = 'Y'
121400180305     C                   EndIf
121500180305     C                   ENDIF
121600180305      *
121700180305     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
121800180305     C                   EVAL      CATAXSPD ='Y'
121900180305     C                   ENDIF
122000180305      * @1622: End
122100180227      * Misc and freight charges is for all country
122200160526     C                   IF        HOLDMISCCHG > '0000000000'
122300160526     C                   EVAL      HOLDCHG = 'M'
122400160526     C                   EXSR      WRITECHARGES
122500160526     C                   ENDIF
122600160708      *
122700160708      * Write freight charges as separate record
122800160708      *
122900160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
123000160526     C                   EVAL      HOLDCHG = 'F'
123100160526     C                   EXSR      WRITECHARGES
123200160526     C                   ENDIF
123300160708      *
123400180228      *
123500160708      * Write taxes as separate record
123600160708      *
123700180213      * @uxh : Begin
123800180228      * New detail line tax record only for US and CA
123900180228     C                   Select
124000180228      *
124100180303     C                   When      HOLDTAXES<>'0000000000'
124200180303     C                             AND HDRCNTRYCOD  ='US'
124300180227     C                             AND TAXSTATE = 0
124400160526     C                   EVAL      HOLDCHG = 'T'
124500160526     C                   EXSR      WRITECHARGES
124600180228      *
124700180303     C                   When      HOLDTAXES <>'0000000000'
124800180303     C                             AND HDRCNTRYCOD  ='CA'
124900180228     C                             AND IBMIND  = 'N'
125000180228     C                   EVAL      HOLDCHG = 'T'
125100180228     C                   EXSR      WRITECHARGES
125200180228      *
125300180228     C                   Other
125400180221     C                   EVAL      HOLDTAXES = '0000000000'
125500180221      *
125600180228     C                   Endsl
125700180228      * @uxh : End
125800160708
125900180202     C                   EXSR      CpyPF7BPF7A
126000180202
126100160311     C                   EVAL      DSCONTROL = EDIRCD7
126200160609     C                   EVAL      E7KEY1 = E7KEY1 + 1
126300160328     C                   EVAL      E7KEY2 = '0000000'
126400160328     C                   EVAL      E7KEY3 = 0
126500160328     C                   EVAL      E7KEY4 = 0
126600160510     C                   EVAL      E7KEY5 = '  '
126700160328     C                   EXSR      WRITEPF7
126800180202      *
126900180202      *
127000160311     C                   ENDSR
127100171212      **********************************************************************
127200171212      * HEADER
127300171212      **********************************************************************
127400160311      *
127500160311     C     SRHEADER      BEGSR
127600160311     C                   EVAL      DSHEADER = EDIRCD7
127700160314     C                   EVAL      HDROBJID = E7OBJID
127800160328     C                   EVAL      HDRINVTYPE = E7INVTYP
127900160328     C                   EVAL      HDRSRANUM = E7SRA#
128000160329     C                   EVAL      HDRPOEX   = E7POEX
128100160330     C                   EVAL      HDRVENNUM  = E7SUPLR
128200160329     C                   EVAL      HDRVENNAME = E7NAME
128300160329     C                   EVAL      HDRCOMPCODE = E7CMPCODE
128400160314      *
128500171219     C                   EVAL      DIVBYZERO   = *Blanks
128600180302     C                   EVAL      TAXPCT      = *Zero
128700171219      *
128800180303      * @1622: Begin
128900180303     C                   Eval      IBMIND = *Blanks
129000180303     C                   IF        HDRCNTRYCOD = 'CA'
129100180303     C                   Eval      IBMIND = 'N'
129200180303     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
129300180303     C                   If        IBMCHK  <> 0
129400180303     C                   Eval      IBMIND = 'Y'
129500180303     C                   EndIf
129600180303     C                   ENDIF
129700180303      * @1622: End
129800160314      * Validate number of detail lines
129900160314      *
130000160314     C                   IF        FIRSTHDR = 0
130100160314     C                   EVAL      FIRSTHDR = 1
130200160314     C                   ELSE
130300160526     C                   IF        HOLDDTL <> DTLCOUNTA
130400160316     C                   EVAL      HEADERIND = 1
130500160526     C                   EVAL      INCOUNT = %CHAR(DTLCOUNTA)
130600160314     C                   EVAL      CNTLCOUNT = %CHAR(HOLDDTL)
130700160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
130800160316     C                             'Number of detail lines does not '   +
130900160314     C                             'match number of detail lines in '   +
131000160314     C                             'invoice header.  Number of lines '  +
131100160314     C                             'in header: '                        +
131200160314     C                             %TRIMR(CNTLCOUNT)                    +
131300160314     C                             '; Number of lines in file: '        +
131400160314     C                             %TRIMR(INCOUNT)
131500160316     C                   EXSR      WRITEPF5
131600160314     C                   EVAL      *INLR = *ON
131700160314     C                   RETURN
131800160314     C                   ENDIF
131900160314     C                   ENDIF
132000160314      *
132100160314      * Validate that content manager object id is in invoice header
132200160314      *
132300160314     C                   IF        HDROBJID = *BLANKS
132400160316     C                   EVAL      HEADERIND = 1
132500160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
132600160314     C                             'CM object id does not exist in '    +
132700160314     C                             'invoice header.  Invoice number: '  +
132800160314     C                             %TRIMR(HDRINVNO)
132900160316     C                   EXSR      WRITEPF5
133000160314     C                   EVAL      *INLR = *ON
133100160314     C                   RETURN
133200160314     C                   ENDIF
133300161108      *
133400161108      * set freight charges to 0 if blank
133500161108      *
133600161108     C                   IF        %LEN(%TRIMR(HDRFREIGHTCHARG)) = 0
133700161108     C                   EVAL      HDRFREIGHTCHARG = '0000000000'
133800161108     C                   ENDIF
133900160606      *
134000160606      * Validate that there are detail lines
134100160606      *
134200160606     C                   EVAL      INVOICENDX = INVOICENDX + 1
134300160606     C                   IF        HDRNUMITM = '000000'
134400161108     C                   IF        HDRFREIGHTCHARG = '0000000000'
134500160606     C                   EVAL      HEADERIND = 1
134600160606     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
134700160606     C                             'There are no detail lines for '     +
134800160606     C                             'invoice number: '  +
134900160606     C                             %TRIMR(HDRINVNO)
135000160606     C                   EXSR      WRITEPF5
135100160606     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
135200161108     C                   ENDIF
135300160606     C                   ENDIF
135400160316      *
135500160316      * Validate that header total amount is numeric
135600160316      *
135700160316     C                   EVAL      POS =%CHECK('0123456789':HDRTOTAMT)
135800160316     C                   IF        POS > 0
135900160316     C                   EVAL      HEADERIND = 1
136000160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
136100160316     C                             'Total amount is not numeric in '    +
136200160316     C                             'invoice header.  Invoice number: '  +
136300160316     C                             %TRIMR(HDRINVNO)
136400160316     C                   EXSR      WRITEPF5
136500160316     C                   EVAL      *INLR = *ON
136600160316     C                   RETURN
136700160316     C                   ENDIF
136800160708      *
136900160708      * Validate that number if items is numeric
137000160708      *
137100160316     C                   EVAL      POS =%CHECK('0123456789':HDRNUMITM)
137200160316     C                   IF        POS > 0
137300160316     C                   EVAL      HEADERIND = 1
137400160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
137500160316     C                             'Item count is not numeric in '    +
137600160316     C                             'invoice header.  Invoice number: '  +
137700160316     C                             %TRIMR(HDRINVNO)
137800160316     C                   EXSR      WRITEPF5
137900160316     C                   EVAL      *INLR = *ON
138000160316     C                   RETURN
138100160316     C                   ENDIF
138200160708      *
138300160708      * set miscellaneous charges to 0 if blank
138400160708      *
138500160616     C                   IF        %LEN(%TRIMR(HDRMISCCHARG)) = 0
138600160616     C                   EVAL      HDRMISCCHARG = '0000000000'
138700160616     C                   ENDIF
138800160708      *
138900160708      * save freight charges is greater than 0
139000160708      *
139100160526     C                   IF        HDRFREIGHTCHARG > '0000000000'
139200160526     C                   EVAL      HOLDFREIGHTCHG = HDRFREIGHTCHARG
139300160526     C                   ENDIF
139400160708      *
139500160708      * save miscellaneous charges is greater than 0
139600160708      *
139700160526     C                   IF        HDRMISCCHARG > '0000000000'
139800160526     C                   EVAL      HOLDMISCCHG = HDRMISCCHARG
139900160526     C                   ENDIF
140000160708      *
140100180302      *
140200160708      * calculate tax percentage if taxes is greater than 0
140300160708      *
140400160526     C                   IF        HDRTAXES > '0000000000'
140500160526     C                   EVAL      HOLDTAXES = HDRTAXES
140600161115     C                   IF        (%INT(HDRTOTAMT)-
140700161115     C                              %INT(HDRTAXES)) = 0
140800161115     C                   EVAL      DIVBYZERO = 'Y'
140900161115     C                   ELSE
141000161115     C                   EVAL      DIVBYZERO = 'N'
141100180227      * @UXH : Begin
141200180227     C***                EVAL      TAXPCT = %DECH((%INT(HDRTAXES)/
141300180227     C***                                         (%INT(HDRTOTAMT)-
141400180227     C***                                          %INT(HDRMISCCHARG)-
141500180227     C***                                          %INT(HDRTAXES)))*100:7:4)
141600180227     C                   EVAL      TAXPCT = %DECH((%INT(HDRTAXES)/
141700180227     C                                            (%INT(HDRTOTAMT)-
141800180227     C                                             %INT(HDRTAXES)))*100:7:4)
141900180227      * @UXH : End
142000161115     C                   ENDIF
142100160526     C                   ENDIF
142200160708      *
142300160708      * for upfront states create XML for webservice call to CTS
142400160708      *
142500161227     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
142600161227     C                   EVAL      SCAN_POS =
142700161227     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
142800180303     C                   IF        (SCAN_POS > 0 and HDRCNTRYCOD ='US' )
142900180303     C                             or (IBMIND='Y')
143000171206     C                   Select
143100180303     C                   When      DIVBYZERO = 'N' and HDRCNTRYCOD ='CA'
143200180302     C                   EVAL      TAXSTATE = 0
143300180302     C                   EVAL      TAXACCUM = %INT(HDRTAXES)/100
143400180302     C                   EXSR      CATOLSR
143500180302      *
143600180303     C                   When      DIVBYZERO = 'N' and HDRCNTRYCOD ='US'
143700160705     C                   EVAL      TAXSTATE = 1
143800160706     C                   EVAL      TAXACCUM = %INT(HDRTAXES)/100
143900170621     C                   EXSR      CTSXMLSR
144000180302      *
144100171206     C                   When      DIVBYZERO = 'Y'
144200161115     C                   EVAL      HEADERIND = 1
144300180309      * @1607f : Begin
144400180309     C***                EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
144500180309     C***                          'Upfront state division by zero for ' +
144600180309     C***                          'invoice number: '  +
144700180309     C***                          %TRIMR(HDRINVNO)
144800180417     C                   EVAL      E5MSGVAR = 'Warning :' +
144900180417     C                             ERRNOTE1 + 'for invoice number: '  +
145000180309     C                             %TRIMR(HDRINVNO)
145100180309      * @1607f : End
145200161115     C                   EXSR      WRITEPF5
145300180411      * @1647 : Begin
145400180417     C                   EVAL      WErrNote = ERRNOTE1
145500180411     C                   EXSR      CrtCFEXML
145600180411      * @1647 : End
145700161115     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
145800180209      * @UXH : Begin
145900180209     C                   EVAL      HOLDMISCCHG = '0000000000'
146000180209     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
146100180209     C                   EVAL      HOLDTAXES      = '0000000000'
146200180209      * @UXH : End
146300171206     C                   Other
146400171206     C                   EVAL      TAXSTATE = 0
146500180202     C                   EVAL      TAXACCUM = 0
146600171206     C                   Endsl
146700171206      *
146800160705     C                   ELSE
146900160705     C                   EVAL      TAXSTATE = 0
147000180202     C                   EVAL      TAXACCUM = 0
147100160627     C                   ENDIF
147200180417
147300180417      * @1647 : Begin
147400180417      * Do not send US Nonupfront with tax having multisoldto
147500180417      * address to GCMS , send it to notelog
147600180417      *
147700180718      * @1647a: Begin
147800180718      * IGF confirmed multisoldto  not sent in EDI files so
147900180718      * comment logic earlier given by Miguel
148000180718     C***                If        HDRCNTRYCOD ='US' AND TAXSTATE=0
148100180718     C***                          AND HDRTAXES > '0000000000'
148200180417      *
148300180718     C***                Select
148400180718     C***                When      HDRSHPAD1 <> *Blanks AND HDRSHPAD2 <>*Blanks
148500180718     C***                EVAL      HEADERIND = 1
148600180718     C***                EVAL      E5MSGVAR = 'Warning :' +
148700180718     C***                          ERRNOTE3
148800180718     C***                EXSR      WRITEPF5
148900180718     C***                EVAL      WErrNote = ErrNote3
149000180718     C***                EXSR      CrtCFEXML
149100180718      *
149200180718     C***                EVAL      INVOICEVALID (INVOICENDX) = '1'
149300180718      *
149400180718     C***                EVAL      HOLDMISCCHG = '0000000000'
149500180718     C***                EVAL      HOLDFREIGHTCHG = '0000000000'
149600180718     C***                EVAL      HOLDTAXES      = '0000000000'
149700180718     C***                Endsl
149800180417      *
149900180718     C***                Endif
150000180718      * @1647a: End
150100180417      * @1647 : End
150200180417
150300160316     C                   EVAL      HOLDDTL = %DEC(HDRNUMITM:6:0)
150400180129     C                   EVAL      DTLCOUNT = 0
150500160526     C                   EVAL      DTLCOUNTA = 0
150600160314     C                   EVAL      TOTINVCNT = TOTINVCNT + 1
150700160316     C                   EVAL      INTAMT = %INT(HDRTOTAMT)
150800160316     C                   EVAL      DECAMT = INTAMT / 100
150900160316     C                   EVAL      TOTINVAMT = TOTINVAMT + DECAMT
151000160328     C                   EVAL      E7KEY1 = E7KEY1
151100160328     C                   EVAL      E7KEY2 = E7KEY2
151200160328     C                   EVAL      E7KEY3 = E7KEY3
151300160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
151400160510     C                   EVAL      E7KEY5 = E7KEY5
151500160328     C                   EXSR      WRITEPF7
151600161206     C
151700180213      * @uxh : Begin
151800180213     C***                IF        TAXSTATE = 1
151900180213      * Misc and freight charges is for all country
152000180227     C*                  IF        HOLDMISCCHG > '0000000000'
152100180227     C*                  EVAL      HOLDCHG = 'M'
152200180227     C*                  EXSR      WRITECHARGES
152300180227     C*                  ENDIF
152400180213      * @uxh : End
152500180227     C*                  IF        HOLDFREIGHTCHG > '0000000000'
152600180227     C*                  EVAL      HOLDCHG = 'F'
152700180227     C*                  EXSR      WRITECHARGES
152800180227     C*                  ENDIF
152900180124      * @1607b : Begin
153000180124      * Write taxes as separate record
153100180124      *
153200180227     C*                  IF        HOLDTAXES>'0000000000'
153300180227     C*                            AND (HDRCNTRYCOD='US' or HDRCNTRYCOD='CA')
153400180227     C*                            AND TAXSTATE = 0
153500180227     C*                  IF        INVOICETAX (INVOICENDX) = '0'
153600180227     C*                  EVAL      HOLDCHG = 'T'
153700180227     C*                  EXSR      WRITECHARGES
153800180227     C*                  ENDIF
153900180227     C*                  ELSE
154000180227     C*                  EVAL      HOLDTAXES='0000000000'
154100180227     C*                  ENDIF
154200180124      * @1607b : End
154300180213      * @uxh : Begin
154400180213     C***                ENDIF
154500180213      * @uxh : End
154600160311     C                   ENDSR
154700160311      *
154800180411      * @1647 : Begin
154900180411      **********************************************************************
155000180411     ?* Build XML for Start Workflow , Addnotelog parts
155100180411     ?* and invoke CFE Persist document Webservice
155200180411      *********************************************************************
155300180411     C     CrtCFEXML     BEGSR
155400180411      *
155500180411     ?* PART1 -------------------------------------
155600180411     C                   EVAL      wAPPLID = 'CFE'
155700180411     C                   EVAL      WSOPER  = 'StartWorkflow'
155800180411     C                   EVAL      ErrNote = *Blanks
155900180411     C                   EVAL      RETCODE = '00'
156000180411      *
156100180411     ?* Generate xml for StartWorkflow
156200180411     C                   CALL      'WSCFEIMPR'   ParmCFEXML
156300180411      *
156400180411     C                   If        RETCODE='00'
156500180411     C                   EVAL      WRETCODE = '00'
156600180411     ?* Invoke CFE webservice for StartWorkflow
156700180411     C                   CALL      'WSCLIENT'    ParmCFEWEB
156800180411      *
156900180411     C                   Select
157000180411     C                   When      WRETCODE = '98'
157100180411     C                   EVAL      E5MSGVAR = 'Error  : ' +
157200180411     C                             'Adding to worklist for ' +
157300180411     C                             'invoice number/Objectid: '  +
157400180411     C                             %TRIMR(HDRINVNO)+' / '+ %TRIM(HDROBJID)
157500180411     C                   EXSR      WRITEPF5
157600180411     C                   Endsl
157700180411      *
157800180411     C                   Endif
157900180411      *
158000180411     ?* PART2 -------------------------------------
158100180411     C                   EVAL      WSOPER  = 'AddNotelog'
158200180411     C                   EVAL      ErrNote = WErrNote
158300180411     C                   EVAL      RETCODE = '00'
158400180411      *
158500180411     ?* Generate xml for AddNotelog
158600180411     C                   CALL      'WSCFEIMPR'   ParmCFEXML
158700180411      *
158800180411     C                   If        RETCODE='00'
158900180411     C                   EVAL      WRETCODE = '00'
159000180411     ?* Invoke CFE webservice for AddNotelog
159100180411     C                   CALL      'WSCLIENT'    ParmCFEWEB
159200180411      *
159300180411     C                   Select
159400180411     C                   When      WRETCODE = '98'
159500180411     C                   EVAL      E5MSGVAR = 'Error  : ' +
159600180411     C                             'Adding to Notelog for ' +
159700180411     C                             'invoice number/Objectid: '  +
159800180411     C                             %TRIMR(HDRINVNO)+' / '+ %TRIM(HDROBJID)
159900180411     C                   EXSR      WRITEPF5
160000180411     C                   Endsl
160100180411      *
160200180411     C                   Endif
160300180411      *
160400180411     C                   ENDSR
160500180411      * @1647 : End
160600171212      *******************************************************************
160700160311      * COMMENT
160800171212      *******************************************************************
160900160311      *
161000160311     C     SRCOMMENT     BEGSR
161100160311     C                   EVAL      DSCOMMENT = EDIRCD7
161200160328     C                   EVAL      E7KEY1 = E7KEY1
161300160328     C                   EVAL      E7KEY2 = E7KEY2
161400160328     C                   EVAL      E7KEY3 = E7KEY3
161500160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
161600160510     C                   EVAL      E7KEY5 = E7KEY5
161700160328     C                   EXSR      WRITEPF7
161800160311     C                   ENDSR
161900160311      *
162000171212      *******************************************************************
162100160311      * DETAIL
162200171212      *******************************************************************
162300160311      *
162400160311     C     SRDETAIL      BEGSR
162500180228      * @1622: Begin
162600180302     C                   Eval      IBMIND = *Blanks
162700180303     C                   IF        HDRCNTRYCOD  = 'CA'
162800180228     C                   Eval      IBMIND = 'N'
162900180228     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
163000180228     C                   If        IBMCHK  <> 0
163100180228     C                   Eval      IBMIND = 'Y'
163200180228     C                   EndIf
163300180228     C                   ENDIF
163400180302      *
163500180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
163600180302     C                   EVAL      CATAXSPD ='Y'
163700180302     C                   ENDIF
163800180228      * @1622: End
163900160311     C                   EVAL      DSDETAIL = EDIRCD7
164000160330     C                   EVAL      DTLTAXCODE = E7VATCOD
164100171220      * @1607a: Begin
164200171114     C***                IF        DETLINESEQ = '0000001'
164300180129     C                   EVAL      DTLCOUNT = DTLCOUNT + 1
164400171114     C***                ENDIF
164500171220      * @1607a: End
164600160708
164700160526     C                   EVAL      DTLCOUNTA = DTLCOUNTA + 1
164800160328     C                   EVAL      E7KEY1 = E7KEY1
164900160328     C                   EVAL      E7KEY2 = DETLINESEQ
165000180129     C                   EVAL      E7KEY3 = DTLCOUNT
165100160328     C                   EVAL      E7KEY4 = 0
165200160708
165300160510     C                   IF        %LEN(%TRIMR(DETMCHTYP)) > 0
165400160511     C                   IF        %LEN(%TRIMR(DETMCHMOD)) > 0
165500160510     C                   EVAL      E7KEY5 = 'TM'
165600160511     C                   ENDIF
165700160510     C                   ELSE
165800160510     C                   IF        DETCHARG > '0000000000'
165900160510     C                   EVAL      E7KEY5 = 'OC'
166000160510     C                   ELSE
166100160510     C                   EVAL      E7KEY5 = 'P '
166200160510     C                   ENDIF
166300160510     C                   ENDIF
166400160708      *
166500160708      * for upfront states calculate detail line tax amount
166600160708      *
166700171107     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
166800171107     C                   EVAL      SCAN_POS =
166900171107     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
167000180228      *
167100180303     C                   IF        (HDRCNTRYCOD ='US' and SCAN_POS > 0)
167200180303     C                             or (HDRCNTRYCOD ='CA' and CATAXSPD ='Y')
167300180226      * @1607e : Begin
167400180226     C***                EVAL      TAXAMT = %DECH((DETUNTPRC *
167500180226     C***                                         TAXPCT)/100:10:4)
167600180226     C                   EVAL      TAXAMT = %DECH((DETUNTPRC *
167700180226     C                                            TAXPCT)/100:10:2)
167800180226      * @1607e : End
167900180926      * @1687 : Begin
168000180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
168100180924     C                   EVAL      TAXAMT2 = TAXAMT * 100
168200180926      * @1687 : End
168300160706     C                   EVAL      TAXACCUM = TAXACCUM - TAXAMT
168400160616     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
168500160616     C                   EVAL      EDIRCD7 = DSDETAIL
168600180423      * @1652 : Begin
168700180423     C***                EVAL      E7VATCOD = 'I2'
168800180423     C                   EVAL      E7VATCOD = 'I1'
168900180423      * @1652 : End
169000160616     C                   ENDIF
169100160708
169200180323      * @1607h : Begin
169300180323      * for non upfront states
169400180323     C                   Select
169500180710     C                   When      (HDRCNTRYCOD = 'US' and TAXSTATE = 0) OR
169600180710      * @1622a: Begin
169700180710     C                             (HDRCNTRYCOD = 'CA' and CATAXSPD = 'N')
169800180710      * @1622a: End
169900180323     C                   Other
170000180323      * @1607h : End
170100160609     C                   IF        DETLINTAX > '0000000000'
170200160609     C                   EVAL      INVOICETAX(INVOICENDX) = '1'
170300160609     C                   ENDIF
170400180323      * @1607h : Begin
170500180323     C                   Endsl
170600180323      * @1607h : End
170700160328     C                   EXSR      WRITEPF7
170800160311     C                   ENDSR
170900160311      *
171000171212      ******************************************************************
171100160311      * SERIAL
171200171212      ******************************************************************
171300160311      *
171400160311     C     SRSERIALNO    BEGSR
171500160311     C                   EVAL      DSSERIAL  = EDIRCD7
171600160328     C                   EVAL      E7KEY1 = E7KEY1
171700160328     C                   EVAL      E7KEY2 = E7KEY2
171800160328     C                   EVAL      E7KEY3 = E7KEY3
171900160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
172000160510     C                   EVAL      E7KEY5 = E7KEY5
172100180302      *
172200180302     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
172300180302     C                   EVAL      CATAXSPD ='Y'
172400180302     C                   ENDIF
172500180302      *
172600160328     C                   EXSR      WRITEPF7
172700160311     C                   ENDSR
172800160311      *
172900171212      ******************************************************************
173000160311      * FEATURE
173100171212      ******************************************************************
173200160311      *
173300160311     C     SRFEATURE     BEGSR
173400160311     C                   EVAL      DSFEATURE = EDIRCD7
173500160328     C                   EVAL      E7KEY1 = E7KEY1
173600160328     C                   EVAL      E7KEY2 = E7KEY2
173700160328     C                   EVAL      E7KEY3 = E7KEY3
173800160328     C                   EVAL      E7KEY4 = E7KEY4 + 1
173900160510     C                   EVAL      E7KEY5 = E7KEY5
174000160328     C                   EXSR      WRITEPF7
174100160311     C                   ENDSR
174200160311      *
174300171212      ******************************************************************
174400160311      * TRAILER
174500171212      ******************************************************************
174600160311      *
174700160311     C     SRTRAILER     BEGSR
174800160311     C                   EVAL      DSTRAILER = EDIRCD7
174900160314      *
175000160314      * Validate number of detail lines
175100160314      *
175200160526     C                   IF        HOLDDTL <> DTLCOUNTA
175300160316     C                   EVAL      HEADERIND = 1
175400160526     C                   EVAL      INCOUNT = %CHAR(DTLCOUNTA)
175500160314     C                   EVAL      CNTLCOUNT = %CHAR(HOLDDTL)
175600160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
175700160314     C                             'Number of detail lines does not '   +
175800160314     C                             'match number of detail lines in '   +
175900160314     C                             'invoice header.  Number of lines '  +
176000160314     C                             'in header: '                        +
176100160314     C                             %TRIMR(CNTLCOUNT)                    +
176200160314     C                             '; Number of lines in file: '        +
176300160314     C                             %TRIMR(INCOUNT)
176400160316     C                   EXSR      WRITEPF5
176500160314     C                   EVAL      *INLR = *ON
176600160314     C                   RETURN
176700160314     C                   ENDIF
176800160314      *
176900160314      * Validate number of invoices
177000160314      *
177100160316     C                   EVAL      POS =%CHECK('0123456789':TRLNUMINV)
177200160316     C                   IF        POS > 0
177300160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
177400160316     C                             'Invoice count is not numeric in ' +
177500160316     C                             'trailer'
177600160316     C                   EXSR      WRITEPF5
177700160316     C                   EVAL      *INLR = *ON
177800160316     C                   RETURN
177900160316     C                   ENDIF
178000160708
178100160316     C                   IF        TOTINVCNT <> %DEC(TRLNUMINV:5:0)
178200160316     C                   EVAL      INCOUNT = %CHAR(TOTINVCNT)
178300160316     C                   EVAL      CNTLCOUNT = TRLNUMINV
178400160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
178500160314     C                             'Number of invoices does not match ' +
178600160314     C                             'number of invoices in trailer.  '   +
178700160314     C                             'Number of invoices counted: '       +
178800160314     C                             %TRIMR(INCOUNT)                      +
178900160314     C                             '; Number of invoices in trailer: '  +
179000160314     C                             %TRIMR(CNTLCOUNT)
179100160316     C                   EXSR      WRITEPF5
179200160314     C                   EVAL      *INLR = *ON
179300160314     C                   RETURN
179400160314     C                   ENDIF
179500160314      *
179600160314      * Validate invoice amount hash total
179700160314      *
179800160316     C                   EVAL      POS =%CHECK('0123456789':TRLTOTAMT)
179900160316     C                   IF        POS > 0
180000160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
180100160316     C                             'Total amount is not numeric in ' +
180200160316     C                             'trailer'
180300160316     C                   EXSR      WRITEPF5
180400160316     C                   EVAL      *INLR = *ON
180500160316     C                   RETURN
180600160316     C                   ENDIF
180700160708
180800160316     C                   EVAL      INTAMT = %INT(TRLTOTAMT)
180900160316     C                   EVAL      DECAMT = INTAMT / 100
181000160316     C                   IF        TOTINVAMT <> DECAMT
181100160316     C                   EVAL      INCOUNT = %CHAR(TOTINVAMT)
181200160316     C                   EVAL      CNTLCOUNT = TRLTOTAMT
181300160316     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
181400160314     C                             'Calculated invoice amount does not '+
181500160314     C                             'match total invoice amount in '     +
181600160314     C                             'invoice trailer.  Calculated '      +
181700160314     C                             'invoice amount: '                   +
181800160314     C                             %TRIMR(INCOUNT)                      +
181900160314     C                             '; Total invoice amount in trailer: '+
182000160314     C                             %TRIMR(CNTLCOUNT)
182100160316     C                   EXSR      WRITEPF5
182200160314     C                   EVAL      *INLR = *ON
182300160314     C                   RETURN
182400160314     C                   ENDIF
182500160708
182600180305      * @1622: Begin
182700180305     C                   Eval      IBMIND = *Blanks
182800180305     C                   IF        HDRCNTRYCOD  = 'CA'
182900180305     C                   Eval      IBMIND = 'N'
183000180305     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
183100180305     C                   If        IBMCHK  <> 0
183200180305     C                   Eval      IBMIND = 'Y'
183300180305     C                   EndIf
183400180305     C                   ENDIF
183500180305      *
183600180305     C                   IF        HDRTAXES <>'0000000000' and IBMIND='Y'
183700180305     C                   EVAL      CATAXSPD ='Y'
183800180305     C                   ENDIF
183900180305      * @1622: End
184000180305
184100160526     C                   IF        HOLDMISCCHG > '0000000000'
184200160526     C                   EVAL      HOLDCHG = 'M'
184300160526     C                   EXSR      WRITECHARGES
184400160526     C                   ENDIF
184500160708
184600160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
184700160526     C                   EVAL      HOLDCHG = 'F'
184800160526     C                   EXSR      WRITECHARGES
184900160526     C                   ENDIF
185000160708
185100180228
185200180228      * Write taxes as separate record
185300180228      *
185400180228      * @uxh : Begin
185500180228      * New detail line tax record only for US and CA
185600180228     C                   Select
185700180228      *
185800180303     C                   When      HOLDTAXES <>'0000000000'
185900180303     C                             AND HDRCNTRYCOD  ='US'
186000180228     C                             AND TAXSTATE = 0
186100180228     C                   EVAL      HOLDCHG = 'T'
186200180228     C                   EXSR      WRITECHARGES
186300180228      *
186400180303     C                   When      HOLDTAXES <>'0000000000'
186500180303     C                             AND HDRCNTRYCOD  ='CA'
186600180228     C                             AND IBMIND  = 'N'
186700180228     C                   EVAL      HOLDCHG = 'T'
186800180228     C                   EXSR      WRITECHARGES
186900180228      *
187000180228     C                   Other
187100180228     C                   EVAL      HOLDTAXES = '0000000000'
187200180228      *
187300180228     C                   Endsl
187400180228      * @uxh : End
187500160708
187600180202     C                   EXSR      CpyPF7BPF7A
187700180202
187800160328     C                   EVAL      E7KEY1 = 9999998
187900160328     C                   EVAL      E7KEY2 = '0000000'
188000160328     C                   EVAL      E7KEY3 = 0
188100160328     C                   EVAL      E7KEY4 = 0
188200160510     C                   EVAL      E7KEY5 = '  '
188300160328     C                   EXSR      WRITEPF7
188400160311     C                   ENDSR
188500160311      *
188600171212      ********************************************************************
188700160311      * FILE TRAILER
188800171212      ********************************************************************
188900160311      *
189000160311     C     SRFILETRL     BEGSR
189100160311     C                   EVAL      DSFILETRL = EDIRCD7
189200160314     C                   EVAL      TRLCOUNT = 1
189300160328     C                   EVAL      E7KEY1 = 9999999
189400160328     C                   EVAL      E7KEY2 = '0000000'
189500160328     C                   EVAL      E7KEY3 = 0
189600160328     C                   EVAL      E7KEY4 = 0
189700160510     C                   EVAL      E7KEY5 = '  '
189800160328     C                   EXSR      WRITEPF7
189900160311     C                   ENDSR
190000160526      *
190100171212      ********************************************************************
190200160526      * WRITE FREIGHT/MISC/TAXES
190300171212      ********************************************************************
190400160526      *
190500160526     C     WRITECHARGES  BEGSR
190600171212      *
190700160526     C                   CLEAR                   DSDETAIL
190800180129     C                   EVAL      DTLCOUNT = DTLCOUNT + 1
190900160526     C                   EVAL      E7KEY1 = E7KEY1
191000160526     C                   EVAL      E7KEY2 = '0000001'
191100180129     C                   EVAL      E7KEY3 = DTLCOUNT
191200160526     C                   EVAL      E7KEY4 = 0
191300160526     C                   EVAL      DETQTY = 1
191400160708
191500160526     C                   IF        HOLDCHG = 'M'
191600160526     C                   IF        HOLDMISCCHG > '0000000000'
191700161104     C                   EVAL      E7KEY5 = 'P '
191800161104     C                   EVAL      DETPARTNUM = 'MISC'
191900180213      * @UXH : Begin
192000180213     C                   EVAL      DETEQSRC = *Blanks
192100180213      * @UXH : End
192200160526     C                   EVAL      DETPRTDSC = 'misc charge'
192300160526     C                   EVAL      INTAMT = %INT(HOLDMISCCHG)
192400160526     C                   EVAL      DECAMT = INTAMT / 100
192500180206     C                   EVAL      DETUNTPRC = DECAMT
192600160526     C                   EVAL      HOLDMISCCHG = '0000000000'
192700160526     C                   ENDIF
192800160526     C                   ENDIF
192900160708
193000160526     C                   IF        HOLDCHG = 'F'
193100160526     C                   IF        HOLDFREIGHTCHG > '0000000000'
193200180213      *
193300180213     C                   Select
193400180213      *
193500180213     C                   WHEN      %TRIM(HDRINVTYPE) = 'IBM'
193600180213     C                   EVAL      DETMCHTYP = '9OT9'
193700180213     C                   EVAL      DETMCHMOD = 'IBM'
193800180213     C                   EVAL      DETEQSRC =  'IB'
193900180213      *
194000180213     C                   WHEN      %TRIM(HDRINVTYPE) = 'VEN'
194100180213     C                   EVAL      DETEQSRC =  'BP'
194200170831      *
194300180213     C                   EVAL      FREIGHTKEY1 = %TRIM(HDRCNTRYCOD)
194400161107     C                   EVAL      FREIGHTKEY2 = HDRINVTYPE
194500161107     C     FREIGHTKEY    CHAIN     EDIFRTCTL
194600170831     C                   IF        %FOUND
194700161107     C                   EVAL      DETMCHTYP = EDIFMACTYP
194800161107     C                   EVAL      DETMCHMOD = EDIFMODEL
194900170831     C                   ENDIF
195000180213      *
195100180213     C                   ENDSL
195200180213      *
195300161107     C                   EVAL      E7KEY5 = 'TM'
195400160526     C                   EVAL      DETPRTDSC = 'shipping charge'
195500160526     C                   EVAL      INTAMT = %INT(HOLDFREIGHTCHG)
195600160526     C                   EVAL      DECAMT = INTAMT / 100
195700160526     C                   EVAL      DETUNTPRC = DECAMT
195800160526     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
195900160526     C                   ENDIF
196000160526     C                   ENDIF
196100160708
196200160526     C                   IF        HOLDCHG = 'T'
196300171107      * @1622: Begin
196400171025     C                   Select
196500180206      * @uxh : Begin
196600180206     C***                When      HOLDTAXES>'0000000000' and HDRCNTRYCOD<>'CA'
196700180303     C                   When      HOLDTAXES<>'0000000000'
196800180303     C                             and HDRCNTRYCOD = 'US'
196900180303     C                             and TAXSTATE = 0
197000180206      * @uxh : End
197100171107      * @1622: End
197200161104     C                   EVAL      E7KEY5 = 'TM'
197300160526     C                   EVAL      DETMCHTYP = '9TX8'
197400160526     C                   EVAL      DETMCHMOD = 'TAX'
197500160526     C                   EVAL      INTAMT = %INT(HOLDTAXES)
197600180206     C                   EVAL      DECAMT = INTAMT / 100
197700180206      * @uxh : Begin
197800180213     C                   EVAL      DETUNTPRC = DECAMT
197900180209     C*                  MOVE      DECAMT        DETLINTAX
198000180206      *
198100180206     C                   IF        HDRINVTYPE = 'IBM'
198200180206     C                   EVAL      DETEQSRC = 'IB'
198300180228     C                   ELSEIF    HDRINVTYPE = 'VEN'
198400180206     C                   EVAL      DETEQSRC = 'BP'
198500180206     C                   ELSE
198600180206     C                   EVAL      DETEQSRC = '  '
198700180206     C                   ENDIF
198800180206      * @uxh : End
198900160526     C                   EVAL      HOLDTAXES = '0000000000'
199000171107      * @1622: Begin
199100180303     C                   When      HOLDTAXES<>'0000000000'
199200180303     C                             and HDRCNTRYCOD = 'CA'
199300171025     C                   EVAL      E7KEY5 = 'TM'
199400171101     C                   IF        IBMIND = 'N'
199500171025     C                   EVAL      DETMCHTYP = '9TX8'
199600171025     C                   EVAL      DETMCHMOD = 'HST'
199700171101     C                   ENDIF
199800171025     C                   EVAL      INTAMT = %INT(HOLDTAXES)
199900171025     C                   EVAL      DECAMT = INTAMT / 100
200000180206      * @uxh : Begin
200100180209     C                   EVAL      DETUNTPRC = DECAMT
200200180209     C**                 MOVE      DECAMT        DETLINTAX
200300180206      * @uxh : End
200400180228     C                   IF        HDRINVTYPE = 'IBM'
200500180228     C                   EVAL      DETEQSRC = 'IB'
200600180228     C                   ELSEIF    HDRINVTYPE = 'VEN'
200700180228     C                   EVAL      DETEQSRC = 'BP'
200800180228     C                   ELSE
200900180228     C                   EVAL      DETEQSRC = '  '
201000180228     C                   ENDIF
201100171025     C                   EVAL      HOLDTAXES = '0000000000'
201200180220      * @1607d : Begin
201300180220     C                   Other
201400180220     C                   EVAL      HOLDTAXES = '0000000000'
201500180220      * @1607d : End
201600171025     C                   ENDSL
201700171107      * @1622: End
201800160526     C                   ENDIF
201900160708
202000180206      * @UXH : Begin
202100180206     C***                IF        %TRIMR(HDRCNTRYCOD) = 'US'
202200180206     C***                IF        HDRINVTYPE = 'IBM'
202300180206     C***                EVAL      DETEQSRC = 'IB'
202400180206     C***                ELSE
202500180206     C***                IF        HDRINVTYPE = 'VEN'
202600180206     C***                EVAL      DETEQSRC = 'BP'
202700180206     C***                ELSE
202800180206     C***                EVAL      DETEQSRC = '  '
202900180206     C***                ENDIF
203000180206     C***                ENDIF
203100180206     C***                ENDIF
203200180206      * @UXH : End
203300161103
203400160526     C                   EVAL      DETRCDID = RECTYPE5
203500180302     C                   IF        TAXSTATE = 0 and CATAXSPD<>'Y'
203600160526     C                   EVAL      E7SKEY1 = E7KEY1
203700160526     C                   EVAL      E7SKEY2 = E7KEY2
203800160526     C                   EVAL      E7SKEY3 = E7KEY3
203900160526     C                   EVAL      E7SKEY4 = E7KEY4
204000160526     C                   EVAL      E7SKEY5 = E7KEY5
204100160526     C                   EVAL      EDIRCD7S = DSDETAIL
204200171206     C                   WRITE     EDIPF7SR                             70
204300171206     C                   EXSR      ErrPF7A
204400161206     C                   ELSE
204500180226      * @1607e : Begin
204600180226     C***                EVAL      TAXAMT = %DECH((DETUNTPRC *
204700180226     C***                                         TAXPCT)/100:10:4)
204800180226     C                   EVAL      TAXAMT = %DECH((DETUNTPRC *
204900180226     C                                            TAXPCT)/100:10:2)
205000180226      * @1607e : End
205100180926      * @1687 : Begin
205200180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
205300180924     C                   EVAL      TAXAMT2 = TAXAMT * 100
205400180926      * @1687 : End
205500161206     C                   EVAL      TAXACCUM = TAXACCUM - TAXAMT
205600161206     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
205700180423      * @1652 : Begin
205800180423     C***                EVAL      E7VATCOD = 'I2'
205900180423     C                   EVAL      E7VATCOD = 'I1'
206000180423      * @1652 : End
206100161206     C                   EVAL      E7TKEY1 = E7KEY1
206200161206     C                   EVAL      E7TKEY2 = E7KEY2
206300161206     C                   EVAL      E7TKEY3 = E7KEY3
206400161206     C                   EVAL      E7TKEY4 = E7KEY4
206500161206     C                   EVAL      E7TKEY5 = E7KEY5
206600161206     C                   EVAL      EDIRCD7T = DSDETAIL
206700171213     C                   WRITE     EDIPF7TR                             70
206800171213     C                   EXSR      ErrPF7B
206900161206     C                   ENDIF
207000160526     C                   ENDSR
207100171206      *************************************************************
207200171206      * EDIPF7A error logging on write
207300171206      *************************************************************
207400171206     C     ErrPF7A       Begsr
207500171206      *
207600171206     C                   IF        *IN70
207700171206     C                   CLEAR                   ERRORDS
207800171206     C                   EVAL      MSGID    = 'ICC6700'
207900171206     C                   EVAL      FILENAME = PF7AFIL
208000171206     C                   EVAL      OPCODE   = PF7AOPC
208100171206     C                   EVAL      STATUS   = PF7AFST
208200171206     C                   EVAL      EXTMSG   = 'Write failed while ' +
208300171206     C                             'processing GCMS EDI for ' +
208400171206     C                              PRMMBRNAME
208500171206     C                   EXSR      ERRLOG
208600171206     C                   ENDIF
208700171206      *
208800171206     C                   Endsr
208900171213      *************************************************************
209000171213      * EDIPF7B error logging on write
209100171213      *************************************************************
209200171213     C     ErrPF7B       Begsr
209300171213      *
209400171213     C                   IF        *IN70
209500171213     C                   CLEAR                   ERRORDS
209600171213     C                   EVAL      MSGID    = 'ICC6700'
209700171213     C                   EVAL      FILENAME = PF7BFIL
209800171213     C                   EVAL      OPCODE   = PF7BOPC
209900171213     C                   EVAL      STATUS   = PF7BFST
210000171213     C                   EVAL      EXTMSG   = 'Write failed while ' +
210100171213     C                             'processing GCMS EDI for ' +
210200171213     C                              PRMMBRNAME
210300171213     C                   EXSR      ERRLOG
210400171213     C                   ENDIF
210500171213      *
210600171213     C                   Endsr
210700171206      *************************************************************
210800160322      * FILE HEADER
210900171212      *************************************************************
211000160322      *
211100160322     C     XMLFILEHDR    BEGSR
211200160329     C                   EVAL      DSFILEHDR = EDIRCD7S
211300160322     C                   ENDSR
211400171212      *************************************************************
211500160322      * CONTROL
211600171212      *************************************************************
211700160322      *
211800160322     C     XMLCONTROL    BEGSR
211900160325     C                   IF        PROCESSINV <> 0
212000160330     C                   EXSR      ENDOFINV
212100180917      * @1685 : Begin
212200180917     C***                EVAL      BUFFER = ' '
212300180917      * @1685 : End
212400171206     C                   EVAL      BUFFER1= *Blanks
212500190225      * @1692  : Begin
212600190225     C                   EVAL      BUFFER2= *Blanks
212700190225      * @1692  : End
212800160325     C                   ENDIF
212900160708
213000161116     C                   EVAL      INVOICENDX = INVOICENDX + 1
213100160325     C                   EVAL      PROCESSINV = PROCESSINV + 1
213200160411     C                   EVAL      DSCONTROL = EDIRCD7S
213300160620     C                   EVAL      EDIXMLLEN = 0
213400171212     C                   EVAL      wrkXMLCTL  = *Blanks
213500171212     ?* Time ***
213600171212     C                   TIME                    TIMSTP
213700171212     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
213800171212      *
213900171212      *
214000171208       /free
214100171212     ?* Clear old xml - EDI
214200171212     ?* O_CREAT indicates create file if not exist
214300171208            fd  = open(%trim($file_path)
214400171208                       : O_WRONLY+O_CREAT+O_TRUNC
214500171208                       : S_IRGRP + S_IWGRP + S_IXGRP +
214600180309                          S_IRUSR + S_IWUSR + S_IXUSR+S_IROTH+S_IXOTH);
214700171208
214800171208            callp close(fd);
214900171212     ?* Compose new xml  - EDI
215000171208            fd = open(%trim($file_path)
215100190501                      :O_WRONLY+O_TEXTDATA+O_CCSID
215200190501                      :S_IRGRP: 37);
215300171208       /end-free
215400171208      *
215500171212     C                   EVAL      WrkXMLCTL = '<?xml version="1.0" '  +
215600171212     C                                         'encoding="UTF-8"?>'    +
215700171212      *
215800171212     C                                         '<soapenv:Envelope '           +
215900160331     C                                         'xmlns:xsl="http://www.w3.org' +
216000160331     C                                         '/2001/XMLSchema-instance" '   +
216100160331     C                                         'xmlns:xsd="http://www.w3.org/'+
216200160331     C                                         '2001/XMLSchema" xmlns:soapenv'+
216300160331     C                                         '="http://schemas.xmlsoap.org' +
216400171212     C                                         '/soap/envelope/">'            +
216500171212      *
216600171212     C                                         '<soapenv:Header>'             +
216700171212      *
216800171212     C                                         '<wsa:To soapenv:mustUnderstand'+
216900160331     C                                         '="0" '                        +
217000160331     C                                         'xmlns:wsa="http://schemas.xml'+
217100160331     C                                         'soap.org/ws/2004/03/'         +
217200160331     C                                         'addressing">jms:/queue?destin'+
217300160331     C                                         'ation=jms/IGFHUB/IGFHUBeBizW' +
217400170531     C                                         'SRequest&amp;amp;connectionFa'+
217500160331     C                                         'ctory=jms/IGFHUB/SOAPJMSFacto'+
217600171212     C                                         'ry</wsa:To>'                  +
217700171212      *
217800171212     C                                         '<wsa:Action '                 +
217900160331     C                                         'xmlns:wsa="http://schemas.xml'+
218000160331     C                                         'soap.org/ws/2004/03/'         +
218100160331     C                                         'addressing" soapenv:mustUnde' +
218200160331     C                                         'rstand="0">jms:/targetService'+
218300171212     C                                         '=ProcessInvoice</wsa:Action>' +
218400171212      *
218500171212     C                                         '<wsa:ReplyTo '                +
218600160331     C                                         'xmlns:wsa="http://schemas.xml'+
218700160331     C                                         'soap.org/ws/2004/03/'         +
218800160331     C                                         'addressing" soapenv:mustUnde' +
218900171212     C                                         'rstand="0">'                  +
219000171212      *
219100171212     C                                         '<wsa:Address '                +
219200160331     C                                         'xmlns:wsa="http://schemas.xml'+
219300160331     C                                         'soap.org/ws/2004/03/'         +
219400160331     C                                         'addressing">jms:/queue?destin'+
219500161227     C                                         'ation=jms/'                   +
219600171212     C                                         %TRIMR(WSOAPADR)               +
219700171212     C                                         '</wsa:Address>'               +
219800171212      *
219900171212     C                                         '</wsa:ReplyTo>'               +
220000171212      *
220100171212     C                                         '<wsa:MessageId '              +
220200160331     C                                         'xmlns:wsa="http://schemas.xml'+
220300160331     C                                         'soap.org/ws/2004/03/'         +
220400160331     C                                         'addressing" soapenv:mustUnde' +
220500171212     C                                         'rstand="0"> </wsa:MessageId>' +
220600171212      *
220700171212     C                                         '<Application soapenv:mustUnde'+
220800160331     C                                         'rstand="0" xmlns="">GAPTS'    +
220900171212     C                                         '</Application>'               +
221000171212      *
221100171212     C                                         '<Environment soapenv:mustUnde'+
221200161227     C                                         'rstand="0" xmlns="">'         +
221300171212     C                                         %TRIMR(wXMLENV)                +
221400171212     C                                         '</Environment>'               +
221500171212      *
221600171212     C                                         '<Format soapenv:mustUnderstan'+
221700160331     C                                         'd="0" xmlns="">ProcessInvoice'+
221800171212     C                                         '</Format>'                    +
221900171212      *
222000171212     C                                         '<ServiceParameter soapenv:mus'+
222100171212     C                                         'tUnderstand="0" xmlns=""/>'   +
222200171212      *
222300171212     C                                         '<RefId soapenv:mustUnderstan' +
222400160509     C                                         'd="0" xmlns="">'              +
222500160509     C                                         HOLDTIME                       +
222600171212     C                                         '</RefId>'                     +
222700171212      *
222800171212     C                                         '</soapenv:Header>'            +
222900171212      *
223000171212     C                                         '<soapenv:Body>'               +
223100171212      *
223200171212     C                                         '<ProcessInvoice'               +
223300160325     C                                         ' xmlns="http://www.ibm.com/'   +
223400160325     C                                         'xmlns/ims/1.3/ProcessInvoice'  +
223500160325     C                                         '_2012-12-20" xmlns:ns2="'      +
223600160325     C                                         'http://www.openapplications'   +
223700160325     C                                         '.org/oagis/8.2/ProcessInvoice' +
223800171212     C                                         '_2012-12-20" revision="1.0">'  +
223900171212      *
224000171212     C                                         '<ApplicationArea>'             +
224100171212      *
224200171212     C                                         '<ns2:Sender>'                  +
224300171212      *
224400171212     C                                         '<ns2:Component>'      +
224500160325     C                                         'GAPTS'                +
224600171212     C                                         '</ns2:Component>'     +
224700171212      *
224800171212     C                                         '</ns2:Sender>'        +
224900171212      *
225000171212     C                                         '<ns2:CreationDateTime>'  +
225100160325     C                                         '1970-01-01T00:00:00.000-05:00' +
225200171212     C                                         '</ns2:CreationDateTime>'  +
225300171212      *
225400171212     C                                         '<ns2:BODId>'        +
225500160325     C                                         'GAPTS-'             +
225600160413     C                                         HOLDTIME             +
225700171212     C                                         '</ns2:BODId>'       +
225800171212      *
225900171212     C                                         '<Application/>'     +
226000171212      *
226100171212     C                                         '</ApplicationArea>' +
226200171212      *
226300171212     C                                         '<DataArea>'         +
226400171212      *
226500171212     C                                         '<ns2:Process/>'     +
226600171212      *
226700171212     C                                         '<Invoice>'
226800171212      *
226900171212      *
227000171212     ?* Append buffer
227100171212     C                   IF        INVOICEVALID (INVOICENDX) = '0'
227200171212     C                   EVAL      BUFFER1 = %Trimr(BUFFER1)      +
227300171212     C                                       %Trimr(WrkXMLCTL)
227400171212     C                   ENDIF
227500171212      *
227600160322     C                   ENDSR
227700171212      *****************************************************************
227800171212     ?* End of invoice
227900171212      *****************************************************************
228000160330     C     ENDOFINV      BEGSR
228100171212      *
228200171212     C                   EVAL      EDIXMLDTL = '</Invoice>' +
228300171212      *
228400171212     C                                         '</DataArea>'  +
228500171212      *
228600171212     C                                         '</ProcessInvoice>'  +
228700171212      *
228800171212     C                                         '</soapenv:Body>' +
228900171212      *
229000171212     C                                         '</soapenv:Envelope>'
229100171212     C                   EXSR      WRITEXML
229200171212      *
229300161116     C                   IF        INVOICEVALID (INVOICENDX) = '0'
229400170111     C                   EXSR      MQSR
229500161116     C                   ENDIF
229600171212      *
229700160330     C                   ENDSR
229800171212      *****************************************************************
229900171212     ?* HEADER
230000171212      * ****************************************************************
230100160322      *
230200160322     C     XMLHEADER     BEGSR
230300160708
230400180917      * @1652 : Begin
230500180917     C                   EVAL      Wrkxmldtl1 = *Blanks
230600180917      * @1652 : End
230700160322     C                   EVAL      XMLDTLLINE = 0
230800160329     C                   EVAL      DSHEADER = EDIRCD7S
230900190129      * @1712 : Begin
231000190129      * Do not create XML for invalid invoices
231100190129     C                   IF        INVOICEVALID (INVOICENDX) = '1'
231200190129     C                   LEAVESR
231300190129     C                   ENDIF
231400190129      * @1712 : End
231500180303      * @1622: Begin
231600180303     C                   Eval      IBMIND = *Blanks
231700180303     C                   IF        HDRCNTRYCOD  = 'CA'
231800180303     C                   EVAL      wPROVINCE = HDRSHPSTA
231900180303     C                   Eval      IBMIND = 'N'
232000180303     C     'IBM'         SCAN      HDRBLLNAM     IBMCHK
232100180303     C                   If        IBMCHK  <> 0
232200180303     C                   Eval      IBMIND = 'Y'
232300180303     C                   EndIf
232400180303     C                   ELSE
232500180303     C                   EVAL      wPROVINCE = *Blanks
232600180303     C                   ENDIF
232700180303      * @1622: End
232800180303     C                   IF        %LEN(%TRIMR(HDRFREIGHTCHARG))= 0
232900180303     C                   EVAL      HDRFREIGHTCHARG = '0000000000'
233000180303     C                   ENDIF
233100180303
233200180303     C                   IF        %LEN(%TRIMR(HDRMISCCHARG))= 0
233300180303     C                   EVAL      HDRMISCCHARG = '0000000000'
233400180303     C                   ENDIF
233500180303
233600180303     C                   IF        %LEN(%TRIMR(HDRTAXES))= 0
233700180303     C                   EVAL      HDRTAXES = '0000000000'
233800180303     C                   ENDIF
233900180303      *
234000160329     C                   EVAL      HDROBJID = E7SOBJID
234100160329     C                   EVAL      HDRINVTYPE = E7SINVTYP
234200160329     C                   EVAL      HDRSRANUM = E7SSRA#
234300160329     C                   EVAL      HDRPOEX   = E7SPOEX
234400160330     C                   EVAL      HDRVENNUM = E7SSUPLR
234500160329     C                   EVAL      HDRVENNAME = E7SNAME
234600160329     C                   EVAL      HDRCOMPCODE = E7SCMPCODE
234700160325     C                   EVAL      EDIXMLDTL = '<Header>'
234800160325     C                   EXSR      WRITEXML
234900160325     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
235000160325     C                   EXSR      WRITEXML
235100160325     C                   EVAL      EDIXMLDTL = '<ns2:SupplierDocumentId>'
235200160325     C                   EXSR      WRITEXML
235300160325     C                   EVAL      EDIXMLDTL = '<ns2:Id type="E" '         +
235400160505     C                                         'IdOrigin="IBM/Invoice">'   +
235500160328     C                                         %TRIMR(HDRINVNO)            +
235600160325     C                                         '</ns2:Id>'
235700160325     C                   EXSR      WRITEXML
235800160325     C                   EVAL      EDIXMLDTL = '</ns2:SupplierDocumentId>'
235900160325     C                   EXSR      WRITEXML
236000160325     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
236100160325     C                   EXSR      WRITEXML
236200160325     C                   EVAL      EDIXMLDTL = '<LastModificationDateTime>'+
236300160325     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
236400160325     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
236500160325     C                                         %SUBST(HDRINVDAT:7:2)       +
236600160325     C                                         'T00:00:01.000Z'            +
236700160325     C                                         '</LastModificationDateTime>'
236800160325     C                   EXSR      WRITEXML
236900160328     C                   EVAL      EDIXMLDTL = '<DocumentDateTime>'+
237000160328     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
237100160328     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
237200160328     C                                         %SUBST(HDRINVDAT:7:2)       +
237300160328     C                                         'T00:00:01.000Z'            +
237400160328     C                                         '</DocumentDateTime>'
237500160328     C                   EXSR      WRITEXML
237600160707     C                   READ      EDIPF7A
237700160329     C                   DOW       %SUBST(EDIRCD7S:1:10) = RECTYPE4
237800160329     C                   EVAL      DSCOMMENT = EDIRCD7S
237900160328     C                   EVAL      SCAN_FIELD = COMTXT
238000160328     C                   EXSR      REPLACECHAR
238100160328     C                   TIME                    TIMSTP
238200160328     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
238300160328     C                   EVAL      EDIXMLDTL = '<Note entryDateTime="'     +
238400160328     C                                         %CHAR(SYS_DATE) + 'T'       +
238500160328     C                                         %SUBST(HOLDTIME:1:2) + ':'  +
238600160328     C                                         %SUBST(HOLDTIME:3:2) + ':'  +
238700160328     C                                         %SUBST(HOLDTIME:5:2)        +
238800160328     C                                         '.000-04:00">'              +
238900160328     C                                         %TRIMR(SCAN_FIELD)          +
239000160328     C                                         '</Note>'
239100160328     C                   EXSR      WRITEXML
239200160707     C                   READ      EDIPF7A
239300160328     C                   ENDDO
239400160708
239500160707     C                   READP     EDIPF7A
239600160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentReferences>'
239700160328     C                   EXSR      WRITEXML
239800160328     C                   EVAL      EDIXMLDTL = '<ns2:InvoiceDocumentReference>'
239900160328     C                   EXSR      WRITEXML
240000160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
240100160328     C                   EXSR      WRITEXML
240200160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
240300160328     C                   EXSR      WRITEXML
240400170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="GCPS"/>'
240500160328     C                   EXSR      WRITEXML
240600160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
240700160328     C                   EXSR      WRITEXML
240800160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
240900160328     C                   EXSR      WRITEXML
241000170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin='    +
241100160328     C                                         '"ContentManager">'    +
241200160328     C                                         %TRIMR(HDROBJID)       +
241300170605     C                                         '</ns2:Id>'
241400160328     C                   EXSR      WRITEXML
241500160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
241600160328     C                   EXSR      WRITEXML
241700160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
241800160328     C                   EXSR      WRITEXML
241900170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="GIL">'  +
242000160527     C                                         %TRIMR(HDRREFINV)          +
242100170605     C                                         '</ns2:Id>'
242200160328     C                   EXSR      WRITEXML
242300160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
242400160328     C                   EXSR      WRITEXML
242500160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
242600160328     C                   EXSR      WRITEXML
242700160601     C                   IF        %LEN(%TRIMR(HDRDAT)) > 0
242800160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentDate>'   +
242900160328     C                                         %SUBST(HDRDAT:1:4) + '-' +
243000160328     C                                         %SUBST(HDRDAT:5:2) + '-' +
243100160328     C                                         %SUBST(HDRDAT:7:2)     +
243200170517     C                                         'T00:00:01.000Z'       +
243300160328     C                                         '</ns2:DocumentDate>'
243400160601     C                   ELSE
243500160601     C                   EVAL      EDIXMLDTL = '<ns2:DocumentDate>'        +
243600160601     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
243700160601     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
243800160601     C                                         %SUBST(HDRINVDAT:7:2)       +
243900170517     C                                         'T00:00:01.000Z'            +
244000160601     C                                         '</ns2:DocumentDate>'
244100160601     C                   ENDIF
244200160708
244300160328     C                   EXSR      WRITEXML
244400160328     C                   EVAL      EDIXMLDTL = '</ns2:InvoiceDocumentReference>'
244500160328     C                   EXSR      WRITEXML
244600160328     C                   EVAL      EDIXMLDTL = '<ns2:FinancialOffering' +
244700160328     C                                          'LetterDocumentReference>'
244800160328     C                   EXSR      WRITEXML
244900160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
245000160328     C                   EXSR      WRITEXML
245100160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
245200160328     C                   EXSR      WRITEXML
245300170602     C                   EVAL      EDIXMLDTL = '<ns2:Id>'             +
245400160328     C                                         %TRIMR(HDROFFLTR)      +
245500170602     C                                         '</ns2:Id>'
245600160328     C                   EXSR      WRITEXML
245700160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
245800160328     C                   EXSR      WRITEXML
245900160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
246000160328     C                   EXSR      WRITEXML
246100160328     C                   EVAL      EDIXMLDTL = '</ns2:FinancialOffering' +
246200160328     C                                          'LetterDocumentReference>'
246300160328     C                   EXSR      WRITEXML
246400160328     C                   EVAL      EDIXMLDTL = '<ns2:ContractDocumentReference>'
246500160328     C                   EXSR      WRITEXML
246600160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIds>'
246700160328     C                   EXSR      WRITEXML
246800160328     C                   EVAL      EDIXMLDTL = '<ns2:DocumentIdType>'
246900160328     C                   EXSR      WRITEXML
247000170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="IBM">'  +
247100160328     C                                         %TRIMR(HDRSRANUM)          +
247200170605     C                                         '</ns2:Id>'
247300160328     C                   EXSR      WRITEXML
247400160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIdType>'
247500160328     C                   EXSR      WRITEXML
247600160328     C                   EVAL      EDIXMLDTL = '</ns2:DocumentIds>'
247700160328     C                   EXSR      WRITEXML
247800160328     C                   EVAL      EDIXMLDTL ='</ns2:ContractDocumentReference>'
247900160328     C                   EXSR      WRITEXML
248000170621     C                   EVAL      EDIXMLDTL = '</ns2:DocumentReferences>'
248100160328     C                   EXSR      WRITEXML
248200160328     C                   EVAL      EDIXMLDTL = '<ns2:OrderStatus>'
248300160328     C                   EXSR      WRITEXML
248400160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>Invoice_' +
248500160328     C                                         'header-Invoice_status'     +
248600160328     C                                         '</ns2:Description>'
248700160328     C                   EXSR      WRITEXML
248800160328     C                   EVAL      EDIXMLDTL = '<ns2:AcknowledgementDetail>'
248900160328     C                   EXSR      WRITEXML
249000160509     C                   EVAL      EDIXMLDTL = '<ns2:Code>N</ns2:Code>'
249100160328     C                   EXSR      WRITEXML
249200160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>invoice_' +
249300160328     C                                         'header-coa_with_invoice_indc' +
249400160328     C                                         '</ns2:Description>'
249500160328     C                   EXSR      WRITEXML
249600160328     C                   EVAL      EDIXMLDTL = '</ns2:AcknowledgementDetail>'
249700160328     C                   EXSR      WRITEXML
249800160328     C                   EVAL      EDIXMLDTL = '<ns2:AcknowledgementDetail>'
249900160328     C                   EXSR      WRITEXML
250000160509     C                   EVAL      EDIXMLDTL = '<ns2:Code>N</ns2:Code>'
250100160328     C                   EXSR      WRITEXML
250200160328     C                   EVAL      EDIXMLDTL = '<ns2:Description>invoice_' +
250300160328     C                                         'header-exception_ind'      +
250400160328     C                                         '</ns2:Description>'
250500160328     C                   EXSR      WRITEXML
250600160328     C                   EVAL      EDIXMLDTL = '</ns2:AcknowledgementDetail>'
250700160328     C                   EXSR      WRITEXML
250800160328     C                   EVAL      EDIXMLDTL = '</ns2:OrderStatus>'
250900160328     C                   EXSR      WRITEXML
251000160329     C                   EVAL      EDIXMLDTL = '<Priority>'                +
251100160505     C                                         'Standard'                  +
251200160329     C                                         '</Priority>'
251300160329     C                   EXSR      WRITEXML
251400160610     C                   IF        INVOICETAX(INVOICENDX) = '1'
251500160610     C                   EVAL      INTAMT = %INT(HDRTOTAMT) -
251600160610     C                                      %INT(HDRTAXES)
251700160610     C                   ELSE
251800160610     C                   EVAL      INTAMT = %INT(HDRTOTAMT)
251900160610     C                   ENDIF
252000160708
252100160329     C                   EVAL      DECAMT = INTAMT / 100
252200160329     C                   EVAL      INCOUNT = %CHAR(DECAMT)
252300160510     C                   IF        HDRDBCRINDIC = 'DR'
252400160510     C                   EVAL      TOTAMTTYPE = 'DB'
252500160510     C                   ELSE
252600160510     C                   EVAL      TOTAMTTYPE = 'CR'
252700160510     C                   ENDIF
252800160708
252900160525     C                   IF        DECAMT < 1
253000160329     C                   EVAL      EDIXMLDTL = '<TotalAmount type="'       +
253100160510     C                                         TOTAMTTYPE                  +
253200160329     C                                         '" currency ="'             +
253300160512     C                                         %TRIMR(HDRCURCOD)           +
253400160525     C                                         '" basis="TotalAmount">0'   +
253500160329     C                                         %TRIMR(INCOUNT)             +
253600160329     C                                         '</TotalAmount>'
253700160525     C                   ELSE
253800160525     C                   EVAL      EDIXMLDTL = '<TotalAmount type="'       +
253900160525     C                                         TOTAMTTYPE                  +
254000160525     C                                         '" currency ="'             +
254100160525     C                                         %TRIMR(HDRCURCOD)           +
254200160525     C                                         '" basis="TotalAmount">'    +
254300160525     C                                         %TRIMR(INCOUNT)             +
254400160525     C                                         '</TotalAmount>'
254500160525     C                   ENDIF
254600160708
254700160329     C                   EXSR      WRITEXML
254800160329     C                   EVAL      EDIXMLDTL = '<TotalAmount currency="'   +
254900160512     C                                         %TRIMR(HDRCURCOD)           +
255000160329     C                                         '" basis="AvailableUnit'    +
255100160329     C                                         'Amount"/>'
255200160329     C                   EXSR      WRITEXML
255300160329     C                   EVAL      EDIXMLDTL = '<ns2:Parties>'
255400160329     C                   EXSR      WRITEXML
255500160329     C                   EVAL      EDIXMLDTL = '<ns2:SupplierParty>'
255600160329     C                   EXSR      WRITEXML
255700170605     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
255800160329     C                   EXSR      WRITEXML
255900170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="Supplier"/>'
256000160329     C                   EXSR      WRITEXML
256100170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="POEX">'  +
256200160329     C                                         %TRIMR(HDRPOEX)     +
256300170605     C                                         '</ns2:Id>'
256400160329     C                   EXSR      WRITEXML
256500170605     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="SAP">'  +
256600160330     C                                         %TRIMR(HDRVENNUM)   +
256700170605     C                                         '</ns2:Id>'
256800160329     C                   EXSR      WRITEXML
256900170605     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
257000160329     C                   EXSR      WRITEXML
257100181018      * @1691 : Begin
257200181018     C***                EVAL      EDIXMLDTL = '<ns2:Name>'               +
257300181018     C***                                      %TRIMR(HDRVENNAME)         +
257400181018     C***                                      '</ns2:Name>'
257500181018     C                   EVAL      SCAN_FIELD = HDRVENNAME
257600190412     C                   EXSR      REPLACECHAR
257700181018     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
257800181018     C                                         %TRIMR(SCAN_FIELD)         +
257900181018     C                                         '</ns2:Name>'
258000181018      * @1691 : End
258100160329     C                   EXSR      WRITEXML
258200160601     C                   EVAL      EDIXMLDTL = '<ns2:TaxId IdOrigin="VAT">' +
258300160601     C                                         %TRIMR(HDRLEGALID)           +
258400160601     C                                         '</ns2:TaxId>'
258500160329     C                   EXSR      WRITEXML
258600160524     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
258700160524     C                   EXSR      WRITEXML
258800160524     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
258900160524     C                   EXSR      WRITEXML
259000160524     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
259100160524     C                                         %TRIMR(HDRCNTRYCOD) +
259200160524     C                                         '</ns2:Country>'
259300160524     C                   EXSR      WRITEXML
259400160524     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
259500160524     C                   EXSR      WRITEXML
259600160524     C                   EVAL      EDIXMLDTL = '<ns2:SecondaryAddress>'
259700160524     C                   EXSR      WRITEXML
259800160524     C                   EVAL      EDIXMLDTL = '<ns2:Country>'
259900160524     C                   EXSR      WRITEXML
260000160524     C                   EVAL      EDIXMLDTL = '</ns2:Country>'
260100160524     C                   EXSR      WRITEXML
260200160524     C                   EVAL      EDIXMLDTL = '</ns2:SecondaryAddress>'
260300160524     C                   EXSR      WRITEXML
260400160524     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
260500160524     C                   EXSR      WRITEXML
260600160329     C                   EVAL      EDIXMLDTL = '</ns2:SupplierParty>'
260700160329     C                   EXSR      WRITEXML
260800160329     C                   EVAL      EDIXMLDTL = '<ns2:EmployeeParty>'
260900160329     C                   EXSR      WRITEXML
261000160329     C                   EVAL      EDIXMLDTL = '<ns2:Contacts>'
261100160329     C                   EXSR      WRITEXML
261200160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
261300160329     C                   EXSR      WRITEXML
261400160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
261500160329     C                                         'BSP'                       +
261600160329     C                                         '</ns2:JobTitle>'
261700160329     C                   EXSR      WRITEXML
261800170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
261900160329     C                                        'sequence="1"/>'
262000160329     C                   EXSR      WRITEXML
262100160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
262200160329     C                   EXSR      WRITEXML
262300160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
262400160329     C                   EXSR      WRITEXML
262500160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
262600160329     C                                         'Indexer-Creator'           +
262700160329     C                                         '</ns2:JobTitle>'
262800160329     C                   EXSR      WRITEXML
262900170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
263000160329     C                                        'sequence="1">'        +
263100160329     C                                        'GAPTS'                +
263200170602     C                                        '</ns2:EMailAddress>'
263300160329     C                   EXSR      WRITEXML
263400160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
263500160329     C                   EXSR      WRITEXML
263600160329     C                   EVAL      EDIXMLDTL = '<ns2:ContactAbs>'
263700160329     C                   EXSR      WRITEXML
263800160329     C                   EVAL      EDIXMLDTL = '<ns2:JobTitle>'            +
263900160329     C                                         'Indexer-Modified'          +
264000160329     C                                         '</ns2:JobTitle>'
264100160329     C                   EXSR      WRITEXML
264200170602     C                   EVAL      EDIXMLDTL ='<ns2:EMailAddress '   +
264300160329     C                                        'sequence="1"/>'
264400160329     C                   EXSR      WRITEXML
264500160329     C                   EVAL      EDIXMLDTL = '</ns2:ContactAbs>'
264600160329     C                   EXSR      WRITEXML
264700160329     C                   EVAL      EDIXMLDTL = '</ns2:Contacts>'
264800160329     C                   EXSR      WRITEXML
264900160329     C                   EVAL      EDIXMLDTL = '<ns2:SplitPayInfo/>'
265000160329     C                   EXSR      WRITEXML
265100160329     C                   EVAL      EDIXMLDTL = '</ns2:EmployeeParty>'
265200160329     C                   EXSR      WRITEXML
265300160329     C                   EVAL      EDIXMLDTL = '<ns2:ShipToParty>'
265400160329     C                   EXSR      WRITEXML
265500160329     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
265600160329     C                   EXSR      WRITEXML
265700160524     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="IBM">'   +
265800160329     C                                         %TRIMR(HDRCOMPCODE)         +
265900160329     C                                         '</ns2:Id>'
266000160329     C                   EXSR      WRITEXML
266100160329     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
266200160329     C                   EXSR      WRITEXML
266300160329     C                   EVAL      EDIXMLDTL = '<ns2:Business>'
266400160329     C                   EXSR      WRITEXML
266500160329     C                   EVAL      EDIXMLDTL = '<ns2:RelatedUnit>'
266600160329     C                   EXSR      WRITEXML
266700160329     C                   EVAL      EDIXMLDTL = '<ns2:Relationship>'        +
266800160510     C                                         'CostCenter'                +
266900160329     C                                         '</ns2:Relationship>'
267000160329     C                   EXSR      WRITEXML
267100160329     C                   EVAL      EDIXMLDTL = '<ns2:Unit>'
267200160329     C                   EXSR      WRITEXML
267300160329     C                   EVAL      EDIXMLDTL = '<ns2:Id/>'
267400160329     C                   EXSR      WRITEXML
267500160329     C                   EVAL      EDIXMLDTL = '</ns2:Unit>'
267600160329     C                   EXSR      WRITEXML
267700160329     C                   EVAL      EDIXMLDTL = '</ns2:RelatedUnit>'
267800160329     C                   EXSR      WRITEXML
267900160329     C                   EVAL      EDIXMLDTL = '</ns2:Business>'
268000160329     C                   EXSR      WRITEXML
268100160329     C                   EVAL      EDIXMLDTL = '</ns2:ShipToParty>'
268200160329     C                   EXSR      WRITEXML
268300160330     C                   EVAL      EDIXMLDTL = '<ns2:RemitToParty>'
268400160330     C                   EXSR      WRITEXML
268500160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
268600160330     C                   EXSR      WRITEXML
268700160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'        +
268800160330     C                                         'GIL'                       +
268900160330     C                                         '"/>'
269000160330     C                   EXSR      WRITEXML
269100160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
269200160330     C                   EXSR      WRITEXML
269300160330     C                   EVAL      EDIXMLDTL = '</ns2:RemitToParty>'
269400160330     C                   EXSR      WRITEXML
269500160330     C                   EVAL      EDIXMLDTL = '<ns2:BillToParty>'
269600160330     C                   EXSR      WRITEXML
269700160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
269800160330     C                   EXSR      WRITEXML
269900160331      *
270000160331      * Remove first 2 zeroes for DRDA invoices
270100160331      *
270200160331     C                   IF        %LEN(%TRIMR(HDRBLLCUS)) = 8 AND
270300160331     C                             %SUBST(HDRBLLCUS:1:2) = '00'
270400160331     C                   EVAL      EDIXMLDTL = '<ns2:Id>'                 +
270500160331     C                                         %SUBST(HDRBLLCUS:3:6)      +
270600160331     C                                         '</ns2:Id>'
270700160331     C                   ELSE
270800160330     C                   EVAL      EDIXMLDTL = '<ns2:Id>'                 +
270900160330     C                                         %TRIMR(HDRBLLCUS)          +
271000160330     C                                         '</ns2:Id>'
271100160331     C                   ENDIF
271200160708
271300160331     C                   EXSR      WRITEXML
271400160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
271500160330     C                   EXSR      WRITEXML
271600160330     C                   EVAL      SCAN_FIELD = HDRBLLNAM
271700160330     C                   EXSR      REPLACECHAR
271800160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
271900160330     C                                         %TRIMR(SCAN_FIELD)         +
272000160330     C                                         '</ns2:Name>'
272100160330     C                   EXSR      WRITEXML
272200160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
272300160330     C                   EXSR      WRITEXML
272400160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
272500160330     C                   EXSR      WRITEXML
272600160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
272700160330     C                   EXSR      WRITEXML
272800160510     C                   IF        %LEN(%TRIMR(HDRBLLAD1)) > 0
272900160330     C                   EVAL      SCAN_FIELD = HDRBLLAD1
273000160330     C                   EXSR      REPLACECHAR
273100160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
273200160330     C                                         %TRIMR(SCAN_FIELD)         +
273300160330     C                                         '</ns2:Line>'
273400160330     C                   EXSR      WRITEXML
273500160510     C                   ENDIF
273600160708
273700160510     C                   IF        %LEN(%TRIMR(HDRBLLAD2)) > 0
273800160330     C                   EVAL      SCAN_FIELD = HDRBLLAD2
273900160330     C                   EXSR      REPLACECHAR
274000160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
274100160330     C                                         %TRIMR(SCAN_FIELD)         +
274200160330     C                                         '</ns2:Line>'
274300160330     C                   EXSR      WRITEXML
274400160510     C                   ENDIF
274500160708
274600160510     C                   IF        %LEN(%TRIMR(HDRBLLCTY)) > 0
274700160330     C                   EVAL      SCAN_FIELD = HDRBLLCTY
274800160330     C                   EXSR      REPLACECHAR
274900160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
275000160330     C                                         %TRIMR(SCAN_FIELD)         +
275100160330     C                                         '</ns2:Line>'
275200160330     C                   EXSR      WRITEXML
275300160510     C                   ENDIF
275400160708
275500160510     C                   IF        %LEN(%TRIMR(HDRBLLSTA)) > 0
275600160330     C                   EVAL      SCAN_FIELD = HDRBLLSTA
275700160330     C                   EXSR      REPLACECHAR
275800160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
275900160330     C                                         %TRIMR(SCAN_FIELD)         +
276000160330     C                                         '</ns2:Line>'
276100160330     C                   EXSR      WRITEXML
276200160510     C                   ENDIF
276300160708
276400160510     C                   IF        %LEN(%TRIMR(HDRBLLZIP)) > 0
276500160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
276600160330     C                                         %TRIMR(HDRBLLZIP)          +
276700160330     C                                         '</ns2:Line>'
276800160330     C                   EXSR      WRITEXML
276900160510     C                   ENDIF
277000160708
277100160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
277200160330     C                   EXSR      WRITEXML
277300160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
277400160512     C                                         %TRIMR(HDRCNTRYCOD) +
277500160330     C                                         '</ns2:Country>'
277600160330     C                   EXSR      WRITEXML
277700160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
277800160330     C                   EXSR      WRITEXML
277900160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
278000160330     C                   EXSR      WRITEXML
278100160330     C                   EVAL      EDIXMLDTL = '</ns2:BillToParty>'
278200160330     C                   EXSR      WRITEXML
278300160330     C                   EVAL      EDIXMLDTL = '<ns2:ShipToParty>'
278400160330     C                   EXSR      WRITEXML
278500160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
278600160330     C                   EXSR      WRITEXML
278700160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'       +
278800160330     C                                         'IBM/ShipTo"'              +
278900160330     C                                         '/>'
279000160330     C                   EXSR      WRITEXML
279100160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
279200160330     C                   EXSR      WRITEXML
279300160330     C                   EVAL      SCAN_FIELD = HDRSHPNAM
279400160330     C                   EXSR      REPLACECHAR
279500160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
279600160330     C                                         %TRIMR(SCAN_FIELD)         +
279700160330     C                                         '</ns2:Name>'
279800160330     C                   EXSR      WRITEXML
279900160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
280000160330     C                   EXSR      WRITEXML
280100160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
280200160330     C                   EXSR      WRITEXML
280300160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
280400160330     C                   EXSR      WRITEXML
280500160512     C                   IF        %LEN(%TRIMR(HDRSHPAD1)) > 0
280600160330     C                   EVAL      SCAN_FIELD = HDRSHPAD1
280700160330     C                   EXSR      REPLACECHAR
280800160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
280900160330     C                                         %TRIMR(SCAN_FIELD)         +
281000160330     C                                         '</ns2:Line>'
281100160330     C                   EXSR      WRITEXML
281200160512     C                   ENDIF
281300160708
281400160512     C                   IF        %LEN(%TRIMR(HDRSHPAD2)) > 0
281500160330     C                   EVAL      SCAN_FIELD = HDRSHPAD2
281600160330     C                   EXSR      REPLACECHAR
281700160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
281800160330     C                                         %TRIMR(SCAN_FIELD)         +
281900160330     C                                         '</ns2:Line>'
282000160330     C                   EXSR      WRITEXML
282100160512     C                   ENDIF
282200160708
282300160512     C                   IF        %LEN(%TRIMR(HDRSHPCTY)) > 0
282400160330     C                   EVAL      SCAN_FIELD = HDRSHPCTY
282500160330     C                   EXSR      REPLACECHAR
282600160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
282700160330     C                                         %TRIMR(SCAN_FIELD)         +
282800160330     C                                         '</ns2:Line>'
282900160330     C                   EXSR      WRITEXML
283000160512     C                   ENDIF
283100160708
283200160512     C                   IF        %LEN(%TRIMR(HDRSHPSTA)) > 0
283300160330     C                   EVAL      SCAN_FIELD = HDRSHPSTA
283400160330     C                   EXSR      REPLACECHAR
283500160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
283600160330     C                                         %TRIMR(SCAN_FIELD)         +
283700160330     C                                         '</ns2:Line>'
283800160330     C                   EXSR      WRITEXML
283900160512     C                   ENDIF
284000160708
284100160512     C                   IF        %LEN(%TRIMR(HDRSHPZIP)) > 0
284200160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
284300160330     C                                         %TRIMR(HDRSHPZIP)          +
284400160330     C                                         '</ns2:Line>'
284500160330     C                   EXSR      WRITEXML
284600160512     C                   ENDIF
284700160708
284800160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
284900160330     C                   EXSR      WRITEXML
285000160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
285100160512     C                                         %TRIMR(HDRCNTRYCOD) +
285200160330     C                                         '</ns2:Country>'
285300160330     C                   EXSR      WRITEXML
285400160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
285500160330     C                   EXSR      WRITEXML
285600160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
285700160330     C                   EXSR      WRITEXML
285800160330     C                   EVAL      EDIXMLDTL = '</ns2:ShipToParty>'
285900160330     C                   EXSR      WRITEXML
286000160330     C                   EVAL      EDIXMLDTL = '<ns2:SoldToParty>'
286100160330     C                   EXSR      WRITEXML
286200160330     C                   EVAL      EDIXMLDTL = '<ns2:PartyId>'
286300160330     C                   EXSR      WRITEXML
286400160330     C                   EVAL      EDIXMLDTL = '<ns2:Id IdOrigin="'       +
286500160330     C                                         'IBM/SoldTo"'              +
286600160330     C                                         '/>'
286700160330     C                   EXSR      WRITEXML
286800160330     C                   EVAL      EDIXMLDTL = '</ns2:PartyId>'
286900160330     C                   EXSR      WRITEXML
287000160330     C                   EVAL      SCAN_FIELD = HDRSHPNAM
287100160330     C                   EXSR      REPLACECHAR
287200160330     C                   EVAL      EDIXMLDTL = '<ns2:Name>'               +
287300160330     C                                         %TRIMR(SCAN_FIELD)         +
287400160330     C                                         '</ns2:Name>'
287500160330     C                   EXSR      WRITEXML
287600160330     C                   EVAL      EDIXMLDTL = '<ns2:Addresses>'
287700160330     C                   EXSR      WRITEXML
287800160330     C                   EVAL      EDIXMLDTL = '<ns2:PrimaryAddress>'
287900160330     C                   EXSR      WRITEXML
288000160330     C                   EVAL      EDIXMLDTL = '<ns2:AddressLine>'
288100160330     C                   EXSR      WRITEXML
288200160512     C                   IF        %LEN(%TRIMR(HDRSHPAD1)) > 0
288300160330     C                   EVAL      SCAN_FIELD = HDRSHPAD1
288400160330     C                   EXSR      REPLACECHAR
288500160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="1">'  +
288600160330     C                                         %TRIMR(SCAN_FIELD)         +
288700160330     C                                         '</ns2:Line>'
288800160330     C                   EXSR      WRITEXML
288900160512     C                   ENDIF
289000160708
289100160512     C                   IF        %LEN(%TRIMR(HDRSHPAD2)) > 0
289200160330     C                   EVAL      SCAN_FIELD = HDRSHPAD2
289300160330     C                   EXSR      REPLACECHAR
289400160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="2">'  +
289500160330     C                                         %TRIMR(SCAN_FIELD)         +
289600160330     C                                         '</ns2:Line>'
289700160330     C                   EXSR      WRITEXML
289800160512     C                   ENDIF
289900160708
290000160512     C                   IF        %LEN(%TRIMR(HDRSHPCTY)) > 0
290100160330     C                   EVAL      SCAN_FIELD = HDRSHPCTY
290200160330     C                   EXSR      REPLACECHAR
290300160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="3">'  +
290400160330     C                                         %TRIMR(SCAN_FIELD)         +
290500160330     C                                         '</ns2:Line>'
290600160330     C                   EXSR      WRITEXML
290700160512     C                   ENDIF
290800160708
290900160512     C                   IF        %LEN(%TRIMR(HDRSHPSTA)) > 0
291000160330     C                   EVAL      SCAN_FIELD = HDRSHPSTA
291100160330     C                   EXSR      REPLACECHAR
291200160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="4">'  +
291300160330     C                                         %TRIMR(SCAN_FIELD)         +
291400160330     C                                         '</ns2:Line>'
291500160330     C                   EXSR      WRITEXML
291600160512     C                   ENDIF
291700160708
291800160512     C                   IF        %LEN(%TRIMR(HDRSHPZIP)) > 0
291900160330     C                   EVAL      EDIXMLDTL = '<ns2:Line sequence="5">'  +
292000160330     C                                         %TRIMR(HDRSHPZIP)          +
292100160330     C                                         '</ns2:Line>'
292200160330     C                   EXSR      WRITEXML
292300160525     C                   ENDIF
292400160708
292500160330     C                   EVAL      EDIXMLDTL = '</ns2:AddressLine>'
292600160330     C                   EXSR      WRITEXML
292700160512     C                   EVAL      EDIXMLDTL = '<ns2:Country>'     +
292800160512     C                                         %TRIMR(HDRCNTRYCOD) +
292900160330     C                                         '</ns2:Country>'
293000160330     C                   EXSR      WRITEXML
293100160330     C                   EVAL      EDIXMLDTL = '</ns2:PrimaryAddress>'
293200160330     C                   EXSR      WRITEXML
293300160330     C                   EVAL      EDIXMLDTL = '</ns2:Addresses>'
293400160330     C                   EXSR      WRITEXML
293500160330     C                   EVAL      EDIXMLDTL = '<ns2:TotalTax/>'
293600160330     C                   EXSR      WRITEXML
293700160330     C                   EVAL      EDIXMLDTL = '</ns2:SoldToParty>'
293800160330     C                   EXSR      WRITEXML
293900160329     C                   EVAL      EDIXMLDTL = '</ns2:Parties>'
294000160329     C                   EXSR      WRITEXML
294100160601     C                   EVAL      EDIXMLDTL = '<Type>'           +
294200160601     C                                         %TRIMR(HDRINVTYPE) +
294300160601     C                                         '</Type>'
294400160330     C                   EXSR      WRITEXML
294500160513     C                   EVAL      EDIXMLDTL = '<Reason code="'         +
294600160513     C                                         'Variance_Reason">'      +
294700160513     C                                         '</Reason>'
294800160330     C                   EXSR      WRITEXML
294900180816      * @def1: Begin
295000180816     C***                EVAL      EDIXMLDTL = '<CurrenyConversion>'
295100180816     C                   EVAL      EDIXMLDTL = '<CurrencyConversion>'
295200180816      * @def1: End
295300160330     C                   EXSR      WRITEXML
295400160512     C                   EVAL      EDIXMLDTL = '<ns2:Actual currency="'    +
295500160512     C                                         %TRIMR(HDRCURCOD)           +
295600160512     C                                         '">0</ns2:Actual>'
295700160330     C                   EXSR      WRITEXML
295800160512     C                   EVAL      INTAMT = %INT(HDREXCHRATE)
295900160512     C                   EVAL      DECAMT4 = INTAMT / 10000
296000160512     C                   EVAL      INCOUNT = %CHAR(DECAMT4)
296100160525     C                   IF        DECAMT4 < 1
296200160512     C                   EVAL      EDIXMLDTL = '<ns2:Converted currency="' +
296300160512     C                                         %TRIMR(HDRCURCOD)           +
296400160525     C                                         '" conversionFactor="0'     +
296500160512     C                                         %TRIMR(INCOUNT)             +
296600160512     C                                         '"/>'
296700160525     C                   ELSE
296800160525     C                   EVAL      EDIXMLDTL = '<ns2:Converted currency="' +
296900160525     C                                         %TRIMR(HDRCURCOD)           +
297000160525     C                                         '" conversionFactor="'      +
297100160525     C                                         %TRIMR(INCOUNT)             +
297200160525     C                                         '"/>'
297300160525     C                   ENDIF
297400160708
297500160330     C                   EXSR      WRITEXML
297600180209      * @uxh : Begin
297700180209      * Set total tax amount in header to 0 for non upfront
297800180209      *
297900180209     C                   EVAL      CHECKSTATE = HDRSHPSTA + '/'
298000180209     C                   EVAL      SCAN_POS =
298100180209     C                             %SCAN(CHECKSTATE:UPFRONTSTATES:1)
298200180209     C                   IF        SCAN_POS > 0
298300180209     C                   Eval      TAXSTATE = 1
298400180209     C                   ELSE
298500180209     C                   Eval      TAXSTATE = 0
298600180209     C                   ENDIF
298700180209      *
298800180228      * @1622 : Begin
298900180228     C                   Select
299000180303     C                   WHEN      HDRCNTRYCOD = 'US' and TAXSTATE = 0
299100180209     C                             and  HDRTAXES <> '0000000000'
299200180209     C                   Eval      DECAMT = *Zero
299300180228      *
299400180303     C                   WHEN      HDRCNTRYCOD  = 'CA' and IBMIND ='N'
299500180228     C                             and  HDRTAXES <> '0000000000'
299600180228     C                   Eval      DECAMT = *Zero
299700180228     C                   Other
299800180228      *
299900160610     C                   EVAL      INTAMT = %INT(HDRTAXES)
300000160610     C                   EVAL      DECAMT = INTAMT / 100
300100180228      *
300200180228     C                   Endsl
300300180228      * @1622: End
300400160512     C                   EVAL      INCOUNT = %CHAR(DECAMT)
300500180816      * @def1: Begin
300600180816     C***                EVAL      EDIXMLDTL = '</CurrenyConversion>'
300700180816     C                   EVAL      EDIXMLDTL = '</CurrencyConversion>'
300800180816      * @def1: End
300900160330     C                   EXSR      WRITEXML
301000160524     C                   IF        DECAMT < 1
301100160512     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
301200160512     C                                         %TRIMR(HDRCURCOD)           +
301300160524     C                                         '" basis="TotalTax">0'      +
301400160512     C                                         %TRIMR(INCOUNT)             +
301500160512     C                                         '</TotalTax>'
301600160524     C                   ELSE
301700160524     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
301800160524     C                                         %TRIMR(HDRCURCOD)           +
301900160524     C                                         '" basis="TotalTax">'       +
302000160524     C                                         %TRIMR(INCOUNT)             +
302100160524     C                                         '</TotalTax>'
302200160524     C                   ENDIF
302300160708
302400160330     C                   EXSR      WRITEXML
302500160512     C                   EVAL      EDIXMLDTL = '<TotalTax currency="'      +
302600160512     C                                         %TRIMR(HDRCURCOD)           +
302700160512     C                                         '" basis="AvailableTax"/>'
302800160330     C                   EXSR      WRITEXML
302900160330     C                   EVAL      EDIXMLDTL = '<InterfaceData>'
303000160330     C                   EXSR      WRITEXML
303100160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
303200160512     C                                         'SourceIndc">'             +
303300160512     C                                         %TRIMR(%SUBST(CNTSNDIND:1:3))+
303400160330     C                                         '</InterfaceProperty>'
303500160330     C                   EXSR      WRITEXML
303600160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
303700160602     C                                         'CPS NUMBER">'              +
303800160602     C                                         %TRIMR(HDCPSNUM)            +
303900160602     C                                         '</InterfaceProperty>'
304000160330     C                   EXSR      WRITEXML
304100160330     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
304200160512     C                                         'AutoCreateCoaIndc">N'      +
304300160330     C                                         '</InterfaceProperty>'
304400160330     C                   EXSR      WRITEXML
304500171220      * @1622: Begin
304600171220     C                   EVAL      EDIXMLDTL = '<InterfaceProperty name="' +
304700171220     C                                         'ProvinceCode">'            +
304800171220     C                                         %TRIMR(wPROVINCE)           +
304900171220     C                                         '</InterfaceProperty>'
305000171220     C                   EXSR      WRITEXML
305100171220      * @1622: End
305200160330     C                   EVAL      EDIXMLDTL = '</InterfaceData>'
305300160330     C                   EXSR      WRITEXML
305400160325     C                   EVAL      EDIXMLDTL = '</Header>'
305500160325     C                   EXSR      WRITEXML
305600180917      * @1685 : Begin
305700180917     C                   IF        INVOICEVALID (INVOICENDX) = '0'
305800180917     C                   EVAL      BUFFER1= %TRIMR(BUFFER1) + %TRIMR(Wrkxmldtl1)
305900180917     C                   ENDIF
306000180917      * @1685 : End
306100160322     C                   ENDSR
306200171212      *******************************************************************
306300171212     ?* COMMENT
306400171212      *******************************************************************
306500160322      *
306600160322     C     XMLCOMMENT    BEGSR
306700160329     C                   EVAL      DSCOMMENT = EDIRCD7S
306800160322     C                   ENDSR
306900160322      *
307000171212      *******************************************************************
307100171212     ?* DETAIL
307200171212      *******************************************************************
307300160322      *
307400171212     C     XMLDETAIL     BEGSR
307500190128      * @1712 : Begin
307600190128      * Do not create XML for invalid invoices
307700190130     C                   IF        INVOICEVALID (INVOICENDX) = '1'
307800190130     C                   LEAVESR
307900190130     C                   ENDIF
308000190128      * @1712 : End
308100171206      * Set values for all variables
308200171206     C                   EVAL      WrkXmlDtl1= *Blanks
308300171206     C                   EVAL      WrkXmlDtl2= *Blanks
308400171206     C                   EVAL      WrkXmlDtl3= *Blanks
308500171206     C                   EVAL      DSDETAIL = EDIRCD7S
308600171206     C                   EVAL      DTLTAXCODE = E7SVATCOD
308700171206     C                   EVAL      XMLDTLLINE = XMLDTLLINE + 1
308800171206     C                   EVAL      XMLDTLCOUNT = %EDITC(E7SKEY3:'X')
308900171206     C                   EVAL      XMLDTLSEQ = %DEC(E7SKEY2:6:0)
309000171206     C                   EVAL      XMLDTLCOUNT1= %EDITC(XMLDTLSEQ:'X')
309100180309      * @1607g : Begin
309200180309     C                   EVAL      SCAN_FIELD = DETPARTNUM
309300180309     C                   EXSR      REPLACECHAR
309400180309     C                   EVAL      SCAN_FIELD1= SCAN_FIELD
309500180309      * @1607g : End
309600171206     C                   EVAL      SCAN_FIELD = DETPRTDSC
309700171206     C                   EXSR      REPLACECHAR
309800171206      *
309900171212     ?* Set  WrkXmlDtl1
310000171206     C                   EVAL      WrkXmlDtl1= '<Line>' +
310100171206     C                                         '<LineNumber>'             +
310200171206     C                                         %SUBST(XMLDTLCOUNT:2:6)    +
310300171206     C                                         '</LineNumber>'            +
310400171206     C                                         '<LineSeq>'                +
310500171206     C                                         %SUBST(XMLDTLCOUNT1:2:6)   +
310600171206     C                                         '</LineSeq>'               +
310700171206     C                                         '<OrderItem>'              +
310800171206     C                                         '<ns2:ItemIds>'            +
310900171206     C                                         '<ns2:ItemId>'             +
311000171206     C                                        '<ns2:Id IdOrigin="Vendor">'+
311100180309     C                                         %TRIMR(SCAN_FIELD1)        +
311200171206     C                                         '</ns2:Id>'                +
311300171206     C                                         '<ns2:Id IdOrigin='        +
311400171206     C                                         '"IBM/MachineType">'       +
311500171206     C                                         %TRIMR(DETMCHTYP)          +
311600171206     C                                         '</ns2:Id>'                +
311700171206     C                                         '<ns2:Id IdOrigin='        +
311800171206     C                                         '"IBM/Model">'             +
311900171206     C                                         %TRIMR(DETMCHMOD)          +
312000171206     C                                         '</ns2:Id>'                +
312100171206     C                                         '</ns2:ItemId>'            +
312200171206     C                                         '</ns2:ItemIds>'           +
312300171206     C                                         '<ItemCategoryId '         +
312400171206     C                                         'type="ItemType">'         +
312500171206     C                                         %TRIMR(E7SKEY5)            +
312600171206     C                                         '</ItemCategoryId>'        +
312700171206     C                                         '<ItemCategoryId '         +
312800171206     C                                         'type="ProductCategory">'  +
312900171206     C                                         %TRIMR(' ')                +
313000171206     C                                         '</ItemCategoryId>'        +
313100171206     C                                         '<ItemCategoryId '         +
313200171206     C                                         'type="ProductClass">'     +
313300171206     C                                         %TRIMR(' ')                +
313400171206     C                                         '</ItemCategoryId>'        +
313500171206     C                                         '<Description>'            +
313600171206     C                                         %TRIMR(SCAN_FIELD)         +
313700171206     C                                         '</Description>'
313800171212     ?* End  WrkXmlDtl1
313900171206     C                   READ      EDIPF7A                                90
314000171206     C                   IF        %SUBST(EDIRCD7S:1:10) <> RECTYPE6
314100171206     C                   CLEAR                   DSSERIAL
314200171206     C                   READP     EDIPF7A
314300171206     C                   ELSE
314400171206     C                   EVAL      DSSERIAL  = EDIRCD7S
314500171206     C                   ENDIF
314600171206      * UpgradeorMES
314700171206     C                   IF        %LEN(%TRIMR(DETMES)) > 0
314800171206     C                   EVAL      DETMES = 'MES'
314900171206     C                   ELSE
315000171206     C                   EVAL      DETMES = 'Upgrade'
315100171206     C                   ENDIF
315200171206      * Equipment source
315300171206     C                   IF        %LEN(%TRIMR(DETEQSRC)) = 0
315400171206     C                   IF        %LEN(%TRIMR(HDRINVTYPE)) > 0
315500171206     C                   IF        HDRINVTYPE = 'IBM'
315600171206     C                   EVAL      DETEQSRC = 'IB'
315700171206     C                   ELSE
315800171206     C                   IF        HDRINVTYPE = 'VEN'
315900171206     C                   EVAL      DETEQSRC = 'BP'
316000171206     C                   ELSE
316100171206     C                   EVAL      DETEQSRC = '  '
316200171206     C                   ENDIF
316300171206     C                   ENDIF
316400171206     C                   ENDIF
316500171206     C                   ENDIF
316600171206
316700180218      * @1607C : Begin
316800180218     C***                IF        DETMCHTYP = '9OT9'
316900180218     C***                EVAL      DETEQSRC = '  '
317000180218     C***                EVAL      DTLTAXCODE = '  '
317100180218     C***                ENDIF
317200171206
317300180218     C***                IF        DETMCHTYP = '9TX8'
317400180218     C***                EVAL      DETEQSRC = '  '
317500180218     C***                EVAL      DTLTAXCODE = 'I2'
317600180218     C***                ENDIF
317700180218      * @1607C : End
317800171206
317900180222      * @1607d : Begin
318000180222     C***                EVAL      INCOUNTU= %CHAR(DETUNTPRC)
318100180222     C                   EVAL      INCOUNTU= %CHAR(DETUNTPRC * DETQTY)
318200180222      * @1607d : End
318300171206
318400171206     C                   IF        DETUNTPRC < 1
318500171206     C                   EVAL      EDIXMLDTLU= '<ns2:Amount currency="'    +
318600171206     C                                         HDRCURCOD                   +
318700171206     C                                         '" basis="ListPrice">0'     +
318800171206     C                                         %TRIMR(INCOUNTU)            +
318900171206     C                                         '</ns2:Amount>'
319000171206     C                   ELSE
319100171206     C                   EVAL      EDIXMLDTLU= '<ns2:Amount currency="'    +
319200171206     C                                         HDRCURCOD                   +
319300171206     C                                         '" basis="ListPrice">'      +
319400171206     C                                         %TRIMR(INCOUNTU)            +
319500171206     C                                         '</ns2:Amount>'
319600171206     C                   ENDIF
319700171206
319800171206     C                   IF        %LEN(%TRIMR(DETITMDSC)) = 0
319900171206     C                   EVAL      DETITMDSC = '0000000000'
320000171206     C                   ENDIF
320100171206
320200171206     C                   IF        %LEN(%TRIMR(DETLINTAX)) = 0
320300171206     C                   EVAL      DETLINTAX = '0000000000'
320400171206     C                   ENDIF
320500171206
320600171206     C                   EVAL      INTAMT = %INT(DETITMDSC)
320700171206     C                   EVAL      DECAMT = INTAMT / 100
320800171206     C                   EVAL      INCOUNT = %CHAR(DECAMT)
320900171206
321000171206     C                   IF        DECAMT < 1
321100171206     C                   EVAL      EDIXMLDTL = '<ns2:Amount currency="'    +
321200171206     C                                         HDRCURCOD                   +
321300171206     C                                         '" basis="DiscountAmount">0'+
321400171206     C                                         %TRIMR(INCOUNT)             +
321500171206     C                                         '</ns2:Amount>'
321600171206     C                   ELSE
321700171206     C                   EVAL      EDIXMLDTL = '<ns2:Amount currency="'    +
321800171206     C                                         HDRCURCOD                   +
321900171206     C                                         '" basis="DiscountAmount">' +
322000171206     C                                         %TRIMR(INCOUNT)             +
322100171206     C                                         '</ns2:Amount>'
322200171206     C                   ENDIF
322300171206
322400171206     C                   TIME                    TIMSTP
322500171206     C                   EVAL      HOLDTIME = %EDITC(TIMSTP:'X')
322600171206
322700171212     ?* Set WrkXmlDtl2
322800171206     C                   EVAL      WrkXmlDtl2= '<AssetId>'  +
322900171206     C                                         '<SerialNumber>'            +
323000171206     C                                         %TRIMR(SERSERNO)            +
323100171206     C                                         '</SerialNumber>'           +
323200171206     C                                         '<Id IdOrigin="Supplier">'  +
323300171206     C                                         %TRIMR(' ')                 +
323400171206     C                                         '</Id>'                     +
323500171206     C                                         '</AssetId>'                +
323600171206     C                                         '<UpgradeOrMES>'            +
323700171206     C                                         %TRIMR(DETMES)              +
323800171206     C                                         '</UpgradeOrMES>'           +
323900171206     C                                         '<EquipmentSource>'         +
324000171206     C                                         %TRIMR(DETEQSRC)            +
324100171206     C                                         '</EquipmentSource>'        +
324200171206     C                                         '</OrderItem>'              +
324300171206     C                                         '<UnitPrice>'               +
324400171206     C                                         %TRIMR(EDIXMLDTLU)          +
324500171206     C                                         '<ns2:PerQuantity uom="">'  +
324600171206     C                                         '1'                         +
324700171206     C                                         '</ns2:PerQuantity>'        +
324800171206     C                                         '</UnitPrice>'              +
324900171206     C                                         '<UnitPrice>'               +
325000171206     C                                         %TRIMR(EDIXMLDTL)           +
325100171206     C                                         '<ns2:PerQuantity uom="">'  +
325200171206     C                                         '1'                         +
325300171206     C                                         '</ns2:PerQuantity>'        +
325400171206     C                                         '</UnitPrice>'              +
325500171206      *
325600171206     C                                         '<ns2:OrderStatus>'         +
325700171206     C                                         '<ns2:AcknowledgementDetail>'+
325800171206     C                                         '<ns2:Change>'              +
325900171206     C                                         '<ns2:ChangeDate>'          +
326000171206     C                                         %CHAR(SYS_DATE) + 'T'       +
326100171206     C                                         %SUBST(HOLDTIME:1:2) + ':'  +
326200171206     C                                         %SUBST(HOLDTIME:3:2) + ':'  +
326300171206     C                                         %SUBST(HOLDTIME:5:2)        +
326400171206     C                                         '.000-04:00'                +
326500171206     C                                         '</ns2:ChangeDate>'         +
326600171206     C                                         '</ns2:Change>'             +
326700171206     C                                         '</ns2:AcknowledgementDetail>' +
326800171206     C                                         '</ns2:OrderStatus>'
326900171212     ?* End WrkXmlDtl2
327000171206      *
327100180710      * @1622a: Begin
327200180710     C                   Eval      DECAMT = *Zero
327300180710      * @1622a: End
327400171206     C                   EVAL      INTAMT = %INT(DETLINTAX)
327500180209      * @UXH : Begin
327600180209     C***                IF        INVOICETAX(INVOICENDX) = '1'
327700180209     C                   IF        INTAMT > 0
327800180209      * @UXH : End
327900171206     C                   Select
328000180305     C                   WHEN      TAXSTATE = 1  or IBMIND ='Y'
328100180926      * @1687 : Begin
328200180924     C***                EVAL(H)   DECAMT  = INTAMT / 10000
328300180924     C                   EVAL(H)   DECAMT  = INTAMT / 100
328400180926      * @1687 : End
328500171206     C                   Other
328600171206     C                   EVAL(H)   DECAMT  = INTAMT / 100
328700171206     C                   Endsl
328800180209      * @UXH : Begin
328900180209     C                   Endif
329000180209      * @UXH : End
329100171212      *
329200180218      * For non-upfront state, Set total tax amount in header to 0
329300180303     C                   If        HDRCNTRYCOD = 'US' and TAXSTATE = 0
329400180209     C                             and  HDRTAXES <> '0000000000'
329500180209     C                   Eval      DECAMT = *Zero
329600180423      * @1652 : Begin
329700180423     C**                 Eval      DTLTAXCODE = 'I0'
329800180423     C                   Eval      DTLTAXCODE = 'U1'
329900180423      * @1652 : End
330000180209     C                   Endif
330100180228      * @1622 : Begin
330200180228      * For Canada, Set total tax amount in header to 0
330300180303     C                   If        HDRCNTRYCOD = 'CA' and IBMIND ='N'
330400180228     C                             and  HDRTAXES <> '0000000000'
330500180228     C                   Eval      DECAMT = *Zero
330600180228     C                   Endif
330700180228      *
330800180314      * @1607c : Begin
330900180314      * For US upfront state with tax, Set tax code to I0 for zero tax line
331000180314     C                   If        HDRCNTRYCOD = 'US' and TAXSTATE = 1
331100180314     C                             and  HDRTAXES <> '0000000000'
331200180314     C                             and  DETLINTAX = '0000000000'
331300180423      * @1652 : Begin
331400180423     C**                 Eval      DTLTAXCODE = 'I0'
331500180423     C                   Eval      DTLTAXCODE = 'U1'
331600180423      * @1652 : End
331700180314     C                   Endif
331800180314      * @1607c : End
331900180314      *
332000180303     C                   If        HDRCNTRYCOD  = 'CA'
332100180303     C                   Exsr      Upd_TaxCode
332200180228     C                   Endif
332300180228      * @1622 : End
332400180209      * @uxh : End
332500171206     C                   EVAL      INCOUNT = %CHAR(DECAMT)
332600171206     C                   IF        DECAMT  < 1
332700171212      *
332800171206     C                   EVAL      EDIXMLDTL = '<ns2:TaxAmount '        +
332900171206     C                                         'currency="'             +
333000171206     C                                         HDRCURCOD                +
333100171206     C                                         '" basis="unit_tax">0'   +
333200171206     C                                         %TRIMR(INCOUNT)          +
333300171206     C                                         '</ns2:TaxAmount>'
333400171206     C                   ELSE
333500171206     C                   EVAL      EDIXMLDTL = '<ns2:TaxAmount '        +
333600171206     C                                         'currency="'             +
333700171206     C                                         HDRCURCOD                +
333800171206     C                                         '" basis="unit_tax">'    +
333900171206     C                                         %TRIMR(INCOUNT)          +
334000171206     C                                         '</ns2:TaxAmount>'
334100171206     C                   ENDIF
334200171206
334300171206     C                   IF        DETMCHTYP = '9OT9'
334400171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
334500171206     C                                         '</ns2:Id>'
334600171206     C                   ELSE
334700171206     C                   IF        DETMCHTYP = '9TX8'
334800171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
334900171206     C                                         '</ns2:Id>'
335000171206     C                   ELSE
335100171206     C                   EVAL      EDIXMLDTLU= '<ns2:Id IdOrigin="Supplier">' +
335200171206     C                                         %TRIMR(HDRPONUM)               +
335300171206     C                                         '</ns2:Id>'
335400171206     C                   ENDIF
335500171206     C                   ENDIF
335600171206     C                   EVAL      INCOUNTU= %CHAR(DETQTY)
335700171206
335800171206      *
335900171212     ?* Set WrkXmlDtl3
336000171206     C                   EVAL      WrkXmlDtl3  =
336100171206     C                                         '<ns2:Tax>'              +
336200171206     C                                         %TRIMR(EDIXMLDTL)        +
336300171206     C                                         '<ns2:TaxCode>'          +
336400171206     C                                         %TRIMR(DTLTAXCODE)       +
336500171206     C                                         '</ns2:TaxCode>'         +
336600171206     C                                         '</ns2:Tax>'             +
336700171206     C                                         '<ns2:DocumentReferences>'  +
336800171206     C                                         '<ns2:InvoiceDocumentReference>'+
336900171206     C                                         '<ns2:Status>'             +
337000171206     C                                         '<ns2:Code>'               +
337100171206     C                                         'false'                    +
337200171206     C                                         '</ns2:Code>'              +
337300171206     C                                         '</ns2:Status>'            +
337400171206     C                                  '</ns2:InvoiceDocumentReference>' +
337500171206     C                             '<ns2:PurchaseOrderDocumentReference>' +
337600171206     C                                         '<ns2:DocumentIds>'        +
337700171206     C                                         '<ns2:SupplierDocumentId>' +
337800171206     C                                         %TRIMR(EDIXMLDTLU)         +
337900171206     C                                         '</ns2:SupplierDocumentId>'+
338000171206     C                                         '<ns2:SupplierDocumentId>' +
338100171206     C                                         '<ns2:Id IdOrigin="IBM/MES">'  +
338200180626      * @1672 : Begin
338300180626     C***                                      %TRIMR(' ')                    +
338400180626     C                                         %TRIMR(SERASSTAG)              +
338500180626      * @1672 : End
338600171206     C                                         '</ns2:Id>'                +
338700171206     C                                         '</ns2:SupplierDocumentId>'+
338800171206     C                                         '</ns2:DocumentIds>'       +
338900171206     C                                         '</ns2:PurchaseOrder' +
339000171206     C                                         'DocumentReference>'  +
339100171206     C                                         '</ns2:DocumentReferences>' +
339200171206     C                                         '<ns2:PartyId>'             +
339300171206     C                                         '<ns2:Id/>'                 +
339400171206     C                                         '</ns2:PartyId>'            +
339500171206     C                                         '<ItemQuantity uom="">'+
339600171206     C                                         %TRIMR(INCOUNTU)        +
339700171206     C                                         '</ItemQuantity>'       +
339800171206     C                                         '<LeaseTerms>'          +
339900171206     C                                         '<PeriodTime/>'         +
340000171206     C                                         '</LeaseTerms>'         +
340100171206     C                                         '</Line>'
340200171212     ?* End WrkXmlDtl3
340300171206      *
340400171206     C                   IF        INVOICEVALID (INVOICENDX) = '0'
340500171206     C                   EVAL      BUFFER1 = %Trimr(BUFFER1)      +
340600171206     C                                       %Trimr(WrkXmlDtl1)   +
340700171206     C                                       %Trimr(WrkXmlDtl2)   +
340800171206     C                                       %Trimr(WrkXmlDtl3)
340900171206     C                   ENDIF
341000171206      *
341100171206     C                   ENDSR
341200171212      **********************************************************
341300171212     ?* Serial
341400171212      **********************************************************
341500160322      *
341600160322     C     XMLSERIALNO   BEGSR
341700160329     C                   EVAL      DSSERIAL  = EDIRCD7S
341800160322     C                   ENDSR
341900171212      **********************************************************
342000171212     ?* FEATURE
342100171212      *********************************************************
342200160322      *
342300160322     C     XMLFEATURE    BEGSR
342400160329     C                   EVAL      DSFEATURE = EDIRCD7S
342500160322     C                   ENDSR
342600160322      *
342700171212      *********************************************************
342800171212     ?* TRAILER
342900171212      *********************************************************
343000160322      *
343100160322     C     XMLTRAILER    BEGSR
343200160329     C                   EVAL      DSTRAILER = EDIRCD7S
343300160322     C                   ENDSR
343400160322      *
343500171212      *********************************************************
343600171212     ?* FILE TRAILER
343700171212      *********************************************************
343800160322      *
343900160322     C     XMLFILETRL    BEGSR
344000160329     C                   EVAL      DSFILETRL = EDIRCD7S
344100160322     C                   ENDSR
344200171212      *
344300171212      *********************************************************
344400171212     ?* Write error messages
344500171212      *********************************************************
344600160316      *
344700160316     C     WRITEPF5      BEGSR
344800160707     C                   EVAL      E5MBRNAM = PRMMBRNAME
344900160316     C                   EVAL      E5RUNDATE = SYS_DATE
345000160316     C                   EVAL      E5RUNTIME = SYS_TIME
345100161227     C                   EVAL      E5COUNTRY = HDRCNTRYCOD
345200160708
345300160316     C                   IF        HEADERIND = 1
345400160316     C                   EVAL      E5SNDIND = CNTSNDIND
345500160316     C                   EVAL      E5CTRNUM = CNTCTRNUM
345600160316     C                   EVAL      E5INVNO = HDRINVNO
345700160316     C                   ELSE
345800160316     C                   EVAL      E5SNDIND = *BLANKS
345900160316     C                   EVAL      E5CTRNUM = *BLANKS
346000160316     C                   EVAL      E5INVNO = *BLANKS
346100160316     C                   ENDIF
346200160708
346300160316     C                   EVAL      E5INVTYP = *BLANKS
346400160316     C                   EVAL      E5MSGID = *BLANKS
346500160316     C                   WRITE     EDIPF5R
346600160316     C                   ENDSR
346700160325      *
346800171212      *********************************************************
346900171212     ?* Write XML
347000171212      *********************************************************
347100160325      *
347200160325     C     WRITEXML      BEGSR
347300180917      * @1685 : Begin
347400180917      * Load wrkxmldtl1  for XMLHEADER
347500180917     C                   Select
347600180917     C                   When      RECTYPE = RECTYPE3
347700180917     C                   IF        INVOICEVALID (INVOICENDX) = '0'
347800180917     C                   EVAL      WrkXmlDtl1 = %TRIMR(WrkXmlDtl1) +
347900180917     C                                           %TRIMR(EDIXMLDTL)
348000180917     C                   ENDIF
348100180917     C                   Other
348200180917      * @1685 : End
348300160606     C                   IF        INVOICEVALID (INVOICENDX) = '0'
348400171206     C                   EVAL      BUFFER1= %TRIMR(BUFFER1) + %TRIMR(EDIXMLDTL)
348500160606     C                   ENDIF
348600180917      * @1685 : Begin
348700180917     C                   ENDSL
348800180917      * @1685 : End
348900160325     C                   ENDSR
349000160627      *
349100180302      *********************************************************
349200180302     ?* TOLRANCE CHECK - CANADA
349300180302      *********************************************************
349400180302     C     CATOLSR       BEGSR
349500180302      *
349600180303     C                   EVAL      Vld_Tax_Tol     ='N'
349700180303     C                   Exsr      Get_TaxCode
349800180303      * Calculated tax amt based on province TAX%
349900180303     C                   EVAL      TAXAMT= %DECH((
350000180303     C                                  (%INT(HDRTOTAMT)-  %INT(HDRTAXES))
350100180303     C                                      *  @@MQTAXPCT)/100:10:2)
350200180303      * Check if tax amount within tolerance or not
350300180303     C                   IF        %INT(HDRTAXES)/100 <= (TAXAMT+HldVatVar)
350400180303     C                             and  %INT(HDRTAXES)/100 >= (TAXAMT-HldVatVar)
350500180303     C                   EVAL      Vld_Tax_Tol     ='Y'
350600180303     C                   ENDIF
350700180303     C
350800180303     C                   IF        Vld_Tax_Tol ='N'
350900180302     C                   EVAL      HEADERIND = 1
351000180417     C                   EVAL      E5MSGVAR = 'Warning: ' + Errnote2 +
351100180417     C                             'for invoice number: '  +
351200180302     C                             %TRIMR(HDRINVNO)
351300180302     C                   EXSR      WRITEPF5
351400180411      * @1647 : Begin
351500180411     C                   EVAL      WErrNote = ErrNote2
351600180411     C                   EXSR      CrtCFEXML
351700180411      * @1647 : End
351800180302     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
351900180302      * @UXH : Begin
352000180302     C                   EVAL      HOLDMISCCHG = '0000000000'
352100180302     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
352200180302     C                   EVAL      HOLDTAXES      = '0000000000'
352300180303     C                   ENDIF
352400180303      *
352500180302     C                   ENDSR
352600171212      *********************************************************
352700171212     ?* Create XML for CTS
352800171212      *********************************************************
352900170621     C     CTSXMLSR      BEGSR
353000171212      *
353100160825     C                   CLEAR                   BUFFCTS
353200171212     C                   EVAL      WrkCTSXML1 = *Blanks
353300171212     C                   EVAL      WrkCTSXML2 = *Blanks
353400171212     C                   EVAL      WrkCTSXML3 = *Blanks
353500171212     ?* Set  wrkCTSXML1
353600171212     C                   EVAL      wrkCTSXML1 = '<soapenv:Envelope '          +
353700160627     C                                         'xmlns:soapenv'                +
353800160627     C                                         '="http://schemas.xmlsoap.org' +
353900171212     C                                         '/soap/envelope/">'            +
354000171212      *
354100171212     C                                         '<soapenv:Body>'               +
354200171212      *
354300171212     C                                         '<ns7:GetTaxserviceRequest'    +
354400171212     C                                         ' xmlns:ns12='                 +
354500171212     C                                         '"http://w3.ibm.com/xmlns/igf' +
354600171212     C                                         '/gcps/cts/upfront"'           +
354700160627     C                                         ' xmlns:ns11='                 +
354800160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
354900160627     C                                         '/gcps/cts/taxAmount/response"'+
355000160627     C                                         ' xmlns:ns10='                 +
355100160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
355200160627     C                                         '/gcps/cts/taxAmount/request"' +
355300160627     C                                         ' xmlns:ns9='                  +
355400160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
355500160627     C                                         '/gcps/cts/qmc"'               +
355600160627     C                                         ' xmlns:ns8='                  +
355700160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
355800160627     C                                         '/gcps/cts/taxes/response"'    +
355900160627     C                                         ' xmlns:ns7='                  +
356000160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
356100160627     C                                         '/gcps/cts/taxes/request"'     +
356200160627     C                                         ' xmlns:ns6='                  +
356300160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
356400160627     C                                         '/gcps/cts/custinfo"'          +
356500160627     C                                         ' xmlns:ns5='                  +
356600160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
356700160627     C                                         '/gcps/cts/commonTypes"'       +
356800160627     C                                         ' xmlns:ns4='                  +
356900160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
357000160627     C                                         '/gcps/common/faults"'         +
357100160627     C                                         ' xmlns:ns3='                  +
357200160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
357300160627     C                                         '/gcps/common/errors"'         +
357400160627     C                                         ' xmlns:ns2='                  +
357500160627     C                                         '"http://w3.ibm.com/xmlns/igf' +
357600171212     C                                         '/gcps/common/addressing">'    +
357700171212      *
357800171212     C                                         '<CommonTaxHeader>'            +
357900171212      *
358000171212     C                                         '<ApplicationName>GAPTS'       +
358100171212     C                                         '</ApplicationName>'           +
358200171212      *
358300171212     C                                         '<ApplicationId>GAPTS'         +
358400171212     C                                         '</ApplicationId>'             +
358500171212      *
358600171212     C                                         '<ClientLoggingId>GAPTS'       +
358700171212     C                                         '</ClientLoggingId>'           +
358800171212      *
358900171212     C                                         '<CtsRequestId>GAPTS'          +
359000171212     C                                         '</CtsRequestId>'              +
359100171212      *
359200171212     C                                         '</CommonTaxHeader>'           +
359300171212      *
359400171212     C                                         '<Contract>'                   +
359500171212      *
359600171212     C                                         '<CountryCode>896'  +
359700171212     C                                         '</CountryCode>'     +
359800171212      *
359900171212     C                                         '<SubsidairyCode>01'   +
360000171212     C                                         '</SubsidairyCode>'    +
360100171212      *
360200171212     C                                         '<CurrencyCode>USD'   +
360300171212     C                                         '</CurrencyCode>'     +
360400171212      *
360500171212     C                                         '<ContractNumber>'   +
360600171212     C                                         %TRIMR(HDRINVNO)     +
360700171212     C                                         '</ContractNumber>'  +
360800171212      *
360900171212     C                                         '<ContractDate>'   +
361000160819     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
361100160819     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
361200160819     C                                         %SUBST(HDRINVDAT:7:2)       +
361300160819     C                                         '-04:00'                    +
361400171212     C                                         '</ContractDate>'       +
361500171212      *
361600171212     C                                         '<Line ID="1">'         +
361700171212      *
361800171212     C                                         '<ContractLineNumber>0'   +
361900171212     C                                         '</ContractLineNumber>'   +
362000171212      *
362100171212     C                                         '<Financed>Y'             +
362200171212     C                                         '</Financed>'             +
362300171212      *
362400171212     C                                         '<TransactionType>NLSE'   +
362500171212     C                                         '</TransactionType>'      +
362600171212      *
362700171212     C                                         '<FinanceType>FMV'       +
362800171212     C                                         '</FinanceType>'         +
362900171212      *
363000171212     C                                         '<OriginalFinanceType>FMV' +
363100171212     C                                         '</OriginalFinanceType>'   +
363200171212      *
363300171212     C                                         '<UpfrontIndicator>N' +
363400171212     C                                         '</UpfrontIndicator>'   +
363500171212      *
363600171212     C                                         '<InvoiceLineNumber>1' +
363700171212     C                                         '</InvoiceLineNumber>' +
363800171212      *
363900171212     C                                         '<InvoiceDate>'   +
364000160627     C                                         %SUBST(HDRINVDAT:1:4) + '-' +
364100160627     C                                         %SUBST(HDRINVDAT:5:2) + '-' +
364200160627     C                                         %SUBST(HDRINVDAT:7:2)       +
364300160627     C                                         '-04:00'                    +
364400171212     C                                         '</InvoiceDate>'            +
364500171212      *
364600171212     C                                         '<Quantity>1' +
364700171212     C                                         '</Quantity>'
364800171212     ?* End  wrkCTSXML1
364900171212      ****
365000180226      * as per Java code , need to subtract freight as well
365100160627     C                   EVAL      INTAMT = %INT(HDRTOTAMT)-
365200160627     C                                      %INT(HDRMISCCHARG)-
365300180226     C                                      %INT(HDRFREIGHTCHARG) -
365400160627     C                                      %INT(HDRTAXES)
365500160627     C                   EVAL      DECAMT = INTAMT / 100
365600160627     C                   EVAL      INCOUNT = %CHAR(DECAMT)
365700160708
365800160627     C                   IF        DECAMT < 1
365900160627     C                   EVAL      CTSXMLDTL = '<NetPurchasePrice>0'     +
366000160627     C                                         %TRIMR(INCOUNT)           +
366100160627     C                                         '</NetPurchasePrice>'
366200160627     C                   ELSE
366300160627     C                   EVAL      CTSXMLDTL = '<NetPurchasePrice>'      +
366400160627     C                                         %TRIMR(INCOUNT)           +
366500160627     C                                         '</NetPurchasePrice>'
366600160627     C                   ENDIF
366700171212     ?* Set  wrkCTSXML2
366800171212     C                   EVAL      wrkCTSXML2 = %TRIMR(CTSXMLDTL) +
366900160824
367000171212     C                                         '<SumOfPayments>0'        +
367100160627     C                                         '</SumOfPayments>'
367200171212     ?* End  wrkCTSXML2
367300171212      *
367400160627     C                   EVAL      INTAMT = %INT(HDRTAXES)
367500160627     C                   EVAL      DECAMT = INTAMT / 100
367600160627     C                   EVAL      INCOUNT = %CHAR(DECAMT)
367700160708
367800160627     C                   IF        DECAMT < 1
367900160627     C                   EVAL      CTSXMLDTL = '<TaxesPaid>0'            +
368000160627     C                                         %TRIMR(INCOUNT)           +
368100160627     C                                         '</TaxesPaid>'
368200160627     C                   ELSE
368300160627     C                   EVAL      CTSXMLDTL = '<TaxesPaid>'             +
368400160627     C                                         %TRIMR(INCOUNT)           +
368500160627     C                                         '</TaxesPaid>'
368600160627     C                   ENDIF
368700171212     ?* Set  wrkCTSXML3
368800171212     C                   EVAL      wrkCTSXML3 = %TRIMR(CTSXMLDTL) +
368900171212      *
369000171212     C                                         '<GenericMaterialCode>'   +
369100160627     C                                         '74E 16'        +
369200171212     C                                         '</GenericMaterialCode>'  +
369300171212      *
369400171212     C                                         '<ShipTo>'                +
369500171212      *
369600171212     C                                         '<CountryAbbreviation>'   +
369700160627     C                                         'US'        +
369800171212     C                                         '</CountryAbbreviation>'  +
369900171212      *
370000171212     C                                         '<StateCode>'       +
370100160627     C                                         %TRIMR(HDRSHPSTA)   +
370200171212     C                                         '</StateCode>'      +
370300171212      *
370400171212     C                                         '</ShipTo>'         +
370500171212      *
370600171212     C                                         '</Line>'           +
370700171212      *
370800171212     C                                         '</Contract>'        +
370900171212      *
371000171212     C                                         '</ns7:GetTaxserviceRequest>' +
371100171212      *
371200171212     C                                         '</soapenv:Body>'   +
371300171212      *
371400171212     C                                         '</soapenv:Envelope>'
371500171212     ?* End wrkCTSXML3
371600171212      *
371700171212     C                   EXSR      CTSWRITE
371800171212       /free
371900171212     ?* Clear old XML Input - CTS
372000171212            fd  = open(%trim($file_path1)
372100171212                       : O_WRONLY+O_CREAT+O_TRUNC
372200171212                       : S_IRGRP + S_IWGRP + S_IXGRP +
372300180308                          S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
372400171212                       : 819);
372500171212
372600171212            callp close(fd);
372700171212     ?* Compose new XML  -  CTS
372800171212            fd = open(%trim($file_path1)
372900190501                      :O_WRONLY+O_TEXTDATA+O_CCSID
373000190501                      :S_IRGRP: 37);
373100171212     ?* Write CTSXML buffer into IFS
373200171212            callp write(fd:%addr(buffcts): %len(%trim(buffcts)));
373300171212            callp close(fd);
373400171212     ?* Create CTSXML history
373500171212            // Append date,timestamp for every file to be unique
373600171212            WWTIME    = %TIME();
373700171212            $new_file = 'CTSXMLIN'+ %char(WWDATE) + %char(WWTIME);
373800171212            cmd = 'CPY OBJ(''' + %trim($file_path1) + ''') +
373900171212                 TOOBJ(''' + %trim($file_dir1)+ %trim($new_file)+ ''')';
374000180227            callp(e) QCMDEXC(cmd: %len(cmd));
374100180227       /end-free
374200171212
374300180227      * Log error if copy object CTSXMLIN failed
374400180227     C                   IF        %ERROR
374500180227     C                   CLEAR                   ERRORDS
374600180227     C                   EVAL      PROGRAMNAME = PGMNAME
374700180227     C                   EVAL      MSGID       = PGMMSGID
374800180227     C                   EVAL      FILENAME = 'CTSXMLIN'
374900180227     C                   EVAL      OPCODE   = 'QCMD'
375000180227     C                   EVAL      STATUS   = PGMSTS
375100180227     C                   EVAL      EXTMSG='Error while CPY object for: '
375200180228     C                                    +%trim(HDRINVNO) + ':'
375300180227     C                                    + %trim(PGMERRDTA)
375400180227     C                   CALLB     'LOGIOERRS'
375500180227     C                   PARM                    ERRORDS
375600180227     C                   EVAL      MSG_ID = 'RBT7200'
375700180228     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + ':'
375800180227     C                                       + %trim(PGMERRDTA)
375900180227     C                   EXSR      SND_ROBOT
376000180227     C
376100180227      *
376200180227     C                   ENDIF
376300180227
376400171212      *
376500171212      *     Now invoke CTS Webservice and
376600171212      *     check return to see if WithinTolerance="Y" is found
376700171212      *
376800171212     ?* Clear old CTSXML Output
376900180227       /free
377000171212            fd  = open(%trim(IFS)
377100171212                       : O_WRONLY+O_CREAT+O_TRUNC +O_CCSID
377200171212                       : S_IRGRP + S_IWGRP + S_IXGRP +
377300180308                          S_IRUSR + S_IWUSR + S_IXUSR +S_IROTH+ S_IXOTH
377400171212                       : 819);
377500171212
377600171212            callp close(fd);
377700171212
377800171212     ?* CTS Webservice call
377900171212
378000160825                         rc =      http_url_post(
378100160825                                   %trim(URL)
378200160825                                   : %addr(BUFFCTS)
378300160825                                   : %len(%trim(BUFFCTS))
378400160825                                   : %trim(IFS)
378500160802                                   : HTTP_TIMEOUT
378600160802                                   : HTTP_USERAGENT
378700160802                                   : 'text/xml'
378800160825                                   : %trim(URL)+%trim(ACTION));
378900190501                         fd = open(%TRIM(IFS): O_RDONLY + O_TEXTDATA+O_CCSID
379000190501                              :S_IRGRP: 37);
379100160826                         len = read(fd:%addr(data):%size(data));
379200180814     ?* @def : Begin
379300180814            callp close(fd);
379400180814     ?* @def : End
379500160823              /end-free
379600160825     C                   EVAL      SCAN_POS =
379700160825     C                             %SCAN(TOLERANCE:DATA:1)
379800171212     ?* check return to see if WithinTolerance="Y" is found
379900171212      *
380000160825     C                   IF        SCAN_POS = 0
380100160825     C                   EVAL      HEADERIND = 1
380200180312     C                   EVAL      E5MSGVAR = 'Warning: ' +
380300160825     C                             'Taxes are not within tolerance for ' +
380400160825     C                             'invoice number: '  +
380500160825     C                             %TRIMR(HDRINVNO)
380600160825     C                   EXSR      WRITEPF5
380700180411      * @1647 : Begin
380800180411     C                   EVAL      WErrNote = ErrNote2
380900180411     C                   EXSR      CrtCFEXML
381000180411      * @1647 : End
381100160825     C                   EVAL      INVOICEVALID (INVOICENDX) = '1'
381200180209      * @UXH : Begin
381300180209     C                   EVAL      HOLDMISCCHG = '0000000000'
381400180209     C                   EVAL      HOLDFREIGHTCHG = '0000000000'
381500180209     C                   EVAL      HOLDTAXES      = '0000000000'
381600180209      * @UXH : End
381700180411     C                   Endif
381800171212     ?* Create CTSXMLRES history
381900171212       /free
382000171212            // Append date,timestamp for every file to be unique
382100171212            WWTIME    = %TIME();
382200171212            $new_file = 'CTSXMLRES'+ %char(WWDATE) + %char(WWTIME);
382300171212            cmd = 'CPY OBJ(''' + %trim(IFS) + ''') +
382400171212                 TOOBJ(''' + %trim($file_dir1)+ %trim($new_file)+ ''')';
382500180227            callp(e) QCMDEXC(cmd: %len(cmd));
382600171212
382700171212       /end-free
382800170705      *
382900180227      * Log error if copy object CTSXMLRES failed
383000180227     C                   IF        %ERROR
383100180227     C                   CLEAR                   ERRORDS
383200180227     C                   EVAL      PROGRAMNAME = PGMNAME
383300180227     C                   EVAL      MSGID       = PGMMSGID
383400180227     C                   EVAL      FILENAME = 'CTSXMLRES'
383500180227     C                   EVAL      OPCODE   = 'QCMD'
383600180227     C                   EVAL      STATUS   = PGMSTS
383700180227     C                   EVAL      EXTMSG='Error while CPY object for: '
383800180227     C                                    +%trim(PRMMBRNAME) + '#'
383900180227     C                                    + %trim(PGMERRDTA)
384000180227     C                   CALLB     'LOGIOERRS'
384100180227     C                   PARM                    ERRORDS
384200180227     C                   EVAL      MSG_ID = 'RBT7200'
384300180227     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + '#'
384400180227     C                                       + %trim(PGMERRDTA)
384500180227     C                   EXSR      SND_ROBOT
384600180227     C
384700180227      *
384800180227     C                   ENDIF
384900171212      *
385000170705      * end of subroutine for CTSXML
385100160823     C                   ENDSR
385200171212      **********************************************************
385300171212     ?* Load CTS Buffer
385400171212      **********************************************************
385500160824     C     CTSWRITE      BEGSR
385600171212      *
385700171212     C                   EVAL      BUFFCTS = %Trimr(WrkCTSXML1)    +
385800171212     C                                       %Trimr(WrkCTSXML2)    +
385900171212     C                                       %Trimr(WrkCTSXML3)
386000171212      *
386100160824     C                   ENDSR
386200171212      **********************************************************
386300171212     ?* Write EDIPF7A and EDIPF7B
386400171212      **********************************************************
386500160801     C     WRITEPF7      BEGSR
386600160801
386700180214      * @uxh : Begin
386800180214     C**                 IF        TAXSTATE = 0 OR
386900180214     C**                           RECTYPE <> 'DDETAIL'
387000180228     C                   IF        ((TAXSTATE =0) OR (RECTYPE<>'DDETAIL'
387100180228     C                             and RECTYPE<>'DSERIALNO'))
387200180302     C                             AND (CATAXSPD<>'Y')
387300180214      * @uxh : End
387400160328     C                   EVAL      E7SKEY1 = E7KEY1
387500160328     C                   EVAL      E7SKEY2 = E7KEY2
387600160328     C                   EVAL      E7SKEY3 = E7KEY3
387700160328     C                   EVAL      E7SKEY4 = E7KEY4
387800160510     C                   EVAL      E7SKEY5 = E7KEY5
387900160328     C                   EVAL      EDIRCD7S = EDIRCD7
388000160328     C                   EVAL      E7SSEQNUM = E7SEQNUM
388100160328     C                   EVAL      E7SOBJID = E7OBJID
388200160328     C                   EVAL      E7SINVTYP = E7INVTYP
388300160328     C                   EVAL      E7SNAME = E7NAME
388400160328     C                   EVAL      E7SVATCOD = E7VATCOD
388500160328     C                   EVAL      E7SSUPLR = E7SUPLR
388600160328     C                   EVAL      E7SCMPCODE = E7CMPCODE
388700160328     C                   EVAL      E7SPOEX = E7POEX
388800160328     C                   EVAL      E7SSRA# = E7SRA#
388900160328     C                   EVAL      E7SCPSNUM = E7CPSNUM
389000160328     C                   EVAL      E7SPAYRID = E7PAYRID
389100171213     C                   WRITE     EDIPF7SR                             70
389200171213     C                   EXSR      ErrPF7A
389300160705     C                   ELSE
389400160705     C                   EVAL      E7TKEY1 = E7KEY1
389500160705     C                   EVAL      E7TKEY2 = E7KEY2
389600160705     C                   EVAL      E7TKEY3 = E7KEY3
389700160705     C                   EVAL      E7TKEY4 = E7KEY4
389800160705     C                   EVAL      E7TKEY5 = E7KEY5
389900160705     C                   EVAL      EDIRCD7T = EDIRCD7
390000160705     C                   EVAL      E7TSEQNUM = E7SEQNUM
390100160705     C                   EVAL      E7TOBJID = E7OBJID
390200160705     C                   EVAL      E7TINVTYP = E7INVTYP
390300160705     C                   EVAL      E7TNAME = E7NAME
390400160705     C                   EVAL      E7TVATCOD = E7VATCOD
390500160705     C                   EVAL      E7TSUPLR = E7SUPLR
390600160705     C                   EVAL      E7TCMPCODE = E7CMPCODE
390700160705     C                   EVAL      E7TPOEX = E7POEX
390800160705     C                   EVAL      E7TSRA# = E7SRA#
390900160705     C                   EVAL      E7TCPSNUM = E7CPSNUM
391000160705     C                   EVAL      E7TPAYRID = E7PAYRID
391100171213     C                   WRITE     EDIPF7TR                             70
391200171213     C                   EXSR      ErrPF7B
391300160705     C                   ENDIF
391400160708
391500180302     C                   EVAL      CATAXSPD  = 'N'
391600180302
391700160328     C                   ENDSR
391800171212      **********************************************************
391900171213     ?* Update EDIPF7B after Tax Spread
392000171212      **********************************************************
392100161206     C     PF7BTOPF7A1   BEGSR
392200161206     C                   EVAL      DSDETAIL = EDIRCD7T
392300160706     C                   IF        TAXACCUM <> 0 AND
392400160706     C                             DETLINTAX > '0000000000'
392500160706     C                   EVAL      INTAMT = %INT(DETLINTAX)
392600160706     C                   IF        TAXACCUM > 0
392700180226      * @1607e : Begin
392800180226     C***                EVAL      INTAMT = INTAMT + 1
392900180226     C***                EVAL      TAXACCUM = TAXACCUM - .0001
393000181004      * @1687a : Begin
393100181004     C***                EVAL      INTAMT = INTAMT + 100
393200181004     C                   EVAL      INTAMT = INTAMT + 1
393300181004      * @1687a : End
393400180226     C                   EVAL      TAXACCUM = TAXACCUM - .01
393500180226      * @1607e : End
393600160706     C                   ELSE
393700180226      * @1607e : Begin
393800180226     C***                EVAL      INTAMT = INTAMT - 1
393900180226     C***                EVAL      TAXACCUM = TAXACCUM + .0001
394000181004      * @1687a : Begin
394100181004     C***                EVAL      INTAMT = INTAMT - 100
394200181004     C                   EVAL      INTAMT = INTAMT - 1
394300181004      * @1687a : End
394400180226     C                   EVAL      TAXACCUM = TAXACCUM + .01
394500180226      * @1607e : End
394600160706     C                   ENDIF
394700161206     C                   EVAL      TAXAMT = %DECH((INTAMT)/10000:10:4)
394800180926      * @1687 : Begin
394900180924     C***                EVAL      TAXAMT2 = TAXAMT * 10000
395000181004      * @1687a : Begin
395100181004     C***                EVAL      TAXAMT2 = TAXAMT * 100
395200181004     C                   EVAL      TAXAMT2 = TAXAMT * 10000
395300181004      * @1687a : End
395400180926      * @1687 : End
395500160706     C                   EVAL      DETLINTAX = %EDITC(TAXAMT2:'X')
395600160706     C                   ENDIF
395700161206     C                   EVAL      EDIRCD7T = DSDETAIL
395800171213     C                   UPDATE    EDIPF7TR                             70
395900171213     C                   EXSR      ErrPF7B
396000160706     C                   ENDSR
396100161206
396200171212      **********************************************************
396300171212     ?* Write from EDIPF7B (Non Upfront) to EDIPF7A (Upfront)
396400171212      **********************************************************
396500161206     C     PF7BTOPF7A2   BEGSR
396600171212      *
396700161206     C                   EVAL      E7SKEY1 = E7TKEY1
396800161206     C                   EVAL      E7SKEY2 = E7TKEY2
396900161206     C                   EVAL      E7SKEY3 = E7TKEY3
397000161206     C                   EVAL      E7SKEY4 = E7TKEY4
397100161206     C                   EVAL      E7SKEY5 = E7TKEY5
397200161206     C                   EVAL      E7SSEQNUM = E7TSEQNUM
397300161206     C                   EVAL      E7SOBJID = E7TOBJID
397400161206     C                   EVAL      E7SINVTYP = E7TINVTYP
397500161206     C                   EVAL      E7SNAME = E7TNAME
397600161206     C                   EVAL      E7SVATCOD = E7TVATCOD
397700161206     C                   EVAL      E7SSUPLR = E7TSUPLR
397800161206     C                   EVAL      E7SCMPCODE = E7TCMPCODE
397900161206     C                   EVAL      E7SPOEX = E7TPOEX
398000161206     C                   EVAL      E7SSRA# = E7TSRA#
398100161206     C                   EVAL      E7SCPSNUM = E7TCPSNUM
398200161206     C                   EVAL      E7SPAYRID = E7TPAYRID
398300161206     C                   EVAL      EDIRCD7S = EDIRCD7T
398400161206     C                   WRITE     EDIPF7SR
398500171213     C                   EXSR      ErrPF7A
398600171212      *
398700161206     C                   ENDSR
398800171212      **********************************************************
398900171212     ?* Replace & > < ' " for XML as &amp; &gt; &lt; &apos; &quot
399000171212      **********************************************************
399100160323     C     REPLACECHAR   BEGSR
399200171212      *
399300160324     C                   EXSR      REPLACEAMP
399400160324     C                   EXSR      REPLACEGT
399500160324     C                   EXSR      REPLACELT
399600160324     C                   EXSR      REPLACEQUOT
399700160324     C                   EXSR      REPLACEAPOS
399800160602     C                   EXSR      REPLACEJUNK
399900160324     C                   ENDSR
400000171212      *
400100171212      **********************************************************
400200160324     C     REPLACEAMP    BEGSR
400300171212      **********************************************************
400400160323     C                   EVAL      SCAN_POS = 1
400500160323     C                   EVAL      SCAN_POS1 = 1
400600160323     C                   DOU       SCAN_POS <= 0
400700160323     C                   EVAL      SCAN_POS =
400800160324     C                             %SCAN(%TRIM(SCAN_AMP)
400900160323     C                             :SCAN_FIELD:SCAN_POS1)
401000160708
401100160323     C                   IF        (SCAN_POS = 0)
401200160323     C                   LEAVE
401300160323     C                   ENDIF
401400160708
401500160323     C                   EVAL      SCAN_POS1 = SCAN_POS + 4
401600160323     C                   EVAL      SCAN_FIELD =
401700160324     C                             %REPLACE(%TRIM(REPLACE_AMP)
401800160323     C                             :SCAN_FIELD
401900160323     C                             :SCAN_POS
402000160324     C                             :%LEN(%TRIM(SCAN_AMP)))
402100160708
402200160323     C                   IF        (SCAN_POS
402300160324     C                              + %LEN(%TRIM(REPLACE_AMP)) >
402400160323     C                             %LEN(SCAN_FIELD))
402500160323     C                   LEAVE
402600160323     C                   ENDIF
402700160708
402800160323     C                   ENDDO
402900160323     C                   ENDSR
403000171212      **********************************************************
403100171212     C     REPLACEGT     BEGSR
403200171212      **********************************************************
403300171212      *
403400160324     C                   EVAL      SCAN_POS = 1
403500160324     C                   EVAL      SCAN_POS1 = 1
403600160324     C                   DOU       SCAN_POS <= 0
403700160324     C                   EVAL      SCAN_POS =
403800160324     C                             %SCAN(%TRIM(SCAN_GT)
403900160324     C                             :SCAN_FIELD:SCAN_POS1)
404000160708
404100160324     C                   IF        (SCAN_POS = 0)
404200160324     C                   LEAVE
404300160324     C                   ENDIF
404400160708
404500160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 3
404600160324     C                   EVAL      SCAN_FIELD =
404700160324     C                             %REPLACE(%TRIM(REPLACE_GT)
404800160324     C                             :SCAN_FIELD
404900160324     C                             :SCAN_POS
405000160324     C                             :%LEN(%TRIM(SCAN_GT)))
405100160708
405200160324     C                   IF        (SCAN_POS
405300160324     C                              + %LEN(%TRIM(REPLACE_GT)) >
405400160324     C                             %LEN(SCAN_FIELD))
405500160324     C                   LEAVE
405600160324     C                   ENDIF
405700160708
405800160324     C                   ENDDO
405900160324     C                   ENDSR
406000171212      **********************************************************
406100171212     C     REPLACELT     BEGSR
406200171212      **********************************************************
406300171212      *
406400160324     C                   EVAL      SCAN_POS = 1
406500160324     C                   EVAL      SCAN_POS1 = 1
406600160324     C                   DOU       SCAN_POS <= 0
406700160324     C                   EVAL      SCAN_POS =
406800160324     C                             %SCAN(%TRIM(SCAN_LT)
406900160324     C                             :SCAN_FIELD:SCAN_POS1)
407000160708
407100160324     C                   IF        (SCAN_POS = 0)
407200160324     C                   LEAVE
407300160324     C                   ENDIF
407400160708
407500160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 3
407600160324     C                   EVAL      SCAN_FIELD =
407700160324     C                             %REPLACE(%TRIM(REPLACE_LT)
407800160324     C                             :SCAN_FIELD
407900160324     C                             :SCAN_POS
408000160324     C                             :%LEN(%TRIM(SCAN_LT)))
408100160708
408200160324     C                   IF        (SCAN_POS
408300160324     C                              + %LEN(%TRIM(REPLACE_LT)) >
408400160324     C                             %LEN(SCAN_FIELD))
408500160324     C                   LEAVE
408600160324     C                   ENDIF
408700160708
408800160324     C                   ENDDO
408900160324     C                   ENDSR
409000171212      **********************************************************
409100171212     C     REPLACEQUOT   BEGSR
409200171212      **********************************************************
409300171212      *
409400160324     C                   EVAL      SCAN_POS = 1
409500160324     C                   EVAL      SCAN_POS1 = 1
409600160324     C                   DOU       SCAN_POS <= 0
409700160324     C                   EVAL      SCAN_POS =
409800160324     C                             %SCAN(%TRIM(SCAN_QUOT)
409900160324     C                             :SCAN_FIELD:SCAN_POS1)
410000160708
410100160324     C                   IF        (SCAN_POS = 0)
410200160324     C                   LEAVE
410300160324     C                   ENDIF
410400160708
410500160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 5
410600160324     C                   EVAL      SCAN_FIELD =
410700160324     C                             %REPLACE(%TRIM(REPLACE_QUOT)
410800160324     C                             :SCAN_FIELD
410900160324     C                             :SCAN_POS
411000160324     C                             :%LEN(%TRIM(SCAN_QUOT)))
411100160708
411200160324     C                   IF        (SCAN_POS
411300160324     C                              + %LEN(%TRIM(REPLACE_QUOT)) >
411400160324     C                             %LEN(SCAN_FIELD))
411500160324     C                   LEAVE
411600160324     C                   ENDIF
411700160708
411800160324     C                   ENDDO
411900160324     C                   ENDSR
412000171212      **********************************************************
412100171212     C     REPLACEAPOS   BEGSR
412200171212      **********************************************************
412300171212      *
412400160324     C                   EVAL      SCAN_POS = 1
412500160324     C                   EVAL      SCAN_POS1 = 1
412600160324     C                   DOU       SCAN_POS <= 0
412700160324     C                   EVAL      SCAN_POS =
412800160324     C                             %SCAN(%TRIM(SCAN_APOS)
412900160324     C                             :SCAN_FIELD:SCAN_POS1)
413000160708
413100160324     C                   IF        (SCAN_POS = 0)
413200160324     C                   LEAVE
413300160324     C                   ENDIF
413400160708
413500160324     C                   EVAL      SCAN_POS1 = SCAN_POS + 5
413600160324     C                   EVAL      SCAN_FIELD =
413700160324     C                             %REPLACE(%TRIM(REPLACE_APOS)
413800160324     C                             :SCAN_FIELD
413900160324     C                             :SCAN_POS
414000160324     C                             :%LEN(%TRIM(SCAN_APOS)))
414100160708
414200160324     C                   IF        (SCAN_POS
414300160324     C                              + %LEN(%TRIM(REPLACE_APOS)) >
414400160324     C                             %LEN(SCAN_FIELD))
414500160324     C                   LEAVE
414600160324     C                   ENDIF
414700160708
414800160324     C                   ENDDO
414900160324     C                   ENDSR
415000171212      **********************************************************
415100171212     C     REPLACEJUNK   BEGSR
415200171212      **********************************************************
415300171212      *
415400160602     C                   EVAL      SCAN_POS = 1
415500160602     C                   DOU       SCAN_POS <= 0
415600160602     C                   EVAL      SCAN_POS =
415700160602     C                             %CHECK(KEYBOARD : SCAN_FIELD)
415800160708
415900160602     C                   IF        (SCAN_POS = 0)
416000160602     C                   LEAVE
416100160602     C                   ENDIF
416200160708
416300160602     C                   EVAL      SCAN_FIELD =
416400160602     C                             %REPLACE('?'
416500160602     C                             :SCAN_FIELD
416600160602     C                             :SCAN_POS
416700160602     C                             :1)
416800160602     C                   ENDDO
416900160602     C                   ENDSR
417000160323      *
417100171212     ?* Initialize
417200170831      *********************************************************************
417300160316     C     INITSR        BEGSR
417400170831      *********************************************************************
417500160316     C                   TIME                    TIMSTP
417600160316     C     *HMS          MOVE      SYSTIME       SYS_TIME
417700171212      *
417800170628      * Set program name.
417900170628     C                   EVAL      PROGRAMNAME = PGMNAME
418000170628      *
418100170615     C                   EVAL      WWDATE     = SYS_DATE
418200170620     C                   EVAL      WWTIME     = SYS_TIME
418300170620      *
418400170831      * Clear workfiles, initialize, and open
418500170831      *
418600180220     C                   EVAL      INVOICENDX = 1
418700170831
418800170831     C                   DOU       INVOICENDX > 10000
418900170831     C                   EVAL      INVOICEVALID(INVOICENDX) = '0'
419000170831     C                   EVAL      INVOICETAX(INVOICENDX) = '0'
419100170831     C                   EVAL      INVOICENDX = INVOICENDX + 1
419200170831     C                   ENDDO
419300170831
419400180220      * @1607d : Begin
419500180220     C***                EVAL      INVOICENDX = 1
419600180220     C                   EVAL      INVOICENDX = 0
419700180220      * @1607d : End
419800171212      *
419900170831     C                   EVAL      CMDLENGTH = 256
420000170831     C                   EVAL      CMDTEXT = *BLANKS
420100170831     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7A'
420200170831     C                   CALL      'QCMDEXC'
420300170831     C                   PARM                    CMDTEXT
420400170831     C                   PARM                    CMDLENGTH
420500170831
420600170831     C                   EVAL      CMDTEXT = *BLANKS
420700170831     C                   EVAL      CMDTEXT = 'CLRPFM EDIPF7B'
420800170831     C                   CALL      'QCMDEXC'
420900170831     C                   PARM                    CMDTEXT
421000170831     C                   PARM                    CMDLENGTH
421100170831
421200180917      * @1685 : Begin
421300180917     C***                EVAL      BUFFER = ' '
421400180917      * @1685 : End
421500171212      *
421600171206     C                   EVAL      BUFFER1= *Blanks
421700190225      * @1692  : Begin
421800190225     C                   EVAL      BUFFER2= *Blanks
421900190225      * @1692  : End
422000171212      *
422100170831     C                   OPEN      EDIPF7A
422200170831     C                   OPEN      EDIPF7B
422300180222      *
422400171212     ?* Chain EDIPF14 to load all work variables
422500170831     C                   EVAL      EDIXMLKEY0 = '*ANY'
422600170831     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
422700170831     C                   EVAL      EDIXMLKEY2 = 'UPFRONT'
422800170831      *
422900170831     C     EDIXMLKEY     CHAIN     EDIPF14
423000170831     C                   IF        %FOUND
423100170831     C                   EVAL      UPFRONTSTATES = EDIXMLDATA
423200170831     C                   ENDIF
423300170831      *
423400171212     ?* Set xml save Path for EDIXML
423500171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
423600171208     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
423700171208     C                   EVAL      EDIXMLKEY2 = 'EDIIFSIN'
423800171208      *
423900171208     C     EDIXMLKEY     CHAIN     EDIPF14
424000171208     C                   IF        %FOUND
424100171208     C                   EVAL      $file_path         = EDIXMLDATA
424200171208     C                   ENDIF
424300171208      *
424400171208     C                   EVAL      EDIXMLKEY0 = PRMSYSID
424500171208     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
424600171208     C                   EVAL      EDIXMLKEY2 = 'EDIIFSDIR'
424700171208      *
424800171208     C     EDIXMLKEY     CHAIN     EDIPF14
424900171208     C                   IF        %FOUND
425000171208     C                   EVAL      $file_dir          = EDIXMLDATA
425100171208     C                   ENDIF
425200171208      *
425300171212     ?* Set xml save Path for CTSXML
425400171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
425500171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
425600171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSIN'
425700171212      *
425800171212     C     EDIXMLKEY     CHAIN     EDIPF14
425900171212     C                   IF        %FOUND
426000171212     C                   EVAL      $file_path1        = EDIXMLDATA
426100171212     C                   ENDIF
426200171212      *
426300171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
426400171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
426500171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSDIR'
426600171212      *
426700171212     C     EDIXMLKEY     CHAIN     EDIPF14
426800171212     C                   IF        %FOUND
426900171212     C                   EVAL      $file_dir1         = EDIXMLDATA
427000171212     C                   ENDIF
427100180222     ?* Set archive save Path for EDI file in tmp
427200180222     C                   EVAL      EDIXMLKEY0 = PRMSYSID
427300180222     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
427400180222     C                   EVAL      EDIXMLKEY2 = 'EDITMPDIR'
427500180222      *
427600180222     C     EDIXMLKEY     CHAIN     EDIPF14
427700180222     C                   IF        %FOUND
427800180222     C                   EVAL      $tmp_dir           = EDIXMLDATA
427900180222     C                   ENDIF
428000180222      *
428100180222     C                   EVAL      EDIXMLKEY0 = PRMSYSID
428200180222     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
428300180222     C                   EVAL      EDIXMLKEY2 = 'EDIARCDIR'
428400180222      *
428500180222     C     EDIXMLKEY     CHAIN     EDIPF14
428600180222     C                   IF        %FOUND
428700180222     C                   EVAL      $arc_dir           = EDIXMLDATA
428800180222     C                   ENDIF
428900171212     ?* XMLCONTROL work variables
429000171212     ?* SOAPADDR ********
429100171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
429200171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
429300171212     C                   EVAL      EDIXMLKEY2 = 'SOAPADDR'
429400171212     C     EDIXMLKEY     CHAIN     EDIPF14
429500171212      *
429600171212     C                   IF        NOT %FOUND
429700171212     C                   EVAL      MSG_ID = 'RBT8011'
429800171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
429900171212     C                   EXSR      SND_ROBOT
430000171212     C                   CLEAR                   ERRORDS
430100171212     C                   EVAL      FILENAME = PF14FIL
430200171212     C                   EVAL      OPCODE = PF14OPC
430300171212     C                   EVAL      STATUS = PF14FST
430400171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
430500171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
430600171212     C                                      ' ' + EDIXMLKEY2
430700171212     C                   EXSR      ERRLOG
430800171212     C                   ELSE
430900171212     C                   EVAL      wSOAPADR = EDIXMLDATA
431000171212     C                   ENDIF
431100171212     ?* XMLENV *******
431200171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
431300171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
431400171212     C                   EVAL      EDIXMLKEY2 = 'XMLENV'
431500171212      *
431600171212     C     EDIXMLKEY     CHAIN     EDIPF14
431700171212      *
431800171212     C                   IF        NOT %FOUND
431900171212     C                   EVAL      MSG_ID = 'RBT8011'
432000171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
432100171212     C                   EXSR      SND_ROBOT
432200171212     C                   CLEAR                   ERRORDS
432300171212     C                   EVAL      FILENAME = PF14FIL
432400171212     C                   EVAL      OPCODE = PF14OPC
432500171212     C                   EVAL      STATUS = PF14FST
432600171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
432700171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
432800171212     C                                      ' ' + EDIXMLKEY2
432900171212     C                   EXSR      ERRLOG
433000171212     C                   ELSE
433100171212     C                   EVAL      wXMLENV = EDIXMLDATA
433200171212     C                   ENDIF
433300171212     ?********
433400171212     ?* CTS Webservice work variables
433500171212     ?* CTSURL ***************************
433600171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
433700171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
433800171212     C                   EVAL      EDIXMLKEY2 = 'CTSURL'
433900171212     C     EDIXMLKEY     CHAIN     EDIPF14
434000171212      *
434100171212     C                   IF        NOT %FOUND
434200171212     C                   EVAL      MSG_ID = 'RBT8011'
434300171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
434400171212     C                   EXSR      SND_ROBOT
434500171212     C                   CLEAR                   ERRORDS
434600171212     C                   EVAL      FILENAME = PF14FIL
434700171212     C                   EVAL      OPCODE = PF14OPC
434800171212     C                   EVAL      STATUS = PF14FST
434900171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
435000171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
435100171212     C                                      ' ' + EDIXMLKEY2
435200171212     C                   EXSR      ERRLOG
435300171212     C                   ENDIF
435400171212      *
435500171212     C                   EVAL      URL = EDIXMLDATA
435600171212     ?* CTSACTION *************
435700171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
435800171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
435900171212     C                   EVAL      EDIXMLKEY2 = 'CTSACTION'
436000171212     C     EDIXMLKEY     CHAIN     EDIPF14
436100171212      *
436200171212     C                   IF        NOT %FOUND
436300171212     C                   EVAL      MSG_ID = 'RBT8011'
436400171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
436500171212     C                   EXSR      SND_ROBOT
436600171212     C                   CLEAR                   ERRORDS
436700171212     C                   EVAL      FILENAME = PF14FIL
436800171212     C                   EVAL      OPCODE = PF14OPC
436900171212     C                   EVAL      STATUS = PF14FST
437000171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
437100171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
437200171212     C                                      ' ' + EDIXMLKEY2
437300171212     C                   EXSR      ERRLOG
437400171212     C                   ENDIF
437500171212      *
437600171212     C                   EVAL      ACTION = EDIXMLDATA
437700171212     ?* CTSIFSOUT *************
437800171212     C                   EVAL      EDIXMLKEY0 = PRMSYSID
437900171212     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
438000171212     C                   EVAL      EDIXMLKEY2 = 'CTSIFSOUT'
438100171212     C     EDIXMLKEY     CHAIN     EDIPF14
438200171212      *
438300171212     C                   IF        NOT %FOUND
438400171212     C                   EVAL      MSG_ID = 'RBT8011'
438500171212     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
438600171212     C                   EXSR      SND_ROBOT
438700171212     C                   CLEAR                   ERRORDS
438800171212     C                   EVAL      FILENAME = PF14FIL
438900171212     C                   EVAL      OPCODE = PF14OPC
439000171212     C                   EVAL      STATUS = PF14FST
439100171212     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
439200171212     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
439300171212     C                                      ' ' + EDIXMLKEY2
439400171212     C                   EXSR      ERRLOG
439500171212     C                   ENDIF
439600171212      *
439700171212     C                   EVAL      IFS = EDIXMLDATA
439800171212     ?*************************
439900171212      *
440000160316     C                   ENDSR
440100180222      *********************************************************************
440200180222     ?* Move EDI Invoice file from tmp to archive directory
440300180222      *********************************************************************
440400180222     C     MovTmpEDI     BEGSR
440500180222      *
440600180222     C                   MOVE      WWDATE        CHAR_DATE
440700180222     C                   EVAL      CHAR_DATE1= %SUBST(CHAR_DATE:1:4)+
440800180222     C                                         %SUBST(CHAR_DATE:6:2)+
440900180222     C                                         %SUBST(CHAR_DATE:9:2)
441000180222      *
441100180222       /free
441200180222            // Rename EDI invoice file with control num and current date
441300180222
441400180222            $new_file = %trim(PRMMBRNAME) + '.' + %triml(%CHAR(HldSEQNUM))
441500180222                        +'.' + %trim(CHAR_DATE1);
441600180222            $tmp_dir  = %trim($tmp_dir) + %trim(PRMMBRNAME);
441700180222
441800180222            cmd = 'CPY OBJ(''' + %trim($tmp_dir) + ''') +
441900180223                   TOOBJ(''' + %trim($arc_dir)+ %trim($new_file)+ ''') +
442000180223                   REPLACE(*YES)';
442100180222            callp(e) QCMDEXC(cmd: %len(cmd));
442200180224
442300180224            if not%error;
442400180225            rcdlt = unlink(%TRIM($tmp_dir));
442500180224            endif;
442600180222       /end-free
442700180225      * Log error if copy object EDI file failed
442800180222     C                   IF        %ERROR
442900180222     C                   CLEAR                   ERRORDS
443000180222     C                   EVAL      PROGRAMNAME = PGMNAME
443100180222     C                   EVAL      MSGID       = PGMMSGID
443200180222     C                   EVAL      FILENAME = 'MOVTMPEDI'
443300180222     C                   EVAL      OPCODE   = 'QCMD'
443400180222     C                   EVAL      STATUS   = PGMSTS
443500180222     C                   EVAL      EXTMSG='Error while CPY object for: '
443600180222     C                                    +%trim(PRMMBRNAME) + '-'
443700180222     C                                    + %trim(PGMERRDTA)
443800180222     C                   CALLB     'LOGIOERRS'
443900180222     C                   PARM                    ERRORDS
444000180222     C                   EVAL      MSG_ID = 'RBT7200'
444100180222     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + '-'
444200180222     C                                       + %trim(PGMERRDTA)
444300180222     C                   EXSR      SND_ROBOT
444400180222     C
444500180222      *
444600180222     C                   ENDIF
444700180225      * Log error if unlink failed
444800180225     C                   IF        RCDLT < 0
444900180225     C                   CLEAR                   ERRORDS
445000180225     C                   EVAL      PROGRAMNAME = PGMNAME
445100180225     C                   EVAL      MSGID       = 'ICC6700'
445200180225     C                   EVAL      FILENAME = 'DLTTMPEDI'
445300180225     C                   EVAL      OPCODE   = 'UNLINK'
445400180225     C                   EVAL      STATUS   = PGMSTS
445500180225     C                   EVAL      EXTMSG='Error while unlink for: '
445600180225     C                                    +%trim(PRMMBRNAME)
445700180225     C                   CALLB     'LOGIOERRS'
445800180225     C                   PARM                    ERRORDS
445900180225     C                   EVAL      MSG_ID = 'RBT7200'
446000180225     C                   EVAL      MSG_DTA = 'Error unlink for: '
446100180225     C                                       +%trim(PRMMBRNAME)
446200180225     C                   EXSR      SND_ROBOT
446300180225     C
446400180225      *
446500180225     C                   ENDIF
446600180225      *
446700180222     C                   ENDSR
446800180222      *********************************************************************
446900180222     ?* Archive EDI xml
447000180222      *********************************************************************
447100180222     C     CpyObjEDI     BEGSR
447200180222      *
447300180222       /free
447400180222            // Append date,timestamp for every file to be unique
447500180222            WWTIME    = %TIME();
447600180222
447700180222            $new_file = 'EDIXMLIN'+ %char(WWDATE) + %char(WWTIME);
447800180222
447900180222            cmd = 'CPY OBJ(''' + %trim($file_path) + ''') +
448000180222                   TOOBJ(''' + %trim($file_dir)+ %trim($new_file)+ ''')';
448100180222            callp(e) QCMDEXC(cmd: %len(cmd));
448200180222
448300180222            if not%error;
448400180222            counter = 6;
448500180222            endif;
448600180222
448700180222       /end-free
448800180222      *
448900180222     C                   ENDSR
449000170831      *********************************************************************
449100171212     ?* MQ Process
449200170831      *********************************************************************
449300170111     C     MQSR          BEGSR
449400171212      *
449500180305       /free
449600171208     ?* Write xml buffer into IFS
449700171208            callp write(fd:%addr(buffer1): %len(%trim(buffer1)));
449800171208            callp close(fd);
449900171208     ?* Create EDI xml history
450000180305         // Exsr CpyObjEDI;
450100180222
450200180222     ?* if EDIXMLIN object in use
450300180305         // if %error and PGMMSGID = 'CPFA09E';
450400180305         // counter = 0;
450500180305         // Dou counter>5;
450600180305         // cmd =  'DLYJOB DLY(1)';
450700180305         // callp QCMDEXC(cmd: %len(cmd));
450800180305         // Exsr CpyObjEDI;
450900180305         // counter = counter + 1;
451000180305         // Enddo;
451100180305         // Endif;
451200171214       /end-free
451300180222      *
451400180305     C*                  IF        %ERROR
451500180305     C*                  CLEAR                   ERRORDS
451600180305     C*                  EVAL      PROGRAMNAME = PGMNAME
451700180305     C*                  EVAL      MSGID       = PGMMSGID
451800180305     C*                  EVAL      FILENAME = 'EDIXMLIN'
451900180305     C*                  EVAL      OPCODE   = 'QCMD'
452000180305     C*                  EVAL      STATUS   = PGMSTS
452100180305     C*                  EVAL      EXTMSG='Error while CPY object for: '
452200180305     C*                                   +%trim(HDRINVNO) + '-'
452300180305     C*                                   + %trim(PGMERRDTA)
452400180305     C*                  CALLB     'LOGIOERRS'
452500180305     C*                  PARM                    ERRORDS
452600180305     C*                  EVAL      MSG_ID = 'RBT8013'
452700180305     C*                  EVAL      MSG_DTA = %TRIM(HDRINVNO) + '-'
452800180305     C*                                      + %trim(PGMERRDTA)
452900180305     C*                  EXSR      SND_ROBOT
453000180305     C*
453100180222      *
453200180305     C*                  ENDIF
453300180305       /free
453400180305            // Append date,timestamp for every file to be unique
453500180305            WWTIME    = %TIME();
453600180305
453700180305            $new_file = %trim($file_dir) + 'EDIXMLIN'+ %char(WWDATE) +
453800180305                              %char(WWTIME);
453900180305     ?* Clear old XML log history
454000180305            fd  = open(%trim($new_file)
454100180305                       : O_WRONLY+O_CREAT+O_TRUNC
454200180305                       : S_IRGRP + S_IWGRP + S_IXGRP +
454300180308                          S_IRUSR + S_IWUSR + S_IXUSR + S_IROTH+ S_IXOTH
454400180305                       : 819);
454500180305
454600180305            callp close(fd);
454700180305     ?* Create EDI xml history
454800180305            fd = open(%trim($new_file)
454900180305                      :O_WRONLY+O_TEXTDATA);
455000180305     ?* Write EDIXML buffer into IFS archive
455100180305            callp(e) write(fd:%addr(buffer1): %len(%trim(buffer1)));
455200180305            callp close(fd);
455300180305       /end-free
455400171213
455500180305     C                   IF        %ERROR
455600180305     C                   CLEAR                   ERRORDS
455700180305     C                   EVAL      PROGRAMNAME = PGMNAME
455800180305     C                   EVAL      MSGID       = PGMMSGID
455900180305     C                   EVAL      FILENAME = 'EDIXMLIN'
456000180305     C                   EVAL      OPCODE   = 'WRITE'
456100180305     C                   EVAL      STATUS   = PGMSTS
456200180305     C                   EVAL      EXTMSG='Error while WRT object for: '
456300180305     C                                    +%trim(HDRINVNO) + '-'
456400180305     C                                    + %trim(PGMERRDTA)
456500180305     C                   CALLB     'LOGIOERRS'
456600180305     C                   PARM                    ERRORDS
456700180305     C                   EVAL      MSG_ID = 'RBT8013'
456800180305     C                   EVAL      MSG_DTA = %TRIM(HDRINVNO) + '-'
456900180305     C                                       + %trim(PGMERRDTA)
457000180305     C                   EXSR      SND_ROBOT
457100180305      *
457200180305     C                   ENDIF
457300180305
457400171212      *
457500171212     ?* Get Queue manager name
457600161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
457700160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
457800160422     C                   EVAL      EDIXMLKEY2 = 'MQMANAGER'
457900160707     C     EDIXMLKEY     CHAIN     EDIPF14
458000170831      *
458100170831     C                   IF        NOT %FOUND
458200170831     C                   EVAL      MSG_ID = 'RBT8011'
458300170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
458400170831     C                   EXSR      SND_ROBOT
458500170831     C                   CLEAR                   ERRORDS
458600170831     C                   EVAL      FILENAME = PF14FIL
458700170831     C                   EVAL      OPCODE = PF14OPC
458800170831     C                   EVAL      STATUS = PF14FST
458900170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
459000170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
459100170831     C                                      ' ' + EDIXMLKEY2
459200170831     C                   EXSR      ERRLOG
459300170831     C                   ENDIF
459400170831      *
459500160422      * Queue manager name
459600160422     C                   EVAL      QMNAME     = EDIXMLDATA
459700160422     C                   EVAL      ODMN       = EDIXMLDATA
459800171212      *
459900171212     ?* Get Output queue name
460000161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
460100160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
460200160422     C                   EVAL      EDIXMLKEY2 = 'MQOUTNAME'
460300160707     C     EDIXMLKEY     CHAIN     EDIPF14
460400170831      *
460500170831     C                   IF        NOT %FOUND
460600170831     C                   EVAL      MSG_ID = 'RBT8011'
460700170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
460800170831     C                   EXSR      SND_ROBOT
460900170831     C                   CLEAR                   ERRORDS
461000170831     C                   EVAL      FILENAME = PF14FIL
461100170831     C                   EVAL      OPCODE = PF14OPC
461200170831     C                   EVAL      STATUS = PF14FST
461300170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
461400170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
461500170831     C                                      ' ' + EDIXMLKEY2
461600170831     C                   EXSR      ERRLOG
461700170831     C                   ENDIF
461800170831      *
461900160422      * Output queue
462000160422     C                   EVAL      ODON       = EDIXMLDATA
462100171212     ?* Connect MQ
462200160617     C                   EVAL      MQCNT = 1
462300160617     C                   EVAL      CMPCOD = 1
462400160617     C                   DOU       CMPCOD = 0 OR
462500160617     C                             MQCNT > 5
462600170528      /free
462700170528       MQCONN(QMNAME : HConn : CMPCOD         : Reason);
462800170528      /end-free
462900160708
463000160617     C                   IF        CMPCOD = 0
463100160617     C                   EVAL      MQCNT = 6
463200160617     C                   ELSE
463300160617     C                   EVAL      MQCNT = MQCNT + 1
463400160617     C                   EVAL      CMDLENGTH = 256
463500160617     C                   EVAL      CMDTEXT = *BLANKS
463600160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
463700160617     C                   CALL      'QCMDEXC'
463800160617     C                   PARM                    CMDTEXT
463900160617     C                   PARM                    CMDLENGTH
464000160617     C                   ENDIF
464100160708
464200160617     C                   ENDDO
464300160708
464400160617     C                   IF        CMPCOD <> 0
464500160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
464600160617     C                             'cannot connect to MQ'
464700160617     C                   EXSR      WRITEPF5
464800171212      *
464900171212     ?* Log MQ Invoke history file
465000170615     C                   EVAL      WCNAME  = 'MQCONN'
465100170615     C                   EXSR      LOGMQCALL
465200171212      *
465300160617     C                   EVAL      *INLR = *ON
465400160617     C                   RETURN
465500160617     C                   ENDIF
465600160422      *
465700171212     ?* Open queue to put messages
465800170528     C                   EVAL      OPTS = OOOUT + OOFIQ
465900171212      *
466000160422     C                   EVAL      OBJDSC= MQOD
466100160617     C                   EVAL      MQCNT = 1
466200160617     C                   EVAL      CMPCOD = 1
466300160617     C                   DOU       CMPCOD = 0 OR
466400160617     C                             MQCNT > 5
466500170528      /free
466600170528       MQOPEN(HConn : MQOD : Opts    : HObj : CMPCOD   : Reason);
466700170528      /end-free
466800160708
466900160617     C                   IF        CMPCOD = 0
467000160617     C                   EVAL      MQCNT = 6
467100160617     C                   ELSE
467200160617     C                   EVAL      MQCNT = MQCNT + 1
467300160617     C                   EVAL      CMDLENGTH = 256
467400160617     C                   EVAL      CMDTEXT = *BLANKS
467500160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
467600160617     C                   CALL      'QCMDEXC'
467700160617     C                   PARM                    CMDTEXT
467800160617     C                   PARM                    CMDLENGTH
467900160617     C                   ENDIF
468000160708
468100160617     C                   ENDDO
468200160617     C                   IF        CMPCOD <> 0
468300160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
468400160617     C                             'cannot open MQ'
468500160617     C                   EXSR      WRITEPF5
468600171212      *
468700171212     ?* Log MQ Invoke history file
468800170615     C                   EVAL      WCNAME  = 'MQOPEN'
468900170615     C                   EXSR      LOGMQCALL
469000171212      *
469100160617     C                   EVAL      *INLR = *ON
469200160617     C                   RETURN
469300160617     C                   ENDIF
469400160422      *
469500190225      * @1692  : Begin
469600190225     C                   MOVEL     FMSTR         MDFMT
469700190225           MQCMHO.CMOPT = CMVAL;
469800190225
469900190225           MQCRTMH(HConn : MQCMHO : HMsg : CMPCOD  : Reason);
470000190225     C                   IF        CMPCOD <> 0
470100190225     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
470200190225     C                             'on MQCRTMH'
470300190225     C                   EXSR      WRITEPF5
470400190225      *
470500190225     ?* Log MQ Invoke history file
470600190225     C                   EVAL      WCNAME  = 'MQCRTM'
470700190225     C                   EXSR      LOGMQCALL
470800190225      *
470900190225     C                   EVAL      *INLR = *ON
471000190225     C                   RETURN
471100190225     C                   ENDIF
471200190225     ?* Set Message properties
471300190225              PropertyName = 'format';
471400190225              PropertyValue = 'xml';
471500190225              PropName.VCHRP = %ADDR(PropertyName : *DATA);
471600190225              PropName.VCHRL = %LEN(PropertyName);
471700190225
471800190225             MQSETMP(HConn : HMsg : MQSMPO : PropName : MQPD : TYPSTR :
471900190225                     %LEN(PropertyValue) : %ADDR(PropertyValue) + 2 :
472000190225                     CMPCOD : Reason);
472100190225     C                   IF        CMPCOD <> 0
472200190225     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
472300190225     C                             'on MQSETMP'
472400190225     C                   EXSR      WRITEPF5
472500190225      *
472600190225     ?* Log MQ Invoke history file
472700190225     C                   EVAL      WCNAME  = 'MQSETM'
472800190225     C                   EXSR      LOGMQCALL
472900190225      *
473000190225     C                   EVAL      *INLR = *ON
473100190225     C                   RETURN
473200190225     C                   ENDIF
473300190225      * @1692  : End
473400171212     ?* Put
473500171212     ?* Positive and Negative action notification reports
473600190225      * @1692  : Begin
473700190225                         MQPMO.PMVER = PMVER3;
473800190225                         MQPMO.PMOMH = HMsg;
473900190225      * @1692  : End
474000160422     C                   EVAL      MDREP = RONAN + ROPAN
474100160422      * Report message
474200171212      *
474300170518     C                   MOVEL     FMSTR         MDFMT
474400171212      *
474500161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
474600160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
474700160422     C                   EVAL      EDIXMLKEY2 = 'MQCCSID'
474800160707     C     EDIXMLKEY     CHAIN     EDIPF14
474900170831      *
475000170831     C                   IF        NOT %FOUND
475100170831     C                   EVAL      MSG_ID = 'RBT8011'
475200170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
475300170831     C                   EXSR      SND_ROBOT
475400170831     C                   CLEAR                   ERRORDS
475500170831     C                   EVAL      FILENAME = PF14FIL
475600170831     C                   EVAL      OPCODE = PF14OPC
475700170831     C                   EVAL      STATUS = PF14FST
475800170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
475900170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
476000170831     C                                      ' ' + EDIXMLKEY2
476100170831     C                   EXSR      ERRLOG
476200170831     C                   ENDIF
476300170831      *
476400171212     ?* MQPRIORITY
476500160422     C                   EVAL      MDCSI = %INT(%TRIMR(EDIXMLDATA))
476600161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
476700160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
476800160422     C                   EVAL      EDIXMLKEY2 = 'MQPRIORITY'
476900160707     C     EDIXMLKEY     CHAIN     EDIPF14
477000170831      *
477100170831     C                   IF        NOT %FOUND
477200170831     C                   EVAL      MSG_ID = 'RBT8011'
477300170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
477400170831     C                   EXSR      SND_ROBOT
477500170831     C                   CLEAR                   ERRORDS
477600170831     C                   EVAL      FILENAME = PF14FIL
477700170831     C                   EVAL      OPCODE = PF14OPC
477800170831     C                   EVAL      STATUS = PF14FST
477900170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
478000170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
478100170831     C                                      ' ' + EDIXMLKEY2
478200170831     C                   EXSR      ERRLOG
478300170831     C                   ENDIF
478400170831      *
478500160422      * Priority
478600160422     C                   EVAL      MDPRI = %INT(%TRIMR(EDIXMLDATA))
478700171212      *
478800161227     C                   EVAL      EDIXMLKEY0 = PRMSYSID
478900160707     C                   EVAL      EDIXMLKEY1 = PRMLIBNAME
479000160422     C                   EVAL      EDIXMLKEY2 = 'MQINNAME'
479100160707     C     EDIXMLKEY     CHAIN     EDIPF14
479200170831      *
479300170831     C                   IF        NOT %FOUND
479400170831     C                   EVAL      MSG_ID = 'RBT8011'
479500170831     C                   EVAL      MSG_DTA = %TRIM(PRMMBRNAME) + ' ' + CHAR_DATE
479600170831     C                   EXSR      SND_ROBOT
479700170831     C                   CLEAR                   ERRORDS
479800170831     C                   EVAL      FILENAME = PF14FIL
479900170831     C                   EVAL      OPCODE = PF14OPC
480000170831     C                   EVAL      STATUS = PF14FST
480100170831     C                   EVAL      EXTMSG = PRMMBRNAME + '-' +
480200170831     C                                      EDIXMLKEY0 + ' ' + EDIXMLKEY1 +
480300170831     C                                      ' ' + EDIXMLKEY2
480400170831     C                   EXSR      ERRLOG
480500170831     C                   ENDIF
480600170831      *
480700171212     ?* Input queue
480800180312      * @1607g : Begin
480900180312      * Clear message id so that new msg id sent by MQ for every invoice
481000180309     C                   EVAL      MDMID      = MINONE
481100180312      * @1607g : End
481200160422     C                   EVAL      MDRQ       = EDIXMLDATA
481300160422     C                   EVAL      MSGDSC     = MQMD
481400160422     C                   EVAL      PMO        = MQPMO
481500160617     C                   EVAL      MQCNT = 1
481600160617     C                   EVAL      CMPCOD = 1
481700171212      *
481800171212     ?* Write Invoice_Control  before MQPUT
481900170616     C                   EXSR      Wrt_INVOCTL
482000171212      *
482100180917      * @1685 : Begin
482200180917     C***                EVAL      BUFFER = %TRIMR(BUFFER1)
482300180917     C***                EVAL      BUFLEN    = %LEN(%TRIMR(Buffer))
482400180917     C                   EVAL      BUFFER1= %TRIMR(BUFFER1)
482500180917     C                   EVAL      BUFLEN    = %LEN(%TRIMR(Buffer1))
482600180917      * @1685 : End
482700190225      * @1692  : Begin
482800190225               UTF8DATA  = BUFFER1;
482900190225               buffer2   = %TRIM(UTF8DATA);
483000190225               buflen1   = %LEN(%TRIM(Buffer2));
483100190225      * @1692  : End
483200171212      *
483300160617     C                   DOU       CMPCOD = 0 OR
483400160617     C                             MQCNT > 5
483500170526      *
483600170528      /free
483700180917        // @1685 : Begin
483800180917        //    MQPUT(HConn : HObj : MQMD  : MQPMO :  Buflen :%ADDR(BUFFER)  :
483900180917        //       Cmpcod         : Reason);
484000190225        // @1692  : Begin
484100190225        //    MQPUT(HConn : HObj : MQMD  : MQPMO :  Buflen :%ADDR(BUFFER1):
484200190225        //       Cmpcod         : Reason);
484300190225              MQPUT(HConn : HObj : MQMD  : MQPMO :  Buflen1:%ADDR(BUFFER2):
484400190225                 Cmpcod         : Reason);
484500190225        // @1692  : End
484600180917        // @1685 : End
484700170528      /end-free
484800160708
484900160617     C                   IF        CMPCOD = 0
485000160617     C                   EVAL      MQCNT = 6
485100171212      *
485200171212     ?* Convert Character to Hexadecimal Message id
485300170627     C                   CALL      'CVTCHARHEX'
485400170627     C                   PARM                    MDMID
485500170627     C                   PARM                    hldMQ_MSG_ID
485600170627      *
485700170616     C                   EXSR      Upd_INVOCTL
485800171212      *
485900160617     C                   ELSE
486000160617     C                   EVAL      MQCNT = MQCNT + 1
486100160617     C                   EVAL      CMDLENGTH = 256
486200160617     C                   EVAL      CMDTEXT = *BLANKS
486300160617     C                   EVAL      CMDTEXT = 'DLYJOB DLY(300)'
486400160617     C                   CALL      'QCMDEXC'
486500160617     C                   PARM                    CMDTEXT
486600160617     C                   PARM                    CMDLENGTH
486700160617     C                   ENDIF
486800160708
486900160617     C                   ENDDO
487000171212      *
487100171212     ?* Log MQ Invoke history file
487200170615     C                   EVAL      WCNAME  = 'MQPUT'
487300170615     C                   EXSR      LOGMQCALL
487400171212      *
487500160617     C                   IF        CMPCOD <> 0
487600160617     C                   EVAL      HEADERIND = 1
487700160617     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
487800160617     C                             'cannot put to MQ for invoice number: '+
487900160617     C                             %TRIMR(HDRINVNO)
488000160617     C                   EXSR      WRITEPF5
488100160617     C                   RETURN
488200160617     C                   ENDIF
488300160422      *
488400190225      * @1692  : Begin
488500190225           MQDLTMH(Hconn : HMsg : MQDMHO : CMPCOD : Reason);
488600190225     C                   IF        CMPCOD <> 0
488700190225     C                   EVAL      E5MSGVAR = 'GCMS EDI UPDATE ERROR: ' +
488800190225     C                             'on MQDLTMH'
488900190225     C                   EXSR      WRITEPF5
489000190225      *
489100190225     ?* Log MQ Invoke history file
489200190225     C                   EVAL      WCNAME  = 'MQDLTM'
489300190225     C                   EXSR      LOGMQCALL
489400190225      *
489500190225     C                   EVAL      *INLR = *ON
489600190225     C                   RETURN
489700190225     C                   ENDIF
489800190225      * @1692  : End
489900171212     ?* Disconnect MQ
490000170528      /free
490100170528         MQDISC(HConn : CMPCOD         : Reason);
490200170528      /end-free
490300170528     C                   ENDSR
