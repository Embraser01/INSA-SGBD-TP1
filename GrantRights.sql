--Requete qui recupere toutes les tables
SELECT table_name
  from user_tables;

--Requete qui genere les commandes pour la selection
SELECT 'GRANT SELECT ON '||table_name||' to MAFERNANDES;'
  FROM user_tables;

-- code sql+ pour generer les commandes

SET HEADING OFF
SET ECHO OFF
SET FEEDBACK OFF
SPOOL "grant.sql" REPLACE;

SELECT 'GRANT SELECT ON '||table_name||' to MAFERNANDES;'
FROM USER_TABLES;

SPOOL OFF;

/

SPOOL "grant.sql" APPEND;


SELECT 'GRANT UPDATE ON '||table_name||' to MAFERNANDES;'
FROM USER_TABLES;

SPOOL OFF;

/