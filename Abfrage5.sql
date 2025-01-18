SELECT * FROM Buchung;
SELECT * FROM Ferienwohnung;
SELECT * FROM Kunde;

// Wie viele Ferienwohnungen wurden noch nie gebucht?
SELECT COUNT(*) AS Ungebucht FROM Ferienwohnung f WHERE NOT EXISTS (SELECT * FROM Buchung b WHERE f.NameFeWo = b.NameFeWo);


// Welche Kunden haben EINE Ferienwohnung bereits mehrmals gebucht?
SELECT KundenID FROM Buchung GROUP BY KundenID HAVING COUNT(*) >1;

SELECT Distinct b1.KundenID FROM Buchung b1 JOIN Buchung b2 ON b1.KundenID = b2.KundenID AND b1.NameFeWo = b2.NameFeWo AND b1.Buchungsnr <> b2.Buchungsnr;
SELECT Distinct b1.KundenID FROM Buchung b1, Buchung b2 WHERE b1.KundenID = b2.KundenID AND b1.NameFeWo = b2.NameFeWo AND b1.Buchungsnr <> b2.Buchungsnr;


// Welche Ferienwohnung in Spanien haben durchschnittlich mehr als 4 Sterne erhalten?

    
SELECT f.NameFeWo, AVG(b.AnzahlSterne) AS Durchschnitt
    FROM Ferienwohnung f
    JOIN Adresse a ON f.AdressID = a.AdressID
    JOIN Buchung b ON f.NameFeWo = b.NameFeWo
    WHERE a.NameLand = 'Spanien'
    GROUP BY f.NameFeWo
    HAVING AVG(b.AnzahlSterne) >= 4;
    


// Welche Ferienwohnung hat die meisten Ausstattungen? Falls mehrere Ferienwohnungen das Maximum an Ausstattung erreichen, sollen alle ausgegben werden.

SELECT NameFeWo, COUNT(*) AS Anzahl
    FROM FeWoHatAus
    GROUP BY NameFeWo
    ORDER BY Anzahl DESC;

SELECT MAX(Anzahl) FROM (
    SELECT NameFeWo, COUNT(*) AS Anzahl
        FROM FeWoHatAus
        GROUP BY NameFeWo
        ORDER BY Anzahl DESC);

SELECT NameFeWo, Anzahl
FROM (
    SELECT NameFeWo, COUNT(*) AS Anzahl
    FROM FeWoHatAus
    GROUP BY NameFeWo)
    WHERE Anzahl = (
        SELECT MAX(Anzahl)
        FROM (
            SELECT COUNT(*) AS Anzahl
            FROM FeWoHatAus
            GROUP BY NameFeWo
    ));


// Wie viele Reservierungen gibt es für die einzelnen Länder? Länder, in denen keine Reservierungen
// existieren, sollen mit der Anzahl 0 ebenfalls aufgeführt werden. Das Ergebnis soll nach der Anzahl
// Reservierungen absteigend sortiert werden.
    
SELECT NameLand, Anzahl
FROM (
    SELECT a.NameLand, Count(*)AS Anzahl
    FROM Buchung b
    JOIN Ferienwohnung f ON f.NameFeWo = b.NameFeWo
    JOIN Adresse a ON f.AdressID = a.AdressID
    GROUP BY a.NameLand);

SELECT l.NameLand, COALESCE(r.Anzahl, 0) AS Anzahl
FROM Land l
LEFT JOIN (
    SELECT a.NameLand, COUNT(*) AS Anzahl
    FROM Buchung b
    JOIN Ferienwohnung f ON f.NameFeWo = b.NameFeWo
    JOIN Adresse a ON f.AdressID = a.AdressID
    GROUP BY a.NameLand
) r ON l.NameLand = r.NameLand
ORDER BY Anzahl DESC;

// Wie viele Ferienwohnungen sind pro Stadtnamen gespeichert?

SELECT a.Stadt, Count(*) AS Anzahl
    FROM Adresse a
    JOIN Ferienwohnung f ON a.AdressID = f.AdressID
    GROUP BY a.Stadt;
    
    
// Welche Ferienwohnungen haben bisher NUR Bewertungen mit einem oder zwei Sternen erhalten?

SELECT DISTINCT NameFeWo
    FROM Buchung
    WHERE AnzahlSterne <= 2
    AND NameFeWo NOT IN (SELECT NameFeWo FROM Buchung WHERE  AnzahlSterne < 2);



// Welche Ferienwohnungen mit Sauna sind in Spanien in der Zeit vom 01.05.2024 – 21.05.2024 noch
//  frei? Geben Sie den Ferienwohnungs-Namen und deren durchschnittliche Bewertung an.
//  Ferienwohnungen mit guten Bewertungen sollen zuerst angezeigt werden. Ferienwohnungen ohne
//  Bewertungen sollen am Ende ausgegeben werden.

    
SELECT f.NameFewo, AVG(b.AnzahlSterne) AS Durchschnitt, f.Preis 
    FROM Ferienwohnung f 
    JOIN Adresse ad ON f.AdressID = ad.AdressID 
    JOIN FeWoHatAus aus ON f.NameFewo = aus.NameFewo
    LEFT JOIN Buchung b ON f.NameFewo = b.NameFewo 
    WHERE ad.NameLand = 'Spanien'
    AND aus.NameAus = 'Sauna' 
    AND NOT EXISTS (
        SELECT b.NameFewo 
        FROM Buchung b 
        WHERE b.NameFewo = f.NameFewo 
        AND (b.Reservierungsstart >= TO_DATE('01.05.2024', 'DD.MM.YYYY')
        OR b.Reservierungsstart <= TO_DATE('01.05.2024', 'DD.MM.YYYY'))
        AND (b.Reservierungsende <= TO_DATE('21.05.2024', 'DD.MM.YYYY')
        OR b.Reservierungsende >= TO_DATE('21.05.2024', 'DD.MM.YYYY'))
        AND b.Reservierungsstart >= TO_DATE('01.05.2024', 'DD.MM.YYYY')
        AND b.Reservierungsende <= TO_DATE('21.05.2024', 'DD.MM.YYYY')
    ) 
    GROUP BY f.NameFewo, f.Preis 
    ORDER BY AVG(b.AnzahlSterne) DESC;
