package flightstatistic;
import org.apache.hadoop.io.Writable;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

enum EntityType{
    AIRPORT,
    FLIGHT
}

public class DataWritable implements Writable {
    private static final String AIRPORT_DELIMITER = ",\"";
    private static final String FLIGHT_DELIMITER = ",";
    public EntityType type;
    public int id;
    public float delay = 0;
    public String description = "";
    public boolean cancelled = false;
    public DataWritable(){

    }
    public DataWritable(String value, EntityType type) {
        this.type = type;
        if (type == EntityType.AIRPORT){
            String[] data = value.split(AIRPORT_DELIMITER);
            this.id = Integer.parseInt(data[Constants.CODE].replaceAll("\"", ""));
            this.description = data[Constants.DESCRIPTION].replaceAll("\"", "");
        } else if (type == EntityType.FLIGHT) {
            String[] data = value.split(FLIGHT_DELIMITER);
            this.id = Integer.parseInt(data[Constants.AIRPORT_ID].replaceAll("\"", ""));
            this.delay = data[Constants.ARR_DELAY].length() > 0 ? Float.parseFloat(data[Constants.ARR_DELAY]) : 0;
            this.cancelled = Float.parseFloat(data[Constants.IS_CANCELED]) == 1;
        }

    }

    public EntityType getType() {
        return type;
    }

    public int getId() {
        return id;
    }

    public boolean isCancelled() {
        return cancelled;
    }

    public float getDelay() {
        return delay;
    }

    public String getDescription() {
        return description;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(type.ordinal());
        out.writeInt(id);
        out.writeFloat(delay);
        out.writeUTF(description);
        out.writeBoolean(cancelled);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        this.type = EntityType.values()[in.readInt()];
        this.id = in.readInt();
        this.delay = in.readFloat();
        this.description = in.readUTF();
        this.cancelled = in.readBoolean();
    }
}
