      SUBROUTINE HYSOL (N,Y,NFREE,LZFIX)
C--USES SVD TO INVERT THE PARTIAL DERIV MATRIX A FOR THE HYPO ADJUSTMENT
C--VECTOR Y. ALSO CALCULATES EIGENVALUES, EIGENVECTORS, COVARIANCE,
C--IMPORTANCE, AND ERROR ELLIPSE.
      LOGICAL WITHU,LZFIX
      INCLUDE 'common.inc'
      DIMENSION Y(4),V3(3,3),TSVD(MMAX)
      WITHU=DONE .AND. (LPRT.OR.LARC)
      DO 2 I=1,4
2     EIGVAL(I)=0.

C--OBTAIN THE SVD OF MATRIX A.
C--THE DATA VECTOR OF TT RESIDUALS R IS INPUT IN THE N+1ST COL OF A.
C--A IS REPLACED BY U AND R IS REPLACED BY UT*R IN SVD.
      CALL HYSVD (A,EIGVAL,V,MMAX,4,M,N,1,WITHU,.TRUE.,TSVD)

C--NFREE IS THE ACTUAL DEGREES OF FREEDOM USED
C--(THE NO. OF EIGENVALUES > EIGTOL)
      NFREE=0
      DO 5 I=1,N
      IF (EIGVAL(I).GT.EIGTOL) NFREE=NFREE+1
5     CONTINUE

C--CALCULATE ADJUSTMENT VECTOR Y AS V*S**-1*(UT*R)
C--MOVE THE HYPOCENTER ONLY IN DIRECTIONS WITH LARGER EIGENVALUE CONTROL
C--DAMP THE MOVES WITH A FACTOR WHOSE INFLUENCE INCREASES FOR SMALL EIGENVALUES
      DO 10 I=1,4
        Y(I)=0.
        IF (I.GT.N) GO TO 10
        DO 8 J=1,NFREE
8       Y(I)=Y(I)+V(I,J)*A(J,N+1)/ (EIGVAL(J)+0.006)
10    CONTINUE

C--DAMP THE ADJUSTMENT VECTOR
C--USE EXTRA DAMPING IF THE SOLUTION IS NOT CONVERGING QUICKLY
      I=ITRLIM*.6
      TEMP=DAMP
      IF (ITR.GT.I) TEMP=.5*DAMP
      DO 11 I=1,4
11    Y(I)=Y(I)*TEMP

C--CALCULATE IMPORTANCE VECTOR AS TRACE OF INFORMATION MATRIX U*UT
      IF (WITHU) THEN
        DO 15 I=1,M
          TEMP=0.
          DO 12 J=1,N
12        TEMP=TEMP+A(I,J)**2
15      IMPORT(I)=TEMP*1000.
      END IF

C--FIND LENGTH OF HYPO ADJ VECTOR IN KM
      RR=0.
      DO 25 I=2,N
25    RR=RR+Y(I)**2
      RR=SQRT(RR)

C--SKIP THE REMAINING CALCS IF THEY ARE NOT NEEDED FOR FINAL OUTPUT
      IF (.NOT.DONE .AND. KPRINT.LT.5) GO TO 110
C--CALCULATE COVARIANCE MATRIX AS SIGMA**2 * V * EIGVAL**-2 * VT
C--ESTIMATED ARRIVAL TIME ERROR
      SIGSQ=RDERR**2+ERCOF*RMS**2
      TEMP=EIGTOL**2
      DO 52 I=1,4
      DO 50 J=1,I
        COVAR(I,J)=0.
        IF (I.GT.N .OR. J.GT.N) THEN
          IF (I.EQ.J) COVAR(I,J)=999.
          GO TO 50
        END IF
        DO 45 L=1,N
45      COVAR(I,J)=COVAR(I,J)+V(I,L)*V(J,L)/(EIGVAL(L)**2+TEMP)
        COVAR(I,J)=SIGSQ*COVAR(I,J)
50    COVAR(J,I)=COVAR(I,J)
52    CONTINUE

C--EVALUATE THE HYPOCENTER ERROR ELLIPSE BY DIAGONALIZING
C--THE SPATIAL PART OF THE COVARIANCE MATRIX
C--USE A AS TEMPORARY STORAGE
      DO 57 I=1,3
        DO 55 J=1,3
55      A(I,J)=COVAR(I+1,J+1)
57    CONTINUE
      CALL HYSVD (A,SERR,V3,MMAX,3,3,3,0,.FALSE.,.TRUE.,TSVD)
      DO 60 I=1,3
        SERR(I)=SQRT(SERR(I))
        IF (SERR(I).GT.99.) SERR(I)=99.
60    CONTINUE

C--COMPUTE ERH AND ERZ AS THE LARGEST OF THE HORIZ AND VERTICAL
C--PROJECTIONS OF THE PRINCIPAL STANDARD ERRORS
      ERH=0.
      ERZ=0.
      DO 65 I=1,3
        TEMP=SERR(I)*SQRT(V3(1,I)**2+V3(2,I)**2)
        IF (TEMP.GT.ERH) ERH=TEMP
        TEMP=SERR(I)*ABS(V3(3,I))
        IF (TEMP.GT.ERZ) ERZ=TEMP
65    CONTINUE
      IF (ERZ.GT.99.) ERZ=99.
      IF (ERH.GT.99.) ERH=99.

C--NOW CALC THE ORIENTATIONS OF THE PRINCIPAL STD ERRORS
      DO 90 J=1,3
        IAZ(J)=0
        IDIP(J)=90
        TEMP=SQRT(V3(1,J)**2+V3(2,J)**2)
        IF (TEMP.EQ.0.) GO TO 90
        IAZ(J)=RDEG*ATAN2(-V3(2,J),V3(1,J))
        IDIP(J)=RDEG*ATAN2(V3(3,J),TEMP)
        IF (IDIP(J).LT.0) THEN
          IDIP(J)=-IDIP(J)
          IAZ(J)=IAZ(J)+180
        END IF
        IF (IAZ(J).LT.0) IAZ(J)=IAZ(J)+360
90    CONTINUE
110   RETURN
      END
