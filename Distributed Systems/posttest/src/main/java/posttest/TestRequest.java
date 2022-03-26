package posttest;

import java.util.ArrayList;
import java.util.List;

public class TestRequest {
    private String function;
    private String script;
    private List<String> arguments;
    private String rightResult;
    private int packageId;

    public TestRequest(String function, String script, List<String> arguments, String rightResult, int packageId) {
        this.function = function;
        this.script = script;
        this.arguments = arguments;
        this.rightResult = rightResult;
        this.packageId = packageId;
    }

    public String getFunction() {
        return function;
    }

    public String getScript() {
        return script;
    }

    public List<String> getArguments() {
        return arguments;
    }

    public String getRightResult() {
        return rightResult;
    }

    public int getPackageId() {
        return packageId;
    }
}
