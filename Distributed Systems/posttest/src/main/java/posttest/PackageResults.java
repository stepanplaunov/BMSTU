package posttest;
import java.util.ArrayList;

public class PackageResults {
    private ArrayList<String> results;
    private int packageId;

    public ArrayList<String> getResults() {
        return results;
    }

    public int getPackageId() {
        return packageId;
    }

    public PackageResults(int packageId, ArrayList<String> results) {
        this.results = results;
        this.packageId = packageId;
    }

}
