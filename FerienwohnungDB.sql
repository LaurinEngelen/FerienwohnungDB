DROP TABLE Anzahlung;
DROP TABLE FEWOERREICHBARTOURI;
DROP TABLE FEWOHATAUS;
DROP TABLE Touristenattraktion;
DROP TABLE BILDER;
DROP TABLE AUSSTATTUNG;
DROP TABLE BUCHUNG;
DROP TABLE FERIENWOHNUNG;
DROP TABLE KUNDE;
DROP TABLE Adresse;
DROP TABLE LAND;

-----------------------------------------------------------------------------

CREATE TABLE Land
    (NameLand VARCHAR2(100),
    CONSTRAINT Land_pk PRIMARY KEY (NameLand));

CREATE TABLE Adresse
    (AdressID INT generated always as IDENTITY,
    NameLand VARCHAR2(50),
    Stadt VARCHAR2(50) NOT NULL,
    Straße VARCHAR2(50) NOT NULL,
    PLZ INT NOT NULL,
    Hausnummer INT NOT NULL,
    CONSTRAINT Adresse_pk PRIMARY KEY (AdressID),
    CONSTRAINT Adresse_fk FOREIGN KEY (NameLand) REFERENCES Land(NameLand));
    
CREATE TABLE Kunde
    (KundenID INT generated always as IDENTITY,
    Mailadresse VARCHAR2(50),
    AdressID INT NOT NULL,
    Vorname VARCHAR2(50) NOT NULL,
    Nachname VARCHAR2(50) NOT NULL,
    IBAN VARCHAR2(34) NOT NULL,
    Passwort VARCHAR2(50) NOT NULL,
    Newsletter CHAR(1) NOT NULL,
    CONSTRAINT Kunde_pk PRIMARY KEY (KundenID),
    CONSTRAINT Kunde_fk FOREIGN KEY (AdressID) REFERENCES Adresse(AdressID),
    CONSTRAINT mailadresse_format CHECK (REGEXP_LIKE(Mailadresse, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
    CONSTRAINT newsletter_flag CHECK (Newsletter IN ('J', 'N')));

CREATE TABLE Ferienwohnung
    (NameFeWo VARCHAR2(50),
    AdressID INT,
    Zimmeranzahl INT NOT NULL,
    Preis FLOAT NOT NULL,
    Groesse FLOAT NOT NULL,
    CONSTRAINT Ferienwohnung_pk PRIMARY KEY (NameFeWo),
    CONSTRAINT Ferienwohnung_fk FOREIGN KEY (AdressID) REFERENCES Adresse(AdressID));
    
CREATE TABLE Buchung
    (Buchungsnr INT generated always as IDENTITY,
    KundenID INT NOT NULL,
    NameFeWo VARCHAR2(50),
    Stornierungsdatum DATE NULL,
    Reservierungsstart DATE NOT NULL,
    Reservierungsende DATE NOT NULL,
    BewertungsDatum DATE NULL,
    AnzahlSterne FLOAT NULL,
    Rechnungsnr INT NULL UNIQUE generated always as IDENTITY,
    Rechnungsdatum DATE NULL,
    Gesamtbetrag FLOAT NOT NULL,
    CONSTRAINT Buchung_pk PRIMARY KEY (Buchungsnr),
    CONSTRAINT Buchung_fk1 FOREIGN KEY (KundenID) REFERENCES Kunde(KundenID),
    CONSTRAINT Buchung_fk2 FOREIGN KEY (NameFeWo) REFERENCES Ferienwohnung(NameFeWo));


CREATE TABLE Ausstattung
    (NameAus VARCHAR2(50),
    CONSTRAINT Ausstattung_pk PRIMARY KEY (NameAus));

CREATE TABLE Bilder
    (DateiID INT generated always as IDENTITY,
    NameFeWo VARCHAR2(50),
    CONSTRAINT Bilder_pk PRIMARY KEY (DateiID),
    CONSTRAINT Bilder_fk FOREIGN KEY (NameFeWo) REFERENCES Ferienwohnung(NameFeWo));

CREATE TABLE Touristenattraktion
    (NameTouri VARCHAR2(50),
    Beschreibung VARCHAR2(200) NOT NULL,
    CONSTRAINT Touristenattraktion_pk PRIMARY KEY (NameTouri));
    

CREATE TABLE FeWoErreichbarTouri
    (NameFeWo VARCHAR2(50),
    NameTouri VARCHAR2(50),
    CONSTRAINT FeWoErreichbarTouri_pk PRIMARY KEY (NameFeWo, NameTouri),
    CONSTRAINT FeWoErreichbarTouri_fk1 FOREIGN KEY (NameFeWo) REFERENCES Ferienwohnung(NameFeWo) ON DELETE CASCADE,
    CONSTRAINT FeWoErreichbarTouri_fk2 FOREIGN KEY (NameTouri) REFERENCES Touristenattraktion(NameTouri) ON DELETE CASCADE);

CREATE TABLE FeWoHatAus
    (NameFeWo VARCHAR2(50),
    NameAus VARCHAR2(50),
    CONSTRAINT FeWoHatAus_pk PRIMARY KEY (NameFeWo, NameAus),
    CONSTRAINT FeWoHatAus_fk1 FOREIGN KEY (NameFeWo) REFERENCES Ferienwohnung(NameFeWo) ON DELETE CASCADE,
    CONSTRAINT FeWoHatAus_fk2 FOREIGN KEY (NameAus) REFERENCES Ausstattung(NameAus) ON DELETE CASCADE);

CREATE TABLE Anzahlung
    (Anzahlungsnr INT generated always as IDENTITY,
    Buchungsnr INT,
    Zahlungsdatum DATE NOT NULL,
    Betrag FLOAT NOT NULL,
    CONSTRAINT Anzahlung_pk PRIMARY KEY (Anzahlungsnr),
    CONSTRAINT Anzahlung_fk FOREIGN KEY (Buchungsnr) REFERENCES Buchung(Buchungsnr));

--------------------------------------------------------------------------------------------

GRANT SELECT, INSERT ON Buchung TO dbsys80;

GRANT SELECT, INSERT, UPDATE ON KUNDE TO dbsys80;

GRANT SELECT, INSERT, UPDATE ON Adresse TO dbsys80;

GRANT SELECT, INSERT ON Anzahlung TO dbsys80;

GRANT SELECT ON Ferienwohnung TO dbsys80;

GRANT SELECT ON Touristenattraktion TO dbsys80;

GRANT SELECT ON Ausstattung TO dbsys80;

GRANT SELECT ON Bilder TO dbsys80;

GRANT SELECT ON Land TO dbsys80;


---------------------------------------------------------------------------------------

INSERT INTO Land(NameLand) VALUES ('Deutschland');
INSERT INTO Land(NameLand) VALUES ('Spanien'); 
INSERT INTO Land(NameLand) VALUES ('Frankreich');
INSERT INTO Land(NameLand) VALUES ('Italien');
INSERT INTO Land(NameLand) VALUES ('Österreich');
INSERT INTO Land(NameLand) VALUES ('Schweiz');
INSERT INTO Land(NameLand) VALUES ('Niederlande');
INSERT INTO Land(NameLand) VALUES ('Belgien');
INSERT INTO Land(NameLand) VALUES ('Luxemburg');
INSERT INTO Land(NameLand) VALUES ('Dänemark');
INSERT INTO Land(NameLand) VALUES ('Norwegen');
INSERT INTO Land(NameLand) VALUES ('Schweden');
INSERT INTO Land(NameLand) VALUES ('Finnland');


INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Deutschland', 'Esslingen', 'Kirchstraße', 73773, 17);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Italien', 'Rom', 'Via del Corso', 00186, 22);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Österreich', 'Wien', 'Kärntner Straße', 1010, 5);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Schweiz', 'Zürich', 'Bahnhofstrasse', 8001, 10);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Niederlande', 'Amsterdam', 'Damrak', 1012, 15);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Belgien', 'Brüssel', 'Rue Neuve', 1000, 8);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Luxemburg', 'Luxemburg', 'Avenue de la Liberté', 1930, 12);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Dänemark', 'Kopenhagen', 'Strøget', 1150, 20);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Norwegen', 'Oslo', 'Karl Johans gate', 0162, 18);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Schweden', 'Stockholm', 'Drottninggatan', 11151, 25);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Finnland', 'Helsinki', 'Aleksanterinkatu', 00100, 30);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Deutschland', 'Berlin', 'Unter den Linden', 10117, 1);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Spanien', 'Madrid', 'Gran Vía', 28013, 3);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Frankreich', 'Lyon', 'Rue de la République', 69002, 7);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Italien', 'Mailand', 'Corso Buenos Aires', 20124, 9);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Spanien', 'Servia', 'Kirchstraße', 43554, 21);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Deutschland', 'Hamburg', 'Reeperbahn', 20359, 36);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Spanien', 'Barcelona', 'La Rambla', 08002, 45);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Frankreich', 'Paris', 'Champs-Élysées', 75008, 101);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Italien', 'Florenz', 'Via Roma', 50123, 12);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Österreich', 'Salzburg', 'Getreidegasse', 5020, 22);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Schweiz', 'Genf', 'Rue du Rhône', 1204, 5);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Niederlande', 'Rotterdam', 'Coolsingel', 3012, 18);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Belgien', 'Antwerpen', 'Meir', 2000, 27);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Luxemburg', 'Esch-sur-Alzette', 'Rue de lAlzette', 4010, 9);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Dänemark', 'Aarhus', 'Strøget', 8000, 14);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Norwegen', 'Bergen', 'Bryggen', 5003, 7);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Spanien', 'Madrid', 'Gran Vía', 28013, 15);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Finnland', 'Turku', 'Kauppatori', 20100, 11);
INSERT INTO Adresse(NameLand, Stadt, Straße, PLZ, Hausnummer) VALUES ('Deutschland', 'München', 'Marienplatz', 80331, 1);


INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('Laurin.Engelen@gmail.com', 1, 'Laurin', 'Engelen', 'DE123456789', 'passwort', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('anna.schmidt@example.com', 3, 'Anna', 'Schmidt', 'DE987654321', 'password1', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('max.mustermann@example.com', 5, 'Max', 'Mustermann', 'DE123456780', 'password2', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('julia.meyer@example.com', 7, 'Julia', 'Meyer', 'DE234567891', 'password3', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('peter.schulz@example.com', 9, 'Peter', 'Schulz', 'DE345678902', 'password4', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('lisa.bauer@example.com', 11, 'Lisa', 'Bauer', 'DE456789013', 'password5', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('thomas.fischer@example.com', 13, 'Thomas', 'Fischer', 'DE567890124', 'password6', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('sarah.wagner@example.com', 15, 'Sarah', 'Wagner', 'DE678901235', 'password7', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('michael.klein@example.com', 17, 'Michael', 'Klein', 'DE789012346', 'password8', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('laura.hoffmann@example.com', 19, 'Laura', 'Hoffmann', 'DE890123457', 'password9', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('daniel.schwarz@example.com', 21, 'Daniel', 'Schwarz', 'DE901234568', 'password10', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('sophie.neumann@example.com', 23, 'Sophie', 'Neumann', 'DE012345679', 'password11', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('lukas.weber@example.com', 25, 'Lukas', 'Weber', 'DE123456780', 'password12', 'J');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('emily.frank@example.com', 27, 'Emily', 'Frank', 'DE234567891', 'password13', 'N');
INSERT INTO Kunde(Mailadresse, AdressID, Vorname, Nachname, IBAN, Passwort, Newsletter) 
    VALUES ('jonas.koenig@example.com', 29, 'Jonas', 'König', 'DE345678902', 'password14', 'J');



INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung1', 2, 3, 100.0, 50.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung2', 4, 2, 80.0, 40.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung3', 6, 4, 120.0, 60.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung4', 8, 1, 70.0, 35.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung5', 10, 3, 110.0, 55.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung6', 12, 2, 90.0, 45.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung7', 14, 4, 130.0, 65.0);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung8', 16, 1, 75.0, 37.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung9', 18, 3, 115.0, 57.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung10', 20, 2, 85.0, 42.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung11', 22, 4, 125.0, 62.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung12', 24, 1, 65.0, 32.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung13', 26, 3, 105.0, 52.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung14', 28, 2, 95.0, 47.5);
INSERT INTO Ferienwohnung(NameFeWo, AdressID, Zimmeranzahl, Preis, Groesse) VALUES ('Ferienwohnung15', 30, 4, 135.0, 67.5);


INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung1', NULL, TO_DATE('2021-01-01', 'YYYY-MM-DD'), TO_DATE('2021-01-10', 'YYYY-MM-DD'), TO_DATE('2021-01-29', 'YYYY-MM-DD'), 3, 1, TO_DATE('2021-01-01', 'YYYY-MM-DD'), 1000.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (5, 'Ferienwohnung2', NULL, TO_DATE('2021-02-01', 'YYYY-MM-DD'), TO_DATE('2021-02-05', 'YYYY-MM-DD'), TO_DATE('2021-02-17', 'YYYY-MM-DD'), 5, 2, TO_DATE('2021-02-01', 'YYYY-MM-DD'), 400.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (3, 'Ferienwohnung3', NULL, TO_DATE('2021-03-01', 'YYYY-MM-DD'), TO_DATE('2021-03-07', 'YYYY-MM-DD'), TO_DATE('2021-03-29', 'YYYY-MM-DD'), 2, 3, TO_DATE('2021-03-01', 'YYYY-MM-DD'), 840.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung4', NULL, TO_DATE('2021-04-01', 'YYYY-MM-DD'), TO_DATE('2021-04-03', 'YYYY-MM-DD'), TO_DATE('2021-04-23', 'YYYY-MM-DD'), 3, 4, TO_DATE('2021-04-01', 'YYYY-MM-DD'), 210.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (5, 'Ferienwohnung4', NULL, TO_DATE('2021-05-01', 'YYYY-MM-DD'), TO_DATE('2021-05-08', 'YYYY-MM-DD'), TO_DATE('2021-05-19', 'YYYY-MM-DD'), 4, 5, TO_DATE('2021-05-01', 'YYYY-MM-DD'), 770.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (6, 'Ferienwohnung1', NULL, TO_DATE('2021-06-01', 'YYYY-MM-DD'), TO_DATE('2021-06-04', 'YYYY-MM-DD'), TO_DATE('2021-06-16', 'YYYY-MM-DD'), 5, 6, TO_DATE('2021-06-01', 'YYYY-MM-DD'), 270.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (7, 'Ferienwohnung7', NULL, TO_DATE('2021-07-01', 'YYYY-MM-DD'), TO_DATE('2021-07-10', 'YYYY-MM-DD'), TO_DATE('2021-07-18', 'YYYY-MM-DD'), 3, 7, TO_DATE('2021-07-01', 'YYYY-MM-DD'), 1300.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung7', NULL, TO_DATE('2021-08-01', 'YYYY-MM-DD'), TO_DATE('2021-08-02', 'YYYY-MM-DD'), TO_DATE('2021-08-24', 'YYYY-MM-DD'), 2, 8, TO_DATE('2021-08-01', 'YYYY-MM-DD'), 75.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (5, 'Ferienwohnung9', NULL, TO_DATE('2021-09-01', 'YYYY-MM-DD'), TO_DATE('2021-09-05', 'YYYY-MM-DD'), TO_DATE('2021-09-23', 'YYYY-MM-DD'), 4, 9, TO_DATE('2021-09-01', 'YYYY-MM-DD'), 460.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (10, 'Ferienwohnung10', NULL, TO_DATE('2021-10-01', 'YYYY-MM-DD'), TO_DATE('2021-10-03', 'YYYY-MM-DD'), TO_DATE('2021-11-03', 'YYYY-MM-DD'), 3, 10, TO_DATE('2021-10-01', 'YYYY-MM-DD'), 170.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (11, 'Ferienwohnung11', NULL, TO_DATE('2021-11-01', 'YYYY-MM-DD'), TO_DATE('2021-11-07', 'YYYY-MM-DD'), TO_DATE('2021-11-21', 'YYYY-MM-DD'), 2, 11, TO_DATE('2021-11-01', 'YYYY-MM-DD'), 750.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (12, 'Ferienwohnung12', NULL, TO_DATE('2021-12-01', 'YYYY-MM-DD'), TO_DATE('2021-12-02', 'YYYY-MM-DD'), TO_DATE('2021-12-29', 'YYYY-MM-DD'), 4, 12, TO_DATE('2021-12-01', 'YYYY-MM-DD'), 65.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung10', NULL, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-05', 'YYYY-MM-DD'), NULL, NULL, 13, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 420.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (12, 'Ferienwohnung14', NULL, TO_DATE('2022-02-01', 'YYYY-MM-DD'), TO_DATE('2022-02-04', 'YYYY-MM-DD'), TO_DATE('2022-03-04', 'YYYY-MM-DD'), 3, 14, TO_DATE('2022-02-01', 'YYYY-MM-DD'), 285.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (15, 'Ferienwohnung15', NULL, TO_DATE('2022-03-01', 'YYYY-MM-DD'), TO_DATE('2022-03-10', 'YYYY-MM-DD'), TO_DATE('2022-03-17', 'YYYY-MM-DD'), 5, 15, TO_DATE('2022-03-01', 'YYYY-MM-DD'), 1350.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung1', NULL, TO_DATE('2022-04-01', 'YYYY-MM-DD'), TO_DATE('2022-04-10', 'YYYY-MM-DD'), TO_DATE('2022-05-10', 'YYYY-MM-DD'), 2, 16, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 1000.0);

INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung14', NULL, TO_DATE('2024-05-02', 'YYYY-MM-DD'), TO_DATE('2024-05-11', 'YYYY-MM-DD'), TO_DATE('2024-05-29', 'YYYY-MM-DD'), 5, 17, TO_DATE('2025-05-02', 'YYYY-MM-DD'), 1200.0);

COMMIT;

INSERT INTO Ausstattung(NameAus) VALUES ('WLAN');
INSERT INTO Ausstattung(NameAus) VALUES ('Klimaanlage');
INSERT INTO Ausstattung(NameAus) VALUES ('Heizung');
INSERT INTO Ausstattung(NameAus) VALUES ('Küche');
INSERT INTO Ausstattung(NameAus) VALUES ('Waschmaschine');
INSERT INTO Ausstattung(NameAus) VALUES ('Trockner');
INSERT INTO Ausstattung(NameAus) VALUES ('Balkon');
INSERT INTO Ausstattung(NameAus) VALUES ('Terrasse');
INSERT INTO Ausstattung(NameAus) VALUES ('Garten');
INSERT INTO Ausstattung(NameAus) VALUES ('Pool');
INSERT INTO Ausstattung(NameAus) VALUES ('Fitnessraum');
INSERT INTO Ausstattung(NameAus) VALUES ('Sauna');
INSERT INTO Ausstattung(NameAus) VALUES ('Parkplatz');
INSERT INTO Ausstattung(NameAus) VALUES ('Garage');
INSERT INTO Ausstattung(NameAus) VALUES ('Aufzug');


INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung1');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung2');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung3');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung4');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung5');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung6');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung7');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung8');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung9');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung10');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung11');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung12');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung13');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung14');
INSERT INTO Bilder(NameFeWo) VALUES ('Ferienwohnung15');


INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Schloss Neuschwanstein', 'Ein Schloss in Bayern');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Kolosseum', 'Ein antikes Amphitheater in Rom');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Eiffelturm', 'Ein Wahrzeichen von Paris');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Taj Mahal', 'Ein weißes Marmormmausoleum in Indien');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Machu Picchu', 'Eine Inkastadt in Peru');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Grand Canyon', 'Eine riesige Schlucht in den USA');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Great Barrier Reef', 'Das größte Korallenriff der Welt');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Angkor Wat', 'Ein buddhistischer Tempelkomplex in Kambodscha');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Kiyomizu-dera', 'Ein buddhistischer Tempel in Kyoto');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Moai-Statuen', 'Riesenstatuen auf der Osterinsel');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Petra', 'Eine historische Stadt in Jordanien');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Ulmer Münster', 'Der höchste Kirchturm der Welt');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Brandenburger Tor', 'Ein Wahrzeichen Berlins');
INSERT INTO Touristenattraktion(NameTouri, Beschreibung) VALUES ('Mauerpark', 'Ein beliebter Park in Berlin mit Flohmarkt');

INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung1', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung6', 'Garten');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung5', 'Parkplatz');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung7', 'Garten');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung2', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung7', 'Küche');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung3', 'Parkplatz');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung3', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung3', 'Küche');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung4', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung2', 'Garten');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung5', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung8', 'Garten');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung6', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung7', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung8', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung9', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung10', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung6', 'Küche');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung11', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung9', 'Parkplatz');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung3', 'Garten');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung12', 'WLAN');
INSERT INTO FeWoHatAus(NameFeWo, NameAus) VALUES ('Ferienwohnung14', 'Sauna');


INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung1', 'Schloss Neuschwanstein');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung2', 'Kolosseum');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung3', 'Eiffelturm');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung4', 'Taj Mahal');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung5', 'Machu Picchu');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung6', 'Grand Canyon');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung7', 'Great Barrier Reef');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung8', 'Angkor Wat');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung9', 'Kiyomizu-dera');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung10', 'Moai-Statuen');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung11', 'Petra');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung12', 'Ulmer Münster');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung13', 'Schloss Neuschwanstein');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung1', 'Brandenburger Tor');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung2', 'Schloss Neuschwanstein');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung3', 'Mauerpark');
INSERT INTO FeWoErreichbarTouri(NameFeWo, NameTouri) VALUES ('Ferienwohnung4', 'Petra');


INSERT INTO Anzahlung(Buchungsnr, Zahlungsdatum, Betrag) VALUES (1, TO_DATE('2021-01-01', 'YYYY-MM-DD'), 100.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (2, TO_DATE('2021-02-15', 'YYYY-MM-DD'), 200.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (3, TO_DATE('2021-03-10', 'YYYY-MM-DD'), 150.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (4, TO_DATE('2021-04-05', 'YYYY-MM-DD'), 300.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (5, TO_DATE('2021-05-20', 'YYYY-MM-DD'), 250.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (6, TO_DATE('2021-06-15', 'YYYY-MM-DD'), 180.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (7, TO_DATE('2021-07-01', 'YYYY-MM-DD'), 220.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (8, TO_DATE('2021-08-10', 'YYYY-MM-DD'), 350.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (9, TO_DATE('2021-09-05', 'YYYY-MM-DD'), 280.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (10, TO_DATE('2021-10-20', 'YYYY-MM-DD'), 210.0);
INSERT INTO Anzahlung (Buchungsnr, Zahlungsdatum, Betrag) VALUES (11, TO_DATE('2021-11-15', 'YYYY-MM-DD'), 190.0); 


COMMIT;
---------------------------------------------------------------------------------------------------

UPDATE Kunde SET Newsletter = 'N' WHERE Mailadresse = 'Laurin.Engelen@gmail.com';
UPDATE Ferienwohnung SET Preis = 200.0 WHERE NameFeWo = 'Ferienwohnung1'; // Fehlermeldung, da Preis nicht geändert werden darf


SELECT * FROM Kunde WHERE Mailadresse = 'Laurin.Engelen@gmail.com';

SELECT * FROM Ferienwohnung;

SELECT * FROM dbsys80.Buchung;



