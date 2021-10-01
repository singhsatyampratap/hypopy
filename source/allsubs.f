      SUBROUTINE ASKC (PROMPT, STRING)

C  ASKC PROMPTS THEN READS A CHARACTER STRING FROM THE TERMINAL.
C  THE ORIGINAL VALUE IS UNCHANGED BY A CR RESPONSE.

      CHARACTER  PROMPT*(*)            ! PROMPT STRING
      CHARACTER  STRING*(*)  ! CHARACTER RESPONSE, OR ORIGINAL STRING ON CR.
      CHARACTER  TEMP*80              ! SCRATCH
      INTEGER    LENG                 ! FUNCTION
      INTEGER    NCH                  ! NUMBER OF CHARACTERS
      INTEGER    OUNIT  ! LOGICAL UNIT FOR OUTPUT (0 FOR UNIX, 6 FOR VMS)
      PARAMETER (OUNIT = 6)
C      PARAMETER (OUNIT = 0)

      NCH = LENG(STRING)
10    WRITE (OUNIT, 20) PROMPT
20    FORMAT (1X, A)
      IF (NCH .LT. 20) THEN
        WRITE (OUNIT, 30) STRING(1:NCH)
30      FORMAT (' [CR = ', A, ']? ', $)
      ELSE
        WRITE (OUNIT, 40) STRING(1:NCH)
40      FORMAT (' [CR = ', A, ']?')
      END IF
      READ (5, '(A)', ERR = 10, END = 50) TEMP
      IF (LENG(TEMP) .GT. 0) STRING = TEMP
50    RETURN
      END

      REAL FUNCTION ASKR (PROMPT, DFLT)

C  ASKR PROMPTS THEN READS A REAL VALUE FROM THE TERMINAL.
C  THE DEFAULT VALUE IS RETURNED ON A CR RESPONSE.

      REAL  DFLT ! DEFAULT SUPPLIED ON CARRIAGE RETURN AND DISPLAYED IN PROMPT
      CHARACTER PROMPT*(*)         ! PROMPT STRING
      INTEGER   I                  ! LOOP INDEX
      INTEGER   J                  ! LOOP INDEX
      INTEGER   LENG               ! FUNCTION
      CHARACTER TEMP*20            ! SCRATCH
      INTEGER   OUNIT  ! LOGICAL UNIT FOR OUTPUT (0 FOR UNIX, 6 FOR VMS)

      PARAMETER (OUNIT = 6)

      WRITE (TEMP, 10) DFLT
10    FORMAT (G20.5)
      DO 20 I = 1, 20
        IF (TEMP(I:I) .NE. ' ') GOTO 30
20    CONTINUE
30    DO 40 J = 20, 1, -1
        IF (TEMP(J:J) .NE. ' ') GOTO 50
40    CONTINUE
50    WRITE (OUNIT, 60) PROMPT, TEMP(I:J)
60    FORMAT (1X, A, ' [cr = ', A, ']? ', $)
      READ (5, '(A)', ERR = 50, END = 70) TEMP
      IF (LENG(TEMP) .GT. 0) THEN
        READ (TEMP, *, ERR = 50) ASKR
      ELSE
        ASKR = DFLT
      END IF
70    RETURN
      END
      LOGICAL FUNCTION BOX2 (Y,X,Z,KLAS,NAME,FULNAM)
C--DETERMINES WHETHER A POINT IS IN THE REGION NUMBER KLAS.
C  ONLY ONE REGION IS TESTED. FOR NET 2 (NORTHERN CALIF)

C--INPUTS:
C  Y     LATITUDE, DECIMAL DEGREES
C  X     LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z     DEPTH, KM
C  KLAS  REGION NUMBER TO TEST

C--OUTPUTS:
C  BOX2  TRUE IF POINT IS IN REGION OR ON EDGE, FALSE OTHERWISE
C  NAME  3-LETTER NAME FOR REGION IF INSIDE
C  FULNAM  THE FULL (25 CHAR. MAX) REGION NAME

      PARAMETER (NVEXS=242)            !NUMBER OF VERTEX POINTS
      PARAMETER (NREGS=103)            !NUMBER OF DEFINED REGIONS
      PARAMETER (NLIST=636)            !NUMBER OF VERTICIES IN LIST
      PARAMETER (NLP1=637)            !NLIST + 1

      DIMENSION PX(NVEXS), PY(NVEXS)      !VERTEX COORDS
      CHARACTER*3 NAME, NAM(NREGS)      !SHORT REGION NAMES
      CHARACTER*25 FULNAM,FN(NREGS)      !LONG REGION NAMES
      INTEGER JVEX(NLIST)      !ORDERED LIST OF VERTICIES FOR EACH REGION

C--POINTER TO FIRST VERTEX IN JVEX LIST FOR EACH REGION
      DIMENSION NS(NREGS+1)
C--FICTITIOUS POINTER TO LAST VERTEX PLUS 1
      DATA NS(NREGS+1) /NLP1/

      INCLUDE 'box2.inc'

C--ACCUMULATE THE SIGNED CROSSING NUMBERS WITH INSID
      INSID=0
C--FIRST VERTEX NUMBERS OF THIS AND NEXT REGION
      N1=NS(KLAS)
      N2=NS(KLAS+1)

C--LOOP OVER POLYGON EDGES TO SEE IF -X AXIS IS CROSSED
      DO 20 I=N1,N2-2
C--THESE ARE THE TWO VERTEX NUMBERS FOR THIS SEGMENT
        J1=JVEX(I)
        J2=JVEX(I+1)

C--CALC THE CROSSING NUMBER, TRANSLATING TEST POINT TO ORIGIN
        ISIC=KSIC (PX(J1)-X, PY(J1)-Y, PX(J2)-X, PY(J2)-Y)
C--WE WILL SAY WE ARE IN THE REGION IF TEST POINT IS ON EDGE
        IF (ISIC.EQ.4) GOTO 55
20    INSID=INSID+ISIC

C--CHECK THE SEGMENT FROM THE LAST BACK TO THE FIRST VERTEX
      J1=JVEX(N2-1)
      J2=JVEX(N1)
      ISIC=KSIC (PX(J1)-X, PY(J1)-Y, PX(J2)-X, PY(J2)-Y)
      IF (ISIC.EQ.4) GOTO 55
      INSID=INSID+ISIC

C--IF INSID=0, THE POINT IS OUTSIDE
C  IF INSID= +/- 1, THE POINT IS INSIDE
      IF (INSID.NE.0) GOTO 55
      BOX2=.FALSE.
      RETURN

C--POINT IS INSIDE BOX OR ON EDGE
55    BOX2=.TRUE.
      NAME=NAM(KLAS)
      FULNAM=FN(KLAS)
      RETURN
      END
      LOGICAL FUNCTION BOX2A (Y,X,Z,KLAS,NAME,FULNAM)
C--DETERMINES WHETHER A POINT IS IN THE REGION NUMBER KLAS.
C  CALLS THE SUBROUTINE BOX2.
C  ONLY ONE REGION IS TESTED. FOR NET 2 (NORTH CALIF)
C  THE REGION NUMBER NREGS+1 IS OUTSIDE ALL OF THE NREG REGIONS.  UNLIKE BOX2,
C  BOX2A WILL TEST THIS REGION BY EXCLUDING THE EVENT FROM ALL THE OTHER
C  REGIONS.

C--INPUTS:
C  Y     LATITUDE, DECIMAL DEGREES
C  X     LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z     DEPTH, KM
C  KLAS  REGION NUMBER TO TEST

C--OUTPUTS:
C  BOX2A  TRUE IF POINT IS IN REGION OR ON EDGE, FALSE OTHERWISE
C  NAME  3-LETTER NAME FOR REGION IF INSIDE
C  FULNAM  THE FULL (25 CHAR. MAX) REGION NAME

      PARAMETER (NREGS=103)            !NUMBER OF DEFINED REGIONS
      CHARACTER NAME*3, FULNAM*25
      LOGICAL BOX2

      IF (KLAS .GT. NREGS) THEN
C--TEST ALL REGIONS.  IF EVENT IS NOT IN ANY IT IS IN REGION NREGS+1
        BOX2A=.FALSE.
        DO I=1,NREGS
          IF (BOX2 (Y,X,Z,I,NAME,FULNAM)) RETURN
        END DO
        BOX2A=.TRUE.
        NAME='DIS'
        FULNAM='Distant'

C--THE RESULT IS THAT FOR THE SINGLE REGION
      ELSE
        BOX2A = BOX2 (Y,X,Z,KLAS,NAME,FULNAM)
      END IF
      RETURN
      END
      FUNCTION DAYJL(JY,JM,JD)
C--RETURNS THE PERPETUAL JULIAN DAY RELATIVE TO JAN 1, 1960
C--FOR YEARS JY FROM 0 TO 99 (INCLUSIVE) IN THE 20TH CENTURY
C--OR YEARS JY LARGER THAN 1582.
C--THE JULIAN DAY ON JAN 1, 1960 AT 0H U.T. WAS 2436934.5,
C--BUT THIS FUNCTION RETURNS DAYJL (60,1,1) = 0.
      K=JY
      IF (K.LT.300) K=K+1900
      L=JM
      IF (L.GT.2) GOTO 10
      K=K-1
      L=L+12
10    A=365.25*(K-1960)
      I=.01*K
      B=30.6001*(L+1)
      DAYJL=AINT(A)+AINT(B)+(JD-I-48)+AINT(.25*I)
C--CORRECT DAY IF AINT TOOK THE INTEGER PART OF A NEGATIVE NO.
      IF (A.LT.0.) DAYJL=DAYJL-1.
      RETURN
      END
      SUBROUTINE GETREC (REC, IUNIT, ISTAT)
C--GETREC READS A BUFFER OF ASCII RECORDS, THE RETURNS THEM ONE AT A TIME

      SAVE NSIZE	! NUMBER OF RECORDS IN BUFFER (PRESENTLY 500 MAX)
      CHARACTER*(*) REC	! RECORD TO BE "READ"
      INTEGER IUNIT	! INPUT UNIT NUMBER
      INTEGER ISTAT	! 0 FOR NORMAL RETURN OF A RECORD
C                         1 END OF FILE REACHED, NO MORE RECORDS
      SAVE NREC
      DATA NREC /0/	! CURRENT POSITION OF LAST RECORD RETURNED IN BUFFER
      CHARACTER*138 BUF(500) ! CHARACTER BUFFER

C--READ IN A NEW BUFFER IF ITS EMPTY
      IF (NREC.EQ.0 .OR. NREC.EQ.NSIZE) THEN
        NREC=0
        READ (IUNIT, END=9) NSIZE, (BUF(I),I=1,NSIZE)
      END IF

      ISTAT=0
C--GRAB THE NEXT RECORD FROM THE BUFFER
      NREC = NREC +1
      REC = BUF(NREC)
      RETURN

C--END OF FILE
9     ISTAT=1
      RETURN
      END
      FUNCTION KLAS (NET,Y,X,Z,NAME,FULNAM)
C--USED BY HYPOINVERSE TO DETERMINE THE REGION NUMBER OF A HYPOCENTER.

C--INPUT:
C  NET      -THE NETWORK NUMBER AS FOLLOWS:
C      1 OLD HAWAII
C      2 NORTHERN CALIFORNIA
C      3 NEW HAWAII

C  Y      -LATITUDE, DECIMAL DEGREES
C  X      -LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z      -DEPTH IN KM

C--OUTPUT:
C  KLAS  -THE REGION NUMBER WITHIN THE NETWORK ABOVE.
C  NAME  -THE REGION NAME OF THE HYPOCENTER (3 CHAR.)
C  FULNAM-THE FULL REGION NAME (25 CHAR. MAX)

C--THE NUMBER OF REGIONS HERE IS THE NUMBER OF SMALLER REGIONS TO BE SEARCHED,
C  EXCLUDING THE REGIONS WHICH AGGLOMERATE OTHERS TOGETHER
      PARAMETER (NREG1=30,NREG2=98)      !OF 103 REGIONS, 98 ARE TO BE SEARCHED
      PARAMETER (NREG3=51)
      LOGICAL BOX2, BOX3
      EXTERNAL BOX2, BOX3
      CHARACTER NAME*3,FULNAM*25

C--UNTIL THE BOX1 FUNCTION IS WRITTEN, THESE HOLD THE HAWAII REGION NAMES
      CHARACTER N1(NREG1)*3,FN1(NREG1)*25
      DATA N1 /
     2'SNC','SSC','SEC','SER','SME','KOA','SSF','SLE','SF1','SF2',
     3'SF3','SF4','SF5','LER','MLO','LSW','GLN','SWR','INT','KAO',
     4'DEP','DLS','DML','LOI','KON','HUA','KOH','KEA','HIL','DIS'/

      DATA FN1 /
     2'SHALLOW NORTH CALDERA         ','SHALLOW SOUTH CALDERA         ',
     3'SHALLOW EAST CALDERA          ','SHALLOW EAST RIFT             ',
     4'SHALLOW MIDDLE ERZ            ','KOAE FAULT ZONE               ',
     5'SHALLOW SOUTH FLANK           ','SHALLOW LOWER EAST RIFT       ',
     6'SOUTH FLANK 1                 ','SOUTH FLANK 2                 ',
     6'SOUTH FLANK 3                 ','SOUTH FLANK 4                 ',
     7'SOUTH FLANK 5                 ','LOWER EAST RIFT               ',
     8'MAUNA LOA SUMMIT              ','LOWER SOUTHWEST RIFT          ',
     8'GLENWOOD                      ','SOUTHWEST RIFT                ',
     9'INTERMED. DEPTH CALDERA       ','KAOIKI                        ',
     9'DEEP KILAUEA                  ','DEEP LOWER SOUTHWEST RIFT     ',
     1'DEEP MAUNA LOA                ','LOIHI                         ',
     1'KONA                          ','HUALALAI                      ',
     2'KOHALA                        ','MAUNA KEA                     ',
     3'HILO                          ','DISTANT                       '/

C--THIS IS THE ORDERED SEARCH LIST FOR THE N. CALIF (NET 2) REGIONS
C  DONT SEARCH REGIONS 63, 64, 66, 67, 68 BECAUSE THEY AGGLOMERATE OTHER REGIONS
      DIMENSION ISRCH2(NREG2)
      DATA ISRCH2 /
     1  8,  7, 12, 43, 11,  4, 22, 23, 24, 21,
     2 31, 90, 96, 98, 79, 25,  9,  5, 10,  6,
     3 13, 14, 26, 19, 16, 18, 27, 17, 20, 29,
     4 28, 30, 15,  2,  1,  3, 48, 42, 46, 45,
     5 39, 37, 38, 36, 35, 34, 49, 44, 47, 41,
     6 57, 58, 56, 62, 93, 92, 50, 52, 51, 33,
     7 32, 59, 60, 61, 65, 53, 55, 54, 40, 72,
     8 73, 69, 70, 71, 74, 75, 76, 77, 78, 80,
     9 81, 82, 83, 84, 85, 86, 87, 88, 89, 91,
     9 94, 95, 97, 99,100,101,102,103/

C--THIS IS THE SEARCH LIST FOR NEW HAWAII REGIONS
      DIMENSION ISRCH3(NREG3)
      DATA ISRCH3 /
     1 27, 28, 29, 15,  5,  2,  3, 26, 16,  9,
     2 10, 30,  1,  6,  7, 25, 35, 11, 31,  8,
     3 14, 32,  4, 36, 44, 12, 13, 24, 33, 34,
     4 23, 17, 18, 19, 51, 21, 22, 20, 38, 39,
     5 37, 42, 40, 43, 41, 50, 45, 46, 47, 48,
     6 49/


C--USE THE APPROPRIATE CODE FOR EACH NET
      GOTO (100, 200, 300), NET

C--NET IS UNDEFINED
      KLAS=0
      NAME='   '
      RETURN

C****************** HAWAII NETWORK (1) *******************************
C  USE OLD KLASS SUBROUTINE FOR NOW, REPLACE WITH BOX1 ROUTINE LATER.
100   K=KLASS (1,Y,X,Z)
      KLAS=K
      NAME=N1(K)
      FULNAM=FN1(K)
      RETURN

C********************* NO. CALIFORNIA NETWORK (2) ***********************
C--TEST EACH REGION UNTIL THE RIGHT ONE IS FOUND
C--SEARCH REGIONS IN THE ORDER GIVEN BY ISRCH2
200   DO 220 I=1,NREG2
        K=ISRCH2(I)
        KLAS=K
        IF (BOX2(Y,X,Z,K,NAME,FULNAM)) RETURN
220   CONTINUE

C--POINT IS OUTSIDE ALL REGIONS
      KLAS=NREG2+1
      NAME='DIS'
      FULNAM='Distant'
      RETURN

C********************* NEW HAWAII NETWORK (3) ***********************
C--TEST EACH REGION UNTIL THE RIGHT ONE IS FOUND
C--SEARCH REGIONS IN THE ORDER GIVEN BY ISRCH3
300   DO 320 I=1,NREG3
        K=ISRCH3(I)
        KLAS=K
        IF (BOX3(Y,X,Z,K,NAME,FULNAM)) RETURN
320   CONTINUE

C--POINT IS OUTSIDE ALL REGIONS
      KLAS=NREG3+1
      NAME='DIS'
      FULNAM='Distant'
      RETURN
      END
      FUNCTION KLASS (NET,Y,X,Z)
C--ASSIGNS AN INTEGER CODE TO A HYPOCENTER BASED ON LOCATION & DEPTH.
C
C--ARGUMENTS:
C  NET=NETWORK NUMBER
C       NET=1 FOR HAWAII
C  Y=LAT IN DEG (POS NORTH)
C  X=LON IN DEG (POS EAST, NEG WEST)
C  Z=DEPTH IN KM
C
C----------------------------------------------------------
C************* NETWORK 1 = HAWAII *****************
C--ALL EARTHQUAKES ARE IN ONE OF THE FOLLOWING GROUPS,
C--IDENTIFIED BY A NUMERICAL CLASS OR 3-LETTER CODE:
C
C--SHALLOW:
C 1  SNC - SHALLOW NORTH CALDERA (0-5 KM)
C 2  SSC - SHALLOW SOUTH CALDERA (0-5 KM)
C 3  SEC - SHALLOW EAST CALDERA (0-5 KM)
C 4  SER - SHALLOW EAST RIFT (0-5 KM)
C 5  SME - SHALLOW MIDDLE EAST RIFT (0-5 KM)
C 6  KOA - KOAE FAULT ZONE (0-5 KM)
C 7  SSF - SHALLOW SOUTH FLANK (0-5 KM)
C 8  SLE - SHALLOW LOWER EAST RIFT (0-5 KM)
C
C--INTERMEDIATE DEPTH:
C 9  SF1 - KILAUEA SOUTH FLANK (5-13 KM) (WEST END)
C 10 SF2 - KILAUEA SOUTH FLANK (5-13 KM)
C 11 SF3 - KILAUEA SOUTH FLANK (5-13 KM)
C 12 SF4 - KILAUEA SOUTH FLANK (5-13 KM)
C 13 SF5 - KILAUEA SOUTH FLANK (5-13 KM) (EAST END)
C 14 LER - LOWER EAST RIFT (5-99 KM)
C 15 MLO - MAUNA LOA (0-13 KM)
C 16 LSW - LOWER SW RIFTS OF KILAUEA & MAUNA LOA (0-13 KM)
C 17 GLN - GLENWOOD (0-13 KM)
C 18 SWR - SW RIFT (0-13 KM)
C 19 INT - INTERMEDIATE CALDERA (5-13 KM)
C 20 KAO - KAOIKI (0-13 KM)
C
C--DEEP:
C 21 DEP - DEEP KILAUEA (>13 KM) (BELOW REGIONS 1-13,17-19)
C 22 DLS - DEEP LOWER SW RIFT (>13 KM) (BELOW REGION 16)
C 23 DML - DEEP MAUNA LOA (>13 KM) (BELOW REGIONS 15,20)
C
C--OUTER REGIONS, ALL DEPTHS:
C 24 LOI - LOIHI (ALL DEPTHS)
C 25 KON - SOUTH KONA (ALL DEPTHS)
C 26 HUA - HUALALAI (ALL DEPTHS)
C 27 KOH - KOHALA (ALL DEPTHS)
C 28 KEA - MAUNA KEA (ALL DEPTHS)
C 29 HIL - HILO (ALL DEPTHS)
C 30 DIS - DISTANT, EVERYWHERE ELSE
C
C---------------------------------------------------------
C--THE LATITUDE AND LONGITUDE LIMITS OF THE REGIONS ARE GIVEN BELOW.
C--WHEN THE COORDINATES IMPLY AN OVERLAP, PRECEDENCE IS GIVEN AS IN THE MAPS.
C
C NO. CODE      N.LAT.            S.LAT.            W.LON.            E.LON.
C  1  SNC      19 28            19 24.5          155 19            155 14
C  2  SSC      19 24.5          19 22            155 19            155 16.5
C  3  SEC      19 24.5          19 22            155 16.5          155 14
C  4  SER      19 26            19 20.5          155 14            155 07.2
C  5  SME      19 26            -----            155 07.2          155 00
C  6  KOA      19 22            19 20.5          155 17            155 14
C  7  SSF      -----            19 10            155 17            155 00
C  8  SLE      19 32            19 16            155 00            154 40
C  9  SF1      19 22            19 10            155 17            155 14.5
C 10  SF2      19 26            19 10            155 14.5          155 12.3
C 11  SF3      19 26            19 10            155 12.3          155 09.1
C 12  SF4      19 26            19 10            155 09.1          155 05.3
C 13  SF5      19 26            19 10            155 05.3          155 00
C 14  LER      19 32            19 16            155 00            154 40
C 15  MLO      19 43            19 19            155 35            155 19
C 16  LSW      19 19            18 40            155 43            155 25
C 17  GLN      19 43            19 26            155 19            155 00
C 18  SWR      19 22            19 10            155 25            155 17
C 19  INT      19 28            19 22            155 19            155 14
C 20  KAO      19 30            19 19            155 32            155 19
C 21  DEP      19 43            19 10            155 25            155 00
C 22  DLS      19 19            18 40            155 43            155 25
C 23  DML      19 43            19 19            155 35            155 19
C 24  LOI      19 10            18 40            155 25            155 00
C 25  KON      19 39            19 00            156 20            155 43
C 26  HUA      19 55            19 39            156 20            155 43
C 27  KOH      20 25            19 55            156 20            155 34
C 28  KEA      20 25            19 43            155 43            154 40
C 29  HIL      19 47            19 32            155 09            154 40
C---------------------------------------------------
C
C********** HAWAII ************
C
      IF (Y.GT.19.467 .OR. Y.LT.19.367 .OR. X.GT.-155.233
     2 .OR. X.LT.-155.317) GO TO 10
C--KILAUEA CALDERA
C--DEP
      KLASS=21
      IF (Z.GT.13.) RETURN
C--INT
      KLASS=19
      IF (Z.GT.5.) RETURN
C--SNC
      KLASS=1
      IF (Y.GT.19.409) RETURN
C--SSC
      KLASS=2
      IF (X.LT.-155.275) RETURN
C--SEC
      KLASS=3
      RETURN
C----------------------------------------------------------
10    IF (Y.GT.19.433 .OR. Y.LT.19.167 .OR. X.GT.-155.
     2 .OR. X.LT.-155.283) GO TO 30
C--EAST RIFT OR SOUTH FLANK
C--DEP
      KLASS=21
      IF (Z.GT.13.) RETURN
      IF (Z.GT.5.) GO TO 20
C--SHALLOW EAST RIFT
C--SSF
      KLASS=7
      IF (Y.LT.19.342 .OR. Y.LT.70.1+.3271*X) RETURN
C--KOA
      KLASS=6
      IF (X.LT.-155.233) RETURN
C--SER
      KLASS=4
      IF (X.LT.-155.12) RETURN
C--SME
      KLASS=5
      RETURN
C------------------------------------------------------
C--SOUTH FLANK
C--SF1
20    KLASS=9
      IF (X.LT.-155.242) RETURN
C--SF2
      KLASS=10
      IF (X.LT.-155.205) RETURN
C--SF3
      KLASS=11
      IF (X.LT.-155.152) RETURN
C--SF4
      KLASS=12
      IF (X.LT.-155.088) RETURN
C--SF5
      KLASS=13
      RETURN
C-----------------------------------------------------
C--OUTER REGIONS WITH DEPTH DISCRIMINATION
C
30    IF (X.LT.-155.417 .OR. X.GT.-155.283 .OR. Y.GT.19.367
     2 .OR. Y.LT.19.167) GO TO 35
C--SWR
      KLASS=18
      IF (Z.LT.13.) RETURN
C--DEP
      KLASS=21
      RETURN
C
35    IF (Y.GT.19.5 .OR. Y.LT.19.317 .OR. X.GT.-155.317
     2 .OR. X.LT.-155.533) GO TO 40
C--KAO
      KLASS=20
      IF (Z.LT.13.) RETURN
C--DML
      KLASS=23
      RETURN
C
40    IF (Y.GT.19.533 .OR. Y.LT.19.267 .OR. X.GT.-154.667
     2 .OR. X.LT.-155.) GO TO 45
C--SLE
      KLASS=8
      IF (Z.LT.5.) RETURN
C--LER
      KLASS=14
      RETURN
C
45    IF (Y.GT.19.317 .OR. Y.LT.18.667 .OR. X.GT.-155.417
     2 .OR. X.LT.-155.717) GO TO 50
C--LSW
      KLASS=16
      IF (Z.LT.13.) RETURN
C--DLS
      KLASS=22
      RETURN
C
50    IF (X.LT.-155.717 .OR. X.GT.-155.317 .OR. Y.LT.19.317
     2 .OR. Y.GT.19.583) GO TO 55
C--MLO
      KLASS=15
      IF (Z.LT.13.) RETURN
C--DML
      KLASS=23
      RETURN
C---------------------------------------------------------
C--TESTS FOR OUTER REGIONS INCLUDING ALL DEPTHS
C--KON
55    KLASS=25
      IF (Y.LT.19.650 .AND. Y.GT.19. .AND. X.GT.-156.333
     2 .AND. X.LT.-155.717) RETURN
C--HUA
      KLASS=26
      IF (Y.LT.19.917 .AND. Y.GT.19.650 .AND. X.GT.-156.333
     2 .AND. X.LT.-155.717) RETURN
C--KOH
      KLASS=27
      IF (Y.LT.20.417 .AND. Y.GT.19.917 .AND. X.GT.-156.333
     2 .AND. X.LT.-155.567) RETURN
C--LOI
      KLASS=24
      IF (Y.LT.19.167 .AND. Y.GT.18.667 .AND. X.GT.-155.417
     2 .AND. X.LT.-155.) RETURN
C--HIL
      KLASS=29
      IF (Y.LT.19.783 .AND. Y.GT.19.533 .AND. X.GT.-155.15
     2 .AND. X.LT.-154.667) RETURN
C
      IF (Y.GT.19.583 .OR. Y.LT.19.43 .OR. X.LT.-155.317
     2 .OR. X.GT.-155.) GO TO 60
C--GLN
      KLASS=17
      IF (Z.LT.13.) RETURN
C--DEP
      KLASS=21
      RETURN
C--KEA
60    KLASS=28
      IF (Y.LT.20.417 .AND. Y.GT.19.583 .AND. X.GT.-155.717
     2 .AND. X.LT.-154.667) RETURN
C--DIS, EVERYTHING ELSE
      KLASS=30
      RETURN
      END
C******************************** KSIC *******************************
      FUNCTION KSIC (X1,Y1,X2,Y2)
C--COMPUTES THE SIGNED CROSSING NUMBER FOR THE KLAS FUNCTION

C--IF BOTH POINTS ARE ON THE SAME SIDE OF THE X AXIS, RETURN 0
      IF (Y1*Y2 .GT. 0.) GOTO 60

      S=X1*Y2-X2*Y1
C--CHECK IF SEGMENT CROSSES THRU ORIGIN
      IF (S.EQ.0. .AND. X1*X2 .LE. 0.) THEN
        KSIC=4
        RETURN
      END IF

C--CHECK FOR COMPLETE CROSSING
      IF (Y1*Y2 .LT. 0.) GOTO 30

C--ONE END OF SEGMENT TOUCHES X AXIS - WHICH END?
      IF (Y2.EQ.0.) GOTO 20
C--SINCE Y1=0, CHECK IF SEGMENT TOUCHES +X AXIS
      IF (X1.GT.0.) GOTO 60
C--UPWARD OR DOWNWARD?
      IF (Y2.GT.0.) GOTO 70
      GOTO 80

C--SINCE Y2=0, CHECK IF SEGMENT TOUCHES +X AXIS
20    IF (Y1.EQ.0. .OR. X2.GT.0.) GOTO 60
C--UPWARD OR DOWNWARD?
      IF (Y1.GT.0.) GOTO 80
      GOTO 70

C--COMPLETE CROSSING OF -X AXIS? BREAK INTO CASES ACCORDING TO DIRECTION
30    IF (Y1.GT.0.) GOTO 40

C--HERE IS THE CASE OF Y1 < 0 < Y2
      IF (S.GE.0.) GOTO 60
C--WE HAVE AN UPWARD CROSSING
      KSIC=2
      RETURN

C--HERE IS THE CASE OF Y1 > 0 > Y2
40    IF (S.LE.0.) GOTO 60
C--WE HAVE A DOWNWARD CROSSING
      KSIC=-2
      RETURN

C--THERE IS NO CROSSING
60    KSIC=0
      RETURN

C--THERE IS AN UPWARD HALF CROSSING
70    KSIC=1
      RETURN

C--THERE IS A DOWNWARD HALF CROSSING
80    KSIC=-1
      RETURN
      END
      SUBROUTINE OPENR (IUNIT,FIL,FOR,IOS)
C--OPEN A FILE FOR READING ON THE SUN OR THE VAX (SAME SUBROUTINE).
C--THE FILE MUST EXIST TO AVOID AN ERROR.

C--THE ARGUMENTS ARE:
C  IUNIT   UNIT NUMBER (INTEGER)
C  FIL     CHAR STRING CONTAINING FILENAME
C  FOR     CHAR STRING FOR THE FORM SPECIFIER:
C            'F' OR 'FORMATTED'   ASCII FILE TO READ FORMATTED
C            'U' OR 'UNFORMATTED' BINARY FILE TO READ UNFORMATTED
C  IOS     ERROR RETURN:
C            0    OPEN WAS OK
C            >0   AN ERROR OCCURRED

      CHARACTER FIL*(*), FOR*(*), FSTR*11
      INTEGER IUNIT,IOS

      FSTR='formatted'
      IF (FOR(1:1).EQ.'u' .OR. FOR(1:1).EQ.'U') FSTR='unformatted'

C--VAX VERSION
C      OPEN (IUNIT,FILE=FIL,FORM=FSTR,IOSTAT=IOS,STATUS='OLD',
C     2 BLANK='ZERO', SHARED, READONLY, RECL=256)

C--SUN & OS2 VERSION
      OPEN (IUNIT,FILE=FIL,FORM=FSTR,IOSTAT=IOS,STATUS='OLD',
     2 BLANK='ZERO')

      RETURN
      END
      SUBROUTINE OPENW (IUNIT,FIL,FOR,IOS,ACC)
C--OPEN A FILE FOR WRITING

C--THE ARGUMENTS ARE:
C  IUNIT   UNIT NUMBER (INTEGER)
C  FIL     CHAR STRING CONTAINING FILENAME
C  FOR     CHAR STRING FOR THE FORM SPECIFIER:
C            'F' OR 'FORMATTED'   ASCII FILE TO READ FORMATTED
C            'U' OR 'UNFORMATTED' BINARY FILE TO READ UNFORMATTED
C            'P' OR 'PRINT'       ASCII FILE TO WRITE WITH CARRIAGECONTROL
C                   CHARACTER
C  IOS     ERROR RETURN:
C             0    OPEN WAS OK
C             >0   AND ERROR OCCURRED
C  ACC     ACCESS SPECIFIER
C            'S' OR 'SEQUENTIAL'  NORMAL ACCESS, WRITE FROM BEGINNING OF FILE
C            'A' OR 'APPEND'      WRITE AT END OF FILE IF IT EXISTS

      CHARACTER FIL*(*), FOR*(*), ACC*(*), FSTR*12, ASTR*11 
C     CHARACTER CC*9
      INTEGER IUNIT,IOS

      FSTR='formatted  '
      IF (FOR(1:1).EQ.'u' .or. FOR(1:1).EQ.'U') FSTR='unformatted  '
C--SUN & OS2
      IF (FOR(1:1).EQ.'p' .or. FOR(1:1).EQ.'P') FSTR='print  '
C--VAX
C      CC='list  '
C      IF (FOR(1:1).EQ.'p' .OR. FOR(1:1).EQ.'P') CC='FORTRAN  '

      ASTR='sequential  '
      IF (ACC(1:1).EQ.'a' .OR. ACC(1:1).EQ.'A') ASTR='append  '

C--SUN
      OPEN (IUNIT,FILE=FIL, FORM=FSTR, IOSTAT=IOS, STATUS='unknown',
     2 ACCESS=ASTR)

C--OS2
C      OPEN (IUNIT,FILE=FIL, FORM=FSTR, IOSTAT=IOS, STATUS='UNKNOWN',
C     2 ACCESS=ASTR)

C--VAX
C      OPEN (IUNIT,FILE=FIL, FORM=FSTR, IOSTAT=IOS, STATUS='NEW',
C     2 ACCESS=ASTR, CARRIAGECONTROL=CC, RECL=256)
      RETURN
      END
      INTEGER FUNCTION JASK (PROMPT, IDFLT)
C
C  JASK PROMPTS THEN READS AN INTEGER VALUE FROM THE TERMINAL.
C  THE DEFAULT VALUE IS RETURNED ON A CR RESPONSE.
C  IDFLT IS DEFAULT SUPPLIED ON CARRIAGE RETURN AND DISPLAYED IN PROMPT

      INTEGER     IDFLT
      CHARACTER   PROMPT*(*)	! PROMPT STRING
      CHARACTER   TEMP*20	! SCRATCH
      INTEGER     I		! LOOP INDEX
      INTEGER     LENG		! FUNCTION
      INTEGER     OUNIT	! LOGICAL UNIT FOR OUTPUT (0 FOR UNIX, 6 FOR VMS)

      PARAMETER (OUNIT = 6)

      WRITE (TEMP, 10) IDFLT
10    FORMAT (I20)
      DO 20 I = 1, 20
        IF (TEMP(I:I) .NE. ' ') GOTO 30
20    CONTINUE
30    WRITE (OUNIT, 40) PROMPT, TEMP(I:20)
40    FORMAT (1X, A, ' [cr = ', A, ']? ', $)
      READ (5, '(A)', ERR = 30, END = 50) TEMP
      IF (LENG(TEMP) .GT. 0) THEN
        READ (TEMP, *, ERR = 30) JASK
      ELSE
        JASK = IDFLT
      END IF
50    RETURN
      END
	SUBROUTINE JDATE (W,JY,JM,JD,JH,JN)
C--FOR THE PERPETUAL JULIAN DAY D (DBL PREC) RELATIVE TO JAN 1, 1960,
C--JDATE RETURNS THE DATE AND TIME AS 5 INTEGERS.
C--THE YEAR IS 4 DIGITS.  
C--THE JULIAN DAY CAN BE CALCULATED FROM A DATE BY THE ROUTINE DAYJL.
	DOUBLE PRECISION D,E,F,T,A,B,C,W
	D=W+1.D0	!THIS MOD SEEMS TO BE NECESSARY
	E=DINT(D)
	IF (D.LT.0.D0) E=E-1.D0
	F=D-E
	T=E/365.25D0+.8355D0
	A=DINT(T)
	IF (T.LT.0.D0) A=A-1.D0
	T=365.25D0*A+.75D0
	B=DINT(T)
	IF (T.LT.0.D0) B=B-1.D0
	C=DINT((E-B+428.D0)/30.6001D0)
	JD=E-B+428.1D0-DINT(30.6001D0*C)
C	JD=E-B+429.1D0-DINT(30.6001D0*C)
	JM=C-.9D0
	IF (JM.GT.12) JM=JM-12
	JY=A+59.1D0
	IF (JM.LT.3) JY=JY+1
	jy=jy+1900
	JH=24.D0*F+.001D0
	JN=1440.D0*(F-JH/24.D0)
	IF (JH.LT.24) RETURN
	JH=JH-24
	JD=JD+1
	RETURN
	END
	LOGICAL FUNCTION ISITIN (NET,Y,X,Z,KLAS)
C--USED BY QPLOT & SELECT TO DETERMINE IF A HYPOCENTER IS IN A REGION

C--INPUT:
C  NET	-THE NETWORK NUMBER AS FOLLOWS:
C	1 HAWAII
C	2 NORTHERN CALIFORNIA
C       3 NEW HAWAII
C  Y	-LATITUDE, DECIMAL DEGREES
C  X	-LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z	-DEPTH IN KM
C  KLAS  -THE REGION NUMBER WITHIN THE NETWORK ABOVE.

C--OUTPUT:
C  ISITIN  TRUE WHEN EVENT IS IN THE REGION KLAS

	LOGICAL BOX2, BOX3A
	CHARACTER NAME*3,FULNAM*25

C--USE THE APPROPRIATE CODE FOR EACH NET
	GOTO (100, 200, 300), NET

C--NET IS UNDEFINED
	ISITIN=.FALSE.
	RETURN

C****************** HAWAII NETWORK (1) *******************************
C  USE OLD KLASS SUBROUTINE FOR NOW, REPLACE WITH BOX1 ROUTINE LATER.
100	ISITIN=KLAS .EQ. KLASS(1,Y,X,Z)
	RETURN

C********************* NO. CALIFORNIA NETWORK (2) ***********************
200	IF (KLAS.EQ.104) THEN
	  DO I=1,103
	    IF (BOX2 (Y,X,Z,I,NAME,FULNAM)) THEN
	      ISITIN=.FALSE.
	      RETURN
	    END IF
	  END DO
	ELSE
	  ISITIN = BOX2 (Y,X,Z,KLAS,NAME,FULNAM)
	END IF
	RETURN

C********************* NEW HAWAII NETWORK (3) ***********************
C--BOX3A HANDLES THE CASE OF ANY REGION, INCLUDING DISTANT (OUTSIDE
C  ALL DEFINED REGIONS).

300	ISITIN = BOX3A (Y,X,Z,KLAS,NAME,FULNAM)
	RETURN
	END
      LOGICAL FUNCTION LASK (PROMPT,LDFLT)
C--LASK PROMPTS USING THE STRING "PROMPT", THEN READS A LOGICAL VALUE
C--FROM THE TERMINAL. THE DEFAULT VALUE LDFLT IS RETURNED ON A CR RESPONSE.
C      LASK= LOGICAL RESPONSE.
C      PROMPT= PROMPT STRING.

      CHARACTER PROMPT*(*), TEMP*20
      LOGICAL LDFLT
5     WRITE (6,1001) PROMPT,LDFLT
1001  FORMAT (1X,A,' [t or f, cr=',l1,']? ',$)

      READ (5,'(A)',ERR=5,END=9) TEMP
      IF (LENG(TEMP).GT.0) THEN
        READ (TEMP,*,ERR=5) LASK
      ELSE
        LASK=LDFLT
      END IF
9     RETURN
      END
      INTEGER FUNCTION LENG (STRING)
C
C THE NON-BLANK LENGTH OF STRING WHOSE PHYSICAL LENGTH IS MAXLEN
C (RETURNS THE POSITION OF THE LAST NON-BLANK CHARACTER)
C
      CHARACTER         STRING*(*)	! STRING
C
      INTEGER           I		! CHARACTER POSITION
      INTEGER           MAXLEN		! LENGTH OF STRING

      MAXLEN = LEN(STRING)
      DO 10 I = MAXLEN,1,-1
        IF (STRING(I:I) .NE. ' ') GOTO 20
10    CONTINUE
      I = 0
20    LENG = I
      RETURN
      END
	subroutine putrec (nsize, rec, ounit, istat)
c	subroutine putrec (nsize, rec, ounit, istat, lwrit)
c--Putrec collects ASCII records in a buffer, then writes them out when the
c  buffer is full.

	integer		nsize			
c				max number of records in buffer (presently 500)
	character*(*)	rec
c				record to be "written"
	integer		ounit			
c				output unit number
	integer		istat
c				-1 to initialize buffer
c				0 to grab a record
c				1 to write final buffer, dont add a new record
c	logical		lwrit
c				t if this call wrote out the buffer
	save		nrec			
c				total number of lines in buffer
	character*138	buf(500)
c				character buffer

c--Initialize (clear) buffer
	if (istat.lt.0) then
	  if (nsize.gt.500) then
	    print *,' Max size of record buffer is 500'
	    stop
	  end if
	  nrec = 0
c	  lwrit = .false.
	  return
	end if

c--Write out last buffer
	if (istat.gt.0) then
	  write (ounit) nrec, (buf(i),i=1,nrec)
c	  lwrit = .true.
	  return
	end if

c--Accumulate the record in the buffer
	nrec = nrec +1
	buf(nrec) = rec
c	lwrit = .false.

c--Write buffer out if its full
	if (nrec.eq.nsize) then
	  write (ounit) nrec, (buf(i),i=1,nrec)
c	  lwrit = .true.
	  nrec = 0
	end if
	return
	end
	subroutine putrec2 (nsize, rec, ounit, istat)
c--Putrec collects ASCII records in a buffer, then writes them out when the
c  buffer is full.

	integer		nsize			
c				max number of records in buffer (presently 500)
	character*(*)	rec
c				record to be "written"
	integer		ounit			
c				output unit number
	integer		istat
c				-1 to initialize buffer
c				0 to grab a record
c				1 to write final buffer, dont add a new record
c	logical		lwrit
c				t if this call wrote out the buffer
	save		nrec			
c				total number of lines in buffer
	character*138	buf(500)
c				character buffer

c--Initialize (clear) buffer
	if (istat.lt.0) then
	  if (nsize.gt.500) then
	    print *,' Max size of record buffer is 500'
	    stop
	  end if
	  nrec = 0
c	  lwrit = .false.
	  return
	end if

c--Write out last buffer
	if (istat.gt.0) then
	  write (ounit) nrec, (buf(i),i=1,nrec)
c	  lwrit = .true.
	  return
	end if

c--Accumulate the record in the buffer
	nrec = nrec +1
	buf(nrec) = rec
c	lwrit = .false.

c--Write buffer out if its full
	if (nrec.eq.nsize) then
	  write (ounit) nrec, (buf(i),i=1,nrec)
c	  lwrit = .true.
	  nrec = 0
	end if
	return
	end
      SUBROUTINE UPSTR (STR, LEN)
C
C      UPSTR CONVERTS THE CHARACTER STRING STR TO UPPER CASE.
C      LEN IS THE NUMBER OF CHARACTERS TO CONVERT, NOT TO EXCEED THE
C      ACTUAL LENGTH OF STR.
C
C      AUTHOR: FRED KLEIN (U.S.G.S)
C
      CHARACTER            STR*(*)
      INTEGER                  I
      INTEGER                  J
      INTEGER                  LEN

      DO I = 1, LEN
        J = ICHAR(STR(I:I))
        IF (J .GT. 96 .AND. J .LT. 123) STR(I:I) =  CHAR(J - 32)
      END DO
      RETURN
      END

	SUBROUTINE IOFL
C--PROMPTS FOR AND OPENS AN INPUT (UNIT 2) AND OUTPUT (UNIT 3) FILE
C--NO CARRIAGE CONTROL CHARACTER IS EXPECTED ON OUTPUT.
	CHARACTER IFL*80
	WRITE (6,1000)
1000	FORMAT (' INPUT FILENAME? ',$)
	READ (5,1001) IFL
1001	FORMAT (A)
	call openr (2,ifl,'f',ios)
	if (ios.ne.0) then
	  print *,'*** Error: cant open input file'
	  stop
	end if

	WRITE (6,1002)
1002	FORMAT (' OUTPUT FILENAME? ',$)
	READ (5,1001) IFL
	call openw (3,ifl,'f',ios,'s')
	if (ios.ne.0) then
	  print *,'*** Error: cant open output file'
	  stop
	end if
	RETURN
	END
	SUBROUTINE IFL
C--PROMPTS FOR AND OPENS AN INPUT FILE AS UNIT 2.
	CHARACTER INFL*80
	WRITE (6,1000)
1000	FORMAT (' INPUT FILENAME? ',$)
	READ (5,1001) INFL
1001	FORMAT (A)
	call openr (2,infl, 'f',ios)
	if (ios.ne.0) then
	  print *,'*** Error: cant open input file'
	  stop
	end if
	RETURN
	END
	SUBROUTINE OFL
C--PROMPTS FOR AND OPENS AN OUTPUT FILE AS UNIT 3.
C--NO CARRIAGE CONTROL CHARACTER IS EXPECTED ON OUTPUT.
	CHARACTER IFL*80
	WRITE (6,1000)
1000	FORMAT (' OUTPUT FILENAME? ',$)
	READ (5,1001) IFL
1001	FORMAT (A)
	call openw (3,ifl,'f',ios,'s')
	if (ios.ne.0) then
	  print *,'*** Error: cant open output file'
	  stop
	end if
	RETURN
	END
      SUBROUTINE SPAWN (MESS)
C--SPAWN A SUBPROCESS OR ISSUE A SYSTEM COMMAND FROM WITHIN A PROGRAM
      CHARACTER MESS*(*)
C--VAX:
C      CALL LIB$SPAWN (MESS)
C--SUN:
      I = SYSTEM (MESS)
      WRITE (*,*) I
C--OS2:
C      INCLUDE 'FSUBLIB.FI'
C      I = FSYSTEM (MESS)
C      WRITE (*,*) I

      RETURN
      END
      SUBROUTINE ERRSET (I,L1,L2,L3,L4)
C--DUMMY ROUTINE SO SUN AND VAX SOURCE CODE ARE IDENTICAL
C--TAKES PLACE OF VAX ERROR CONTROL ROUTINE SO OVERFLOW CONDITION ON
C  OUTPUT FIELDS DOESN'T GENERATE AN ERROR MESSAGE
      LOGICAL L1,L2,L3,L4
      RETURN
      END
      LOGICAL FUNCTION BOX3 (Y,X,Z,KLAS,NAME,FULNAM)
C--DETERMINES WHETHER A POINT IS IN THE REGION NUMBER KLAS.
C  CALLED BY THE SUBROUTINE BOX3A.
C  ONLY ONE REGION IS TESTED. FOR NET 3 (New Hawaii)
C  THE REGION NUMBER NREGS+1 IS OUTSIDE ALL OF THE NREG REGIONS.  UNLIKE BOX3,
C  BOX3A WILL TEST THIS REGION BY EXCLUDING THE EVENT FROM ALL THE OTHER
C  REGIONS.

C--INPUTS:
C  Y     LATITUDE, DECIMAL DEGREES
C  X     LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z     DEPTH, KM
C  KLAS  REGION NUMBER TO TEST

C--OUTPUTS:
C  BOX3  TRUE IF POINT IS IN REGION OR ON EDGE, FALSE OTHERWISE
C  NAME  3-LETTER NAME FOR REGION IF INSIDE
C  FULNAM  THE FULL (25 CHAR. MAX) REGION NAME

      PARAMETER (NVEXS=82)            !NUMBER OF VERTEX POINTS
      PARAMETER (NREGS=65)            !NUMBER OF DEFINED REGIONS, ALSO BOX3A
      PARAMETER (NLIST=389)            !NUMBER OF VERTICIES IN LIST
      PARAMETER (NLP1=390)            !NLIST + 1

      DIMENSION PX(NVEXS), PY(NVEXS)      !VERTEX COORDS
      CHARACTER*3 NAME, NAM(NREGS)      !SHORT REGION NAMES
      CHARACTER*25 FULNAM,FN(NREGS)      !LONG REGION NAMES
      INTEGER JVEX(NLIST)       !ORDERED LIST OF VERTICIES FOR EACH REGION

C--POINTER TO FIRST VERTEX IN JVEX LIST FOR EACH REGION
      DIMENSION NS(NREGS+1)
C--FICTITIOUS POINTER TO LAST VERTEX PLUS 1
      DATA NS(NREGS+1) /NLP1/

      INCLUDE 'box3.inc'

      BOX3=.FALSE.
C--TEST WHETHER REGION IS ALLOWED FOR THIS DEPTH RANGE
C--0-4.5
      IF (Z.LT.4.5) THEN
        IF ((KLAS.GE.25 .AND. KLAS.LE.50) .OR. KLAS.GE.61) RETURN

C--4.5-14
      ELSE IF (Z.GE.4.5 .AND. Z.LT.14.) THEN
        IF ((KLAS.LE.14) .OR. KLAS.EQ.23 .OR. 
     2  (KLAS.GE.36 .AND. KLAS.LE.50) .OR. KLAS.GE.61) RETURN

C--14-20
      ELSE IF (Z.GE.14. .AND. Z.LT.20) THEN
        IF (KLAS.LE.23 .OR. (KLAS.GE.25 .AND. KLAS.LE.43) .OR.
     2  KLAS.EQ.51 .OR. KLAS.EQ.52 .OR. KLAS.GE.61) RETURN

C--20-70
      ELSE IF (Z.GE.20.) THEN
        IF (KLAS.LE.35 .OR. (KLAS.GE.44 .AND. KLAS.LE.56) .OR. 
     2  KLAS.EQ.58 .OR. KLAS.EQ.59) RETURN

      END IF

C--ACCUMULATE THE SIGNED CROSSING NUMBERS WITH INSID
      INSID=0
C--FIRST VERTEX NUMBERS OF THIS AND NEXT REGION
      N1=NS(KLAS)
      N2=NS(KLAS+1)

C--LOOP OVER POLYGON EDGES TO SEE IF -X AXIS IS CROSSED
      DO 20 I=N1,N2-2
C--THESE ARE THE TWO VERTEX NUMBERS FOR THIS SEGMENT
        J1=JVEX(I)
        J2=JVEX(I+1)

C--CALC THE CROSSING NUMBER, TRANSLATING TEST POINT TO ORIGIN
        ISIC=KSIC (PX(J1)-X, PY(J1)-Y, PX(J2)-X, PY(J2)-Y)
C--WE WILL SAY WE ARE IN THE REGION IF TEST POINT IS ON EDGE
        IF (ISIC.EQ.4) GOTO 55
20    INSID=INSID+ISIC

C--CHECK THE SEGMENT FROM THE LAST BACK TO THE FIRST VERTEX
      J1=JVEX(N2-1)
      J2=JVEX(N1)
      ISIC=KSIC (PX(J1)-X, PY(J1)-Y, PX(J2)-X, PY(J2)-Y)
      IF (ISIC.EQ.4) GOTO 55
      INSID=INSID+ISIC

C--IF INSID=0, THE POINT IS OUTSIDE
C  IF INSID= +/- 1, THE POINT IS INSIDE
      IF (INSID.NE.0) GOTO 55
      BOX3=.FALSE.
      RETURN

C--POINT IS INSIDE BOX OR ON EDGE
55    BOX3=.TRUE.
      NAME=NAM(KLAS)
      FULNAM=FN(KLAS)
      RETURN
      END
      LOGICAL FUNCTION BOX3A (Y,X,Z,KLAS,NAME,FULNAM)
C--DETERMINES WHETHER A POINT IS IN THE REGION NUMBER KLAS.
C  CALLS THE SUBROUTINE BOX3.
C  ONLY ONE REGION IS TESTED. FOR NET 3 (New Hawaii)
C  THE REGION NUMBER NREGS+1 IS OUTSIDE ALL OF THE NREG REGIONS.  UNLIKE BOX3,
C  BOX3A WILL TEST THIS REGION BY EXCLUDING THE EVENT FROM ALL THE OTHER
C  REGIONS.

C--INPUTS:
C  Y     LATITUDE, DECIMAL DEGREES
C  X     LONGITUDE, DECIMAL DEGREES, POSITIVE EAST
C  Z     DEPTH, KM
C  KLAS  REGION NUMBER TO TEST

C--OUTPUTS:
C  BOX3A  TRUE IF POINT IS IN REGION OR ON EDGE, FALSE OTHERWISE
C  NAME  3-LETTER NAME FOR REGION IF INSIDE
C  FULNAM  THE FULL (25 CHAR. MAX) REGION NAME

      PARAMETER (NREGS=65)            !NUMBER OF DEFINED REGIONS
      CHARACTER NAME*3, FULNAM*25
      LOGICAL BOX3

      IF (KLAS .GT. NREGS) THEN
C--TEST ALL REGIONS.  IF EVENT IS NOT IN ANY IT IS IN REGION NREGS+1
        BOX3A=.FALSE.
        DO I=1,NREGS
          IF (BOX3 (Y,X,Z,I,NAME,FULNAM)) RETURN
        END DO
        BOX3A=.TRUE.
        NAME='DIS'
        FULNAM='Distant'

C--THE RESULT IS THAT FOR THE SINGLE REGION
      ELSE
        BOX3A = BOX3 (Y,X,Z,KLAS,NAME,FULNAM)
      END IF
      RETURN
      END
      SUBROUTINE READQ (IUNIT,STRING,LEN,IOS)
C--READS A STRING FROM AN EXTERNAL FILE, ALSO TELLING HOW LONG THE RECORD IS.
C--THIS IS SOMEWHAT SYSTEM DEPENDENT BECAUSE NOT ALL COMPILERS HAVE Q FORMATS.

C--INPUT:
C    IUNIT -LOGICAL UNIT TO READ
C--RETURNS:
C    STRING -ASCII CHARACTER STRING READ
C    LEN    -LENGTH OF RECORD (OR ITS NON-BLANK LENGTH IF THAT IS ALL WE KNOW)
C    IOS    0 IF A NORMAL READ OCCURRED
C           1 IF AN ERROR OR END-OF-FILE OCCURRED

      CHARACTER STRING*(*)
      IOS=0

C--VAX AND SUNS
C      READ (IUNIT,'(Q,A)',ERR=9,END=9) LEN,STRING
C      RETURN

C--OS2 AND G77
      READ (IUNIT,'(A)',ERR=9,END=9) STRING
      LEN=LENG(STRING)
      RETURN

C--ERROR OR EOF
9     IOS=1
      RETURN
      END
      SUBROUTINE DOWNSTR (STR, LEN)
C
C      UPSTR CONVERTS THE CHARACTER STRING STR TO LOWER CASE.
C      LEN IS THE NUMBER OF CHARACTERS TO CONVERT, NOT TO EXCEED THE
C      ACTUAL LENGTH OF STR.
C
C      AUTHOR: FRED KLEIN (U.S.G.S)
C
      CHARACTER            STR*(*)
      INTEGER                  I
      INTEGER                  J
      INTEGER                  LEN

      DO I = 1, LEN
        J = ICHAR(STR(I:I))
        IF (J .GT. 64 .AND. J .LT. 91) STR(I:I) =  CHAR(J + 32)
      END DO
      RETURN
      END

