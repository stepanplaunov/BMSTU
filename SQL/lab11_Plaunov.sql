USE master;
IF DB_ID ('Lab11') IS NOT NULL
DROP DATABASE [Lab11]
GO


CREATE DATABASE Lab11
ON (
	NAME = Lab_DB, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.LOCAL\MSSQL\DATA\lab11db.mdf',
	SIZE = 10MB,
	MAXSIZE = 1GB,
	FILEGROWTH = 5MB
)
LOG ON (
	NAME = Lab_DB_LOG, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.LOCAL\MSSQL\DATA\lab11log.ldf',
	SIZE = 10MB,
	MAXSIZE = 30MB,
	FILEGROWTH = 5MB
);
GO

USE Lab11;

DROP TABLE IF EXISTS Users
DROP TABLE IF EXISTS TextilesOrders
DROP TABLE IF EXISTS Textiles
DROP TABLE IF EXISTS LineTextiles
DROP TABLE IF EXISTS MaterialTypes
DROP TABLE IF EXISTS Decoration
DROP TABLE IF EXISTS Clothes
DROP TABLE IF EXISTS DecorKind

GO
CREATE TABLE Users(
    id INT IDENTITY(1,1) PRIMARY KEY,
	phone  NVARCHAR(50) UNIQUE NOT NULL,
    firstName NVARCHAR(50) NOT NULL,
    secondName NVARCHAR(50) NOT NULL,
    birthday DATE NOT NULL,
	email NVARCHAR(318) UNIQUE NOT NULL,
)

CREATE TABLE TextilesOrders(
	orderId INT IDENTITY(1,1) PRIMARY KEY,
	userId INT NOT NULL,
	CONSTRAINT userIdFK FOREIGN KEY (userId) REFERENCES Users(id) on DELETE CASCADE,
	time DATETIME Not NULL DEFAULT(CAST(GETDATE() AS DATETIME)),
)

CREATE TABLE Textiles(
	article INT IDENTITY(1,1) PRIMARY KEY,
	imageLink NVARCHAR(1083) UNIQUE Not NULL,
	color INT CHECK (color BETWEEN 0 AND 16777216),
	material INT CONSTRAINT materialTypeCheck CHECK (material BETWEEN 0 AND 12),
	baseWashPrice Money CONSTRAINT basePriceCheck CHECK (baseWashPrice > 0)
--(‘cotton’,‘silk’,‘wool’,‘fluff’,‘jersey’,‘viscose’,‘linen’,‘membrane’,‘water repellent’,‘sintepon’,’leather’)
)

CREATE TABLE LineTextiles(
	article Int Not NULL,
	CONSTRAINT articleFK FOREIGN KEY (article) REFERENCES Textiles(article) on DELETE NO ACTION,
	orderId Int Not NULL,
	CONSTRAINT orderIdFK FOREIGN KEY (orderId) REFERENCES TextilesOrders(orderId) on DELETE CASCADE,
	resultPrice Money NULL
)

CREATE TABLE Clothes(
	article INT NOT NULL,
	clothesKind INT NoT NULL,
	CONSTRAINT articleClothesFK FOREIGN KEY (article) REFERENCES Textiles(article) on DELETE CASCADE,
)

CREATE TABLE Decoration(
	article INT NOT NULL,
	decorKind INT CONSTRAINT decorKindCheck CHECK (decorKind BETWEEN 0 AND 4),
	CONSTRAINT articleDecorationFK FOREIGN KEY (article) REFERENCES Textiles(article) on DELETE CASCADE,
)
	
CREATE TABLE DecorKind(
	id INT IDENTITY(1,1) PRIMARY KEY,
	name NVARCHAR(50) UNIQUE NOT NULL,
	width FLOAT CHECK (width > 0),
	height FLOAT CHECK (height > 0)
)

CREATE TABLE MaterialTypes(
	id INT IDENTITY(1,1) PRIMARY KEY,
	name NVARCHAR(50) UNIQUE NOT NULL,
)

INSERT INTO DecorKind(name) VALUES	('carpet'),
									('curtains'),
									('pillowcase'),
									('bedsheet')

INSERT INTO MaterialTypes(name) VALUES ('cotton'),
										('silk'),
										('wool'),
										('fluff'),
										('jersey'),
										('viscose'),
										('linen'),
										('membrane'),
										('water repellent'),
										('sintepon'),
										('leather')
SELECT * FROM MaterialTypes

ALTER TABLE Clothes 
DROP CONSTRAINT articleClothesFK;
ALTER TABLE Decoration 
DROP CONSTRAINT articleDecorationFK;
ALTER TABLE TextilesOrders 
DROP CONSTRAINT userIdFK;
ALTER TABLE LineTextiles 
DROP CONSTRAINT articleFK;
ALTER TABLE LineTextiles 
DROP CONSTRAINT orderIdFK;
