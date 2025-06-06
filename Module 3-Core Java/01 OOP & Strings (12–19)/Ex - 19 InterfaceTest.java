interface Playable {
    void play();
}

class Guitar implements Playable {
    public void play() {
        System.out.println("Strumming Guitar...");
    }
}

class Piano implements Playable {
    public void play() {
        System.out.println("Playing Piano...");
    }
}

public class InterfaceTest {
    public static void main(String[] args) {
        Playable p1 = new Guitar();
        Playable p2 = new Piano();
        p1.play();
        p2.play();
    }
}