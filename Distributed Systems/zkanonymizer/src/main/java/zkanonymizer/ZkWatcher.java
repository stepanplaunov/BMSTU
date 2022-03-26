package zkanonymizer;

import akka.actor.ActorRef;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.*;
import org.apache.zookeeper.ZooKeeper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class ZkWatcher implements Watcher {
    private final ActorRef config;
    private ZooKeeper zk;
    private static final String SERVER_PATH = "/servers";

    public ZkWatcher(ActorRef config, ZooKeeper zk) {
        this.config = config;
        this.zk = zk;
    }

    public ZkWatcher(ActorRef config) {
        this.config = config;
    }

    public void setZk(ZooKeeper zk) {
        this.zk = zk;
    }

    @Override
    public void process(WatchedEvent event) {
        if (event == null) {
            return;
        }
        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();
        String path = event.getPath();
        if (KeeperState.SyncConnected == keeperState) {
                try {

                    List<String> list = zk.getChildren(SERVER_PATH, this);
                    ArrayList<String> serverData = new ArrayList<>();
                    for (String name : list) {
                        serverData.add(new String(zk.getData(SERVER_PATH + '/' + name, this, null)));
                    }
                    config.tell(new ServerList(serverData), ActorRef.noSender());
                } catch (KeeperException | InterruptedException e) {
                    e.printStackTrace();
                }
        }
    }
}
