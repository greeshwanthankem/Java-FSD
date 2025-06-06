import java.util.concurrent.*;

public class CallableExample {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newFixedThreadPool(2);
        Callable<String> task = () -> "Task Result";

        Future<String> result = service.submit(task);
        System.out.println("Callable returned: " + result.get());

        service.shutdown();
    }
}