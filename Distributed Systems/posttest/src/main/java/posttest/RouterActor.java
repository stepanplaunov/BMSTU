package posttest;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.japi.pf.ReceiveBuilder;
import akka.actor.*;
import akka.routing.RoundRobinPool;

public class RouterActor extends AbstractActor {
    private static final int POOL_WIDTH = 5;
    private final ActorRef repository;
    private final ActorRef tester;

    public RouterActor() {
        repository = getContext().actorOf(Props.create(RepositoryActor.class));
        tester = getContext().actorOf(new RoundRobinPool(POOL_WIDTH).props(Props.create(TesterActor.class, repository)));


    }
    @Override
    public AbstractActor.Receive createReceive() {
        return ReceiveBuilder.create()
                .match(Package.class, this::runPackage)
                .match(PackageResultsRequest.class, this::getPackageResults)
                .build();
    }

    private void runPackage(Package pack) {
        pack.getTests()
                .stream()
                .map(test -> generateTestRequest(pack, test))
                .forEach(request -> tester.tell(request, repository));
    }
    private TestRequest generateTestRequest(Package pack, Test test) {
        return new TestRequest(pack.getFunctionName(),
                pack.getJsScript(),
                test.getParams(),
                test.getExpectedResult(),
                Integer.parseInt(pack.getPackageId()));
    }
    private void getPackageResults(PackageResultsRequest request) {
        repository.tell(request, getSender());
    }
}
