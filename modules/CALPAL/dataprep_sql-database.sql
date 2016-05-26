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
  ('Epipalaeolithic ', 'epipalaeolithic'),
  ('Early Neolithic?*', 'neolithic'),
  ('Glockenbecher', 'neolithic'),
  ('Middle Neolithic', 'neolithic'),
  ('neolithic', 'neolithic'),
  ('Neolithic', 'neolithic'),
  ('Neolithic ', 'neolithic'),
  ('Neolithic  ', 'neolithic'),
  ('néolithique', 'neolithic'),
  ('néolithique récent ancien', 'neolithic'),
  ('néolithique récent du Sahara occidental intérieur', 'neolithic'),
  ('néolithique récent / néolithique récent du Sahara occidental', 'neolithic'),
  ('néolithique tardif', 'neolithic'),
  ('Neolitic', 'neolithic'),
  ('neo moyen I', 'neolithic'),
  ('PPN', 'neolithic'),
  ('PPNB', 'neolithic'),
  ('Bodrogkeresztúr', 'chalcolithic'),
  ('Chalcolithic', 'chalcolithic'),
  ('Early Chalc', 'chalcolithic'),
  ('Late Chalc', 'chalcolithic'),
  ('Late Chalcolithic', 'chalcolithic'),
  ('Bronzeage', 'bronzeage'),
  ('Bronze Age', 'bronzeage'),
  ('Bronze  Age', 'bronzeage'),
  ('Early Bronze Age', 'bronzeage'),
  ('Hallstatt Era', 'ironage'),
  ('Iron Age', 'ironage'),
  ('Iron Age ', 'ironage');

SELECT periodreplace.SIMPERIOD, dates.PERIOD
FROM dates
LEFT JOIN periodreplace
ON dates.PERIOD=periodreplace.PERIOD; 