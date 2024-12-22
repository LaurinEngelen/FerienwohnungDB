import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;

public class SuchMenu extends JFrame implements ActionListener {

    JComboBox<String> reiselandDropdown;
    JComboBox<String> ausstattungDropdown;
    JSpinner anreiseDatumSpinner;
    JSpinner abreiseDatumSpinner;
    JTable ergebnisTabelle;

    public void itemStateChange(ItemEvent e){

    }

    public SuchMenu(){
        this.setTitle("Ferienwohnung Suchen");
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setPreferredSize(new Dimension(1000,600));
        this.setBackground(Color.lightGray);

        // Panel Eingabefeld
        JPanel suchfeld = new JPanel();
        suchfeld.setLayout(new BoxLayout(suchfeld, BoxLayout.X_AXIS));
        suchfeld.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JLabel landLabel = new JLabel("Reiseland");
        JLabel anreiseDatumLabel = new JLabel("AnreiseDatum");
        JLabel abreiseDatumLabel = new JLabel("AbreiseDatum");
        JLabel ausstattungLabel = new JLabel("Ausstattung");

        // Load data from database
        String[] reiselandOptions = loadDataFromDatabase("SELECT NameLand FROM Land");
        String[] ausstattungOptions = loadDataFromDatabase("SELECT NameAus FROM Ausstattung");
        ausstattungOptions = addEmptyOption(ausstattungOptions);

        reiselandDropdown = new JComboBox<>(reiselandOptions);
        ausstattungDropdown = new JComboBox<>(ausstattungOptions);

        Dimension dropdownSize = new Dimension(150, 25);
        reiselandDropdown.setPreferredSize(dropdownSize);
        reiselandDropdown.setMaximumSize(dropdownSize);
        ausstattungDropdown.setPreferredSize(dropdownSize);
        ausstattungDropdown.setMaximumSize(dropdownSize);

        SpinnerDateModel dateModelAnreise = new SpinnerDateModel();
        anreiseDatumSpinner = new JSpinner(dateModelAnreise);
        JSpinner.DateEditor dateAnreiseEditoran = new JSpinner.DateEditor(anreiseDatumSpinner, "dd/MM/yyyy");
        anreiseDatumSpinner.setEditor(dateAnreiseEditoran);
        SpinnerDateModel dateModelAbreise = new SpinnerDateModel();
        abreiseDatumSpinner = new JSpinner(dateModelAbreise);
        JSpinner.DateEditor dateAbreiseEditor = new JSpinner.DateEditor(abreiseDatumSpinner, "dd/MM/yyyy");
        abreiseDatumSpinner.setEditor(dateAbreiseEditor);

        JButton searchButton = new JButton("Suchen");
        searchButton.addActionListener(e -> searchFerienwohnungen());

        suchfeld.add(landLabel);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(reiselandDropdown);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(anreiseDatumLabel);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(anreiseDatumSpinner);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(abreiseDatumLabel);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(abreiseDatumSpinner);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(ausstattungLabel);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(ausstattungDropdown);
        suchfeld.add(Box.createRigidArea(new Dimension(10, 0))); // Abstand
        suchfeld.add(searchButton);

        // Tabelle für die Ergebnisse
        String[] spaltenNamen = {"Ferienwohnung", "Anzahl Durchschnittliche Bewertung", "Preis pro Nacht"};
        Object[][] TabellenDaten = {{"Ferienwohnung1", "4.5", "100"}, {"Ferienwohnung2", "4.0", "80"}};

        ergebnisTabelle = new JTable(TabellenDaten, spaltenNamen);
        ergebnisTabelle.setSelectionMode(ListSelectionModel.SINGLE_SELECTION); // Zeilenauswahl aktivieren

        JScrollPane scrollPane = new JScrollPane(ergebnisTabelle);

        JButton buchenButton = new JButton("Buchen");
        buchenButton.addActionListener(e -> {
            int selectedRow = ergebnisTabelle.getSelectedRow();
            if (selectedRow != -1) {
                String selectedFerienwohnung = (String) ergebnisTabelle.getValueAt(selectedRow, 0);
                String selectedPreisProNacht = (String) ergebnisTabelle.getValueAt(selectedRow, 2);
                String selectedKundenID = JOptionPane.showInputDialog(this, "Bitte geben Sie Ihre KundenID ein:", "KundenID eingeben", JOptionPane.QUESTION_MESSAGE);
                if (selectedKundenID != null) {
                    ferienwohnungBuchen(selectedFerienwohnung, selectedKundenID, Double.parseDouble(selectedPreisProNacht));
                }
            } else {
                JOptionPane.showMessageDialog(this, "Bitte wählen Sie eine Ferienwohnung aus.", "Keine Ferienwohnung ausgewählt", JOptionPane.ERROR_MESSAGE);
            }
        });

        // Hauptpanel mit BorderLayout
        JPanel hauptPanel = new JPanel(new BorderLayout());
        hauptPanel.add(suchfeld, BorderLayout.NORTH);
        hauptPanel.add(scrollPane, BorderLayout.CENTER);
        hauptPanel.add(buchenButton, BorderLayout.SOUTH);

        setContentPane(hauptPanel);

        // Fenster zentrieren und anzeigen
        this.pack();
        this.setLocationRelativeTo(null);
        this.setVisible(true);
    }

    private String[] loadDataFromDatabase(String query) {
        ArrayList<String> data = new ArrayList<>();
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASSWORD");

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            while (rs.next()) {
                data.add(rs.getString(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return data.toArray(new String[0]);
    }

    private String[] addEmptyOption(String[] options) {
        String[] newOptions = new String[options.length + 1];
        newOptions[0] = "";
        System.arraycopy(options, 0, newOptions, 1, options.length);
        return newOptions;
    }

    private boolean validateDate() {
        Date selectedDateAnreise = (Date) anreiseDatumSpinner.getValue();
        Date selectedDateAbreise = (Date) abreiseDatumSpinner.getValue();
        Date currentDate = new Date();

        if (selectedDateAnreise.before(currentDate)) {
            JOptionPane.showMessageDialog(this, "Das angegebene Anreisedatum darf nicht in der Vergangenheit liegen.", "Unzulässiges Datum", JOptionPane.ERROR_MESSAGE);
            return false;
        } else if (selectedDateAbreise.before(selectedDateAnreise)) {
            JOptionPane.showMessageDialog(this, "Das angegebene Abreisedatum darf nicht vor dem Anreisedatum liegen.", "Unzulässiges Datum", JOptionPane.ERROR_MESSAGE);
            return false;
        }
        return true;
    }

    private void searchFerienwohnungen() {
        //TODO query Befehl fixen
        if (validateDate()) {
            String selectedLand = (String) reiselandDropdown.getSelectedItem();
            String selectedAusstattung = (String) ausstattungDropdown.getSelectedItem();
            Date anreiseDatum = (Date) anreiseDatumSpinner.getValue();
            Date abreiseDatum = (Date) abreiseDatumSpinner.getValue();

            String anreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(anreiseDatum);
            String abreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(abreiseDatum);

            String query = "SELECT f.NameFewo, AVG(b.AnzahlSterne) AS Durchschnitt, f.Preis " +
                    "FROM Ferienwohnung f " +
                    "JOIN FeWoHatAus aus ON f.NameFewo = aus.NameFewo " +
                    "JOIN Adresse ad ON f.AdressID = ad.AdressID " +
                    "WHERE ad.NameLand = '" + selectedLand + "' " +
                    (selectedAusstattung.isEmpty() ? "" : "AND aus.NameAus = '" + selectedAusstattung + "' ") +
                    "AND f.NameFewo NOT EXISTS (" +
                    "    SELECT b.NameFewo " +
                    "    FROM Buchung b " +
                    "    WHERE b.NameFewo = f.NameFewo" +
                    "    AND b.Reservierungsstart <= TO_DATE('" + abreiseDatumStr + "', 'DD.MM.YYYY') " +
                    "    AND b.Reservierungsende >= TO_DATE('" + anreiseDatumStr + "', 'DD.MM.YYYY')" +
                    ") " +
                    "GROUP BY f.NameFewo, f.Preis " +
                    "ORDER BY AVG(b.AnzahlSterne);";

            loadDataFromDatabase(query);
        }
    }

    private void ferienwohnungBuchen(String nameFeWo, String kundenID, Double preisProNacht){
        //TODO query Befehl fixen
        String selectedNameFeWo = nameFeWo;
        String selectedKundenID = kundenID;
        Double selectedPreisProNacht = preisProNacht ;
        Date anreiseDatum = (Date) anreiseDatumSpinner.getValue();
        Date abreiseDatum = (Date) abreiseDatumSpinner.getValue();

        String anreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(anreiseDatum);
        String abreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(abreiseDatum);

        Double gesamtbetrag = selectedPreisProNacht * (abreiseDatum.getTime() - anreiseDatum.getTime()) / (1000 * 60 * 60 * 24);

        String query = "INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsdatum, Gesamtbetrag) VALUES ( " + selectedKundenID + ", '" + selectedNameFeWo + "', NULL, TO_DATE('" + anreiseDatumStr + "', 'DD.MM.YYYY'), TO_DATE('" + abreiseDatumStr + "', 'DD.MM.YYYY'), NULL, NULL, NULL, " + gesamtbetrag + ");";

        loadDataFromDatabase(query);
    }

    @Override
    public void actionPerformed(ActionEvent e) {}

    public static void main(String[] args) {
        new SuchMenu();
    }
}