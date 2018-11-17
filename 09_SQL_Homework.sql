use sakila;
select count(*) from actor;

select * from actor 
LIMIT 10;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT FIRST_NAME, LAST_NAME
FROM ACTOR;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'ACTOR NAME'
FROM ACTOR;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT ACTOR_ID, FIRST_NAME, LAST_NAME
FROM ACTOR
WHERE FIRST_NAME = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT ACTOR_ID, FIRST_NAME, LAST_NAME
FROM ACTOR
WHERE LAST_NAME LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT ACTOR_ID, FIRST_NAME, LAST_NAME
FROM actor
WHERE LAST_NAME LIKE '%LI%'
ORDER BY LAST_NAME, FIRST_NAME;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT COUNTRY_ID, COUNTRY
FROM COUNTRY
WHERE COUNTRY IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
DESCRIBE ACTOR;
ALTER TABLE ACTOR ADD COLUMN description BLOB; 
DESCRIBE ACTOR;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE ACTOR DROP COLUMN description; 
DESCRIBE ACTOR;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT LAST_NAME, COUNT(LAST_NAME) LastNameCount
FROM actor
GROUP BY LAST_NAME;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT LAST_NAME, COUNT(LAST_NAME) LastNameCount
FROM actor
GROUP BY LAST_NAME
having LastNameCount > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select * from actor
where last_name = 'Williams';

update actor
set first_name = 'HARPO'
WHERE last_name = 'Williams'
and first_name = 'Groucho';

select * from actor
where last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
select * from actor
where first_name = 'Harpo';

update actor
set first_name = 'GROUCHO'
WHERE FIRST_NAME = 'HARPO';

SELECT * FROM ACTOR
WHERE LAST_NAME = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select * from staff;

select s.first_name, s.last_name, a.address, a.address2, a.district, a.postal_code
from staff s join address a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.staff_id, s.first_name, s.last_name, sum(p.amount) as 'staff total amount'
from staff s join payment p
using (staff_id)
where p.payment_date between '2005-08-01' and '2005-08-31'
group by s.staff_id, s.first_name, s.last_name;

-- Below queries ran to verify data
select count(*) from payment
where payment_date between '2005-08-01' and '2005-08-31';

select sum(amount) from payment
where payment_date between '2005-08-01' and '2005-08-31';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
-- below 2 queries to analyze data
select * from film 
limit 1000;

select * from film_actor
limit 1000;

-- Query for 6c
SELECT F.TITLE, COUNT(FA.ACTOR_ID) 'Actor Count'
FROM FILM F INNER JOIN FILM_ACTOR FA
USING (FILM_ID)
group by F.Title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) as 'Inventory Count'
from film f join inventory i
on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) 'Total Amount Paid'
from payment p inner join customer c
on p.customer_id = c.customer_id
group by c.first_name, c.last_name
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

-- Query to analyze
select * from film
where title like 'K%' 
or title like 'Q%'
limit 100;

Select title
from film
where title like 'K%' 
or title like 'Q%'
and language_id in
(select language_id
from language
where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in
(select actor_id
from film_actor
where film_id in
(select film_id
from film 
where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email
from customer c
where address_id in
(select address_id from address a
where city_id in
(select city_id from city ci
where country_id in
(select country_id from country co
where country = 'Canada')));

-- Below query is for testing
select c.first_name, c.last_name, a.address, a.address2, ci.city, co.country 
from customer c join address a using (address_id)
join city ci using (city_id)
join country co using (country_id)
where co.country = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- 
select f.title 'Movie Title', c.name as 'Category Name'
from category c join film_category fc using (category_id)
join film f using (film_id)
where c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
-- Testing
select * from film
where film_id = 103;

select * from inventory 
where film_id =103;

select * from rental 
where inventory_id between 465 and 472;

-- Final query for 7e
select f.film_id, f.title, count(*) as RentCount
from film f 
join inventory i using (film_id)
join rental r using(inventory_id)
group by f.film_id
order by RentCount desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store
limit 50;
-- Payment -> Staff -> Store
Select staff_id, sum(amount)
from payment
group by staff_id;

select staff_id, store_id 
from staff;

select store_id
from store;

-- Final Query for 7f
Select str.store_id, sum(p.amount) 'Store Amount'
from store str join staff stf using(store_id)
join payment p using(staff_id)
group by str.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country
from store s join address a using(address_id)
join city ci using (city_id)
join country co using (country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.category_id, c.name 
from film_category fc
join category c using(category_id);

select * from category;

select c.name, sum(p.amount) as Genre_Revenue
from category c join film_category fc using (category_id)
join inventory i using (film_id)
join rental r using (inventory_id)
join payment p using (rental_id)
group by c.name
order by Genre_Revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
Create view Top5GenresRevenue As
(select c.name, sum(p.amount) as Genre_Revenue
from category c join film_category fc using (category_id)
join inventory i using (film_id)
join rental r using (inventory_id)
join payment p using (rental_id)
group by c.name
order by Genre_Revenue desc
limit 5
);
-- 8b. How would you display the view that you created in 8a?
Select * from Top5GenresRevenue;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop View If Exists sakila.top5genresrevenue;