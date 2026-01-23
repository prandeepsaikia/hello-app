package org.hawk;

import static java.lang.IO.println;

public class HelloApp {

    public void startHelloLoop() {
        try {
            while (!Thread.interrupted()) {
                println("Hello World % %");
                Thread.sleep(2000);
            }
        } catch (InterruptedException _) {

        }
    }


    void main() {
        startHelloLoop();
    }
}