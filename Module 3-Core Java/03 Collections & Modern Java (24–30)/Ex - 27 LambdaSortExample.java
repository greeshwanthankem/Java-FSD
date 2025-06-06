import java.util.*;

public class LambdaSortExample {
    public static void main(String[] args) {
        List<String> items = Arrays.asList("Banana", "Apple", "Orange", "Grapes");
        Collections.sort(items, (a, b) -> a.compareToIgnoreCase(b));
        System.out.println("Sorted List: " + items);
    }
}