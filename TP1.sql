-- Question 2.3.1

SELECT *
FROM COUNTRY
ORDER BY NAME;

-- Question 2.3.2


SELECT
  count(*) AS nbPays,
  NAME
FROM ORGANIZATION
  JOIN IS_MEMBER ON ABBREVIATION = IS_MEMBER.ORGANIZATION
GROUP BY ORGANIZATION, NAME
HAVING count(*) = (SELECT max(count(*))
                   FROM IS_MEMBER
                   GROUP BY ORGANIZATION);

-- Question 2.3.3

SELECT
  (pop_city / COUNTRY.POPULATION) * 100 AS pourcentage,
  COUNTRY.NAME
FROM COUNTRY
  JOIN (SELECT
          sum(NVL(POPULATION, 0)) AS pop_city,
          COUNTRY
        FROM CITY
        GROUP BY COUNTRY
       ) bis ON COUNTRY.CODE = bis.COUNTRY
ORDER BY pourcentage DESC;

-- Question 2.3.4

SELECT
  CONTINENT,
  sum(POPULATION * ENCOMPASSES.PERCENTAGE) AS Population
FROM ENCOMPASSES
  JOIN COUNTRY ON COUNTRY = CODE
GROUP BY CONTINENT
ORDER BY Population DESC;

-- Question 2.3.5

WITH paysGauche AS (
    SELECT
      SUM(LENGTH) AS length1,
      COUNTRY1
    FROM BORDERS
    GROUP BY COUNTRY1
)
  , paysDroit AS (
    SELECT
      SUM(LENGTH) AS length2,
      COUNTRY2
    FROM BORDERS
    GROUP BY COUNTRY2
)

SELECT
  COUNTRY.NAME,
  (LENGTH1 + LENGTH2) AS TotalLength
FROM paysGauche
  JOIN paysDroit ON paysGauche.COUNTRY1 = paysDroit.COUNTRY2
  JOIN COUNTRY ON paysGauche.COUNTRY1 = COUNTRY.CODE
ORDER BY TotalLength DESC;

-- Question 2.3.6 AND 2.3.7

SELECT
  c1.NAME,
  count(*) AS Occurences
FROM CITY c1, CITY c2
WHERE c1.NAME = c2.NAME AND c1.COUNTRY != c2.COUNTRY
GROUP BY c1.NAME
ORDER BY Occurences DESC;

-- Question 2.3.8

SELECT
  COUNTRY.NAME,
  COUNTRY.CODE
FROM POLITICS
  JOIN COUNTRY ON POLITICS.COUNTRY = COUNTRY.CODE
WHERE INDEPENDENCE IS NULL;

-- Question 2.3.9


SELECT NAME
FROM COUNTRY
MINUS
SELECT NAME
FROM COUNTRY
  JOIN IS_MEMBER ON COUNTRY.CODE = IS_MEMBER.COUNTRY


-- Question 2.3.10

SELECT
  COUNTRY.NAME,
  ORGANIZATION.NAME
FROM COUNTRY
  LEFT OUTER JOIN IS_MEMBER ON COUNTRY.CODE = IS_MEMBER.COUNTRY
  LEFT OUTER JOIN ORGANIZATION ON ORGANIZATION.ABBREVIATION = IS_MEMBER.ORGANIZATION
ORDER BY ORGANIZATION.NAME DESC;

-- Question 2.3.17


CREATE OR REPLACE PROCEDURE NombrePaysFrontalier(
  PN$codePays IN COUNTRY.CODE%TYPE
) IS
  PN$nbPays  NUMBER;
  PN$nomPays COUNTRY.NAME%TYPE;
  CURSOR PN$cBorder IS
    SELECT *
    FROM BORDERS;

  BEGIN
    PN$nbPays := 0;

    SELECT COUNTRY.NAME
    INTO PN$nomPays
    FROM COUNTRY
    WHERE COUNTRY.CODE = PN$codePays;

    FOR bord IN PN$cBorder
    LOOP
      IF (bord.COUNTRY1 = PN$codePays OR bord.COUNTRY2 = PN$codePays)
      THEN
        PN$nbPays := PN$nbPays + 1;
      END IF;
    END LOOP;

    dbms_output.put_line(PN$nomPays || ' ' || PN$nbPays);
  END;
/

CALL NombrePaysFrontalier('P');

-- Question 2.3.18

ALTER TABLE COUNTRY
  ADD frontiereLongue VARCHAR2(4);

ALTER TABLE COUNTRY
  ADD CONSTRAINT fk_frontiereLongue FOREIGN KEY (FRONTIERELONGUE)
REFERENCES COUNTRY (CODE);


CREATE OR REPLACE PROCEDURE UpdateFrontiereLongue IS
  PN$nomPays1     COUNTRY.CODE%TYPE;
  PN$nomPays2     COUNTRY.CODE%TYPE;
  PN$lengthBorder NUMBER;
  CURSOR PN$countries IS
    SELECT *
    FROM COUNTRY;

  CURSOR PN$borders (countryCode$ IN COUNTRY.CODE%TYPE) IS
    SELECT
      BORDERS.LENGTH,
      BORDERS.COUNTRY1,
      BORDERS.COUNTRY2
    FROM BORDERS
    WHERE BORDERS.COUNTRY1 = countryCode$
          OR BORDERS.COUNTRY2 = countryCode$
    ORDER BY BORDERS.LENGTH DESC;
  BEGIN

    FOR countryRow IN PN$countries
    LOOP

      OPEN PN$borders(countryRow.CODE);
      FETCH PN$borders INTO PN$lengthBorder, PN$nomPays1, PN$nomPays2;
      IF (PN$borders%FOUND)
      THEN
        IF (countryRow.CODE = PN$nomPays1) -- Si c'est nomPays2 la FrontiereLongue
        THEN
          PN$nomPays1 := PN$nomPays2;
        END IF;

        dbms_output.put_line(
            'Plus grande frontière de ' || countryRow.NAME || ' : ' || PN$nomPays1 || ', Taille : ' || PN$lengthBorder);

        -- On met à jour la table
        UPDATE COUNTRY
        SET FRONTIERELONGUE = PN$nomPays1
        WHERE CODE = countryRow.CODE;
      END IF;
      CLOSE PN$borders;

    END LOOP;
  END;
/

CALL UpdateFrontiereLongue();

-- Question 2.3.19

SELECT
  INDEPENDENCE,
  COUNTRY
FROM POLITICS
WHERE to_char(INDEPENDENCE, 'D') = 1;

-- Question 2.4

SET HEADING OFF;
SET ECHO OFF;
SET FEEDBACK OFF;

SPOOL "grant.sql" REPLACE;

SELECT ('GRANT SELECT, UPDATE ON ' || TABLE_NAME || ' TO GMARCELIN')
FROM USER_TABLES;

SPOOL OFF;

@grant.sql


-- Question 2.5.1

CREATE OR REPLACE TRIGGER dateInde
AFTER INSERT OR UPDATE
  ON politics
FOR EACH ROW
  BEGIN
    IF (SYSDATE < :NEW.Independence)
    THEN
      RAISE_APPLICATION_ERROR(-20000, 'Date future');
    END IF;
  END;
