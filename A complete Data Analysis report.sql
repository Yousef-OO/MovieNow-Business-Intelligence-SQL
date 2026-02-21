SELECT *
FROM renting;

SELECT *
FROM customers;

SELECT *
FROM movies;

SELECT *
FROM actors;

SELECT *
FROM actsin;

---------------------

-- Question 1) What is the number of customers from each country?
SELECT 
    country,
    COUNT(*) AS cust_num
FROM customers
GROUP BY country
ORDER BY COUNT(*) DESC;

---------------------

-- Question 2) What is the average rating of a movie?
SELECT 
	m.title,
	ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
LEFT JOIN renting r 
ON m.movie_id = r.rating
WHERE r.rating IS NOT NULL
GROUP BY m.title
ORDER BY avg_rating DESC;

---------------------

-- Question 3) How many movies did the actor 'Daniel Radcliffe' participate in?
SELECT 
	actors.name,
	COUNT(actsin.actor_id) AS movies_num
FROM actors
FULL JOIN actsin
ON actors.actor_id = actsin.actor_id
WHERE actors.name = 'Daniel Radcliffe'
GROUP BY actors.name;

---------------------

-- my manager is interested in the total number of movie rentals,
-- the total number of ratings and the average rating of all movies since the beginning of 2019.

-- Question 4) Retrieve all records of movie rentals since January 1st 2019

SELECT * 
FROM renting
WHERE date_renting >= '2019-01-01'; 

---------------------

-- Question 5) count the number of movie rentals and calculate the average rating since the beginning of 2019.

SELECT 
	COUNT(*) AS number_renting, 
	AVG(rating) AS average_rating,
	COUNT(rating) AS number_ratings -- counting how many movie ratings since that time as well?
FROM renting
WHERE date_renting >= '2019-01-01';

---------------------

-- Question 6) Conduct an analysis to see when the first customer accounts were created for each country?

SELECT country,
	MIN(date_account_start) AS first_account
FROM customers
GROUP BY country
ORDER BY MIN(date_account_start);

---------------------

-- Question 7) Calculate the average rating, the number of ratings and the number of views For each movie?

SELECT movie_id, 
       AVG(rating) AS avg_rating,
       COUNT(rating) AS number_ratings,
       COUNT(*) AS number_renting
FROM renting
GROUP BY movie_id
ORDER BY AVG(rating) DESC; 
-- The average is NULL because all of the ratings of that first movie are NULL

---------------------

-- Question 8) obtain a table with the average rating given by each customer,
--             include the number of ratings and the number of movie rentals per customer,
--             report these summary statistics only for customers with more than 7 movie rentals

SELECT customer_id,
      AVG(rating) avg_rating, 
      COUNT(rating) ratings_number, 
      COUNT(*) movie_rentals
FROM renting
GROUP BY customer_id
HAVING COUNT(*) > 7 
ORDER BY AVG(rating);

---------------------
 
-- Question 9) What is the Average rating of customers coming from Belgium

SELECT AVG(r.rating) 
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
WHERE c.country='Belgium';

---------------------

-- Question 10) The management of MovieNow wants to report key performance indicators for the performance of the company in 2018.
-- They are interested in measuring the financial successes as well as user engagement.
-- Important KPIs are,  the revenue coming from movie rentals, the number of movie rentals and the number of active customers

SELECT 
	SUM(m.renting_price) AS revenue, 
	COUNT(*) AS movie_rentals, 
	COUNT(DISTINCT r.customer_id) AS active_custmers
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
-- Only look at movie rentals in 2018
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31';

---------------------

-- Question 11) which actors play in which movie(a list of movie titles and actor names)?

SELECT a.name AS actor_name,
       m.title AS movie_name
FROM actsin ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
LEFT JOIN actors AS a
ON a.actor_id = ai.actor_id;

---------------------

-- Question 12) How much income did each movie generate?

SELECT rm.title AS movie_title,
       SUM(rm.renting_price) AS income_movie
FROM
       (SELECT m.title,  
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id=m.movie_id) AS rm
GROUP BY rm.title
ORDER BY SUM(rm.renting_price) DESC;

---------------------

-- Question 13) Explore the age of American actors and actresses. Report the date of birth of the oldest and youngest US actors.

SELECT a.gender AS Gender,
       MIN(a.year_of_birth) AS Oldest,
       MAX(a.year_of_birth) AS youngest 
FROM
   (SELECT *  
   FROM actors
   WHERE nationality = 'USA') AS a 
GROUP BY a.gender;

---------------------

-- Question 14) Who are the most preferred actors by the male customers? (by views number and average rating per actor)

SELECT a.name,  
	COUNT(*) AS number_views,  
	AVG(r.rating) AS avg_rating 
FROM renting as r 
LEFT JOIN customers AS c 
ON r.customer_id = c.customer_id 
LEFT JOIN actsin as ai 
ON r.movie_id = ai.movie_id 
LEFT JOIN actors as a 
ON ai.actor_id = a.actor_id 
WHERE c.gender = 'male' 
GROUP BY a.name 
HAVING AVG(r.rating) IS NOT NULL 
ORDER BY avg_rating DESC, number_views DESC; 

---------------------

-- Question 15) Which is the favorite movie on MovieNow? 

SELECT m.title movie_name, 
COUNT(*) number_of_views,
AVG(r.rating) avg_rating
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1 
ORDER BY AVG(r.rating) DESC, COUNT(*) DESC; 

---------------------

-- Question 16) report the favorite actors only for customers from Spain. (separate by gender)

SELECT a.name,  c.gender,
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting as r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN actsin as ai
ON r.movie_id = ai.movie_id
LEFT JOIN actors as a
ON ai.actor_id = a.actor_id
WHERE c.country = 'Spain'
GROUP BY a.name, c.gender
HAVING AVG(r.rating) IS NOT NULL 
  AND COUNT(*) > 5 
ORDER BY avg_rating DESC, number_views DESC;

---------------------

-- Question 17) The manager is interested in the total number of movie rentals, 
--              the average rating of all movies and the total revenue for each country since the beginning of 2019.

SELECT 
	c.country,                  
	COUNT(*) AS number_renting, 
	AVG(r.rating) AS average_rating, 
	SUM(m.renting_price) AS revenue    
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE date_renting >= '2019-01-01'
GROUP BY c.country
HAVING COUNT(*) > 1;

---------------------

-- Question 18) Retreive all information about movies with more than 5 views.


SELECT *
FROM movies
WHERE movie_id IN 
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5);

---------------------

-- Question 19) Report a list of customers who frequently rent movies on MovieNow (who rented more than 10 movies.)

SELECT *
FROM customers
WHERE customer_id IN         
	(SELECT customer_id
	FROM renting
	GROUP BY customer_id
	HAVING COUNT(*) > 10);

---------------------

-- Question 20) For the advertising campaign the manager needs a list of popular movies with high ratings. Report a list of movies with rating above average.

SELECT title 
FROM movies
WHERE movie_id IN
	(SELECT movie_id
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) > 
		(SELECT AVG(rating)
		 FROM renting));

---------------------

-- Question 21) A new advertising campaign is going to focus on customers who rented fewer than 5 movies.
--              extract all customer information for the customers of interest.

SELECT *
FROM customers as c
WHERE 5 > 
	(SELECT count(*)
	FROM renting as r
	WHERE r.customer_id = c.customer_id);

---------------------

-- Question 22) Identify customers who were not satisfied with movies they watched on MovieNow. Report a list of customers with minimum rating smaller than 4

SELECT *
FROM customers c
WHERE 4 >
	(SELECT MIN(rating)
	FROM renting AS r
	WHERE r.customer_id = c.customer_id);

---------------------

-- Question 23) Who are the customers with at least one rating?

SELECT *
FROM customers c 
WHERE EXISTS
	(SELECT *
	FROM renting AS r
	WHERE rating IS NOT NULL 
	AND r.customer_id = c.customer_id);

---------------------

-- Question 24) In order to analyze the diversity of actors in comedies, report a list of actors who play in comedies and the number of actors for each nationality playing in comedies.


SELECT a.nationality,
	   COUNT(*) AS num_of_comedy_actors
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP BY a.nationality;

---------------------

-- Question 25) Create a table with the total number of all female and male customers for each country.

SELECT gender,
	   country,
	   COUNT(*)
FROM customers
GROUP BY CUBE (gender, country)
ORDER BY country;

---------------------

-- Question 26) Prepare a table for a report about the national preferences of the customers from MovieNow comparing the average rating of movies across countries and genres.

SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY CUBE (c.country, m.genre);

---------------------

-- Question 27) Now the management considers investing money in movies of the best rated genres. 
-- For each genre, calculate the average rating, the number of ratings, the number of movie rentals, and the number of distinct movies.

SELECT genre,
	   AVG(rating) AS avg_rating,
	   COUNT(rating) AS n_rating,
       COUNT(*) AS n_rentals,     
	   COUNT(DISTINCT m.movie_id) AS n_movies 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 3 )
AND r.date_renting >= '2018-01-01'
GROUP BY genre
ORDER BY AVG(r.rating);

---------------------

-- Question 28) The last aspect you have to analyze are customer preferences for certain actors.
-- For each combination of the actors' nationality and gender.
-- Calculate the average rating, the number of ratings, the number of movie rentals, and the number of actors.


SELECT a.nationality,
       a.gender,
	   AVG(r.rating) AS avg_rating,
	   COUNT(r.rating) AS n_rating,
	   COUNT(*) AS n_rentals,
	   COUNT(DISTINCT a.actor_id) AS n_actors
FROM renting AS r
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 4)
AND r.date_renting >= '2018-04-01'
GROUP BY CUBE(a.nationality, a.gender); 

---------------------

-- I sent the report on customer preferences to management. Now they can take informed, data-driven decisions based on this detailed analysis.

 