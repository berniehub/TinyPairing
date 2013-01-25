/**
 * Java-side application for reading timing message from serial port communication.
 *
 *
 * @author Xiaokang Xiong <xkxiong@gmail.com>
 * @date Sep 2009
 */

import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TimeSerial implements MessageListener {
    
    private MoteIF moteIF;
    
    public TimeSerial(MoteIF moteIF) {
        this.moteIF = moteIF;
        this.moteIF.registerListener(new TimeSerialMsg(), this);
    }
    
    public void messageReceived(int to, Message message) {
        TimeSerialMsg msg = (TimeSerialMsg)message;
        if(msg.get_t1()>0)
            System.out.println("T1: " + msg.get_t1()/1024f + " sec");
        if(msg.get_t2()>0)
            System.out.println("T2: " + msg.get_t2()/1024f + " sec");
        if(msg.get_t3()>0)
            System.out.println("T3: " + msg.get_t3()/1024f + " sec");
        if(msg.get_t4()>0)
            System.out.println("T4: " + msg.get_t4()/1024f + " sec");
        if(msg.get_overflow()>0)
            System.out.println("Overflow on time counter happened, overflow: " + msg.get_overflow());
        if(msg.get_result()==1)
            System.out.println("Test successed!");
        else
            System.out.println("Test failed!");
    }
    
    private static void usage() {
        System.err.println("usage: TimeSerial [-comm <source>]");
    }
    
    public static void main(String[] args) throws Exception {
        String source = null;
        if (args.length == 2) {
            if (!args[0].equals("-comm")) {
                usage();
                System.exit(1);
            }
            source = args[1];
        }
        else if (args.length != 0) {
            usage();
            System.exit(1);
        }
        
        PhoenixSource phoenix;
        
        if (source == null) {
            phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
        }
        else {
            phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
        }
        
        MoteIF mif = new MoteIF(phoenix);
        TimeSerial serial = new TimeSerial(mif);
        //serial.sendPackets();
    }
    
}