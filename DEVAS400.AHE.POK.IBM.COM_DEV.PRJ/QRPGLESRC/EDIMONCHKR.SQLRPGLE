000100150408      **********************************************************************
000200160118      * Program name: EDIMONCHKR                                           *
000300150408      *                                                                    *
000400160118      * Description: EDI - check results of WRKACTJOB command to see if    *
000500160118      *                    EDI monitor job already running for EDI member  *
000600160118      *                    ID passed to this program as input              *
000700150408      *                                                                    *
000800160118      * Calling program: EDIINVC1                                          *
000900150408      *                                                                    *
001000150408      * Called programs: LOGIOERRS                                         *
001100150408      *                  SNDERRORS                                         *
001200150408      *                                                                    *
001300160118      * Files used: EDIMONACT                                              *
001400150408      *                                                                    *
001500160118      * Special behavior: *none                                            *
001600150408      *                                                                    *
001700150408      * Messages: None                                                     *
001800150408      *                                                                    *
001900150408      * Change history:                                                    *
002000150408      *                                                                    *
002100150408      * Change                                                             *
002200150408      * flag    Reason        Date     Pgmr   Description                  *
002300150408      * -----   ----------    ------   ----   ------------------------     *
002400150408      * @930    GIP 489       01/2010  PKM    GCMS: Pay/Exclude same       *
002500160118      *                                                                    *
002600150408      **********************************************************************
002700100128      * Define program data structure.
002800100128     DPGMSTS          SDS
002900100128     DPROCNAME                 1     10A
003000100128     DJOBNAME                244    253A
003100100128     DUSERID1                254    263A
003200100128     DJOBNUM                 264    269  0
003300100128     DRUN_DATE               276    281S 0
003400100128     DRUN_TIME               282    287S 0
003500100128      *
003600100128      * Data structure for error processing.
003700100128     DERRORDS          DS
003800100128     DMSGID                           7A
003900100128     DPGMNAME                        10A
004000100128     DFILENAME                        8A
004100100128     DOPCODE                          6A
004200100129     DSTATUS                          5S 0
004300100128     DEXTMSG                        100A
004400100128      *
004500100128      * Data structure for ROBOT errors
004600100128     DMSG_Q            S             10A   INZ(*BLANKS)
004700100128     DMSG_ID           S              7A   INZ(*BLANKS)
004800100128     DMSG_DTA          S            256A   INZ(*BLANKS)
004900100128     DMSG_TYP          S              1A   INZ('I')
005000100128      *
005100160118      * Program Parameters
005200160118     DEDIMBR           S             10A
005300160119     DIsRunning        S              1A
005400160119     DNoActive         S              4S 0
005500150408      *
005600160118      *INPUT PARAMETERS:
005700160118     C     *ENTRY        PLIST
005800160118     C                   PARM                    EDIMBR
005900160119     C                   PARM                    IsRunning
006000160118      *
006100160118      *
006200100128      *---------------------------------------------------------------------*
006300100128 ?    *                  M A I N L I N E
006400100128      *---------------------------------------------------------------------*
006500160118      *
006600160118     C/EXEC SQL
006700160119     C+ Select count(*) into :NoActive
006800160119     C+ from QTEMP/EDIMONACT
006900160118     C+ where edimonrcd like('%No active jobs to display%')
007000160118     C/END-EXEC
007100160118      *
007200160118     C                   Select
007300160118      * If SQLCODE <> 0, perform error recovery.
007400160118     C                   When      SQLCODE <> 0
007500160119     C                   EVAL      IsRunning = 'N'
007600160118     C                   CLEAR                   ERRORDS
007700160118     C                   EVAL      FILENAME = 'EDIMONACT'
007800160118     C                   EVAL      OPCODE   = 'COUNT'
007900160118     C                   EVAL      STATUS   = SQLCODE
008000160118     C                   EVAL      EXTMSG   = 'Select count(*) failed'
008100160118     C                   EVAL      MSGID = 'ICC6700'
008200160118     C                   CALLB     'LOGIOERRS'
008300160118     C                   PARM                    ERRORDS
008400160118      *
008500160119     C                   When      NoActive = 0
008600160119     C                   EVAL      IsRunning = 'Y'
008700160119     C                   When      NoActive > 0
008800160119     C                   EVAL      IsRunning = 'N'
008900160118     C                   EndSl
009000100129      *
009100100129     C                   EXSR      EXITPGM
009200150408      *
009300160118      *
009400100129      *****************************************************************
009500100129      * Subroutine to exit the program.
009600100129      *****************************************************************
009700100129     C     EXITPGM       BEGSR
009800100129      *
009900100129      * Set on the last record indicator and return to the calling program.
010000100129     C                   SETON                                        LR
010100100129     C                   RETURN
010200100129      *
010300100129     C                   ENDSR
