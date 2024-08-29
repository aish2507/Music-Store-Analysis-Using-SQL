Create DATABASE music_database;
Use musics_database;
select * from album2 ;
# who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

# which countries have the most invoices?
select count(billing_country) as c, billing_country
from invoice
group by billing_country
order by c desc;
# what are the top 3 values of total invoice?
select * from invoice;
select * from invoice
order by total desc
limit 3;
# question 4
select Sum(total) as invoice_total, billing_city from invoice 
group by billing_city
order by invoice_total desc;

select * from customer;



select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer 
JOIN invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1 ;



select c.customer_id, c.first_name, c.last_name, sum(i.total) as total
from customer as c
JOIN invoice as i
on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total desc
limit 1 ;

Select distinct email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where	track_id IN (
select track_id from track 
join genre ON track.genre_id = genre.genre_id
where genre.name LIKE 'ROCK'                                                                       // it can be genre.name = 'ROCK' ; LIKE IS USED SO that if anything wrong in spelling it can be ignored.
)
order by email;

select artist.name from artist
join album2 on album2.artist_id = artist.artist_id
join track on album2.album_id = track.album_id
where track_count = ( 
select genre.name from track 
join genre on genre. genre_id = track.genre_id
where count (genre_name LIKE 'rock') = 10 )
order by c desc;


select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track 
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.album_id
join genre on genre.genre_id = track.genre_id
where genre.name LIKE 'RocK' 
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;
 select * from track;
 
 select name, milliseconds from track
 where milliseconds > (select avg(milliseconds) as avg_song_length from track)
 Order by milliseconds desc;
 
 select * from customer;
 select * from artist;
  select * from invoice;
   select * from invoice_line;
   
   select customer.first_name,customer.last_name, artist.name
   from track
   join album2 on album2.album_id = track.album_id
   join artist on artist.artist_id = album2.artist_id
   join invoice_line on invoice_line.track_id = track.track_id
   join invoice on invoice.invoice_id = invoice_line.invoice_id
   join customer on customer.customer_id = invoice.customer_id
   where (select count(quantity) from invoice_line
                group by customer.customer_id) * invoice_line.unit_price
   order by artist.name;
   
 
 
 
 
 
 
 
 select * from artist;
 
  SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
  FROM invoice_line
  JOIN track ON track.track_id = invoice_line.track_id
  join album2 on album2.album_id = track.album_id
  join artist on artist.artist_id = album2.artist_id
  group by 1,2
  order by 3 desc
  limit 1 ;
 
 
 
 
 
 
   
   
   
   
   
   
  with best_selling_artist AS (
  SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
  SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
  FROM invoice_line
  JOIN track ON track.track_id = invoice_line.track_id
  join album2 on album2.album_id = track.album_id
  join artist on artist.artist_id = album2.artist_id
  group by 1,2
  order by 3 desc
  limit 1
  )
  select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
  SUM(il.unit_price*il.quantity) AS amount_spent
  FROM invoice i
  join customer c on c.customer_id = i.customer_id
  join invoice_line il on i.invoice_id = il.invoice_id
  join track t on il.track_id = t.track_id
  join album2  alb on alb.album_id = t.album_id
  join best_selling_artist bsa ON bsa.artist_id = alb.artist_id
  group by 1,2,3,4
  order by 5 desc;
  
  
-- question 2



With most_popular_genre AS (
SELECT COUNT(invoice_line.quantity) AS PURCHASE, customer.country, genre.genre_id, genre.name,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY (invoice_line.quantity) DESC ) AS RowNo
FROM invoice_line
JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
JOIN customer on customer.customer_id = invoice.customer_id
JOIN track on track.track_id = invoice_line.track_id
JOIN genre on genre.genre_id = track.genre_id
GROUP BY 2, 3, 4
ORDER BY 2 ASC, 1 DESC
)

SELECT * FROM most_popular_genre WHERE RowNo <= 1 ;



WITH aggregated_data AS (
  SELECT 
    customer.country, 
    genre.genre_id, 
    genre.name, 
    count(invoice_line.quantity) AS total_purchases
  FROM 
    invoice_line
  JOIN 
    invoice ON invoice.invoice_id = invoice_line.invoice_id
  JOIN 
    customer ON customer.customer_id = invoice.customer_id
  JOIN 
    track ON track.track_id = invoice_line.track_id
  JOIN 
    genre ON genre.genre_id = track.genre_id
  GROUP BY 
    customer.country, 
    genre.genre_id, 
    genre.name
),
most_popular_genre AS (
  SELECT 
    country, 
    genre_id, 
    name, 
    total_purchases,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_purchases DESC) AS RowNo
  FROM 
    aggregated_data
)
SELECT 
  country, 
  genre_id, 
  name, 
  total_purchases
FROM 
  most_popular_genre
  where RowNo = 1
ORDER BY 
country ASC,total_purchases desc
 ;


--- question 3  can be solved with cte and recursive.

With recursive Customer_spent_on_Music AS ( Select  customer.customer_id,customer.first_name, customer.last_name,billing_country, Sum(total) as money_spent_per_customer
From invoice
join customer on invoice.customer_id = customer.customer_id
group by 1,2,3,4
order by 1,5 Desc ),
Top_customer AS (select MAX(money_spent_per_customer) AS max_spending, billing_country
FROM Customer_spent_on_Music
group by billing_country)
select Customer_spent_on_Music.billing_country,Customer_spent_on_Music.first_name,Customer_spent_on_Music.last_name,Customer_spent_on_Music.money_spent_per_customer from Customer_spent_on_Music
join Top_customer on Top_customer.billing_country = Customer_spent_on_Music.billing_country
where Customer_spent_on_Music.money_spent_per_customer = Top_customer.max_spending
order by billing_country;


with customer_with_country AS ( select customer.customer_id, customer.first_name,customer.last_name,billing_country, sum(total) as MAX_Spending,
ROW_NUMBER() OVER (PARTITION by billing_country order by sum(total) DESC) AS ROWNO
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3
order by 4 ASC, 5 DESC)
select * from customer_with_country where ROWNO = 1;