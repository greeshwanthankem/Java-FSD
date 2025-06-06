import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class FileWriteExample {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter text to write to file: ");
        String input = sc.nextLine();

        try (FileWriter fw = new FileWriter("output.txt")) {
            fw.write(input);
            System.out.println("Successfully written to output.txt");
        } catch (IOException e) {
            System.out.println("An error occurred.");
        }
    }
}