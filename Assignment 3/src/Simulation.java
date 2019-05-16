import java.util.Random;

public class Simulation {
    private static final int ARRIVAL = 1;
    private static final int DEPARTURE = 2;
    private static final int MEASURE = 3;

    private double time;
    private EventList eventList;
    private Server[] servers;
    private Random rand;

    private int queue;
    private int noMeasurements;
    private int totalQueue;

    private Simulation() {
        time = 0;
        eventList = new EventList();
        servers = new Server[2];
        servers[0] = new Server(0);
        servers[1] = new Server(1);
        rand = new Random(0);
        noMeasurements = 0;
        queue = 0;
    }

    private void handle_event(Event event) {
        switch (event.getType()) {
            case ARRIVAL:
                handle_arrival();
                break;
            case DEPARTURE:
                handle_departure(event.getServer());
                break;
            case MEASURE:
                handle_measurement();
                break;
        }
    }

    private void handle_arrival() {
        queue++;

        for (Server server : servers) {
            if (server.available) {
                queue++;
                server.available = false;
                eventList.put(new Event(DEPARTURE, getNextDeparture(), server.index));
            }
        }

        eventList.put(new Event(ARRIVAL, getNextArrival()));
    }

    private void handle_departure(int index) {
        queue--;
        servers[index].available = true;
    }

    private void handle_measurement() {
        noMeasurements++;
        eventList.put(new Event(MEASURE, getNextMeasurement()));
    }

    private double getNextArrival() {
        double meanArrival = 1.2;
        return time - Math.log(1 - rand.nextDouble()) * meanArrival;
    }

    private double getNextDeparture() {
        return time + rand.nextDouble();
    }

    private double getNextMeasurement() {
        noMeasurements++;
        totalQueue += queue;
        return time + 5;
    }

    private void run() {
        System.out.println("Starting simulation");

        eventList.put(new Event(ARRIVAL, getNextArrival()));
        eventList.put(new Event(MEASURE, getNextMeasurement()));

        while (time < 1000) {
            Event event = eventList.pop();
            time = event.getTime();
            handle_event(event);
        }

        System.out.println("Simulation finished, results:");
        double averageQueue = Math.round(100.0 * totalQueue / noMeasurements) / 100.0;
        System.out.println("Average queue length: " + averageQueue);
    }

    private class Server {
        private int index;
        private boolean available;

        private Server(int index) {
            this.index = index;
            this.available = true;
        }
    }

    public static void main(String[] args) {
        Simulation sim = new Simulation();
        sim.run();
    }
}
