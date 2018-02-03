-- w textfieldzie podaje numer stackupu
-- i dostaje rysunek jak on wyglada
-- i wszystkie numery PFA jobow, ktore sa oparte na tym stack-upie.
-- do kazdego joba wyswietla skalowanie X i Y.
-- dodac zakladke ustawien (zapis do XMLa)
--
--
-- jak wyglada stackup:
-- folia, prepregi, core, grubosci poszczegolne, zsumowana grubosc calkowita.
-- prostokaty poziome kolorowane odpowiednio grube do wartosci a z boku pojedyncza grubosc.
-- warto by pozniej dodac lakier (ew. peelable). nie pali sie.
--
-- numery jobow w scrolowanym textboxie.

-- PI to core
-- PP to prepreg
-- PC to folia

-- aby otrzymac wlasciwa kolejnosc stackupu nalezy w tabeli RXPLADEVALG posortowac columne LXBENUMMER dla danego stackupu.
-- cyfry w LXBENUMMER nie zawsze wystepuja po sobie, ale zachowana jest kolejnosc (czyli od najmniejszego)
-- patrz tez c:\work\xal\206120\opbygning_raapladevalg.txt

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


SELECT USER FROM DUAL;

SELECT PladeTykkelse
  FROM xal_supervisor.DD_RXPLADEVALG
 WHERE printtype = '206170-005';


-- podaje grubosc
SELECT SUM (COUNT) as total_thickness
  FROM (SELECT PladeTykkelse AS COUNT
          FROM xal_supervisor.DD_RXPLADEVALG
         WHERE printtype = '206170-005');
		 
		 
		 