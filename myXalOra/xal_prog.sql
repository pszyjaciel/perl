
SELECT TYPE,DATASET,NAME,PASSWORD FROM XALUTIL ORDER BY TYPE,DATASET;
SELECT FILEID,FIELDID,NAME,TYPE,Length,FLAGS,INFO FROM XALDICT ORDER BY FILEID,FIELDID;
SELECT UserEnv('SESSIONID') FROM XALDUAL;
SELECT XAL_SEQ.NEXTVAL FROM XALDUAL;

SELECT LXBENUMMER , INT1 ,ROWID FROM USERINFO ORDER BY DATASET,TYPE,USERID;

SELECT  LXBENUMMER,SIDSTRETTET,TYPE,USERID,INT1,INT2,INT3,INT4,INT5,INT6,INT7,INT8,INT9,DATO1,DATO2,DATO3,TEKST1,TEKST2,TEKST3,
  TEKST4,TEKST5,TEKST6,TEKST7,TEKST8,TEKST9,TEKST10,TEKST50,REAL1,NEJJA1,NEJJA2,NEJJA3,NEJJA4,NEJJA5,NEJJA6,NEJJA7,NEJJA8,NEJJA9,ROWID
  FROM USERINFO ORDER BY DATASET,TYPE,USERID;


 SELECT   LXBENUMMER , TEKST50 ,ROWID FROM USERINFO ORDER BY DATASET,TYPE,USERID;


SELECT  LXBENUMMER,SIDSTRETTET,USERID,NAME,TEKST1,TEKST2,TEKST3,TEKST4,TEKST5,TEKST6,TEKST7,TEKST8,TEKST9,TEKST10,TEKST11,TEKST12,
  TEKST13,TEKST14,TEKST50,INT1,INT2,INT3,INT4,INT5,INT6,INT7,REAL1,REAL2,REAL3,DATO1,DATO2,DATO3,DATO4,NEJJA1,NEJJA2,NEJJA3,NEJJA4,
  NEJJA5,NEJJA6,NEJJA7,NEJJA8,NEJJA9,NEJJA10,NEJJA11,NEJJA12,NEJJA13,NEJJA14,NEJJA15,INT8,INT9,INT10,DATO5,REAL4,REAL5,REAL6,INT11,INT12,INT13,INT14,NEJJA16,ROWID
FROM PARAMETRE ORDER BY DATASET,USERID,NAME;

SELECT * FROM AFDELING ORDER BY DATASET,NUMMER;
SELECT * FROM FIRMAOPLYSNINGER;
SELECT MIN(LXBENUMMER) FROM FIRMAOPLYSNINGER ;

SELECT  LXBENUMMER,SIDSTRETTET,ANSVAR,BESKRIVELSE,OPRETTETAF,OPRETTETDATO,TERMIN,BUFFERDAGE,NULPUNKTSDATO,NXSTEGANG,IMPORTRECID,ROWID
FROM DD_JOBKART ORDER BY DATASET,ANSVAR,NXSTEGANG,LXBENUMMER;


grant select on ordrepost to pkr;
grant select on ordrekart to pkr;
COMMIT;

SELECT DISTINCT ordrenavn FROM xal_supervisor.ordrekart;
SELECT * FROM xal_supervisor.ordrekart ORDER BY ordrenummer;

-- zawiera ordrenummer
SELECT DISTINCT(table_name) FROM all_tab_columns WHERE column_name = 'ORDRENUMMER';
SELECT * FROM xal_supervisor.ordrekart WHERE ordrenummer = 83459;
SELECT * FROM xal_supervisor.ordrepost WHERE ordrenummer = 83454 AND linienr = 1;
SELECT varenummer FROM xal_supervisor.ordrepost WHERE ordrenummer = 83454 AND linienr = 1;

SELECT * FROM xal_supervisor.ordrepost WHERE ordrenummer = 83454;
SELECT ordrenavn FROM xal_supervisor.ordrekart WHERE ordrenummer = 83454;

SELECT * FROM ordrepost WHERE varenummer = '292X05141717';

SELECT op.ordrenummer AS opon, op.varenummer AS opvn, op.betegnelse AS opbt, ok.ordrenavn AS okon
FROM xal_supervisor.ordrepost op,  xal_supervisor.ordrekart ok
WHERE ok.ordrenummer = 83459
AND op.ordrenummer = ok.ordrenummer;

-- subquery
SELECT * FROM xal_supervisor.ordrepost op
WHERE op.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '292X05141717');

-- wyswietla nazwe klienta dla numeru joba:
SELECT ok.ordrenavn, ok.land FROM xal_supervisor.ordrekart ok
WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '292X05141717');

-- tez podaje nazwe klienta dla numeru zlecenia
SELECT * FROM xal_supervisor.ordrekart WHERE ordrenummer = 83459;
SELECT ordrenavn FROM xal_supervisor.ordrekart WHERE ordrenummer = 103457;

SELECT * FROM xal_supervisor.ordrekart ok
WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '292X05141717');

SELECT DISTINCT ordrenavn FROM xal_supervisor.ordrekart ok
WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '292X05141717');

SELECT ordrenummer FROM xal_supervisor.ordrekart ok
--WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '292X05141717');
  WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE varenummer = '032X01691725');

SELECT * FROM xal_supervisor.ordrekart ok
WHERE ok.ordrenummer IN (SELECT ordrenummer FROM xal_supervisor.ordrepost WHERE ordrenummer = 106327);

SELECT DISTINCT ordrenavn FROM xal_supervisor.ordrekart ok
			WHERE ok.ordrenummer IN
			  (SELECT ordrenummer FROM xal_supervisor.ordrepost
          -- WHERE varenummer = '032X01701725');
          WHERE varenummer = '032X01691725');


SELECT * FROM XAL_SUPERVISOR.dd_printtype;
SELECT * FROM XAL_SUPERVISOR.dd_fixtur;
SELECT * FROM XAL_SUPERVISOR.dd_mixprint;
SELECT * FROM XAL_SUPERVISOR.mpskart;

-- wyswietla tabele w ktorych wystepuje kolumna PLADETYKKELSE:
SELECT DISTINCT(table_name) FROM all_tab_columns WHERE column_name = 'PLADETYKKELSE';

select Pladetykkelse from XAL_SUPERVISOR.DD_Rxpladevalg;

-- czy wystepuje
select Count(*) from XAL_SUPERVISOR.DD_printkart WHERE varenummer = '292X01860941';

-- wyswietla cora dla danego buildupa (a co gdy nie multilayer?)
SELECT DISTINCT lk.varenummer, lk.varenavn
				FROM XAL_SUPERVISOR.LAGERKART lk, XAL_SUPERVISOR.DD_RXPLADEVALG rpv
  				WHERE rpv.printtype = '204080-001'
          --WHERE rpv.printtype = 'P11621754'
  				AND lk.VARENUMMER = rpv.RXPLADE
  				AND SUBSTR(lk.varenummer, 1, 2) IN ('PI');


SELECT * FROM LAGERSTYKLIST;

SELECT * FROM LAGERSTYKLIST
  WHERE fathervarenr = '342-00110606'
  AND childvarenr = 'P11621754';


SELECT * FROM XAL_SUPERVISOR.LAGERKART lk
  WHERE lk.VARENUMMER = 'PI70502353';

-- wyswietla nazwe materialu dla danego oznaczenia
SELECT varenummer, varenavn FROM XAL_SUPERVISOR.LAGERKART lk
  --WHERE lk.VARENUMMER = 'PI70502353';
  --WHERE lk.VARENUMMER = 'P11621754';
  WHERE lk.VARENUMMER = 'P71621802';

SELECT pk.VARENUMMER, lk.VARENAVN, lk.pladetykkelse
  FROM XAL_SUPERVISOR.DD_PRINTKART pk, XAL_SUPERVISOR.LAGERKART lk, XAL_SUPERVISOR.DD_RXPLADEVALG rpv
  WHERE rpv.RXPLADE = 'PI70502353'
  AND lk.VARENUMMER = rpv.RXPLADE
  AND pk.VARENUMMER = '442X00361715';


-- zwraca numer i nazwe materialu dla podanego buildupa:
SELECT DISTINCT lk.varenummer, lk.varenavn
				FROM XAL_SUPERVISOR.LAGERKART lk, XAL_SUPERVISOR.DD_RXPLADEVALG rpv
  				WHERE rpv.printtype = '208158-002'
          --WHERE rpv.printtype = 'P71621802'
  				AND lk.VARENUMMER = rpv.RXPLADE
  				AND SUBSTR(lk.varenummer, 1, 2) IN ('PI');


SELECT varenummer FROM XAL_SUPERVISOR.DD_printkart WHERE varenummer = '292X01860941';
SELECT Count(*) FROM XAL_SUPERVISOR.DD_printkart WHERE varenummer = '292X01860941';

SELECT * FROM XAL_SUPERVISOR.DD_printkart WHERE SUBSTR(varenummer, 1, 8) IN ('504X0412');
SELECT Count(*) FROM XAL_SUPERVISOR.DD_printkart WHERE SUBSTR(varenummer, 1, 8) IN ('504X0412');


CREATE OR REPLACE FUNCTION x(input IN VARCHAR2)
  RETURN VARCHAR2 AS
  output VARCHAR2(12);
BEGIN
  output :=input;
  RETURN (output);
END;
/

SELECT SUBSTR(x('hello'),1,100) FROM DUAL;

SELECT * FROM dual;

WHERE SUBSTR(parm,1,1) IN ('P','M','F')
AND substr(parm,2,1) between '0' and '9'
AND substr(ltrim(substr(parm,2),'0123456789'),1,1) = '_'




SELECT rpv.LXBENUMMER,
         pk.VARENUMMER AS cam_nummer,
         pk.tekniskgodkendtaf AS cam_operator,
         pk.typenavn AS opbygnig,
         rpt.PRINTTYPE,
         rpv.RXPLADE,
         lk.VARENAVN,
         lk.pladetykkelse,
         lk.cutykkelseside1,
         lk.cutykkelseside2
    FROM XAL_SUPERVISOR.DD_RXPLADETYPER rpt,
         XAL_SUPERVISOR.DD_RXPLADEVALG rpv,
         XAL_SUPERVISOR.LAGERKART lk,
         XAL_SUPERVISOR.DD_PRINTKART pk
   --   WHERE     pk.VARENUMMER = '292X04751714'  -- duze litery!
   WHERE     pk.VARENUMMER = '442X00361715'
         AND rpv.PRINTTYPE = rpt.TYPENAVN
         AND rpt.TYPENAVN = pk.TYPENAVN
         AND lk.VARENUMMER = rpv.RXPLADE
ORDER BY rpv.LXBENUMMER;




-- wyswietla jakie tablice moze czytac user (uruchamiac jako system):
SELECT * FROM DBA_TAB_PRIVS WHERE grantee = 'PKR';
SELECT * FROM DBA_TAB_PRIVS WHERE owner = 'PKR';

grantee,owner,table_name,grantor,privilege,grantable
grantee	owner	table_name	grantor	privilege	grantable
--PKR	XAL_SUPERVISOR	DD_PRINTKART	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	DD_RXPLADETYPER	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	DD_RXPLADEVALG	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	LAGERKART	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	MPSOPERATION	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	MPSRESSKART	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	MPSRUTE	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	ORDREKART	XAL_SUPERVISOR	SELECT	NO
--PKR	XAL_SUPERVISOR	ORDREPOST	XAL_SUPERVISOR	SELECT	NO

