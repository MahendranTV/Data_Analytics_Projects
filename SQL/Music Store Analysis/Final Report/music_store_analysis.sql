/* MUSIC STORE DATA ANALYSIS */

/* Question Set-1 */

/* Q1. Who is the senior most employee based on job title? */

SELECT first_name,last_name,title FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2. Which countries have the most Invoices? */

SELECT MAX(billing_country) FROM invoice;

/* or */

SELECT COUNT(*) AS invoice_count ,billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC


/* Q3. What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

SELECT billing_city,SUM(total) AS invoice_total 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;


/* Q5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */

SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(total) AS total_spendings
FROM customer
JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spendings DESC
LIMIT 1;


/* Question Set-2 */

/* Q1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

SELECT customer.first_name AS First_Name,customer.last_name AS Last_Name,customer.email AS Email 
FROM customer
JOIN invoice
ON customer.customer_id=invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id=invoice_line.invoice_id
JOIN track
ON invoice_line.track_id=track.track_id
JOIN genre
ON track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY customer.email;


/* Q2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

SELECT artist.name, COUNT(*) AS total_track_count FROM artist
JOIN album
ON artist.artist_id = album.artist_id
JOIN track
ON album.album_id=track.album_id
JOIN genre
ON track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY total_track_count DESC
LIMIT 10;


/* Q3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

SELECT track.name,milliseconds 
FROM track
WHERE milliseconds>(SELECT AVG(milliseconds) AS avg_milliseconds FROM track )
ORDER BY milliseconds DESC;


/* Question Set-3 */

/* Q1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artistid, artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track
	ON invoice_line.track_id=track.track_id
	JOIN album
	ON track.album_id=album.album_id
	JOIN artist
	ON album.artist_id=artist.artist_id
	GROUP BY artistid
	ORDER BY total_sales DESC
	LIMIT 1
)

SELECT customer.customer_id,customer.first_name,customer.last_name,
best_selling_artist.artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist ON best_selling_artist.artistid=album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 Desc


/* Q2.We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */

WITH popular_genre AS (
	SELECT customer.country,COUNT(invoice_line.quantity)AS purchase,
	genre.name AS genre_name,genre.genre_id,
	ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rownum
	FROM invoice
	JOIN customer ON customer.customer_id=invoice.customer_id
	JOIN invoice_line ON invoice_line.invoice_id=invoice.invoice_id
	JOIN track ON track.track_id=invoice_line.track_id
	JOIN genre ON genre.genre_id=track.genre_id
	GROUP BY 1,4,3
	ORDER BY 1 ASC, 2 DESC 
)

SELECT * FROM popular_genre WHERE rownum<=1;


/* Q3.Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */

WITH customer_with_country AS (
	SELECT customer.customer_id,customer.first_name,customer.last_name,
	invoice.billing_country,SUM(invoice.total) AS total_spending, 
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS rownum
	FROM customer
	JOIN invoice ON invoice.customer_id=customer.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 desc
)

SELECT * FROM customer_with_country WHERE rownum<=1;
