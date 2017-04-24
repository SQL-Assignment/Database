/* ===== i.	Produce a list of the latest movies by genres for the current month. 

!! WE USED 2016 TO SHOW YOU DATA. OR NOT THE [ YEAR(ReleaseDate)=YEAR(getdate()) ] CAN BE USED TO GET THE CURRENT YEAR*/
SELECT MovieName, Genres, ReleaseDate
FROM Catalogue
where YEAR(ReleaseDate)='2016' AND MONTH(ReleaseDate)=MONTH(getdate())
ORDER BY Genres, ReleaseDate DESC;



/* ===== ii.Produce a list of the top 3 most popular movies for a given genre for the current month. 

!! WE USED 2016 TO SHOW YOU DATA. OR NOT THE [ YEAR(ReleaseDate)=YEAR(getdate()) ] CAN BE USED TO GET THE CURRENT YEAR*/*/
SELECT TOP(3) c.MovieName, c.ID, c.ReleaseDate, Counted.TotalRented
FROM Catalogue AS c, 
		(SELECT DVD.Catalogue_ID, COUNT(DVD_ID) AS TotalRented 
		FROM RentalRecord AS r, DVD WHERE r.DVD_ID=DVD.ID 
		GROUP BY DVD.Catalogue_ID) AS Counted

where YEAR(c.ReleaseDate)=YEAR(getdate()) AND MONTH(c.ReleaseDate)=MONTH(getdate()) AND Counted.Catalogue_ID=c.ID
ORDER BY Counted.TotalRented DESC;




/* iii.	Produce a listing of DVDs currently rented by each member at a given branch. 
		Include the members’ IDs, names, movie titles, genres, dates borrowed and due dates for each rental record.*/
SELECT new.ID, new.Branch_ID, new.FirstName, new.LastName, cat.MovieName, cat.Genres, new.RentDate, new.DueDate
FROM (SELECT r.ID, d.Branch_ID, cust.FirstName, cust.LastName, d.Catalogue_ID, r.RentDate, r.DueDate FROM RentalRecord AS r, DVD AS d, Customer AS cust WHERE r.Customer_ID=cust.ID AND r.DVD_ID=d.ID) AS new, Catalogue AS cat
WHERE cat.ID=new.Catalogue_ID;




/* ===== iv. Produce a listing showing the total number of DVDs currently rented by each member from all of Movies Abdundant’s branches. 
			 Sort your list in alphabetical order of the members’ last names. */
SELECT c.FirstName,c.LastName, COUNT(r.DVD_ID) AS TotalDVDRented
FROM RentalRecord AS r, Customer AS c
WHERE r.Customer_ID=c.ID
GROUP BY c.LastName, c.FirstName
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
ORDER BY deduct.Branch_ID, deduct.Catalogue_ID;




/*vi.	Produce a list displaying the total copies of DVDs categorized by genres that the company has in totality, across all its branches. ============= */
SELECT c.Genres, COUNT(d.Catalogue_ID) AS TotalInGenre
FROM DVD AS d INNER JOIN Catalogue AS c ON d.Catalogue_ID=c.ID
GROUP BY c.Genres;





/*vii.	Show a list of all members with outstanding fines for overdue DVDs. 
List the member IDs, names, movie IDs, movie title, date borrowed, date due, total number of days overdue and fine incurred for each overdue DVD. 
====== OVERDUE CHARGES IS RM 2 A DAY   ============= */
SELECT Overdue.Customer_ID, c.FirstName, cat.ID, cat.MovieName, Overdue.RentDate,Overdue.DueDate, Overdue.ReturnDate, Overdue.TotalOfOverdueDays, Overdue.TotalOfOverdueDays*2 AS 'Overdue Charges, RM'
FROM (
		SELECT r.Customer_ID, r.RentDate, r.ReturnDate, r.DueDate, d.Catalogue_ID,DateDiff(day, r.DueDate, r.ReturnDate) AS TotalOfOverdueDays
		FROM RentalRecord AS r INNER JOIN DVD As d ON r.DVD_ID=d.ID
		WHERE ReturnDate>DueDate ) AS Overdue 
INNER JOIN Customer AS c ON c.ID=Overdue.Customer_ID 
INNER JOIN Catalogue AS cat ON cat.ID=Overdue.Catalogue_ID ;






/*viii.	Produce a list of movies with the total number of various feedback ratings given by members for each movie, 
i.e. based on the scores (1-3 which is 1=bad, 2=average and 3=good) ============= */
SELECT cat.MovieName, scale01.BAD, scale02.AVERAGE, scale03.GOOD
FROM ( SELECT count(f.Scale) AS GOOD, cat.MovieName FROM Feedback AS f, Catalogue AS cat WHERE f.Scale='3' AND cat.ID=f.Catalogue_ID GROUP BY cat.MovieName) AS scale03, 
( SELECT count(f.Scale) AS AVERAGE, cat.MovieName FROM Feedback AS f, Catalogue AS cat WHERE f.Scale='2' AND cat.ID=f.Catalogue_ID GROUP BY cat.MovieName) AS scale02,
( SELECT count(f.Scale) AS BAD, cat.MovieName FROM Feedback AS f, Catalogue AS cat WHERE f.Scale='1' AND cat.ID=f.Catalogue_ID GROUP BY cat.MovieName) AS scale01,
Feedback AS f, Catalogue AS cat
WHERE f.Catalogue_ID=cat.ID AND scale01.MovieName=cat.MovieName AND scale02.MovieName=cat.MovieName AND scale03.MovieName=cat.MovieName
GROUP BY cat.MovieName, scale01.BAD, scale02.AVERAGE, scale03.GOOD;






/*==== ix.	Produce a listing showing the staff distribution at each branch. 
Include the branch number, manager name, total number of supervisors, and total number of male and female staff for each branch. ==== */

/* === Counted Manager as 1 Staff === */
SELECT b.ID, Manager.Manager, Supervisors.Supervisors, fStaff.FemaleStaff, mStaff.MaleStaff, fStaff.FemaleStaff + mStaff.MaleStaff + Supervisors.Supervisors + 1 AS TotalStaff
FROM Branch as b FULL OUTER JOIN Staff AS s ON b.ID=s.Branch_ID FULL OUTER JOIN 
	/* ==== TOTAL SUPERVISORS ======*/
	(SELECT b.ID, COUNT(s.Position) AS Supervisors FROM Branch as b FULL OUTER JOIN Staff AS s ON b.ID=s.Branch_ID WHERE s.Position='Supervisor' GROUP BY b.ID,S.Position) AS Supervisors 
	ON Supervisors.ID=b.ID FULL OUTER JOIN 
	/* ==== MANAGER NAME ======*/
	(SELECT b.ID, s.FirstName AS Manager FROM Branch as b FULL OUTER JOIN Staff AS s ON b.ID=s.Branch_ID WHERE s.Position='Manager' GROUP BY b.ID,s.firstname) AS Manager
	ON Manager.ID=b.ID FULL OUTER JOIN 
	/* ====FEMALE WORKER ======*/
	(SELECT b.ID, COUNT(s.Gender) AS FemaleStaff FROM Branch as b FULL OUTER JOIN Staff AS s ON b.ID=s.Branch_ID WHERE s.Gender='Female' GROUP BY b.ID,S.Gender) AS fStaff
	ON fStaff.ID=b.ID FULL OUTER JOIN
	/* ====MALE WORKER ======*/
	(SELECT b.ID, COUNT(s.Gender) AS MaleStaff FROM Branch as b FULL OUTER JOIN Staff AS s ON b.ID=s.Branch_ID WHERE s.Gender='Male' GROUP BY b.ID,S.Gender) AS mStaff
	ON mStaff.ID=b.ID

GROUP BY b.ID, Supervisors.Supervisors, Manager.Manager, fStaff.FemaleStaff, mStaff.MaleStaff
ORDER BY b.ID;

