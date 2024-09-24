-- Q1. who is the senior most employee based on the job title 
SELECT * FROM employee
order by levels desc
limit 1;

-- Q2. which countries have the most invices
SELECT  count (*) as C, billing_country FROM invoice
group by billing_country
order by c desc; 

-- Q3. what are top 3 values of total invoices?
SELECT  distinct total,billing_country FROM invoice
order by total desc
limit 3;

-- Q4. Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals
SELECT sum(total) as invoice_total,billing_city FROM  INVOICE
group by billing_city
order by invoice_total desc
limit 1

-- Q5. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) 
as total FROM customer
JOIN invoice ON customer.customer_id= invoice.customer_id
group by customer.customer_id
order by total desc
limit  1;

-- 	Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A
SELECT distinct email, first_name, last_name from customer
JOIN invoice on customer.customer_id= invoice.customer_id
JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN (
SELECT track_id FROM track
JOIN genre ON track.genre_id=genre.genre_id
where genre.name = 'Rock'
)
ORDER BY email;

-- Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

 SELECT artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs FROM track
 JOIN album ON album.album_id = track.album_id
 JOIN artist ON artist.artist_id = album.artist_id
 JOIN genre ON genre.genre_id= track.genre_id
 where genre.name LIKE 'Rock'
 group by artist.artist_id
 order by number_of_songs desc
 limit 10;

-- Q8. 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first
SELECT  track.milliseconds, track.name FROM TRACK
where milliseconds > (select avg(milliseconds) as avg_track_length
from track)
ORDER BY milliseconds DESC;


-- Q9.Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
WITH BEST_SELLING_ARTIST AS
       ( SELECT artist.artist_id AS artist_id , artist.name as artist_name,
	   SUM (invoice_line.unit_price*invoice_line.quantity)
	   as Total_Sales from invoice_line
	   JOIN track ON track.track_id = invoice_line.track_id
       JOIN album ON album.album_id =track.album_id
	   JOIN artist ON artist.artist_id = album.artist_id
	   group by 1 
	   order by 3 desc
	   limit 1 )
SELECT C.customer_id, c.first_name,c.last_name, bsa.artist_name,
SUM(il.unit_price*quantity) as amount_spent 
from invoice i
join customer c ON c.customer_id = i.customer_id 
join invoice_line il ON il.invoice_id = i.invoice_id 
join track t ON t.track_id = il.track_id
join album alb ON alb.album_id = t.album_id
join BEST_SELLING_ARTIST bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q10. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres
WITH popular_genre as 
(SELECT count(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
row_number() OVER (partition by customer.country ORDER BY count(invoice_line.quantity)desc)
AS row_no from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id= invoice_line.track_id
join genre on genre.genre_id= track.genre_id
group by 2,3,4
 order by 2 ASC, 1 DESC
)
SELECT *FROM popular_genre where row_no <=1

-- Q11. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount
WITH customer_with_country as 
(SELECT customer.customer_id, first_name, last_name, billing_country,
sum(total) AS total_spending,
row_number() OVER(partition by billing_country ORDER BY sum(total)desc)
AS row_no from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
 order by 4 asc,5 DESC)
 SELECT *FROM customer_with_country where row_no <=1




