package posttest;
import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.japi.pf.ReceiveBuilder;

import javax.script.Invocable;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;


public class TesterActor extends AbstractActor {
    private ActorRef repository;

    public TesterActor(ActorRef repository) {
        this.repository = repository;
    }
    public void sendToRepository(int packageId, String result) {
        repository.tell(new TestResult(packageId, result), ActorRef.noSender());
    }
    public void testRun(TestRequest request) {
        String result;
        try {
            result = eval(request).equals(request.getRightResult()) ? "Test passed" : "Test not passed";
        } catch (ScriptException exception) {
            result = "ScriptException: " + exception.getLocalizedMessage();
        } catch (NoSuchMethodException exception) {
            result = "NoSuchMethodException: " + exception.getLocalizedMessage();
        }
        sendToRepository(request.getPackageId(), result);
    }
    public String eval(TestRequest request) throws ScriptException, NoSuchMethodException {
        ScriptEngine engine = new ScriptEngineManager().getEngineByName("nashorn");
        engine.eval(request.getScript());
        Invocable invocable = (Invocable) engine;
        String[] args = request.getArguments()
                .toArray(new String[request.getArguments().size()]);

        return invocable.invokeFunction(request.getFunction(), args).toString();
    }
    @Override
    public Receive createReceive() {
        return ReceiveBuilder.create()
                .match(TestRequest.class, this::testRun)
                .build();
    }
}