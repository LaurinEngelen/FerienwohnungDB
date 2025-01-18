//Buchungen sollen nicht gelöscht werden, sondern nur „storniert“. Erweitern Sie ihr Datenbankschema 
//um eine Tabelle für diese „stornierte Buchungen“. Nutzen Sie das Triggerkonzept, um sicherzustellen, 
//dass beim Löschen einer Buchung ein passender Eintrag in der Tabelle für „stornierte Buchungen“ 
//vorgenommen wird. Für stornierte Buchungen soll zusätzlich das Stornierungsdatum automatisch 
//hinzugefügt werden

DROP TABLE StornierteBuchungen;
DROP TRIGGER Stornierung;

CREATE TABLE StornierteBuchungen(
    BuchungsNR INT,
    KundenID INT,
    NameFeWo VARCHAR(50),
    Reservierungsstart DATE,
    Reservierungsende DATE,
    BewertungsDatum DATE,
    AnzahlSterne INT,
    Rechnungsnr INT,
    Rechnungsdatum DATE,
    Gesamtbetrag FLOAT,
    Stornierungsdatum DATE,
    CONSTRAINT StornierteBuchungen_pk PRIMARY KEY (BuchungsNR),
    CONSTRAINT StornierteBuchungen_fk2 FOREIGN KEY (KundenID) REFERENCES Kunde(KundenID) ON DELETE CASCADE
    );

CREATE TRIGGER Stornierung
BEFORE DELETE ON Buchung 
FOR EACH ROW
BEGIN
    INSERT INTO StornierteBuchungen(BuchungsNR, KundenID, NameFeWo, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag, Stornierungsdatum)
    VALUES(:OLD.BuchungsNR, :OLD.KundenID, :OLD.NameFeWo, :OLD.Reservierungsstart, :OLD.Reservierungsende, :OLD.BewertungsDatum, :OLD.AnzahlSterne, :OLD.Rechnungsnr, :OLD.Rechnungsdatum, :OLD.Gesamtbetrag, SYSDATE);
END;
/


INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) 
    VALUES (1, 'Ferienwohnung8', NULL, TO_DATE('2023-12-12', 'YYYY-MM-DD'), TO_DATE('2023-12-24', 'YYYY-MM-DD'), TO_DATE('2023-12-30', 'YYYY-MM-DD'), 3, 18, TO_DATE('2023-12-24', 'YYYY-MM-DD'), 790.0);

COMMIT;

DELETE FROM Buchung WHERE BuchungsNR = 18;




//Damit ein Mitarbeiter der Agentur schnell erkennen kann, ob ein Kunde ein geschätzter Stammkunde 
//ist, sollen Informationen wie die Anzahl bisher getätigter Buchungen und die Summe aller bisher 
//gezahlter Rechnungsbeträge zusammengefasst werden. Da diese Informationen sehr verteilt in der 
//Datenbank gespeichert sind, soll ein View erstellt werden, der diese Informationen zusammenfasst. 
//Definieren Sie einen View Kundenstatistik, der folgende Attribute besitzt: Kundennummer, Anzahl 
//Buchungen, Anzahl Stornierungen, Summe aller Zahlungen. Falls ein Kunde noch keine Buchungen 
//bzw. keine Stornierungen durchgeführt hat, soll die Zahl 0 erscheinen (nicht NULL).

CREATE VIEW Kundenstatistik AS 
    SELECT k.KundenID, COALESCE(AnzahlBuchungen, 0) AS AnzahlBuchungen, COALESCE(AnzahlStornierungen, 0) AS AnzahlStornierungen, COALESCE(SummeZahlungen, 0) AS SummeZahlungen
    FROM Kunde k
    LEFT JOIN (
        SELECT KundenID, COUNT(*) AS AnzahlBuchungen, SUM(Gesamtbetrag) AS SummeZahlungen
        FROM Buchung
        GROUP BY KundenID
    ) b ON k.KundenID = b.KundenID
    LEFT JOIN (
        SELECT KundenID, COUNT(*) AS AnzahlStornierungen
        FROM StornierteBuchungen
        Group BY KundenID
    ) s ON k.KundenID = s.KundenID;

SELECT * FROM Kundenstatistik;



//Geben Sie für einen Kunden Empfehlungen aus. Wenn ein Kunde K1 eine Wohnung W1 mit 5 Sterne 
//bewertet hat und ein Kunde K2 die Wohnung W1 ebenfalls mit 5 Sterne bewertet hat, dann sollen alle 
//weiteren Wohnungen, die K2 mit 5 Sternen bewertet hat als Empfehlung für K1 ausgegeben werden

INSERT INTO Buchung (KundenID, NameFeWo, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag)
VALUES (1, 'Ferienwohnung3', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-01-07', 'YYYY-MM-DD'), TO_DATE('2023-01-08', 'YYYY-MM-DD'), 5, 25, TO_DATE('2023-01-08', 'YYYY-MM-DD'), 500.0);

INSERT INTO Buchung (KundenID, NameFeWo, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag)
VALUES (2, 'Ferienwohnung3', TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2023-02-07', 'YYYY-MM-DD'), TO_DATE('2023-02-08', 'YYYY-MM-DD'), 5, 26, TO_DATE('2023-02-08', 'YYYY-MM-DD'), 600.0);

INSERT INTO Buchung (KundenID, NameFeWo, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag)
VALUES (2, 'Ferienwohnung5', TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-03-07', 'YYYY-MM-DD'), TO_DATE('2023-03-08', 'YYYY-MM-DD'), 5, 27, TO_DATE('2023-03-08', 'YYYY-MM-DD'), 700.0);



CREATE OR REPLACE VIEW Empfehlungen (EmpfehlenderKunde, EmpfohleneFewo) AS
    SELECT DISTINCT
        k2.KundenID AS EmpfehlenderKunde, --optional
        b3.NameFeWo AS EmpfohleneFewo 
    FROM Kunde k1
    JOIN Buchung b1 ON k1.KundenID = b1.KundenID
    JOIN Buchung b2 ON b1.NameFeWo = b2.NameFeWo
    JOIN Kunde k2 ON b2.KundenID = k2.KundenID
    JOIN Buchung b3 ON k2.KundenID = b3.KundenID
    WHERE b1.AnzahlSterne = 5 
    AND b2.AnzahlSterne = 5
    AND b3.AnzahlSterne = 5
    AND k1.KundenID <> k2.KundenID
    AND b3.NameFeWo <> b1.NameFeWo;


SELECT * FROM Empfehlungen;


//Angenommen, der Befehl aus Aufgabe 5h ist zu langsam. Definieren Sie einen Index, die die Suche 
//beschleunigt.
// ->
// Welche Ferienwohnungen mit Sauna sind in Spanien in der Zeit vom 01.05.2024 – 21.05.2024 noch
//  frei? Geben Sie den Ferienwohnungs-Namen und deren durchschnittliche Bewertung an.
//  Ferienwohnungen mit guten Bewertungen sollen zuerst angezeigt werden. Ferienwohnungen ohne
//  Bewertungen sollen am Ende ausgegeben werden.


CREATE INDEX idx_suche_FeWo ON Ferienwohnung(AdressID, NameFeWo);
CREATE INDEX idx_Buchung ON Buchung(NameFeWo, Reservierungsstart, Reservierungsende);
CREATE INDEX idx_AnzahlSterne ON Buchung(NameFeWo, AnzahlSterne DESC);


COMMIT;

