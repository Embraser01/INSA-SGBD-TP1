--Question 17
CREATE OR REPLACE PROCEDURE nbPaysFrontaliers(PN$codePays IN COUNTRY.CODE%TYPE) IS
DECLARE
  PN$nbPays NUMBER;
  CURSOR cBorder IS
    SELECT *
    FROM BORDER;
  BEGIN
    PN$nbPays = 0;
    FOR bord IN cBorder
    LOOP
      IF (bord.COUNTRY1 = PN$codePays OR bord.COUNTRY2 = PN$codePays)
      THEN
        PN$nbPays = PN$nbPays + 1;
      END IF;
    END LOOP;
    DBMS_OUT.put_LINE(PN$nbPays);
  END;
/

--Question 18 la plus longue frontiere de chaque pays MODIFICATION SUJET
--on veut le code du pays et non pas le nom.
--first step create new column longestBorder
ALTER TABLE Country
  ADD longestBorder VARCHAR2(32);
/

CREATE OR REPLACE PROCEDURE longestBorder AS
DECLARE
  longestBorderCountry$     BORDERS%ROWTYPE;
  longestBorderCountryCode$ COUNTRY.Code%TYPE;
  CURSOR cCode IS
    SELECT CODE
    FROM COUNTRY;
  BEGIN
    --procedure goes here
    --second step find the longest border for each country
    FOR countryCode IN cCode
    LOOP
      WITH borderLine AS (
          SELECT *
          FROM BORDERS
          WHERE COUNTRY1 = countryCode OR COUNTRY2 = countryCode
      )

      --trouver la plus longue frontiere
      SELECT *
      INTO longestBorderCountry$
      FROM borderLine
      WHERE LENGTH = (SELECT MAX(LENGTH)
                      FROM borderLine);
      --toruver le code du pays
      SELECT countryCode
      INTO longestBorderCountryCode$
      FROM COUNTRY
      WHERE (countryCode = longestBorderCountry$.COUNTRY1 OR countryCode = longestBorderCountry$.COUNTRY2) AND
            countryCode != countryCode;

      UPDATE COUNTRY
      SET LONGESTBORDER = longestBorderCountryName$
      WHERE;
    END LOOP;
  END;
/

CREATE OR REPLACE PROCEDURE addCountry(PN$countryName IN COUNTRY.) IS
  BEGIN END;
/