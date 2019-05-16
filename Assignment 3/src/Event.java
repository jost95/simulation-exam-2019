class Event {
    private int type;
    private int server;
    private double time;

    Event(int type, double time) {
        this(type, time, -1);
    }

    Event(int type, double time, int server) {
        this.type = type;
        this.time = time;
        this.server = server;
    }

    int getType() {
        return type;
    }

    double getTime() {
        return time;
    }

    int getServer() {
        return server;
    }
}
