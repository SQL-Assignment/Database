USE [MoviesAbundant-DVDRental];

-- Create Branch Table
CREATE TABLE Branch (
	ID varchar(7) PRIMARY KEY,
	BranchAddress varchar(255) NOT NULL
);

-- Create Customer Table
CREATE TABLE Customer (
    ID varchar(7) PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
	HomeAddress varchar(255),
	Email varchar(50),
    PhoneNumber varchar(11) NOT NULL,
	Branch_ID varchar(7) FOREIGN KEY REFERENCES Branch(ID) NOT NULL
);

-- Create Catalogue Table
CREATE TABLE Catalogue (
	ID varchar(7) PRIMARY KEY,
	MovieName varchar(60) NOT NULL,
	Genres varchar(20) NOT NULL,
	ReleaseDate date
);

-- Create DVD Table
CREATE TABLE DVD (
	ID varchar(7) PRIMARY KEY,
	Catalogue_ID varchar(7) FOREIGN KEY REFERENCES Catalogue(ID) NOT NULL,
	Branch_ID varchar(7) FOREIGN KEY REFERENCES Branch(ID) NOT NULL
);

-- Create Feedback Table
CREATE TABLE Feedback (
	Scale varchar(1) NOT NULL,
	Comment varchar(255),
	Customer_ID varchar(7) FOREIGN KEY REFERENCES Customer(ID) NOT NULL,
	Catalogue_ID varchar(7) FOREIGN KEY REFERENCES Catalogue(ID) NOT NULL,
	PRIMARY KEY(Customer_ID, Catalogue_ID)
);

-- Create Rental Record Table
CREATE TABLE RentalRecord (
	ID varchar(7) PRIMARY KEY,
	RentDate date NOT NULL,
	DueDate date NOT NULL,
	ReturnDate date,
	Customer_ID varchar(7) FOREIGN KEY REFERENCES Customer(ID) NOT NULL,
	DVD_ID varchar(7) FOREIGN KEY REFERENCES DVD(ID) NOT NULL
);

-- Create Staff Table 
CREATE TABLE Staff (
	ID varchar(7) PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
	Gender varchar(6) NOT NULL,
	Position varchar(20) NOT NULL,
	HomeAddress varchar(255),
	Branch_ID varchar(7) FOREIGN KEY REFERENCES Branch(ID)
);