USE 14C;

CREATE TABLE periodreplace(
  PERIOD VARCHAR(255),
  SIMPERIOD VARCHAR(255)
  );

INSERT INTO periodreplace VALUES
  ('Late Palaeolithic', 'palaeolithic'),
  ('Late Palaeolithic (Ahrensburgian?)', 'palaeolithic'),
  ('Palaeolithic', 'palaeolithic'),
  ('Epilalaeolithic', 'epipalaeolithic'),
  ('Epipalaeolithic', 'epipalaeolithic'),
  ('Epipalaeolithic ', 'epipalaeolithic');

SELECT periodreplace.SIMPERIOD, dates.PERIOD
FROM dates
LEFT JOIN periodreplace
ON dates.PERIOD=periodreplace.PERIOD; 