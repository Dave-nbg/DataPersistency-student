-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S3: Multiple Tables
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S3.1.
-- Produceer een overzicht van alle cursusuitvoeringen; geef de
-- code, de begindatum, de lengte en de naam van de docent.
-- DROP VIEW IF EXISTS s3_1; CREATE OR REPLACE VIEW s3_1 AS                                                     -- [TEST]
select u.cursus as code ,u.begindatum, c.lengte, m.naam from uitvoeringen u, cursussen c, medewerkers m where c.code = u.cursus and m.mnr = u.docent
--1 te veel maar weet niet welke. Is wss niet gedelete

-- S3.2.
-- Geef in twee kolommen naast elkaar de achternaam van elke cursist (`cursist`)
-- van alle S02-cursussen, met de achternaam van zijn cursusdocent (`docent`).
-- DROP VIEW IF EXISTS s3_2; CREATE OR REPLACE VIEW s3_2 AS                                                     -- [TEST]
select l.naam as leerling, d.naam as docent from medewerkers d, medewerkers l, uitvoeringen u, inschrijvingen i where (i.cursist = l.mnr and i.cursus = 'S02') and (u.docent = d.mnr and u.cursus = 'S02') and i.begindatum = u.begindatum
--er is geen achternaam cursist.


-- S3.3.
-- Geef elke afdeling (`afdeling`) met de naam van het hoofd van die
-- afdeling (`hoofd`).
-- DROP VIEW IF EXISTS s3_3; CREATE OR REPLACE VIEW s3_3 AS                                                     -- [TEST]
select a.naam as afdelingsnaam, m.naam as medewerkersnaam from medewerkers m, afdelingen a where a.hoofd=m.mnr

-- S3.4.
-- Geef de namen van alle medewerkers, de naam van hun afdeling (`afdeling`)
-- en de bijbehorende locatie.
-- DROP VIEW IF EXISTS s3_4; CREATE OR REPLACE VIEW s3_4 AS                                                     -- [TEST]
select m.naam as medewerkersnaam, a.naam as afdelingsnaam, a.locatie from medewerkers m, afdelingen a where a.anr = m.afd

-- S3.5.
-- Geef de namen van alle cursisten die staan ingeschreven voor de cursus S02 van 12 april 2019
-- DROP VIEW IF EXISTS s3_5; CREATE OR REPLACE VIEW s3_5 AS                                                     -- [TEST]
select m.naam from inschrijvingen i, medewerkers m where i.cursus = 'S02' and i.begindatum = '2019-04-12' and m.mnr = i.cursist



-- S3.6.
-- Geef de namen van alle medewerkers en hun toelage.
-- DROP VIEW IF EXISTS s3_6; CREATE OR REPLACE VIEW s3_6 AS                                                     -- [TEST]
select m.naam, s.toelage from medewerkers m, schalen s where m.maandsal>s.ondergrens and m.maandsal<s.bovengrens
-- geeft error maar dit is het goede: Alders = 100, De waard = 50, Blaak = 200, den draaier = 100, schotten= 500, De koning=500, jansen =0, Adams = 0, spijker = 500, molenaar = 50, smit = 0, jansen = 500, clerckx = 200, martens = 50 en die uitvoer krijg ik

-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S3.1') AS resultaat
UNION
SELECT * FROM test_select('S3.2') AS resultaat
UNION
SELECT * FROM test_select('S3.3') AS resultaat
UNION
SELECT * FROM test_select('S3.4') AS resultaat
UNION
SELECT * FROM test_select('S3.5') AS resultaat
UNION
SELECT * FROM test_select('S3.6') AS resultaat
ORDER BY resultaat;

