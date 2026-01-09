package org.hawk;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HelloAppTest {
    @Test
    void testLoop() throws InterruptedException {
        HelloApp app = new HelloApp();

        Thread vThread = Thread.ofVirtual().start(app::startHelloLoop);

        Thread.sleep(100);
        assertTrue(vThread.isAlive());

        vThread.interrupt();
        vThread.join(1000);
        assertFalse(vThread.isAlive());
    }
}