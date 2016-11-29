ALTER SESSION SET CURRENT_SCHEMA = MAFERNANDES;

--Q2
SELECT
  count(*) AS nbPays,
  NAME
FROM ORGANIZATION
  JOIN IS_MEMBER ON ABBREVIATION = IS_MEMBER.ORGANIZATION
GROUP BY ORGANIZATION, NAME
HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                   FROM IS_MEMBER
                   GROUP BY ORGANIZATION);

--Q5
WITH paysGauche AS (
    SELECT
      SUM(length) AS length1,
      country1
    FROM BORDERS
    GROUP BY country1
), paysDroit AS (
    SELECT
      sum(length) AS length2,
      country2
    FROM BORDERS
    GROUP BY country2
)
SELECT
  country1,
  (length1 + length2)
FROM paysGauche
  JOIN paysDroit ON paysGauche.country1 = paysDroit.country2
  JOIN COUNTRY ON paysGauche.COUNTRY1 = COUNTRY.CODE
ORDER BY (length1 + length2) DESC;


--Q8
SELECT Country.Name, Country.Code
  FROM POLITICS JOIN Country ON POLITICS.Country = Country.Code
WHERE INDEPENDENCE IS NULL;

