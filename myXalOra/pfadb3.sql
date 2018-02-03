-- nowa instalacja bazy danych 11g (11:04 21-06-2017)
-- SQLTools_18b38.zip nie dziala na xp
-- zainstalowalem tego: InstallSQLTools_16b24.exe

-- jak nie idze zalogowac z odleglego komputera
-- to odblokowac port 1521 na firewallu i pojdzie.

-- byla dodana zmienna TNS_ADMIN c:\XEClient\network\admin
-- dla clienta XE (buildUpViewer\OracleXEClient.exe  - 31MB)
-- teraz jom usunolem i pojszlo.

-- podmiana plikuf dbf nic nie daje tylko potem same problemy.
-- moze trza bylo przekopiowac caly katalog c:\oraclexe ?

-- utworzenie tablespaca 200M konczy sie ORA-03113 gdy robie to
-- na innej maszynie niz DB server

-- system musi byc sysdba
CONNECT SYSTEM/manager;
GRANT CREATE TABLESPACE TO pfa;
GRANT ALTER DATABASE TO pfa;
GRANT DROP TABLESPACE TO pfa;
GRANT SELECT ON dba_data_files TO pfa;
GRANT ALL PRIVILEGES TO pfa;

-- gdy lokalnie to dziala; gdy zdalnie to ORA-12560, tns adapter error
CONNECT pfa/pfa_passwd;

CREATE TABLESPACE pfadata datafile 'c:\oraclexe\app\oracle\oradata\XE\pfadata.dbf' size 200M;
ALTER database datafile 'c:\oraclexe\app\oracle\oradata\XE\pfadata.dbf' RESIZE 500M;
select * from dba_data_files;
-- DROP TABLESPACE pfadata;

-- NLS_CHARACTERSET        AL32UTF8
SELECT * FROM v$NLS_PARAMETERS;

-- c:\XEClient\bin\sqlplus.exe
-- sqlplus pkr/pkramarz@pridana.xalora

SELECT * FROM user_tables;

-------------------------------------------------------------
DROP TABLE pfa_job;

CREATE TABLE pfa_job (
  VARENUMMER VARCHAR(20) NOT NULL,
  KUNDETEGNINGSNR VARCHAR(40) NOT NULL,
  ANTALLPPXPP NUMBER NOT NULL, ANTALPRINTPXPP NUMBER NOT NULL,
  HAL NUMBER(3), BLYFRIHAL NUMBER(3), KEMSN NUMBER(3), KEMAG NUMBER(3), KEMISKNIAU NUMBER(3),
  DONEAT TIMESTAMP,

  -- FK specifies that the values in the column must correspond to values
  -- in a referenced primary key or unique key column or that they are NULL
  CONSTRAINT job_pk
    PRIMARY KEY (VARENUMMER)
);

-- procedura sprawdzajaca czy '1' nie wystepuje kilka razy dla roznych powierzchni
CREATE OR REPLACE TRIGGER check_surface_trig
  BEFORE INSERT OR UPDATE ON pfa_job
  FOR EACH ROW
DECLARE
      myHAL INT;
      myBLYFRIHAL INT;
      myKEMSN INT;
      myKEMAG INT;
      myKEMISKNIAU INT;
BEGIN
    SELECT :new.HAL INTO myHAL FROM dual;
    SELECT :new.BLYFRIHAL INTO myBLYFRIHAL FROM dual;
    SELECT :new.KEMSN INTO myKEMSN FROM dual;
    SELECT :new.KEMAG INTO myKEMAG FROM dual;
    SELECT :new.KEMISKNIAU INTO myKEMISKNIAU FROM dual;
    -- SELECT :new.KEMAG, :new.KEMISKNIAU INTO myKEMAG, myKEMISKNIAU FROM dual;
      --dbms_output.put_line( myHAL );
    IF (myHAL = 0 AND myBLYFRIHAL = 0 AND myKEMSN = 0 AND myKEMAG = 0 AND myKEMISKNIAU = 0) THEN
       RAISE_APPLICATION_ERROR(-20101, 'no surface?');
    ELSIF (myHAL + myBLYFRIHAL + myKEMSN + myKEMAG + myKEMISKNIAU <> 1 ) THEN
       RAISE_APPLICATION_ERROR(-20102, 'many surfaces?');
    ELSIF (myHAL < 0 OR myBLYFRIHAL < 0 OR myKEMSN < 0 OR myKEMAG < 0 OR myKEMISKNIAU < 0) THEN
       RAISE_APPLICATION_ERROR(-20103, 'kind of surface?');
    END IF;
END;
/

DELETE FROM pfa_job WHERE VARENUMMER = '114X00271722';
DELETE FROM pfa_job WHERE VARENUMMER = '292X01801018';
DELETE FROM pfa_job WHERE KUNDETEGNINGSNR = '3 035 7800 050';
DELETE FROM pfa_job WHERE hal = 0;

INSERT INTO pfa_job VALUES (
  '114X00271722', '3 035 7800 050',
  12, 672,
  0, 0, 0, 1, 0,
  -- '97-01-31 09:26:50'
  CURRENT_TIMESTAMP
);

UPDATE pfa_job
SET HAL = 1, BLYFRIHAL = 0, KEMSN = 0, KEMAG = 0, KEMISKNIAU = 1
WHERE VARENUMMER = '114X00271723';

variable  my_id number
UPDATE pfa_job SET hal = 1 WHERE VARENUMMER = '114X00271723' returning my_id into :id;

INSERT INTO pfa_job VALUES ('114X00271722', '3 035 7800 050', 12, 672, 0, 0, 0, 1, 0, CURRENT_TIMESTAMP);
INSERT INTO pfa_job VALUES ('292X01801018', '9779994-04', 7, 21, 0, 1, 0, 0, 0, CURRENT_TIMESTAMP);

SELECT * FROM pfa_job;
SELECT * FROM pfa_job2;
SELECT * FROM pfa_layer;

-------------------------------------

DROP TRIGGER check_duplicate_trig;
DROP TABLE pfa_layer;

CREATE TABLE pfa_layer (
  VARENUMMER VARCHAR(20) NOT NULL,
  LayerName VARCHAR(10) NOT NULL,
  LayerType VARCHAR(10) NOT NULL,
  Lines NUMBER(32, 16) NOT NULL,
  Space NUMBER(32, 16) NOT NULL,
  Via2cu NUMBER(32, 16) NOT NULL,
  AnnRing NUMBER(32, 16) NOT NULL,
  CuPercent NUMBER(32, 16) NOT NULL,
  DONEAT TIMESTAMP NOT NULL,

  CONSTRAINT layer_pk
    FOREIGN KEY (VARENUMMER)
    REFERENCES pfa_job(VARENUMMER)
    ON DELETE CASCADE
);

-- this trigger disallows to insert a layername that already exists for a particular varenummer
CREATE OR REPLACE TRIGGER check_duplicate_trig
  BEFORE INSERT OR UPDATE ON pfa_layer
  FOR EACH ROW
DECLARE
      myLayerNameCount INT;
      myVareNummerCount INT;
      myLayerName VARCHAR(20);
      myVareNummer VARCHAR(20);
BEGIN
    SELECT :new.LayerName INTO myLayerName FROM dual;
    SELECT :new.VareNummer INTO myVareNummer FROM dual;
    SELECT Count(*) INTO myVareNummerCount FROM pfa_layer WHERE varenummer = myVareNummer;
    SELECT Count(*) INTO myLayerNameCount FROM pfa_layer WHERE LayerName = myLayerName;

    -- nie wolno nic wstawic gdy varenummer i layer name ten sam
    -- a co jak chce zmienic record?
     IF ((myLayerNameCount > 0) AND (myVareNummerCount > 0)) THEN
       RAISE_APPLICATION_ERROR(-20102, 'layer exists.');
    END IF;
END;
/

-- https://stackoverflow.com/questions/28037539/how-to-check-if-the-record-exists-before-insert-to-prevent-duplicates
-- CREATE UNIQUE INDEX UIX_pfa_layer ON pfa_layer (LayerName ASC) WITH (IGNORE_DUP_KEY = ON);

INSERT INTO pfa_layer VALUES ('114X00271722', 'top', 'mixed', 200, 125, 500, 156, 32, CURRENT_TIMESTAMP);
INSERT INTO pfa_layer VALUES ('114X00271722', 'bottom', 'mixed', 200, 125, 500, 155, 31, CURRENT_TIMESTAMP);
INSERT INTO pfa_layer VALUES ('292X01861724', 'top', 'mixed', 510, 159, 500, 154, 51, CURRENT_TIMESTAMP);
DELETE FROM pfa_layer WHERE varenummer = '114X00271722';

INSERT INTO pfa_layer VALUES ('292X01801018', 'il2p', 'mixed', 510, 159, 500, 154, 51, CURRENT_TIMESTAMP);
INSERT INTO pfa_layer VALUES ('292X01801018', 'il7p', 'mixed', 510, 159, 500, 154, 51, CURRENT_TIMESTAMP);
DELETE FROM pfa_layer WHERE varenummer = '292X01861724';

SELECT Count(*) FROM pfa_layer WHERE layername = 'bottom';
SELECT Count(*) FROM pfa_layer WHERE varenummer = '292X01861724';

SELECT COUNT(*) FROM pfa_layer HAVING COUNT(*) > 1;

select varenummer, count(varenummer) from pfa_layer group by varenummer having count (varenummer) > 1;
SELECT COUNT(*) FROM pfa_layer GROUP BY varenummer HAVING Count(*) > 1;

SELECT * FROM pfa_layer;
SELECT * FROM pfa_job;

DELETE FROM pfa_job WHERE hal = 0;

-- uwaga na wielkosc tabeli: np. srednio 10 warstw na 1 job
-- wiec 1000 jobuf to 10k wierszy.

----------------------------------------
DROP TABLE pfa_pcb;

CREATE TABLE pfa_pcb (
  VARENUMMER VARCHAR(20) UNIQUE NOT NULL,
  PKLXNGDE NUMBER(32, 16) NOT NULL,
  PKBREDDE NUMBER(32, 16) NOT NULL,
  MINDRILL NUMBER(32, 16) NOT NULL,
  DONEAT TIMESTAMP NOT NULL,

  CONSTRAINT pcb_pk
    FOREIGN KEY (VARENUMMER)
    REFERENCES pfa_job(VARENUMMER)
    ON DELETE CASCADE
);

INSERT INTO pfa_pcb VALUES (
  '114X00271722',
  11.72, 8.64,
  300,
  100,
  99,
  120,
  95,
  CURRENT_TIMESTAMP
);

SELECT * FROM pfa_pcb;

----------------------------------------
DROP TABLE pfa_ark;

CREATE TABLE pfa_ark (
  VARENUMMER VARCHAR(20) UNIQUE NOT NULL,
  LPLXNGDE NUMBER(32, 16) NOT NULL, LPBREDDE NUMBER(32, 16) NOT NULL,
  PKANTALX NUMBER NOT NULL, PKANTALY NUMBER NOT NULL,
  PKSTEPX NUMBER(32, 16) NOT NULL, PKSTEPY NUMBER(32, 16) NOT NULL,
  DONEAT TIMESTAMP NOT NULL,

  CONSTRAINT ark_pk
    FOREIGN KEY (VARENUMMER)
    REFERENCES pfa_job(VARENUMMER)
    ON DELETE CASCADE
);

INSERT INTO pfa_ark VALUES (
  '114X00271722',
  139.0, 117.68,
  8, 7,
  15.84, 13.42,
  CURRENT_TIMESTAMP
);

SELECT * FROM pfa_ark;

----------------------------------------
DROP TABLE pfa_panel;

CREATE TABLE pfa_panel (
  VARENUMMER VARCHAR(20) UNIQUE NOT NULL,
  PPLXNGDE NUMBER(32, 16) NOT NULL, PPBREDDE NUMBER(32, 16) NOT NULL,
  CUAREALL NUMBER(32, 16) NOT NULL, CUAREALK NUMBER(32, 16) NOT NULL,
  NIAUAREALL NUMBER(32, 16) NOT NULL, NIAUAREALK NUMBER(32, 16) NOT NULL,
  GALVNIAUAREALL NUMBER(32, 16)  NOT NULL, GALVNIAUAREALK NUMBER(32, 16) NOT NULL,
  PPSCALEX NUMBER(32, 16) NOT NULL, PPSCALEY NUMBER(32, 16) NOT NULL,
  LPANTALX NUMBER NOT NULL, LPANTALY NUMBER NOT NULL,
  LPSTEPX NUMBER(32, 16) NOT NULL, LPSTEPY NUMBER(32, 16) NOT NULL,
  DONEAT TIMESTAMP NOT NULL,

  CONSTRAINT panel_pk
    FOREIGN KEY (VARENUMMER)
    REFERENCES pfa_job(VARENUMMER)
    ON DELETE CASCADE
);

INSERT INTO pfa_panel VALUES (
  '114X00271722',
  610, 457,
  15.98, 14.85,
  2.5, 1.66,
  0, 0,
  1.000200, 1.000100,
  3, 4,
  127.68, 141.45,
  CURRENT_TIMESTAMP
);


SELECT * FROM pfa_job;
SELECT * FROM pfa_layer;
SELECT * FROM pfa_pcb;
SELECT * FROM pfa_ark;
SELECT * FROM pfa_panel;


INSERT INTO pfa_job VALUES (
      '777X11111008', '113322-111_V5',
      188, 199,
      1, 1, 1, 0, 1,
      CURRENT_TIMESTAMP);



INSERT INTO pfa_job VALUES (
      '777X11111019', '113322-111_V7',
      288, 299,
      1, 1, 0, 0, 1,
      CURRENT_TIMESTAMP);


------------------------------

create table t ( x int );
create sequence s;

declare
  l_id  number;
  begin
    select s.nextval into l_id from dual;
    insert into t values ( l_id );
    dbms_output.put_line( l_id );
    end;
/

declare
  l_id  number;
    begin
    insert into t values ( s.nextval ) returning x into l_id;
    dbms_output.put_line( l_id );
    end;
/

INSERT INTO t VALUES (11);
SELECT * FROM t;



DROP TABLE pfa_job2;

CREATE TABLE pfa_job2 (
  --VARENUMMER VARCHAR(20) NOT NULL PRIMARY KEY,
  VARENUMMER VARCHAR(20) NOT NULL,
  KUNDETEGNINGSNR VARCHAR(40) NOT NULL,
  ANTALLPPXPP NUMBER NOT NULL, ANTALPRINTPXPP NUMBER NOT NULL,
  HAL NUMBER(3), BLYFRIHAL NUMBER(3), KEMSN NUMBER(3), KEMAG NUMBER(3), KEMISKNIAU NUMBER(3),
  DONEAT TIMESTAMP
);

SELECT * FROM pfa_job2;

INSERT INTO pfa_job2 VALUES ('292X01801016', '9779994-06', 7, 21, 0, 1, 0, 0, 0, CURRENT_TIMESTAMP);
