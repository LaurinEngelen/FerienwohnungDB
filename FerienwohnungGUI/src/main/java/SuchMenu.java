import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import io.github.cdimascio.dotenv.Dotenv;


public class SuchMenu extends JFrame implements ActionListener {

    JComboBox<String> reiselandDropdown;
    JComboBox<String> ausstattungDropdown;
    JSpinner anreiseDatumSpinner;
    JSpinner abreiseDatumSpinner;
    JTable ergebnisTabelle;
    DefaultTableModel tableModel;

    public void itemStateChange(ItemEvent e){

    }

    public class DatabaseConfig {
        private static final Dotenv dotenv =
                Dotenv.configure()
                        .directory("src/main/resources/")
                        .filename(".env")
                        .load();

        public static String getDbUrl() {
            return dotenv.get("DB_URL");
        }

        public static String getDbUser() {
            return dotenv.get("DB_USER");
        }

        public static String getDbPassword() {
            return dotenv.get("DB_PASSWORD");
        }
    }

    private static final Dotenv dotenv = Dotenv.configure()
            .directory("src/main/resources/")
            .filename(".env")
            .load();



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
        searchButton.addActionListener(e -> updateTableData());

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
        tableModel = new DefaultTableModel(spaltenNamen, 0);
        ergebnisTabelle = new JTable(tableModel);
        ergebnisTabelle.setSelectionMode(ListSelectionModel.SINGLE_SELECTION); // Zeilenauswahl aktivieren

        JScrollPane scrollPane = new JScrollPane(ergebnisTabelle);

        JButton buchenButton = new JButton("Buchen");
        buchenButton.addActionListener(e -> {
            int selectedRow = ergebnisTabelle.getSelectedRow();
            if (selectedRow != -1) {
                String selectedFerienwohnung = (String) ergebnisTabelle.getValueAt(selectedRow, 0);
                Double selectedPreisProNacht = (Double) ergebnisTabelle.getValueAt(selectedRow, 2); // Corrected to Double
                String selectedKundenID = JOptionPane.showInputDialog(this, "Bitte geben Sie Ihre KundenID ein:", "KundenID eingeben", JOptionPane.QUESTION_MESSAGE);
                if (selectedKundenID != null) {
                    ferienwohnungBuchen(selectedFerienwohnung, selectedKundenID, selectedPreisProNacht);
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

    private static Connection getConnection() throws SQLException {
        String dbUrl = dotenv.get("DB_URL");
        String dbUser = dotenv.get("DB_USER");
        String dbPassword = dotenv.get("DB_PASSWORD");
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }


    private String[] loadDataFromDatabase(String query) {
        List<String> data = new ArrayList<>();
        try (Connection conn = getConnection();
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


    public void insertDataIntoDatabase(String query) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(query);
            stmt.execute("COMMIT");
            System.out.printf("Successfully executed query: %s\n", query);
        } catch (SQLException e) {
            e.printStackTrace();
        }

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

    private List<Object[]> searchFerienwohnungen() {
        List<Object[]> data = new ArrayList<>();
        if (validateDate()) {
            String selectedLand = (String) reiselandDropdown.getSelectedItem();
            String selectedAusstattung = (String) ausstattungDropdown.getSelectedItem();
            Date anreiseDatum = (Date) anreiseDatumSpinner.getValue();
            Date abreiseDatum = (Date) abreiseDatumSpinner.getValue();

            String anreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(anreiseDatum);
            String abreiseDatumStr = new java.text.SimpleDateFormat("dd.MM.yyyy").format(abreiseDatum);
            String query = "";

            if (selectedAusstattung != "") {
                query = String.format("""        
                        SELECT f.NameFewo, AVG(b.AnzahlSterne) AS Durchschnitt, f.Preis 
                                FROM Ferienwohnung f 
                                JOIN Adresse ad ON f.AdressID = ad.AdressID 
                                JOIN FeWoHatAus aus ON f.NameFewo = aus.NameFewo
                                LEFT JOIN Buchung b ON f.NameFewo = b.NameFewo 
                                WHERE ad.NameLand = '%s'
                                AND aus.NameAus = '%s' 
                                AND NOT EXISTS (
                                    SELECT b.NameFewo 
                                    FROM Buchung b 
                                    WHERE b.NameFewo = f.NameFewo 
                                    AND (b.Reservierungsstart >= TO_DATE('%s', 'DD.MM.YYYY')
                                    OR b.Reservierungsstart <= TO_DATE('%s', 'DD.MM.YYYY'))
                                    AND (b.Reservierungsende <= TO_DATE('%s', 'DD.MM.YYYY')
                                    OR b.Reservierungsende >= TO_DATE('%s', 'DD.MM.YYYY'))
                                    AND b.Reservierungsstart >= TO_DATE('%s', 'DD.MM.YYYY')
                                    AND b.Reservierungsende <= TO_DATE('%s', 'DD.MM.YYYY')
                                ) 
                                GROUP BY f.NameFewo, f.Preis 
                                ORDER BY AVG(b.AnzahlSterne) DESC
                        """, selectedLand, selectedAusstattung, anreiseDatumStr, anreiseDatumStr , abreiseDatumStr, abreiseDatumStr, anreiseDatumStr, abreiseDatumStr
                );
            } else {
                query = String.format("""        
                        SELECT f.NameFewo, AVG(b.AnzahlSterne) AS Durchschnitt, f.Preis 
                                FROM Ferienwohnung f 
                                JOIN Adresse ad ON f.AdressID = ad.AdressID 
                                LEFT JOIN Buchung b ON f.NameFewo = b.NameFewo 
                                WHERE ad.NameLand = '%s' 
                                AND NOT EXISTS (
                                    SELECT b.NameFewo 
                                    FROM Buchung b 
                                    WHERE b.NameFewo = f.NameFewo 
                                    AND (b.Reservierungsstart >= TO_DATE('%s', 'DD.MM.YYYY')
                                    OR b.Reservierungsstart <= TO_DATE('%s', 'DD.MM.YYYY'))
                                    AND (b.Reservierungsende <= TO_DATE('%s', 'DD.MM.YYYY')
                                    OR b.Reservierungsende >= TO_DATE('%s', 'DD.MM.YYYY'))
                                    AND b.Reservierungsstart >= TO_DATE('%s', 'DD.MM.YYYY')
                                    AND b.Reservierungsende <= TO_DATE('%s', 'DD.MM.YYYY')
                                ) 
                                GROUP BY f.NameFewo, f.Preis 
                                ORDER BY AVG(b.AnzahlSterne) DESC
                        """, selectedLand, anreiseDatumStr, anreiseDatumStr , abreiseDatumStr, abreiseDatumStr, anreiseDatumStr, abreiseDatumStr
                );
            }
            try (Connection conn = getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(query)) {
                while (rs.next()) {
                    String nameFewo = rs.getString("NameFewo");
                    double durchschnitt = rs.getDouble("Durchschnitt");
                    double preis = rs.getDouble("Preis");
                    data.add(new Object[]{nameFewo, durchschnitt, preis});
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return data;
    }

    private void updateTableData() {
        List<Object[]> data = searchFerienwohnungen();
        tableModel.setRowCount(0); // Clear existing data
        for (Object[] row : data) {
            tableModel.addRow(row);
        }
    }

    private int getMaxRechnungsnr() {
        String query = "SELECT MAX(RechnungsNr) FROM Buchung";
        String[] data = loadDataFromDatabase(query);
        return Integer.parseInt(data[0]);
    }

    private void ferienwohnungBuchen(String nameFeWo, String kundenID, Double preisProNacht){
        String selectedNameFeWo = nameFeWo;
        String selectedKundenID = kundenID;
        Double selectedPreisProNacht = preisProNacht;
        Date anreiseDatum = (Date) anreiseDatumSpinner.getValue();
        Date abreiseDatum = (Date) abreiseDatumSpinner.getValue();
        int rechnungsNr = getMaxRechnungsnr() + 1;

        String anreiseDatumStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(anreiseDatum);
        String abreiseDatumStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(abreiseDatum);

        Float gesamtbetrag = (float) (selectedPreisProNacht * (abreiseDatum.getTime() - anreiseDatum.getTime()) / (1000 * 60 * 60 * 24));

        String query = String.format(
                Locale.US,
                "INSERT INTO Buchung(KundenID, NameFeWo, Stornierungsdatum, Reservierungsstart, Reservierungsende, BewertungsDatum, AnzahlSterne, Rechnungsnr, Rechnungsdatum, Gesamtbetrag) " +
                        "VALUES (%s, '%s', NULL, TO_DATE('%s', 'YYYY-MM-DD'), TO_DATE('%s', 'YYYY-MM-DD'), NULL, NULL, %d, NULL, %.1f)",
                selectedKundenID, selectedNameFeWo, anreiseDatumStr, abreiseDatumStr, rechnungsNr, gesamtbetrag
        );

        insertDataIntoDatabase(query);
        updateTableData();
    }

    @Override
    public void actionPerformed(ActionEvent e) {}

    public static void main(String[] args) {
        new SuchMenu();
    }
}