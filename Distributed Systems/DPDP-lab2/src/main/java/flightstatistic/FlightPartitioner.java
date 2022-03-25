package flightstatistic;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.io.Text;

public class FlightPartitioner extends Partitioner<AirportWritableComparable, DataWritable> {
    @Override
    public int getPartition(AirportWritableComparable key, DataWritable value, int numPartitions) {
        return key.getId() % numPartitions;
    }
}