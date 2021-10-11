-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S7: Indexen
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------
-- LET OP, zoals in de opdracht op Canvas ook gezegd kun je informatie over
-- het query plan vinden op: https://www.postgresql.org/docs/current/using-explain.html


-- S7.1.
--
-- Je maakt alle opdrachten in de 'sales' database die je hebt aangemaakt en gevuld met
-- de aangeleverde data (zie de opdracht op Canvas).
--
-- Voer het voorbeeld uit wat in de les behandeld is:
-- 1. Voer het volgende EXPLAIN statement uit:
--    EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;
--    Bekijk of je het resultaat begrijpt. Kopieer het explain plan onderaan de opdracht
"Gather  (cost=1000.00..6151.57 rows=1003 width=96)"
"  Workers Planned: 2"
"  ->  Parallel Seq Scan on order_lines  (cost=0.00..5051.27 rows=418 width=96)"
"        Filter: (stock_item_id = 9)"
-- 2. Voeg een index op stock_item_id toe:
--    CREATE INDEX ord_lines_si_id_idx ON order_lines (stock_item_id);
CREATE INDEX ord_lines_si_id_idx ON order_lines(stock_item_id)
-- 3. Analyseer opnieuw met EXPLAIN hoe de query nu uitgevoerd wordt
--    Kopieer het explain plan onderaan de opdracht
"Bitmap Heap Scan on order_lines  (cost=20.19..2304.65 rows=1003 width=96)"
"  Recheck Cond: (stock_item_id = 9)"
"  ->  Bitmap Index Scan on ord_lines_si_id_idx  (cost=0.00..19.94 rows=1003 width=0)"
"        Index Cond: (stock_item_id = 9)"
-- 4. Verklaar de verschillen. Schrijf deze hieronder op.
Het verschil is dat de eerste keer over alle item wordt heen gekeken en de 2e keer gaat de query dmv index scan veel sneller over alle items, want hij zoekt op stock_item_id door de opgelegde index

-- S7.2.
--
-- 1. Maak de volgende twee query’s:
-- 	  A. Toon uit de order tabel de order met order_id = 73590
        select * from orders where order_id = 73590

-- 	  B. Toon uit de order tabel de order met customer_id = 1028
        select * from orders where customer_id = 1028

-- 2. Analyseer met EXPLAIN hoe de query’s uitgevoerd worden en kopieer het explain plan onderaan de opdracht
EXPLAIN select * from orders where order_id = 73590
    "Index Scan using pk_sales_orders on orders  (cost=0.29..8.31 rows=1 width=155)"
"  Index Cond: (order_id = 73590)"

EXPLAIN select * from orders where customer_id = 1028
    "Seq Scan on orders  (cost=0.00..1819.94 rows=107 width=155)"
"  Filter: (customer_id = 1028)"
-- 3. Verklaar de verschillen en schrijf deze op
De een kan zoeken op primary key(die zijn uniek dus er is max 1 row) en de ander moet zoeken op alle rijen die customer_id 1028 heeft.
-- 4. Voeg een index toe, waarmee query B versneld kan worden
 CREATE INDEX ord_lines_customer_id ON orders(customer_id)
-- 5. Analyseer met EXPLAIN en kopieer het explain plan onder de opdracht
    "Bitmap Heap Scan on orders  (cost=5.12..308.96 rows=107 width=155)"
    "  Recheck Cond: (customer_id = 1028)"
    "  ->  Bitmap Index Scan on ord_lines_customer_id  (cost=0.00..5.10 rows=107 width=0)"
    "        Index Cond: (customer_id = 1028)"
-- 6. Verklaar de verschillen en schrijf hieronder op
Bij de ene zonder index moet er eerst gekeken worden naar alle customer_ids en bij diegene met de index gaat de lijst op zoek naar dat nummer via tree principe en als die gevonden is dan worden die allemaal laten zien

-- S7.3.A
--
-- Het blijkt dat customers regelmatig klagen over trage bezorging van hun bestelling.
-- Het idee is dat verkopers misschien te lang wachten met het invoeren van de bestelling in het systeem.
-- Daar willen we meer inzicht in krijgen.
-- We willen alle orders (order_id, order_date, salesperson_person_id (als verkoper),
--    het verschil tussen expected_delivery_date en order_date (als levertijd),
--    en de bestelde hoeveelheid van een product zien (quantity uit order_lines).
-- Dit willen we alleen zien voor een bestelde hoeveelheid van een product > 250
--   (we zijn nl. als eerste geïnteresseerd in grote aantallen want daar lijkt het vaker mis te gaan)
-- En verder willen we ons focussen op verkopers wiens bestellingen er gemiddeld langer over doen.
-- De meeste bestellingen kunnen binnen een dag bezorgd worden, sommige binnen 2-3 dagen.
-- Het hele bestelproces is er op gericht dat de gemiddelde bestelling binnen 1.45 dagen kan worden bezorgd.
-- We willen in onze query dan ook alleen de verkopers zien wiens gemiddelde levertijd
--  (expected_delivery_date - order_date) over al zijn/haar bestellingen groter is dan 1.45 dagen.
-- Maak om dit te bereiken een subquery in je WHERE clause.
-- Sorteer het resultaat van de hele geheel op levertijd (desc) en verkoper.
-- 1. Maak hieronder deze query (als je het goed doet zouden er 377 rijen uit moeten komen, en het kan best even duren...)
select o.order_id, o.order_date, (o.expected_delivery_date ::date -  o.order_date ::date) as levertijd,
       o.salesperson_person_id as verkoper, ol.quantity from orders o  join order_lines ol on o.order_id = ol.order_id where ol.quantity > 250
     and ol.order_id in (select o.order_id from orders o where (o.expected_delivery_date ::date -  o.order_date ::date) > 1.45) order by levertijd desc, verkoper

-- S7.3.B
--
-- 1. Vraag het EXPLAIN plan op van je query (kopieer hier, onder de opdracht)
    "Gather Merge  (cost=7630.68..7661.71 rows=266 width=20)"
"  Workers Planned: 2"
"  ->  Sort  (cost=6630.66..6630.99 rows=133 width=20)"
"        Sort Key: ((o.expected_delivery_date - o.order_date)) DESC, o.salesperson_person_id"
"        ->  Nested Loop  (cost=0.58..6625.96 rows=133 width=20)"
"              Join Filter: (ol.order_id = o.order_id)"
"              ->  Nested Loop  (cost=0.29..6558.82 rows=133 width=12)"
"                    ->  Parallel Seq Scan on order_lines ol  (cost=0.00..5051.27 rows=399 width=8)"
"                          Filter: (quantity > 250)"
"                    ->  Index Scan using pk_sales_orders on orders o_1  (cost=0.29..3.78 rows=1 width=4)"
"                          Index Cond: (order_id = ol.order_id)"
"                          Filter: (((expected_delivery_date - order_date))::numeric > 1.45)"
"              ->  Index Scan using pk_sales_orders on orders o  (cost=0.29..0.49 rows=1 width=16)"
"                    Index Cond: (order_id = o_1.order_id)"
-- 2. Kijk of je met 1 of meer indexen de query zou kunnen versnellen
CREATE INDEX orders_customer_id ON orders(order_id)
-- 3. Maak de index(en) aan en run nogmaals het EXPLAIN plan (kopieer weer onder de opdracht)

-- 4. Wat voor verschillen zie je? Verklaar hieronder.



-- S7.3.C
--
-- Zou je de query ook heel anders kunnen schrijven om hem te versnellen?


