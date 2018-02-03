
----------------------- smietnik --------------------
ALTER TABLE pfa_printkart ADD (
PPSCALEX NUMBER(32, 16) NOT NULL,
PPSCALEY NUMBER(32, 16) NOT NULL
);

SELECT * FROM pfa_printkart;

DELETE FROM pfa_printkart  WHERE VARENUMMER = '114X00271722';

-- tu trza zrobic procedure sprawdzajacom czy '1' nie wystepuje kilka razy dla roznych powierzchni
UPDATE pfa_printkart
SET HAL = 1, BLYFRIHAL = 0, KEMSN = 0, KEMAG = 0
WHERE VARENUMMER = '114X00271722';

INSERT INTO pfa_printkart VALUES (
'114X00271722', '3 035 7800 050',
610, 457, 139.0, 117.68, 11.72, 8.64,
12, 672,
15.98, 14.85, 2.5, 1.66,
0, 0,
1.000200, 1.000100,
3, 4, 7, 8,
0, 0, 0, 1
);

INSERT INTO pfa_printkart VALUES (
'292X04951719', '9779184-03',
610, 457, 0, 0, 99.3, 80,
0, 25,
14.17, 5.06, 0.94, 0.83, 0.14, 0.14,
1.000200, 1.000200,
5, 5, 0, 0,
0, 0, 0, 1
);

SELECT * FROM pfa_printkart;

DROP TABLE pfa_printkart;