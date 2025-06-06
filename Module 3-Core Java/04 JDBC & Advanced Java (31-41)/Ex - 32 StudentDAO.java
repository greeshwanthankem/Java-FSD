import java.sql.*;

public class StudentDAO {
    public static void main(String[] args) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:sqlite:students.db");

        // Insert
        PreparedStatement insert = conn.prepareStatement("INSERT INTO students (id, name) VALUES (?, ?)");
        insert.setInt(1, 101);
        insert.setString(2, "John Doe");
        insert.executeUpdate();

        // Update
        PreparedStatement update = conn.prepareStatement("UPDATE students SET name=? WHERE id=?");
        update.setString(1, "Jane Doe");
        update.setInt(2, 101);
        update.executeUpdate();

        conn.close();
    }
}