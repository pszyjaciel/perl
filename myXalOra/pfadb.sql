
--nowa instalacja bazy danych 11g (11:04 21-06-2017)
--SQLTools_18b38.zip nie dziala na xp
--zainstalowalem tego: InstallSQLTools_16b24.exe

--jak nie idze zalogowac z odleglego komputera
--to odblokowac port 1521 na firewallu i pojdzie.

--byla dodana zmienna TNS_ADMIN c:\XEClient\network\admin
--dla clienta XE (buildUpViewer\OracleXEClient.exe  - 31MB)
--teraz jom usunolem i pojszlo.

--podmiana plikuf dbf nic nie daje tylko potem same problemy.
--moze trza bylo przekopiowac caly katalog c:\oraclexe ?

-- utworzenie tablespaca 200M konczy sie ORA-03113 gdy robie to
-- na innej maszynie niz DB server

SELECT * FROM user_tables;
SELECT * FROM dual;

-- system musi byc sysdba
CONNECT SYSTEM/manager;

CREATE USER pfa IDENTIFIED BY pfa_passwd;

GRANT CREATE TABLESPACE TO pfa;
GRANT CREATE SESSION TO pfa;
GRANT ALTER DATABASE TO pfa;
GRANT DROP TABLESPACE TO pfa;
GRANT SELECT ON dba_data_files TO pfa;

CONNECT pfa/pfa_passwd@xe;

-- jak robie zdalnie to ORA-03113: end-of-file on communication channel
CREATE TABLESPACE pfadata datafile 'c:\oraclexe\app\oracle\oradata\XE\pfadata.dbf' size 200M
CREATE TABLESPACE pfadata datafile 'c:\oraclexe\app\oracle\oradata\XE\pfadata.dbf' size 200M;
ALTER database datafile 'c:\oraclexe\app\oracle\oradata\XE\pfadata.dbf' RESIZE 500M;
select * from dba_data_files;
-- DROP TABLESPACE pfadata;

-- NLS_CHARACTERSET        AL32UTF8
SELECT * FROM v$NLS_PARAMETERS;

------------------------------------------


