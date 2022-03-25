package flightstatistic;

import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;

public class FlightComparator extends WritableComparator {
    public FlightComparator() {
        super (AirportWritableComparable.class, true);
    }
    @Override
    public int compare(WritableComparable a, WritableComparable b) {
        return ((AirportWritableComparable) a).getId() - ((AirportWritableComparable) b).getId();
    }

}
