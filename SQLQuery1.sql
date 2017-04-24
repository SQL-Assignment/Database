/* ===== i.	Produce a list of the latest movies by genres for the current month. */
SELECT MovieName, Genres, ReleaseDate
FROM Catalogue
ORDER BY Genres, ReleaseDate DESC;

/* ===== ii.Produce a list of the top 3 most popular movies for a given genre for the current month. */



/* iii.	Produce a listing of DVDs currently rented by each member at a given branch. 
		Include the members’ IDs, names, movie titles, genres, dates borrowed and due dates for each rental record.*/
SELECT new.ID, new.FirstName, new.LastName, cat.MovieName, cat.Genres
FROM (SELECT r.ID, cust.FirstName, cust.LastName, d.Catalogue_ID FROM RentalRecord AS r, DVD AS d, Customer AS cust WHERE r.Customer_ID=cust.ID AND r.DVD_ID=d.ID) AS new, Catalogue AS cat
WHERE cat.ID=new.Catalogue_ID;


/* ===== iv. Produce a listing showing the total number of DVDs currently rented by each member from all of Movies Abdundant’s branches. 
			 Sort your list in alphabetical order of the members’ last names. */
SELECT c.LastName, COUNT(r.DVD_ID) AS TotalDVDRented
FROM RentalRecord AS r, Customer AS c
WHERE r.Customer_ID=c.ID
GROUP BY c.LastName
ORDER BY c.LastName;


/*====v.	Produce a listing of the total number of copies of a particular movie that is available at any of Movies Abdundant’s branches. 
			The list should include the movie title, branch number, total number-in-stock of DVD copies of that movie at that branch, total copies of the DVDs of that movie rented out to members 
			and total number of copies still available for members to rent. === */

SELECT deduct.Branch_ID, deduct.Catalogue_ID, deduct.MovieName,deduct.TotalStock, Counted.TotalRented, deduct.TotalStock - Counted.TotalRented AS 'Remaining For Rent'
FROM  
	/* === CALCULATE TOTAL STOCK ====*/
	( SELECT d.Catalogue_ID, COUNT(d.Catalogue_ID) AS TotalStock, c.MovieName, d.Branch_ID
		FROM DVD AS d INNER JOIN Catalogue AS c ON d.Catalogue_ID=c.ID
		GROUP BY d.Catalogue_ID, c.MovieName, d.Branch_ID) AS deduct, 
	/* === CALCULATE TOTAL RENTED ====*/
	( SELECT DVD.Branch_ID, DVD.Catalogue_ID, COUNT(DVD_ID) AS TotalRented 
		FROM RentalRecord AS r, DVD WHERE r.DVD_ID=DVD.ID 
		GROUP BY DVD.Branch_ID, DVD.Catalogue_ID) AS Counted

WHERE deduct.Catalogue_ID=Counted.Catalogue_ID AND Counted.Branch_ID=deduct.Branch_ID
GROUP BY deduct.Catalogue_ID, deduct.TotalStock, deduct.Branch_ID, Counted.TotalRented, deduct.MovieName
ORDER BY deduct.Branch_ID, deduct.Catalogue_ID


/*vi.	Produce a list displaying the total copies of DVDs categorized by genres that the company has in totality, across all its branches. ============= */
SELECT c.Genres, COUNT(c.ID) AS TotalInGenre
FROM DVD AS d INNER JOIN Catalogue AS c ON c.ID=d.Catalogue_ID
GROUP BY c.Genres;


/*vi.	vii.	Show a list of all members with outstanding fines for overdue DVDs. List the member IDs, names, movie IDs, movie title, date borrowed, date due, total number of days overdue and fine incurred for each overdue DVD. ============= */






/* ==== TESTING ====*/
SELECT DVD.ID, Catalogue_ID, Branch_ID
FROM DVD INNER JOIN RentalRecord ON RentalRecord.DVD_ID = DVD.ID
WHERE DVD.ID='DV00770'



SELECT d.Catalogue_ID, COUNT(d.Catalogue_ID) AS TotalCatalog, c.MovieName, d.Branch_ID
FROM DVD AS d INNER JOIN Catalogue AS c ON d.Catalogue_ID=c.ID
WHERE c.MovieName='The Godfather' AND d.Branch_ID='B001'
GROUP BY d.Catalogue_ID, c.MovieName, d.Branch_ID
ORDER BY d.Catalogue_ID;





SELECT deduct.Catalogue_ID, deduct.MovieName,deduct.TotalCatalog, Counted.TotalRented, deduct.Branch_ID, deduct.TotalCatalog - Counted.TotalRented AS Remaining
FROM DVD AS d LEFT JOIN RentalRecord AS r ON d.ID=r.DVD_ID, ( SELECT d.Catalogue_ID, COUNT(d.Catalogue_ID) AS TotalCatalog, c.MovieName, d.Branch_ID
	FROM DVD AS d INNER JOIN Catalogue AS c ON d.Catalogue_ID=c.ID
	GROUP BY d.Catalogue_ID, c.MovieName, d.Branch_ID) AS deduct, ( SELECT DVD.Branch_ID, DVD.Catalogue_ID, COUNT(DVD_ID) AS TotalRented FROM RentalRecord AS r, DVD WHERE r.DVD_ID=DVD.ID GROUP BY DVD.Branch_ID, DVD.Catalogue_ID) AS Counted

WHERE deduct.Catalogue_ID=Counted.Catalogue_ID AND Counted.Branch_ID=deduct.Branch_ID
GROUP BY deduct.Catalogue_ID, deduct.TotalCatalog, deduct.Branch_ID, Counted.TotalRented, deduct.MovieName
ORDER BY deduct.Catalogue_ID, deduct.Branch_ID


