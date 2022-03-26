package sparkflight;

import java.io.Serializable;

public class StatContainer implements Serializable {
    private float max;
    private int cancelled;
    private int delayed;
    private int counter;
    private static final String PATTERN = "MaxDelay: %f, CancelledPercent: %f, DelayedPercent: %f";


    public float getMax() {
        return max;
    }

    public int getCancelled() {
        return cancelled;
    }

    public int getDelayed() {
        return delayed;
    }

    public int getCounter() {
        return counter;
    }

    public StatContainer(float max, int cancelled, int delayed, int counter) {
        this.max = max;
        this.cancelled = cancelled;
        this.delayed = delayed;
        this.counter = counter;
    }
    public static StatContainer addValue(StatContainer a, float max, boolean cancelled, float delayed) {
        return new StatContainer(Float.max(a.getMax(), max),
                a.getCancelled() +  (cancelled ? 1 : 0),
                a.getDelayed() + (delayed > 0 ? 1 : 0),
                a.getCounter() + 1);
    }
    public static StatContainer add(StatContainer a, StatContainer b) {
        return new StatContainer(Float.max(a.getMax(), b.getMax()),
                a.getCancelled() + b.getCancelled(),
                a.getDelayed() + b.getDelayed(),
                a.getCounter() + b.getCounter());
    }
    public String compareStat() {
        return String.format(PATTERN, max, ((float) cancelled) / counter * 100, ((float) delayed) / counter * 100);
    }
}
