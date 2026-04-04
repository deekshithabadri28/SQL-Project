CREATE DATABASE music_store;
SHOW DATABASES;
USE music_store;


-- 1. Genre (no dependencies - created first)
CREATE TABLE Genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120)
);

-- 2. MediaType (no dependencies - created first)
CREATE TABLE MediaType (
    media_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120)
);

-- 3. Employee (no dependencies - created first)
CREATE TABLE Employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(120),
    first_name VARCHAR(120),
    title VARCHAR(120),
    reports_to INT,
    levels VARCHAR(255),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100)
);

-- 4. Customer (needs Employee to exist first)
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    company VARCHAR(120),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),
    support_rep_id INT,
    FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);

-- 5. Artist (no dependencies - created first)
CREATE TABLE Artist (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120)
);

-- 6. Album (needs Artist to exist first)
CREATE TABLE Album (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(160),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id) ON DELETE CASCADE
);


-- 7. Track (needs Album + MediaType + Genre to exist first)
CREATE TABLE Track (
    track_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(220),
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (album_id) REFERENCES Album(album_id) ON DELETE CASCADE,
    FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) ON DELETE CASCADE
);

-- 8. Invoice (needs Customer to exist first)
CREATE TABLE Invoice (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    invoice_date DATE,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 9. InvoiceLine (needs Invoice + Track to exist first)
CREATE TABLE InvoiceLine (
    invoice_line_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE
);

-- 10. Playlist (no dependencies but needed before PlaylistTrack)
CREATE TABLE Playlist (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);

-- 11. PlaylistTrack (needs Playlist + Track to exist first)
CREATE TABLE PlaylistTrack (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES Track(track_id) ON DELETE CASCADE
);

SHOW TABLES;


SELECT COUNT(*) FROM Genre; -- 25 records
SELECT * FROM Genre; 

SELECT COUNT(*) FROM MediaType; -- 5 records
SELECT * FROM MediaType;

SELECT COUNT(*) FROM Employee; -- 8 records
SELECT * FROM Employee; 

SELECT COUNT(*) FROM Customer; -- 59 records
SELECT * FROM Customer; 

SELECT COUNT(*) FROM Artist; -- 275 records
SELECT * FROM Artist; 

SELECT COUNT(*) FROM Album; -- 347 records
SELECT * FROM Album; 

SELECT COUNT(*) FROM Track;  -- 362 records which is wrong and it should be 3503 records
SELECT * FROM Track LIMIT 10;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM Track;
SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) FROM Track; 

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE Track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

SELECT COUNT(*) FROM Track; -- 3503 records
SELECT * FROM Track;

SELECT COUNT(*) FROM Invoice;  -- 614 records
SELECT * FROM Invoice;

SELECT COUNT(*) FROM InvoiceLine; -- 4757 records
SELECT * FROM InvoiceLine;

SELECT COUNT(*) FROM Playlist; -- 18 records
SELECT * FROM Playlist;

SELECT COUNT(*) FROM PlaylistTrack; -- 8715 records
SELECT * FROM PlaylistTrack;


SELECT 'Genre' AS table_name, COUNT(*) AS total_records FROM Genre
UNION ALL
SELECT 'MediaType', COUNT(*) FROM MediaType
UNION ALL
SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Artist', COUNT(*) FROM Artist
UNION ALL
SELECT 'Album', COUNT(*) FROM Album
UNION ALL
SELECT 'Track', COUNT(*) FROM Track
UNION ALL
SELECT 'Invoice', COUNT(*) FROM Invoice
UNION ALL
SELECT 'InvoiceLine', COUNT(*) FROM InvoiceLine
UNION ALL
SELECT 'Playlist', COUNT(*) FROM Playlist
UNION ALL
SELECT 'PlaylistTrack', COUNT(*) FROM PlaylistTrack;

  
# 1. Who is the senior most employee based on job title? 
SELECT employee_id,
	   first_name,
       last_name,
       title,
       levels 
FROM Employee
ORDER BY levels DESC
LIMIT 1;


# 2. Which countries have the most Invoices?
SELECT billing_country, COUNT(*) AS invoice_count
FROM Invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 5;
 

# 3. What are the top 3 values of total invoice? 
SELECT total 
FROM Invoice
ORDER BY total DESC
LIMIT 3;


# 4. Which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals 
SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;


# 5. Who is the best customer? 
-- The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money 
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;


# 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A 
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoiceline il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;


# 7. Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands  
SELECT ar.name AS artist_name, COUNT(t.track_id) AS total_tracks
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY total_tracks DESC
LIMIT 10;


# 8. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. 
-- Order by the song length, with the longest songs listed first 
SELECT name, milliseconds
FROM Track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM Track)
ORDER BY milliseconds DESC;


# 9. Find how much amount is spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent  
SELECT c.first_name, c.last_name, ar.name AS artist_name,
       SUM(il.unit_price * il.quantity) AS total_spent
FROM Customer c
JOIN Invoice i 
ON c.customer_id = i.customer_id
JOIN InvoiceLine il 
ON i.invoice_id = il.invoice_id
JOIN Track t 
ON il.track_id = t.track_id
JOIN Album al 
ON t.album_id = al.album_id
JOIN Artist ar 
ON al.artist_id = ar.artist_id
GROUP BY c.first_name, c.last_name, ar.name
ORDER BY total_spent DESC;


# 10. We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared, return all Genres 
WITH purchases_per_genre AS (
    SELECT i.billing_country AS country,
           g.name AS genre,
           COUNT(il.quantity) AS purchases
    FROM Invoice i
    JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
    JOIN Track t ON il.track_id = t.track_id
    JOIN Genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.name
)
SELECT country, genre, purchases
FROM purchases_per_genre
WHERE purchases = (
    SELECT MAX(purchases)
    FROM purchases_per_genre p
    WHERE p.country = purchases_per_genre.country
)
ORDER BY country ASC;


# 11. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
WITH customer_spending AS (
    SELECT i.billing_country,
           c.first_name,
           c.last_name,
           SUM(i.total) AS total_spent
    FROM Customer c
    JOIN Invoice i
    ON c.customer_id = i.customer_id
    GROUP BY i.billing_country, c.first_name, c.last_name
)
SELECT billing_country, first_name, last_name, total_spent
FROM customer_spending
WHERE total_spent = (
    SELECT MAX(total_spent)
    FROM customer_spending cs
    WHERE cs.billing_country = customer_spending.billing_country
)
ORDER BY billing_country ASC;