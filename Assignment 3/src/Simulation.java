import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class Simulation {
    private static final int ARRIVAL = 1;
    private static final int DEPARTURE = 2;
    private static final int MEASURE = 3;
    private static final int SIM_LENGTH = 10000;

    private double time;
    private EventList eventList;
    private Server[] servers;
    private Random rand;

    private int queue;
    private boolean antithetic;
    private List<Integer> queueHistory;

    Simulation() {
        reset();
    }

    void reset() {
        time = 0;
        eventList = new EventList();
        servers = new Server[2];
        servers[0] = new Server(0);
        servers[1] = new Server(1);
        rand = new Random();
        queue = 0;
        queueHistory = new ArrayList<>();
        antithetic = false;
    }

    void seedOn() {
        rand = new Random(0);
    }

    void antheticOn() {
        antithetic = true;
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
        queueHistory.add(queue);
        eventList.put(new Event(MEASURE, getNextMeasurement()));
    }

    private double getNextArrival() {
        double meanArrival = 1.2;
        return time - Math.log(1 - getRand()) * meanArrival;
    }

    private double getNextDeparture() {
        return time + getRand() * 2;
    }

    private double getNextMeasurement() {
        return time + 5;
    }

    private double getRand() {
        return antithetic ? 1 - rand.nextDouble() : rand.nextDouble();
    }

    List<Integer> getQueueHistory() {
        return queueHistory;
    }

    void run() {
        System.out.println("Starting simulation");

        eventList.put(new Event(ARRIVAL, getNextArrival()));
        eventList.put(new Event(MEASURE, time + 100));

        while (time < SIM_LENGTH) {
            Event event = eventList.pop();
            time = event.getTime();
            handle_event(event);
        }

        System.out.println("Simulation finished");
    }

    private class Server {
        private int index;
        private boolean available;

        private Server(int index) {
            this.index = index;
            this.available = true;
        }
    }
}
