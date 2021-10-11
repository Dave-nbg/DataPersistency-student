-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
CREATE OR REPLACE VIEW deelnemers AS select i.cursist, i.cursus, i.begindatum, u.docent, u.locatie from uitvoeringen u, inschrijvingen i where i.cursus = u.cursus and i.begindatum = u.begindatum
-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
--     CREATE OR REPLACE VIEW personeel AS
-- 	     SELECT mnr, voorl, naam as medewerker, afd, functie
--       FROM medewerkers;
select d.cursus, d.cursist, p.mnr, d.begindatum from deelnemers d, personeel p where p.mnr = d.cursist
-- 3. Is de view "deelnemers" updatable ? Waarom ?
nee, want hij kent de u.docent bijvoorbeeld niet, omdat alles onder de tabel deelnermers valt en daardoor uitvoeringen niet meer te bereiken is. Hierdoor gaat die zeuren over het feit dat er meerdere tabellen zijn.

-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen:
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt.
CREATE OR REPLACE VIEW dagcursussen as select code, omschrijving, type from cursussen where lengte = 1
-- 2. Maak een tweede view met de naam "daguitvoeringen".
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
create or replace view daguitvoeringen as select u.* from dagcursussen d , uitvoeringen u where u.cursus = d.code

-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
bij CASCADE worden beide gelinkte views verwijderd, maar bij restrict niet

