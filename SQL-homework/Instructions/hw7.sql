--DROP TABLE IF EXISTS card_holder CASCADE;
--DROP TABLE IF EXISTS credit_card CASCADE;
--DROP TABLE IF EXISTS merchant CASCADE;
--DROP TABLE IF EXISTS merchant_category CASCADE;
--DROP TABLE IF EXISTS transaction CASCADE;

--create table schema and import csv files. Specify data types, primary keys, foreign keys, and other constraints
CREATE TABLE card_holder (
id int   NOT NULL,
name varchar NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE credit_card (
card varchar(20) NOT NULL,
cardholder_id int NOT NULL,
PRIMARY KEY (card),
FOREIGN KEY(cardholder_id) REFERENCES card_holder(id)
);

CREATE TABLE merchant_category (
id int NOT NULL,
name varchar NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE merchant (
id int NOT NULL,
name varchar NOT NULL,
id_merchant_category int NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY(id_merchant_category) REFERENCES merchant_Category(id)
);

CREATE TABLE transaction (
id int NOT NULL,
date timestamp NOT NULL,
amount float NOT NULL,
card varchar(20) NOT NULL,
id_merchant int   NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY(card) REFERENCES credit_card (card),
FOREIGN KEY(id_merchant) REFERENCES merchant(id)
);


-- Part 1
-- The CFO of your firm has requested a report to help analyze potential fraudulent transactions. 
-- Using your newly created database, generate queries that will discover the information needed to answer the following questions, 
-- then use your repository's ReadME file to create a markdown report you can share with the CFO:


-- 	Some fraudsters hack a credit card by making several small transactions (generally less than $2.00), which are typically ignored by cardholders.
--  How can you isolate (or group) the transactions of each cardholder?

--  Answer: The below query can be used to isolate transactions of each cardholder, substituting the name 'Robert Johnson' with that of the cardholder in question.
CREATE VIEW Cardholder_Transactions AS
SELECT *
FROM transaction
WHERE card IN
	(
	SELECT card
	FROM credit_card
	WHERE cardholder_id IN
		(
		SELECT id
		FROM card_holder
		WHERE name = 'Robert Johnson'
			)
		);

--  Count the transactions that are less than $2.00 per cardholder.
CREATE VIEW Small_Transactions AS
SELECT name,COUNT(*)
FROM card_holder
WHERE id IN
	(
	SELECT cardholder_id
	FROM credit_card
	WHERE card IN
		(
		SELECT card
		FROM transaction
		WHERE amount < 2
		)
	)
	GROUP BY name;

	
-- 	 is there any evidence to suggest that a credit card has been hacked? Explain your rationale.

--   Answer: No. There does not appear to be any evidence that a credit card has been hacked based on the criteria; while there are many transactions <$2, no single cardholder has more than one of these transactions 

--	 Take your investigation a step futher by considering the time period in which potentially fraudulent transactions are made. What are the top 100 highest transactions made between 7:00 am and 9:00 am?
CREATE VIEW Morning_Transactions AS
select *
from transaction
where date::time between time '07:00:00' and time '09:00:00'
ORDER BY amount DESC
LIMIT 100

--		Do you see any anomalous transactions that could be fraudulent?

--      Answer: There are a handful of transactions > $1,000 that seem large for the time of day, but these are perhaps too conspicuous to truly be fraud. It would be worth investigating further as 
--      there is a substantial dropoff after the first 10 transaction, where the remaining seem more aligned with typical early morning purcahses, e.g. fuel, breakfast, etc. 

--		Is there a higher number of fraudulent transactions made during this time frame versus the rest of the day?

--      Answer: difficult to say. There does not seem to be compelling data to suggest so. 

--		If you answered yes to the previous question, explain why you think there might be fraudulent transactions during this time frame.

--      Answer: N/A

--		What are the top 5 merchants prone to being hacked using small transactions?

CREATE VIEW Vulnerable_Merchants AS
SELECT name, Count(id) as num_small_transactions
FROM merchant
WHERE id IN
	(
	SELECT id_merchant
	FROM transaction
	WHERE amount < 2
	ORDER BY amount DESC
	)
	GROUP BY name
	LIMIT 5;

--		Create a view for each of your queries.

